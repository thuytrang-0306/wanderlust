import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/models/payos_payment_model.dart';
import 'package:wanderlust/data/services/payos_service.dart';
import 'package:wanderlust/data/services/booking_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class PaymentQRController extends BaseController {
  final PayOSService _payosService = Get.find<PayOSService>();
  final BookingService _bookingService = Get.find<BookingService>();

  // Observable values
  final Rx<PayOSPaymentLink?> paymentLink = Rx<PayOSPaymentLink?>(null);
  final Rx<PayOSPaymentStatus?> paymentStatus = Rx<PayOSPaymentStatus?>(null);
  final RxBool isCreatingPayment = false.obs;
  final RxBool isCheckingStatus = false.obs;
  final RxInt pollingCount = 0.obs;

  // Payment polling timer
  Timer? _pollingTimer;
  static const int maxPollingAttempts = 60; // 3 minutes (60 * 3s)
  static const Duration pollingInterval = Duration(seconds: 3);

  // Data from arguments
  String? bookingId;
  String? orderCode;
  int? totalAmount;
  Map<String, dynamic>? bookingData;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    _createPaymentLink();
  }

  @override
  void onClose() {
    _cancelPolling();
    super.onClose();
  }

  void _loadArguments() {
    final args = Get.arguments;
    if (args != null) {
      bookingId = args['bookingId'];
      orderCode = args['orderCode'];
      totalAmount = args['totalAmount'];
      bookingData = args['bookingData'];
    }
  }

  Future<void> _createPaymentLink() async {
    if (orderCode == null || totalAmount == null) {
      AppSnackbar.showError(message: 'Thông tin thanh toán không hợp lệ');
      Get.back();
      return;
    }

    isCreatingPayment.value = true;

    try {
      final link = await _payosService.createPaymentLink(
        orderCode: orderCode!,
        amount: totalAmount!,
        description: 'Dat phong #$orderCode', // Max 25 chars - simplified
        buyerName: bookingData?['guestName'],
        buyerEmail: bookingData?['email'],
        buyerPhone: bookingData?['phone'],
        returnUrl: 'wanderlust://payment-success',
        cancelUrl: 'wanderlust://payment-cancel',
        items: [
          PayOSItem(
            name: bookingData?['accommodationName'] ?? 'Đặt phòng',
            quantity: 1,
            price: totalAmount!,
          ),
        ],
      );

      if (link != null) {
        paymentLink.value = link;
        LoggerService.i('Payment link created: ${link.checkoutUrl}');

        // Start polling after successful creation
        _startPolling();
      } else {
        AppSnackbar.showError(
          message: 'Không thể tạo link thanh toán. Vui lòng thử lại.',
        );
        Get.back();
      }
    } catch (e) {
      LoggerService.e('Error creating payment link', error: e);
      AppSnackbar.showError(
        message: 'Có lỗi xảy ra khi tạo link thanh toán',
      );
      Get.back();
    } finally {
      isCreatingPayment.value = false;
    }
  }

  void _startPolling() {
    _cancelPolling(); // Cancel any existing timer
    pollingCount.value = 0;

    _pollingTimer = Timer.periodic(pollingInterval, (timer) async {
      if (pollingCount.value >= maxPollingAttempts) {
        _cancelPolling();
        LoggerService.w('Payment polling timeout after $maxPollingAttempts attempts');
        return;
      }

      pollingCount.value++;
      await _checkPaymentStatus(autoPolling: true);
    });
  }

  void _cancelPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _checkPaymentStatus({bool autoPolling = false}) async {
    if (orderCode == null) return;

    if (!autoPolling) {
      isCheckingStatus.value = true;
    }

    try {
      final status = await _payosService.getPaymentStatus(orderCode!);

      if (status != null) {
        paymentStatus.value = status;

        if (status.isPaid) {
          LoggerService.i('Payment confirmed for order: $orderCode');
          _cancelPolling();

          // Update booking payment status
          if (bookingId != null) {
            await _bookingService.processPayment(
              bookingId!,
              status.transactions.isNotEmpty
                  ? status.transactions.first.reference
                  : 'payos_${DateTime.now().millisecondsSinceEpoch}',
            );
          }

          // Navigate to success page
          Get.offNamed(
            '/payment-success',
            arguments: {
              'bookingId': bookingId,
              'orderCode': orderCode,
              'totalAmount': totalAmount.toString(),
              'paymentStatus': status.status,
              ...?bookingData,
            },
          );

          AppSnackbar.showSuccess(message: 'Thanh toán thành công!');
        } else if (status.isCancelled) {
          LoggerService.w('Payment cancelled for order: $orderCode');
          _cancelPolling();
          AppSnackbar.showError(message: 'Thanh toán đã bị hủy');
        }
      }
    } catch (e) {
      LoggerService.e('Error checking payment status', error: e);
      if (!autoPolling) {
        AppSnackbar.showError(
          message: 'Không thể kiểm tra trạng thái thanh toán',
        );
      }
    } finally {
      if (!autoPolling) {
        isCheckingStatus.value = false;
      }
    }
  }

  void manualCheckPayment() {
    _checkPaymentStatus(autoPolling: false);
  }

  void cancelPayment() async {
    try {
      Get.dialog(
        barrierDismissible: false,
        const Center(
          child: CircularProgressIndicator(),
        ),
      );

      if (orderCode != null) {
        await _payosService.cancelPaymentLink(
          orderCode!,
          cancellationReason: 'User cancelled',
        );
      }

      Get.back(); // Close loading dialog
      Get.back(); // Go back to previous page

      AppSnackbar.showInfo(message: 'Đã hủy thanh toán');
    } catch (e) {
      Get.back(); // Close loading dialog
      LoggerService.e('Error cancelling payment', error: e);
      AppSnackbar.showError(message: 'Có lỗi khi hủy thanh toán');
    }
  }

  String get pollingStatusText {
    if (pollingCount.value == 0) return 'Đang khởi tạo...';
    final seconds = pollingCount.value * pollingInterval.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    return 'Đang chờ thanh toán ($minutes:$formattedSeconds)';
  }
}
