import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

class PaymentSuccessController extends BaseController {
  // Booking data
  late String bookingCode;
  late String hotelName;
  late String roomType;
  late String guestName;
  late String checkIn;
  late String checkOut;
  late int nights;
  late String totalAmount;
  
  @override
  void onInit() {
    super.onInit();
    loadBookingData();
  }
  
  void loadBookingData() {
    // Get data from arguments or generate mock data
    final args = Get.arguments;
    
    if (args != null && args is Map<String, dynamic>) {
      bookingCode = args['bookingCode'] ?? _generateBookingCode();
      hotelName = args['hotelName'] ?? 'Homestay Sơn Thủy';
      roomType = args['roomType'] ?? 'Phòng đơn homestay';
      guestName = args['guestName'] ?? 'NGUYEN THUY TRANG';
      checkIn = args['checkIn'] ?? 'Thứ Hai, 1/1/2025 (15:00)';
      checkOut = args['checkOut'] ?? 'Thứ Ba, 2/1/2025 (11:00)';
      nights = args['nights'] ?? 1;
      totalAmount = args['totalAmount'] ?? '480.000';
    } else {
      // Default/mock data for testing
      bookingCode = _generateBookingCode();
      hotelName = 'Homestay Sơn Thủy';
      roomType = 'Phòng đơn homestay';
      guestName = 'NGUYEN THUY TRANG';
      checkIn = 'Thứ Hai, 1/1/2025 (15:00)';
      checkOut = 'Thứ Ba, 2/1/2025 (11:00)';
      nights = 1;
      totalAmount = '480.000';
    }
  }
  
  String _generateBookingCode() {
    // Generate a booking code format: WDL-XXXXXX
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final code = (timestamp % 1000000).toString().padLeft(6, '0');
    return 'WDL-$code';
  }
  
  void viewTicket() {
    // Navigate to ticket detail page or show PDF
    AppSnackbar.showInfo(
      message: 'Đang mở vé điện tử...',
    );
    
    // TODO: Implement ticket view
    // Could open a PDF viewer or navigate to a detailed ticket page
  }
  
  void shareBooking() {
    final shareText = '''
🎉 Đặt phòng thành công!

Mã đặt phòng: $bookingCode
Khách sạn: $hotelName
Loại phòng: $roomType
Nhận phòng: $checkIn
Trả phòng: $checkOut
Số đêm: $nights đêm
Tổng tiền: $totalAmount VND

---
Đặt phòng qua Wanderlust App
    ''';
    
    Share.share(
      shareText,
      subject: 'Thông tin đặt phòng - $bookingCode',
    );
  }
  
  void backToHome() {
    // Clear navigation stack and go to main page
    Get.offAllNamed('/main-navigation');
  }
  
  void copyBookingCode() {
    Clipboard.setData(ClipboardData(text: bookingCode));
    AppSnackbar.showSuccess(
      message: 'Đã sao chép mã đặt phòng',
    );
  }
}