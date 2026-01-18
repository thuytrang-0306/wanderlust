import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/services/zalopay_service.dart';
import 'package:wanderlust/data/services/booking_service.dart';
import 'package:intl/intl.dart';

class PaymentZaloPayPage extends StatefulWidget {
  const PaymentZaloPayPage({super.key});

  @override
  State<PaymentZaloPayPage> createState() => _PaymentZaloPayPageState();
}

class _PaymentZaloPayPageState extends State<PaymentZaloPayPage> {
  final ZaloPayService _zaloPayService = Get.find<ZaloPayService>();
  final BookingService _bookingService = Get.find<BookingService>();

  // Data from arguments
  late String bookingId;
  late String appTransId;
  late String orderUrl;
  late int totalAmount;
  late Map<String, dynamic> bookingData;

  // State
  bool isLoading = false;
  bool isPolling = false;
  bool hasOpenedCheckout = false;
  int pollingCount = 0;
  Timer? _pollingTimer;

  static const int maxPollingAttempts = 60; // 3 minutes
  static const Duration pollingInterval = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _loadArguments();
  }

  @override
  void dispose() {
    _cancelPolling();
    super.dispose();
  }

  void _loadArguments() {
    final args = Get.arguments;
    if (args != null) {
      bookingId = args['bookingId'] ?? '';
      appTransId = args['appTransId'] ?? '';
      orderUrl = args['orderUrl'] ?? '';
      totalAmount = args['totalAmount'] ?? 0;
      bookingData = args['bookingData'] ?? {};
    }
  }

  void _startPolling() {
    _cancelPolling();
    setState(() {
      isPolling = true;
      pollingCount = 0;
    });

    _pollingTimer = Timer.periodic(pollingInterval, (timer) async {
      if (pollingCount >= maxPollingAttempts) {
        _cancelPolling();
        LoggerService.w('ZaloPay polling timeout');
        return;
      }

      setState(() => pollingCount++);
      await _checkPaymentStatus();
    });
  }

  void _cancelPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    if (mounted) {
      setState(() => isPolling = false);
    }
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final status = await _zaloPayService.queryOrder(appTransId);

      if (status == null) return;

      if (status.isPaid) {
        _cancelPolling();
        LoggerService.i('ZaloPay payment confirmed: $appTransId');

        // Update booking
        await _bookingService.processPayment(
          bookingId,
          'zalopay_${status.zpTransId ?? appTransId}',
        );

        // Navigate to success
        Get.offNamed(
          '/payment-success',
          arguments: {
            'bookingId': bookingId,
            'orderCode': appTransId,
            'totalAmount': totalAmount.toString(),
            'paymentMethod': 'ZaloPay',
            ...bookingData,
          },
        );

        AppSnackbar.showSuccess(message: 'Thanh toán ZaloPay thành công!');
      } else if (status.isFailed) {
        _cancelPolling();
        AppSnackbar.showError(message: 'Thanh toán thất bại');
      }
    } catch (e) {
      LoggerService.e('Error checking ZaloPay status', error: e);
    }
  }

  Future<void> _openZaloPayCheckout() async {
    setState(() => isLoading = true);

    try {
      final result = await _zaloPayService.openCheckout(orderUrl);

      if (result.status.name != 'failed') {
        setState(() => hasOpenedCheckout = true);
        // Start polling after user goes to checkout
        _startPolling();
      } else {
        AppSnackbar.showError(message: result.message);
      }
    } catch (e) {
      LoggerService.e('Error opening ZaloPay', error: e);
      AppSnackbar.showError(message: 'Không thể mở ZaloPay');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _manualCheck() async {
    setState(() => isLoading = true);
    await _checkPaymentStatus();
    if (mounted) setState(() => isLoading = false);
  }

  void _cancelPayment() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hủy thanh toán?'),
        content: const Text('Bạn có chắc muốn hủy giao dịch này không?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Tiếp tục'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );

    if (result == true) {
      _cancelPolling();
      Get.back();
      AppSnackbar.showInfo(message: 'Đã hủy thanh toán');
    }
  }

  String get pollingStatusText {
    if (!isPolling) return 'Chờ thanh toán';
    final seconds = pollingCount * pollingInterval.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return 'Đang chờ xác nhận ($minutes:${remainingSeconds.toString().padLeft(2, '0')})';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _cancelPayment();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppColors.neutral900),
            onPressed: _cancelPayment,
          ),
          title: Text(
            'Thanh toán ZaloPay',
            style: AppTypography.h4.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.s5),
                  child: Column(
                    children: [
                      // Status indicator
                      if (isPolling) _buildPollingStatus(),

                      SizedBox(height: AppSpacing.s6),

                      // ZaloPay logo/icon
                      _buildZaloPayLogo(),

                      SizedBox(height: AppSpacing.s6),

                      // Payment info
                      _buildPaymentInfo(),

                      SizedBox(height: AppSpacing.s6),

                      // Instructions
                      _buildInstructions(),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPollingStatus() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
      decoration: BoxDecoration(
        color: const Color(0xFF0068FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF0068FF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0068FF)),
            ),
          ),
          SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Text(
              pollingStatusText,
              style: AppTypography.bodyS.copyWith(
                color: const Color(0xFF0068FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZaloPayLogo() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s6),
      decoration: BoxDecoration(
        color: const Color(0xFF0068FF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: const Color(0xFF0068FF),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 40.w,
            ),
          ),
          SizedBox(height: AppSpacing.s4),
          Text(
            'ZaloPay',
            style: AppTypography.h3.copyWith(
              color: const Color(0xFF0068FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            hasOpenedCheckout
                ? 'Hoàn tất thanh toán trong ứng dụng ZaloPay'
                : 'Nhấn nút bên dưới để thanh toán',
            style: AppTypography.bodyS.copyWith(
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin thanh toán',
            style: AppTypography.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          SizedBox(height: AppSpacing.s3),
          _buildInfoRow('Mã giao dịch', appTransId),
          _buildInfoRow(
            'Số tiền',
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalAmount),
            isHighlight: true,
          ),
          if (bookingData['accommodationName'] != null)
            _buildInfoRow('Dịch vụ', bookingData['accommodationName']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodyS.copyWith(color: AppColors.neutral600),
          ),
          SizedBox(width: AppSpacing.s4),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodyS.copyWith(
                color: isHighlight ? const Color(0xFF0068FF) : AppColors.neutral900,
                fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hướng dẫn',
            style: AppTypography.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          SizedBox(height: AppSpacing.s3),
          _buildInstructionItem('1', 'Nhấn "Thanh toán ngay" để mở ZaloPay'),
          _buildInstructionItem('2', 'Đăng nhập tài khoản ZaloPay của bạn'),
          _buildInstructionItem('3', 'Xác nhận thanh toán trong ứng dụng'),
          _buildInstructionItem('4', 'Quay lại app để xem kết quả'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF0068FF),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: AppTypography.bodyXS.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                text,
                style: AppTypography.bodyS.copyWith(color: AppColors.neutral700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasOpenedCheckout)
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _openZaloPayCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0068FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          'Thanh toán ngay',
                          style: AppTypography.bodyM.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              )
            else
              AppButton.primary(
                text: 'Kiểm tra thanh toán',
                onPressed: _manualCheck,
                isLoading: isLoading,
              ),
            SizedBox(height: AppSpacing.s3),
            TextButton(
              onPressed: _cancelPayment,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Hủy giao dịch'),
            ),
          ],
        ),
      ),
    );
  }
}
