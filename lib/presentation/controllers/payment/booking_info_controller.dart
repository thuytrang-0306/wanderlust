import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/data/services/booking_service.dart';
import 'package:wanderlust/data/services/payos_service.dart';
import 'package:wanderlust/data/models/booking_model.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class BookingInfoController extends BaseController {
  final BookingService _bookingService = Get.find<BookingService>();
  final PayOSService _payosService = Get.find<PayOSService>();
  
  // Observable values
  final RxMap<String, dynamic> bookingData = <String, dynamic>{}.obs;
  final RxBool isProcessing = false.obs;

  // Store listing/accommodation data from arguments
  String? listingId;
  String? listingType;
  String? accommodationId;
  String? businessId;
  DateTime? checkInDate;
  DateTime? checkOutDate;

  // Dynamic properties based on listing type
  bool get isRoom => listingType == 'room' || listingType == null;
  bool get isTour => listingType == 'tour';
  bool get isFood => listingType == 'food';
  bool get isService => listingType == 'service';

  String get pageTitle {
    if (isTour) return 'Thông tin đặt tour';
    if (isFood) return 'Thông tin đặt món';
    if (isService) return 'Thông tin đặt dịch vụ';
    return 'Thông tin đặt phòng';
  }

  @override
  void onInit() {
    super.onInit();
    loadBookingData();
  }

  void loadBookingData() {
    // Get data from arguments or load from service
    final args = Get.arguments;
    if (args != null) {
      // Store IDs, type and dates for creating booking
      listingId = args['listingId'];
      listingType = args['listingType'];
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
        'quantity': args['quantity'] ?? 1,
        'bedType': '1 giường đơn',
        'checkIn': checkInDisplay,
        'checkOut': checkOutDisplay,
        'guestName': _bookingService.currentUser?.displayName?.toUpperCase() ?? 'NGUYEN VAN A',
        'userName': _bookingService.currentUser?.displayName ?? 'User',
        'phone': '0123456789',
        'email': _bookingService.currentUser?.email ?? 'user@example.com',
        'paymentMethod': 'cash',
        'price': args['price'] ?? 480000,
        'priceUnit': args['priceUnit'] ?? '/đêm',
        'priceBreakdown': args['priceBreakdown'] ?? '',
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

      // Create booking in Firestore with PENDING status
      String? bookingId;

      // Create booking based on listing type
      switch (listingType) {
        case 'room':
          // Room/Accommodation booking - requires checkIn/checkOut
          if (checkInDate != null && checkOutDate != null) {
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
              paymentMethod: 'payos',
              specialRequests: '',
            );
          }
          break;

        case 'tour':
          // Tour booking - requires departure date
          bookingId = await _bookingService.createTourBooking(
            tourId: listingId ?? '',
            tourName: bookingData['accommodationName'] ?? '',
            tourImage: bookingData['accommodationImage'] ?? '',
            departureDate: checkInDate ?? DateTime.now(),
            adults: bookingData['guests'] ?? 1,
            children: 0,
            unitPrice: (bookingData['price'] as num).toDouble(),
            totalPrice: (bookingData['total'] as num).toDouble(),
            customerInfo: customerInfo,
            paymentMethod: 'payos',
            specialRequests: '',
          );
          break;

        case 'food':
          // Food booking - quantity based
          bookingId = await _bookingService.createFoodBooking(
            foodId: listingId ?? '',
            foodName: bookingData['accommodationName'] ?? '',
            foodImage: bookingData['accommodationImage'] ?? '',
            quantity: bookingData['quantity'] ?? 1,
            unitPrice: (bookingData['price'] as num).toDouble(),
            totalPrice: (bookingData['total'] as num).toDouble(),
            customerInfo: customerInfo,
            paymentMethod: 'payos',
            specialRequests: '',
            orderDate: checkInDate,
          );
          break;

        case 'service':
          // Service booking - quantity based
          bookingId = await _bookingService.createServiceBooking(
            serviceId: listingId ?? '',
            serviceName: bookingData['accommodationName'] ?? '',
            serviceImage: bookingData['accommodationImage'] ?? '',
            quantity: bookingData['quantity'] ?? 1,
            unitPrice: (bookingData['price'] as num).toDouble(),
            totalPrice: (bookingData['total'] as num).toDouble(),
            customerInfo: customerInfo,
            paymentMethod: 'payos',
            specialRequests: '',
            serviceDate: checkInDate,
          );
          break;

        default:
          // Fallback to accommodation if type is unknown
          if (checkInDate != null && checkOutDate != null) {
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
              paymentMethod: 'payos',
              specialRequests: '',
            );
          }
      }

      if (bookingId != null) {
        LoggerService.i('Booking created successfully (pending payment): $bookingId');

        // Generate unique order code for PayOS
        final orderCode = _payosService.generateOrderCode();

        // Navigate to PayOS QR payment page
        Get.toNamed(
          '/payment-qr',
          arguments: {
            'bookingId': bookingId,
            'orderCode': orderCode,
            'totalAmount': (bookingData['total'] as num).toInt(),
            'bookingData': bookingData,
          },
        );
      } else {
        // Dynamic error message based on listing type
        String errorMsg = 'Không thể tạo đặt chỗ';
        if (isTour) errorMsg = 'Không thể tạo đặt tour';
        else if (isFood) errorMsg = 'Không thể tạo đặt món';
        else if (isService) errorMsg = 'Không thể tạo đặt dịch vụ';
        else errorMsg = 'Không thể tạo đặt phòng';

        throw Exception(errorMsg);
      }
    } catch (e) {
      LoggerService.e('Error creating booking', error: e);

      // Dynamic error message based on listing type
      String errorMsg = 'Có lỗi xảy ra khi tạo đặt chỗ. Vui lòng thử lại.';
      if (isTour) errorMsg = 'Có lỗi xảy ra khi tạo đặt tour. Vui lòng thử lại.';
      else if (isFood) errorMsg = 'Có lỗi xảy ra khi tạo đặt món. Vui lòng thử lại.';
      else if (isService) errorMsg = 'Có lỗi xảy ra khi tạo đặt dịch vụ. Vui lòng thử lại.';
      else errorMsg = 'Có lỗi xảy ra khi tạo đặt phòng. Vui lòng thử lại.';

      AppSnackbar.showError(message: errorMsg);
    } finally {
      isProcessing.value = false;
    }
  }
}
