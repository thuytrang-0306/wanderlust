import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/data/services/booking_service.dart';
import 'package:wanderlust/data/models/booking_model.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class BookingInfoController extends BaseController {
  final BookingService _bookingService = Get.find<BookingService>();
  
  // Observable values
  final RxMap<String, dynamic> bookingData = <String, dynamic>{}.obs;
  final RxBool isProcessing = false.obs;
  
  // Store listing/accommodation data from arguments
  String? listingId;
  String? accommodationId;
  String? businessId;
  DateTime? checkInDate;
  DateTime? checkOutDate;

  @override
  void onInit() {
    super.onInit();
    loadBookingData();
  }

  void loadBookingData() {
    // Get data from arguments or load from service
    final args = Get.arguments;
    if (args != null) {
      // Store IDs and dates for creating booking
      listingId = args['listingId'];
      accommodationId = args['accommodationId'];
      businessId = args['businessId'];
      checkInDate = args['checkIn'] as DateTime?;
      checkOutDate = args['checkOut'] as DateTime?;
      
      // Format dates for display
      String checkInDisplay = 'Thứ Hai, 1/1/2025 (15:00 - 03:00)';
      String checkOutDisplay = 'Thứ Ba, 2/1/2025 (trước 11:00)';
      
      if (checkInDate != null && checkOutDate != null) {
        // weekday returns 1-7 (Monday-Sunday), we need to map to Vietnamese days
        final weekdays = {
          1: 'Hai', 2: 'Ba', 3: 'Tư', 4: 'Năm', 5: 'Sáu', 6: 'Bảy', 7: 'CN'
        };
        
        final checkInWeekday = weekdays[checkInDate!.weekday] ?? 'Hai';
        final checkOutWeekday = weekdays[checkOutDate!.weekday] ?? 'Ba';
        
        checkInDisplay = 'Thứ $checkInWeekday, ${checkInDate!.day}/${checkInDate!.month}/${checkInDate!.year} (15:00 - 03:00)';
        checkOutDisplay = 'Thứ $checkOutWeekday, ${checkOutDate!.day}/${checkOutDate!.month}/${checkOutDate!.year} (trước 11:00)';
      }
      
      bookingData.value = {
        'accommodationName': args['accommodationName'] ?? 'Homestay Sơn Thủy',
        'accommodationImage': args['accommodationImage'] ?? '',
        'roomType': args['roomType'] ?? 'Phòng đơn homestay',
        'roomCount': args['rooms'] ?? 1,
        'roomSize': '25.0m2',
        'nights': args['nights'] ?? 1,
        'guests': args['guests'] ?? 1,
        'bedType': '1 giường đơn',
        'checkIn': checkInDisplay,
        'checkOut': checkOutDisplay,
        'guestName': _bookingService.currentUser?.displayName?.toUpperCase() ?? 'NGUYEN VAN A',
        'userName': _bookingService.currentUser?.displayName ?? 'User',
        'phone': '0123456789',
        'email': _bookingService.currentUser?.email ?? 'user@example.com',
        'paymentMethod': 'cash',
        'price': args['price'] ?? 480000,
        'tax': 0,
        'total': args['totalPrice'] ?? args['price'] ?? 480000,
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

    try {
      // Create customer info
      final customerInfo = CustomerInfo(
        fullName: bookingData['guestName'] ?? 'Guest',
        email: bookingData['email'] ?? '',
        phone: bookingData['phone'] ?? '',
        address: '',
        city: '',
        country: 'Vietnam',
        postalCode: '',
        idNumber: '',
        idType: 'cccd',
        gender: 'other',
        nationality: 'Vietnam',
      );

      // Create booking in Firestore
      String? bookingId;
      
      if (checkInDate != null && checkOutDate != null) {
        // Create accommodation booking
        bookingId = await _bookingService.createAccommodationBooking(
          accommodationId: accommodationId ?? listingId ?? '',
          accommodationName: bookingData['accommodationName'] ?? '',
          accommodationImage: bookingData['accommodationImage'] ?? '',
          checkIn: checkInDate!,
          checkOut: checkOutDate!,
          rooms: bookingData['roomCount'] ?? 1,
          adults: bookingData['guests'] ?? 1,
          children: 0,
          unitPrice: (bookingData['price'] as num).toDouble(),
          totalPrice: (bookingData['total'] as num).toDouble(),
          customerInfo: customerInfo,
          paymentMethod: bookingData['paymentMethod'] ?? 'cash',
          specialRequests: '',
        );
      }

      if (bookingId != null) {
        LoggerService.i('Booking created successfully: $bookingId');
        
        // Update booking status to confirmed
        await _bookingService.confirmBooking(bookingId);
        
        // Update payment status
        await _bookingService.processPayment(bookingId, 'payment_${DateTime.now().millisecondsSinceEpoch}');
        
        // Navigate to success page with booking data
        Get.offNamed(
          '/payment-success',
          arguments: {
            'bookingId': bookingId,
            'hotelName': bookingData['accommodationName'],
            'roomType': bookingData['roomType'],
            'guestName': bookingData['guestName'],
            'checkIn': bookingData['checkIn'],
            'checkOut': bookingData['checkOut'],
            'nights': bookingData['nights'],
            'totalAmount': bookingData['total'].toString(),
          },
        );
      } else {
        throw Exception('Không thể tạo đặt phòng');
      }
    } catch (e) {
      LoggerService.e('Error processing payment', error: e);
      Get.back(); // Close dialog
      AppSnackbar.showError(
        message: 'Có lỗi xảy ra khi xử lý thanh toán. Vui lòng thử lại.',
      );
    } finally {
      isProcessing.value = false;
    }
  }
}
