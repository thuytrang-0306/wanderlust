import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:wanderlust/data/services/booking_service.dart';
import 'package:wanderlust/data/models/booking_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:intl/intl.dart';

class BookingHistoryController extends BaseController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final BookingService _bookingService = Get.find<BookingService>();

  // Observable lists for different booking statuses
  final RxList<BookingModel> upcomingBookings = <BookingModel>[].obs;
  final RxList<BookingModel> completedBookings = <BookingModel>[].obs;
  final RxList<BookingModel> cancelledBookings = <BookingModel>[].obs;

  final RxBool isLoadingBookings = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    loadBookingHistory();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void loadBookingHistory() {
    isLoadingBookings.value = true;

    try {
      // Listen to user's bookings stream
      _bookingService.getUserBookings().listen((bookings) {
        // Clear current lists
        upcomingBookings.clear();
        completedBookings.clear();
        cancelledBookings.clear();

        // Sort bookings by status
        for (final booking in bookings) {
          if (booking.status == 'cancelled') {
            cancelledBookings.add(booking);
          } else if (booking.status == 'completed') {
            completedBookings.add(booking);
          } else if (booking.status == 'confirmed' || booking.status == 'pending') {
            // Check if the booking is in the future
            if (booking.checkIn.isAfter(DateTime.now())) {
              upcomingBookings.add(booking);
            } else {
              completedBookings.add(booking);
            }
          }
        }

        LoggerService.i('Bookings loaded: ${bookings.length} total, ${upcomingBookings.length} upcoming');
        isLoadingBookings.value = false;
      }, onError: (error) {
        LoggerService.e('Error loading bookings', error: error);
        // Set loading to false even on error to show empty state
        isLoadingBookings.value = false;
      });
    } catch (e) {
      LoggerService.e('Error setting up booking stream', error: e);
      isLoadingBookings.value = false;
    }
  }

  void navigateToBookingDetail(BookingModel booking) {
    // Navigate to booking detail page
    Get.toNamed('/booking-detail', arguments: booking);
  }

  void viewTicket(BookingModel booking) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    // Navigate to payment success page to view ticket/QR code
    Get.toNamed(
      '/payment-success',
      arguments: {
        'bookingId': booking.id,
        'bookingCode': 'BK${booking.id.substring(0, 8).toUpperCase()}',
        'hotelName': booking.itemName,
        'checkIn': dateFormat.format(booking.checkIn),
        'checkOut': booking.checkOut != null ? dateFormat.format(booking.checkOut!) : '',
        'guests': booking.adults + booking.children,
        'rooms': booking.quantity,
        'totalAmount': booking.displayPrice,
      },
    );
  }

  void cancelBooking(BookingModel booking) async {
    if (!booking.canCancel) {
      AppDialogs.showError(
        title: 'Không thể hủy',
        message: 'Đặt phòng này không thể hủy.',
      );
      return;
    }
    
    final confirm = await AppDialogs.showConfirm(
      title: 'Xác nhận hủy',
      message:
          'Bạn có chắc chắn muốn hủy đặt phòng này?\n\n${booking.itemName}',
      confirmText: 'Hủy đặt phòng',
      cancelText: 'Quay lại',
      confirmColor: Colors.red,
    );

    if (confirm) {
      // Show loading
      AppDialogs.showLoading(message: 'Đang hủy đặt phòng...');

      try {
        // Cancel booking in Firestore
        final success = await _bookingService.cancelBooking(
          booking.id,
          'Khách hàng hủy',
        );
        
        Get.back(); // Close loading
        
        if (success) {
          // Calculate refund if applicable
          final refundAmount = _bookingService.calculateRefundAmount(booking);
          
          // Show success message
          AppDialogs.showSuccess(
            title: 'Hủy thành công',
            message: refundAmount > 0
                ? 'Đặt phòng đã được hủy.\nSố tiền hoàn lại: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(refundAmount)}'
                : 'Đặt phòng đã được hủy.',
          );
          
          // Reload bookings
          loadBookingHistory();
          
          // Switch to cancelled tab
          tabController.animateTo(2);
        } else {
          AppDialogs.showError(
            title: 'Lỗi',
            message: 'Không thể hủy đặt phòng. Vui lòng thử lại.',
          );
        }
      } catch (e) {
        Get.back(); // Close loading
        LoggerService.e('Error cancelling booking', error: e);
        AppDialogs.showError(
          title: 'Lỗi',
          message: 'Có lỗi xảy ra khi hủy đặt phòng.',
        );
      }
    }
  }

  void rebook(BookingModel booking) {
    // Navigate to accommodation detail to rebook
    if (booking.bookingType == 'accommodation') {
      Get.toNamed(
        '/accommodation-detail',
        arguments: booking.itemId,
      );
    } else if (booking.bookingType == 'tour') {
      Get.toNamed(
        '/combo-detail',
        arguments: booking.itemId,
      );
    }
  }
}
