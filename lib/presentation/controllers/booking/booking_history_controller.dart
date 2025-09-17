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
  
  void loadBookingHistory() {
    isLoadingBookings.value = true;
    
    // Simulate loading with fake data
    Future.delayed(const Duration(seconds: 1), () {
      // Upcoming bookings
      upcomingBookings.value = [
        {
          'id': '1',
          'bookingCode': 'HTL-2024-001',
          'type': 'hotel',
          'name': 'Melia Vinpearl Nha Trang Empire',
          'location': 'Nha Trang, Khánh Hòa',
          'checkIn': '15/02/2024',
          'checkOut': '18/02/2024',
          'guests': 2,
          'rooms': 1,
          'totalPrice': '8.500.000đ',
          'status': 'upcoming',
          'statusText': 'Sắp tới',
        },
        {
          'id': '2',
          'bookingCode': 'TUR-2024-002',
          'type': 'tour',
          'name': 'Tour Đà Lạt 3N2Đ - Khám phá thành phố ngàn hoa',
          'location': 'Đà Lạt, Lâm Đồng',
          'checkIn': '20/02/2024',
          'checkOut': '23/02/2024',
          'guests': 4,
          'rooms': 2,
          'totalPrice': '12.000.000đ',
          'status': 'upcoming',
          'statusText': 'Sắp tới',
        },
      ];
      
      // Completed bookings
      completedBookings.value = [
        {
          'id': '3',
          'bookingCode': 'HTL-2024-003',
          'type': 'hotel',
          'name': 'InterContinental Phú Quốc',
          'location': 'Phú Quốc, Kiên Giang',
          'checkIn': '01/01/2024',
          'checkOut': '05/01/2024',
          'guests': 2,
          'rooms': 1,
          'totalPrice': '15.000.000đ',
          'status': 'completed',
          'statusText': 'Hoàn thành',
        },
        {
          'id': '4',
          'bookingCode': 'HTL-2024-004',
          'type': 'hotel',
          'name': 'Sheraton Saigon Hotel & Towers',
          'location': 'TP. Hồ Chí Minh',
          'checkIn': '10/12/2023',
          'checkOut': '12/12/2023',
          'guests': 1,
          'rooms': 1,
          'totalPrice': '4.500.000đ',
          'status': 'completed',
          'statusText': 'Hoàn thành',
        },
      ];
      
      // Cancelled bookings
      cancelledBookings.value = [
        {
          'id': '5',
          'bookingCode': 'HTL-2024-005',
          'type': 'hotel',
          'name': 'Vinpearl Resort & Spa Hội An',
          'location': 'Hội An, Quảng Nam',
          'checkIn': '15/01/2024',
          'checkOut': '18/01/2024',
          'guests': 3,
          'rooms': 2,
          'totalPrice': '7.200.000đ',
          'status': 'cancelled',
          'statusText': 'Đã hủy',
        },
      ];
      
      isLoadingBookings.value = false;
    });
  }
  
  void navigateToBookingDetail(Map<String, dynamic> booking) {
    // Navigate to booking detail page
    Get.toNamed('/booking-detail', arguments: booking);
  }
  
  void viewTicket(Map<String, dynamic> booking) {
    // Navigate to payment success page to view ticket/QR code
    Get.toNamed('/payment-success', arguments: {
      'bookingCode': booking['bookingCode'],
      'hotelName': booking['name'],
      'checkIn': booking['checkIn'],
      'checkOut': booking['checkOut'],
      'guests': booking['guests'],
      'rooms': booking['rooms'],
      'totalAmount': booking['totalPrice'],
    });
  }
  
  void cancelBooking(Map<String, dynamic> booking) async {
    final confirm = await AppDialogs.showConfirm(
      title: 'Xác nhận hủy',
      message: 'Bạn có chắc chắn muốn hủy đặt phòng này?\n\nMã đặt phòng: ${booking['bookingCode']}\n${booking['name']}',
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
            message: 'Đặt phòng của bạn đã được hủy thành công.\nChúng tôi sẽ hoàn tiền trong vòng 3-5 ngày làm việc.',
          );
          
          // Switch to cancelled tab
          tabController.animateTo(2);
        });
    }
  }
  
  void rebook(Map<String, dynamic> booking) {
    // Navigate to accommodation detail to rebook
    if (booking['type'] == 'hotel') {
      Get.toNamed('/accommodation-detail', arguments: {
        'name': booking['name'],
        'location': booking['location'],
        'price': booking['totalPrice'],
      });
    } else {
      Get.toNamed('/combo-detail', arguments: {
        'name': booking['name'],
        'location': booking['location'],
        'price': booking['totalPrice'],
      });
    }
  }
}