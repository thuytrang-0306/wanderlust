import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';

class BookingHistoryController extends BaseController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // Observable lists for different booking statuses
  final RxList<Map<String, dynamic>> upcomingBookings = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> completedBookings = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> cancelledBookings = <Map<String, dynamic>>[].obs;

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

  void loadBookingHistory() async {
    isLoadingBookings.value = true;

    try {
      // TODO: Load real booking data from Firestore
      // For now, keep empty arrays until backend is ready
      upcomingBookings.value = [];
      completedBookings.value = [];
      cancelledBookings.value = [];
    } catch (e) {
      // Handle error
    } finally {
      isLoadingBookings.value = false;
    }
  }

  void navigateToBookingDetail(Map<String, dynamic> booking) {
    // Navigate to booking detail page
    Get.toNamed('/booking-detail', arguments: booking);
  }

  void viewTicket(Map<String, dynamic> booking) {
    // Navigate to payment success page to view ticket/QR code
    Get.toNamed(
      '/payment-success',
      arguments: {
        'bookingCode': booking['bookingCode'],
        'hotelName': booking['name'],
        'checkIn': booking['checkIn'],
        'checkOut': booking['checkOut'],
        'guests': booking['guests'],
        'rooms': booking['rooms'],
        'totalAmount': booking['totalPrice'],
      },
    );
  }

  void cancelBooking(Map<String, dynamic> booking) async {
    final confirm = await AppDialogs.showConfirm(
      title: 'Xác nhận hủy',
      message:
          'Bạn có chắc chắn muốn hủy đặt phòng này?\n\nMã đặt phòng: ${booking['bookingCode']}\n${booking['name']}',
      confirmText: 'Hủy đặt phòng',
      cancelText: 'Quay lại',
      confirmColor: Colors.red,
    );

    if (confirm) {
      // Show loading
      AppDialogs.showLoading(message: 'Đang hủy đặt phòng...');

      // Simulate cancellation
      Future.delayed(const Duration(seconds: 2), () {
        Get.back(); // Close loading

        // Move booking from upcoming to cancelled
        upcomingBookings.remove(booking);
        booking['status'] = 'cancelled';
        booking['statusText'] = 'Đã hủy';
        cancelledBookings.add(booking);

        // Show success message
        AppDialogs.showSuccess(
          title: 'Hủy thành công',
          message:
              'Đặt phòng của bạn đã được hủy thành công.\nChúng tôi sẽ hoàn tiền trong vòng 3-5 ngày làm việc.',
        );

        // Switch to cancelled tab
        tabController.animateTo(2);
      });
    }
  }

  void rebook(Map<String, dynamic> booking) {
    // Navigate to accommodation detail to rebook
    if (booking['type'] == 'hotel') {
      Get.toNamed(
        '/accommodation-detail',
        arguments: {
          'name': booking['name'],
          'location': booking['location'],
          'price': booking['totalPrice'],
        },
      );
    } else {
      Get.toNamed(
        '/combo-detail',
        arguments: {
          'name': booking['name'],
          'location': booking['location'],
          'price': booking['totalPrice'],
        },
      );
    }
  }
}
