import 'package:cloud_firestore/cloud_firestore.dart';

// Main Booking Model (for both Tours and Accommodations)
class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String bookingType; // tour, accommodation
  final String itemId; // tourId or accommodationId
  final String itemName;
  final String itemImage;
  final DateTime checkIn;
  final DateTime? checkOut; // null for single day tours
  final int quantity; // number of people for tours, rooms for accommodations
  final int adults;
  final int children;
  final double unitPrice;
  final double totalPrice;
  final double discount;
  final String discountCode;
  final String currency;
  final String status; // pending, confirmed, cancelled, completed
  final String paymentStatus; // pending, paid, refunded
  final String paymentMethod; // credit_card, bank_transfer, cash, e_wallet
  final String? paymentId;
  final CustomerInfo customerInfo;
  final Map<String, dynamic> metadata; // Additional booking-specific data
  final String? specialRequests;
  final String? cancellationReason;
  final DateTime? cancellationDate;
  final double refundAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.bookingType,
    required this.itemId,
    required this.itemName,
    required this.itemImage,
    required this.checkIn,
    this.checkOut,
    required this.quantity,
    required this.adults,
    required this.children,
    required this.unitPrice,
    required this.totalPrice,
    required this.discount,
    required this.discountCode,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.paymentId,
    required this.customerInfo,
    required this.metadata,
    this.specialRequests,
    this.cancellationReason,
    this.cancellationDate,
    required this.refundAmount,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Display helpers
  String get displayPrice {
    final formatter = totalPrice.toStringAsFixed(0);
    return '$formatter $currency';
  }
  
  String get displayStatus {
    switch (status) {
      case 'pending': return 'Chờ xác nhận';
      case 'confirmed': return 'Đã xác nhận';
      case 'cancelled': return 'Đã hủy';
      case 'completed': return 'Hoàn thành';
      default: return status;
    }
  }
  
  String get displayPaymentStatus {
    switch (paymentStatus) {
      case 'pending': return 'Chờ thanh toán';
      case 'paid': return 'Đã thanh toán';
      case 'refunded': return 'Đã hoàn tiền';
      default: return paymentStatus;
    }
  }
  
  String get displayPaymentMethod {
    switch (paymentMethod) {
      case 'credit_card': return 'Thẻ tín dụng';
      case 'bank_transfer': return 'Chuyển khoản';
      case 'cash': return 'Tiền mặt';
      case 'e_wallet': return 'Ví điện tử';
      default: return paymentMethod;
    }
  }
  
  int get nights {
    if (checkOut != null) {
      return checkOut!.difference(checkIn).inDays;
    }
    return 0;
  }
  
  bool get canCancel {
    return status == 'pending' || status == 'confirmed';
  }
  
  bool get canRefund {
    return paymentStatus == 'paid' && status == 'cancelled';
  }
  
  // From Firestore
  factory BookingModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return BookingModel(
      id: docId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhone: data['userPhone'] ?? '',
      bookingType: data['bookingType'] ?? 'tour',
      itemId: data['itemId'] ?? '',
      itemName: data['itemName'] ?? '',
      itemImage: data['itemImage'] ?? '',
      checkIn: (data['checkIn'] as Timestamp).toDate(),
      checkOut: data['checkOut'] != null 
          ? (data['checkOut'] as Timestamp).toDate()
          : null,
      quantity: data['quantity'] ?? 1,
      adults: data['adults'] ?? 1,
      children: data['children'] ?? 0,
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      discountCode: data['discountCode'] ?? '',
      currency: data['currency'] ?? 'VND',
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? 'cash',
      paymentId: data['paymentId'],
      customerInfo: CustomerInfo.fromMap(
        data['customerInfo'] ?? CustomerInfo.empty().toMap()
      ),
      metadata: data['metadata'] ?? {},
      specialRequests: data['specialRequests'],
      cancellationReason: data['cancellationReason'],
      cancellationDate: data['cancellationDate'] != null 
          ? (data['cancellationDate'] as Timestamp).toDate()
          : null,
      refundAmount: (data['refundAmount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'bookingType': bookingType,
      'itemId': itemId,
      'itemName': itemName,
      'itemImage': itemImage,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      'quantity': quantity,
      'adults': adults,
      'children': children,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'discount': discount,
      'discountCode': discountCode,
      'currency': currency,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'customerInfo': customerInfo.toMap(),
      'metadata': metadata,
      'specialRequests': specialRequests,
      'cancellationReason': cancellationReason,
      'cancellationDate': cancellationDate != null 
          ? Timestamp.fromDate(cancellationDate!)
          : null,
      'refundAmount': refundAmount,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

// Customer Information
class CustomerInfo {
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String postalCode;
  final String idNumber; // CCCD/Passport
  final String idType; // cccd, passport, driver_license
  final DateTime? dateOfBirth;
  final String gender;
  final String nationality;
  
  CustomerInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.postalCode,
    required this.idNumber,
    required this.idType,
    this.dateOfBirth,
    required this.gender,
    required this.nationality,
  });
  
  factory CustomerInfo.fromMap(Map<String, dynamic> map) {
    return CustomerInfo(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? 'Vietnam',
      postalCode: map['postalCode'] ?? '',
      idNumber: map['idNumber'] ?? '',
      idType: map['idType'] ?? 'cccd',
      dateOfBirth: map['dateOfBirth'] != null 
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : null,
      gender: map['gender'] ?? '',
      nationality: map['nationality'] ?? 'Vietnamese',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'idNumber': idNumber,
      'idType': idType,
      'dateOfBirth': dateOfBirth != null 
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'gender': gender,
      'nationality': nationality,
    };
  }
  
  static CustomerInfo empty() {
    return CustomerInfo(
      fullName: '',
      email: '',
      phone: '',
      address: '',
      city: '',
      country: 'Vietnam',
      postalCode: '',
      idNumber: '',
      idType: 'cccd',
      gender: '',
      nationality: 'Vietnamese',
    );
  }
}

// Payment Information
class PaymentInfo {
  final String method; // credit_card, bank_transfer, cash, e_wallet
  final String? transactionId;
  final String? cardNumber; // Last 4 digits only
  final String? cardHolder;
  final String? bankName;
  final String? bankAccount;
  final String? eWalletType; // momo, zalopay, vnpay
  final String? eWalletPhone;
  final DateTime? paymentDate;
  final String status; // pending, processing, success, failed
  final String? failureReason;
  
  PaymentInfo({
    required this.method,
    this.transactionId,
    this.cardNumber,
    this.cardHolder,
    this.bankName,
    this.bankAccount,
    this.eWalletType,
    this.eWalletPhone,
    this.paymentDate,
    required this.status,
    this.failureReason,
  });
  
  factory PaymentInfo.fromMap(Map<String, dynamic> map) {
    return PaymentInfo(
      method: map['method'] ?? 'cash',
      transactionId: map['transactionId'],
      cardNumber: map['cardNumber'],
      cardHolder: map['cardHolder'],
      bankName: map['bankName'],
      bankAccount: map['bankAccount'],
      eWalletType: map['eWalletType'],
      eWalletPhone: map['eWalletPhone'],
      paymentDate: map['paymentDate'] != null 
          ? (map['paymentDate'] as Timestamp).toDate()
          : null,
      status: map['status'] ?? 'pending',
      failureReason: map['failureReason'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'method': method,
      'transactionId': transactionId,
      'cardNumber': cardNumber,
      'cardHolder': cardHolder,
      'bankName': bankName,
      'bankAccount': bankAccount,
      'eWalletType': eWalletType,
      'eWalletPhone': eWalletPhone,
      'paymentDate': paymentDate != null 
          ? Timestamp.fromDate(paymentDate!)
          : null,
      'status': status,
      'failureReason': failureReason,
    };
  }
}