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
  
  void editGuestInfo() async {
    // Navigate to customer info page
    final result = await Get.toNamed('/customer-info');
    
    if (result != null && result is Map<String, dynamic>) {
      // Update booking data with new customer info
      bookingData['guestName'] = '${result['lastName']} ${result['firstName']}'.toUpperCase();
      bookingData['userName'] = '${result['lastName']} ${result['firstName']}';
      bookingData['phone'] = result['phone'];
      bookingData['email'] = result['email'];
    }
  }
  
  void selectPaymentMethod() async {
    // Navigate to payment method page
    final result = await Get.toNamed('/payment-method');
    
    if (result != null && result is Map<String, dynamic>) {
      // Update payment method display
      String paymentDisplay = '';
      
      if (result['type'] == 'card') {
        paymentDisplay = '${result['cardType']} ••${result['lastFourDigits']}';
      } else if (result['type'] == 'digital') {
        paymentDisplay = result['method'];
      }
      
      bookingData['paymentMethod'] = paymentDisplay;
    }
  }
  
  void processPayment() async {
    if (isProcessing.value) return;
    
    isProcessing.value = true;
    
    // Show processing dialog
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang xử lý thanh toán...'),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    isProcessing.value = false;
    Get.back(); // Close dialog
    
    // Navigate to success page with booking data
    Get.offNamed('/payment-success', arguments: {
      'hotelName': bookingData['accommodationName'],
      'roomType': bookingData['roomType'],
      'guestName': bookingData['guestName'],
      'checkIn': bookingData['checkIn'],
      'checkOut': bookingData['checkOut'],
      'nights': bookingData['nights'],
      'totalAmount': bookingData['total'].toString(),
    });
  }
}