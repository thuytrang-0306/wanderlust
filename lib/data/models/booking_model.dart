import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final BookingType type;
  final String referenceId; // accommodationId or tourId
  final String bookingCode;
  final BookingStatus status;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final GuestData guests;
  final PricingData pricing;
  final CustomerData customer;
  final String? qrCode;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final DateTime? completedAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.referenceId,
    required this.bookingCode,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.guests,
    required this.pricing,
    required this.customer,
    this.qrCode,
    required this.createdAt,
    this.confirmedAt,
    this.cancelledAt,
    this.completedAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: BookingType.fromString(data['type'] ?? 'accommodation'),
      referenceId: data['referenceId'] ?? '',
      bookingCode: data['bookingCode'] ?? '',
      status: BookingStatus.fromString(data['status'] ?? 'pending'),
      checkIn: (data['checkIn'] as Timestamp).toDate(),
      checkOut: (data['checkOut'] as Timestamp).toDate(),
      nights: data['nights'] ?? 1,
      guests: GuestData.fromMap(data['guests'] ?? {}),
      pricing: PricingData.fromMap(data['pricing'] ?? {}),
      customer: CustomerData.fromMap(data['customer'] ?? {}),
      qrCode: data['qrCode'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      confirmedAt: data['confirmedAt'] != null 
          ? (data['confirmedAt'] as Timestamp).toDate() 
          : null,
      cancelledAt: data['cancelledAt'] != null 
          ? (data['cancelledAt'] as Timestamp).toDate() 
          : null,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.value,
      'referenceId': referenceId,
      'bookingCode': bookingCode,
      'status': status.value,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'nights': nights,
      'guests': guests.toMap(),
      'pricing': pricing.toMap(),
      'customer': customer.toMap(),
      'qrCode': qrCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmedAt': confirmedAt != null 
          ? Timestamp.fromDate(confirmedAt!) 
          : null,
      'cancelledAt': cancelledAt != null 
          ? Timestamp.fromDate(cancelledAt!) 
          : null,
      'completedAt': completedAt != null 
          ? Timestamp.fromDate(completedAt!) 
          : null,
    };
  }

  // Generate unique booking code
  static String generateBookingCode() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(7);
    final random = (now.microsecond % 1000).toString().padLeft(3, '0');
    return 'BK$timestamp$random';
  }

  // Format date range
  String get dateRange {
    final checkInStr = '${checkIn.day}/${checkIn.month}/${checkIn.year}';
    final checkOutStr = '${checkOut.day}/${checkOut.month}/${checkOut.year}';
    return '$checkInStr - $checkOutStr';
  }

  // Format price
  String get formattedPrice {
    final price = pricing.total.toStringAsFixed(0);
    final formattedPrice = price.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formattedPriceđ';
  }
}

enum BookingType {
  accommodation('accommodation', 'Khách sạn'),
  tour('tour', 'Tour'),
  combo('combo', 'Combo');

  final String value;
  final String displayName;
  
  const BookingType(this.value, this.displayName);

  static BookingType fromString(String value) {
    return BookingType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BookingType.accommodation,
    );
  }
}

enum BookingStatus {
  pending('pending', 'Chờ xác nhận'),
  confirmed('confirmed', 'Đã xác nhận'),
  cancelled('cancelled', 'Đã hủy'),
  completed('completed', 'Hoàn thành');

  final String value;
  final String displayName;
  
  const BookingStatus(this.value, this.displayName);

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

class GuestData {
  final int adults;
  final int children;
  final int infants;

  GuestData({
    required this.adults,
    this.children = 0,
    this.infants = 0,
  });

  factory GuestData.fromMap(Map<String, dynamic> map) {
    return GuestData(
      adults: map['adults'] ?? 1,
      children: map['children'] ?? 0,
      infants: map['infants'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adults': adults,
      'children': children,
      'infants': infants,
    };
  }

  int get total => adults + children + infants;
}

class PricingData {
  final double subtotal;
  final double taxes;
  final double fees;
  final double discount;
  final double total;
  final String currency;
  final String paymentMethod;
  final PaymentStatus paymentStatus;

  PricingData({
    required this.subtotal,
    required this.taxes,
    required this.fees,
    required this.discount,
    required this.total,
    this.currency = 'VND',
    required this.paymentMethod,
    required this.paymentStatus,
  });

  factory PricingData.fromMap(Map<String, dynamic> map) {
    return PricingData(
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      taxes: (map['taxes'] ?? 0).toDouble(),
      fees: (map['fees'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'VND',
      paymentMethod: map['paymentMethod'] ?? 'cash',
      paymentStatus: PaymentStatus.fromString(map['paymentStatus'] ?? 'pending'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subtotal': subtotal,
      'taxes': taxes,
      'fees': fees,
      'discount': discount,
      'total': total,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus.value,
    };
  }
}

enum PaymentStatus {
  pending('pending', 'Chờ thanh toán'),
  paid('paid', 'Đã thanh toán'),
  refunded('refunded', 'Đã hoàn tiền');

  final String value;
  final String displayName;
  
  const PaymentStatus(this.value, this.displayName);

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

class CustomerData {
  final String name;
  final String email;
  final String phone;
  final String? specialRequests;

  CustomerData({
    required this.name,
    required this.email,
    required this.phone,
    this.specialRequests,
  });

  factory CustomerData.fromMap(Map<String, dynamic> map) {
    return CustomerData(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      specialRequests: map['specialRequests'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'specialRequests': specialRequests,
    };
  }
}