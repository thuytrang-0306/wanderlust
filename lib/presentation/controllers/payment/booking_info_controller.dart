import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/constants/app_colors.dart';

class BookingInfoController extends BaseController {
  // Observable values
  final RxMap<String, dynamic> bookingData = <String, dynamic>{}.obs;
  final RxBool isProcessing = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadBookingData();
  }
  
  void loadBookingData() {
    // Get data from arguments or load from service
    final args = Get.arguments;
    if (args != null) {
      bookingData.value = {
        'accommodationName': args['accommodationName'] ?? 'Homestay Sơn Thủy',
        'roomType': 'Phòng đơn homestay',
        'roomCount': args['rooms'] ?? 1,
        'roomSize': '25.0m2',
        'nights': args['nights'] ?? 1,
        'guests': args['guests'] ?? 1,
        'bedType': '1 giường đơn',
        'checkIn': 'Thứ Hai, 1/1/2025 (15:00 - 03:00)',
        'checkOut': 'Thứ Ba, 2/1/2025 (trước 11:00)',
        'guestName': 'NGUYEN THUY TRANG',
        'userName': 'User name',
        'phone': '012345678',
        'email': 'thuytrang@gmail.com',
        'paymentMethod': 'VIB ••6969',
        'price': args['price'] ?? 480000,
        'tax': 0,
        'total': args['price'] ?? 480000,
      };
    }
  }
  
  void editGuestInfo() {
    // Navigate to edit guest info page
    Get.snackbar(
      'Chỉnh sửa',
      'Mở trang chỉnh sửa thông tin khách',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void selectPaymentMethod() {
    // Navigate to payment method selection
    Get.snackbar(
      'Phương thức thanh toán',
      'Chọn phương thức thanh toán',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void processPayment() async {
    if (isProcessing.value) return;
    
    isProcessing.value = true;
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    isProcessing.value = false;
    
    // Navigate to payment success or show result
    Get.snackbar(
      'Thanh toán',
      'Đang xử lý thanh toán...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.9),
      colorText: Colors.white,
    );
    
    // Navigate to success page
    // Get.toNamed('/payment-success');
  }
}