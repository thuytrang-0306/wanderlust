/// PayOS Payment Link Model
class PayOSPaymentLink {
  final String id;
  final String orderCode;
  final int amount;
  final String description;
  final String? accountNumber;
  final String? accountName;
  final String bin;
  final String checkoutUrl;
  final String qrCode;
  final String status;
  final DateTime? createdAt;
  final DateTime? canceledAt;
  final String? cancellationReason;

  PayOSPaymentLink({
    required this.id,
    required this.orderCode,
    required this.amount,
    required this.description,
    this.accountNumber,
    this.accountName,
    required this.bin,
    required this.checkoutUrl,
    required this.qrCode,
    required this.status,
    this.createdAt,
    this.canceledAt,
    this.cancellationReason,
  });

  factory PayOSPaymentLink.fromJson(Map<String, dynamic> json) {
    return PayOSPaymentLink(
      id: json['id'] ?? '',
      orderCode: json['orderCode']?.toString() ?? '',
      amount: json['amount'] ?? 0,
      description: json['description'] ?? '',
      accountNumber: json['accountNumber'],
      accountName: json['accountName'],
      bin: json['bin'] ?? '',
      checkoutUrl: json['checkoutUrl'] ?? '',
      qrCode: json['qrCode'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      canceledAt: json['canceledAt'] != null
          ? DateTime.parse(json['canceledAt'])
          : null,
      cancellationReason: json['cancellationReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderCode': orderCode,
      'amount': amount,
      'description': description,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'bin': bin,
      'checkoutUrl': checkoutUrl,
      'qrCode': qrCode,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'canceledAt': canceledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }
}

/// PayOS Payment Status Model
class PayOSPaymentStatus {
  final String id;
  final String orderCode;
  final int amount;
  final int amountPaid;
  final int amountRemaining;
  final String status;
  final DateTime createdAt;
  final List<PayOSTransaction> transactions;
  final String? cancellationReason;
  final DateTime? canceledAt;

  PayOSPaymentStatus({
    required this.id,
    required this.orderCode,
    required this.amount,
    required this.amountPaid,
    required this.amountRemaining,
    required this.status,
    required this.createdAt,
    required this.transactions,
    this.cancellationReason,
    this.canceledAt,
  });

  factory PayOSPaymentStatus.fromJson(Map<String, dynamic> json) {
    return PayOSPaymentStatus(
      id: json['id'] ?? '',
      orderCode: json['orderCode']?.toString() ?? '',
      amount: json['amount'] ?? 0,
      amountPaid: json['amountPaid'] ?? 0,
      amountRemaining: json['amountRemaining'] ?? 0,
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((t) => PayOSTransaction.fromJson(t))
              .toList() ??
          [],
      cancellationReason: json['cancellationReason'],
      canceledAt: json['canceledAt'] != null
          ? DateTime.parse(json['canceledAt'])
          : null,
    );
  }

  bool get isPaid => status == 'PAID';
  bool get isPending => status == 'PENDING';
  bool get isCancelled => status == 'CANCELLED';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderCode': orderCode,
      'amount': amount,
      'amountPaid': amountPaid,
      'amountRemaining': amountRemaining,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'cancellationReason': cancellationReason,
      'canceledAt': canceledAt?.toIso8601String(),
    };
  }
}

/// PayOS Transaction Model
class PayOSTransaction {
  final String reference;
  final int amount;
  final String? accountNumber;
  final String description;
  final DateTime transactionDateTime;
  final String? virtualAccountName;
  final String? virtualAccountNumber;

  PayOSTransaction({
    required this.reference,
    required this.amount,
    this.accountNumber,
    required this.description,
    required this.transactionDateTime,
    this.virtualAccountName,
    this.virtualAccountNumber,
  });

  factory PayOSTransaction.fromJson(Map<String, dynamic> json) {
    return PayOSTransaction(
      reference: json['reference'] ?? '',
      amount: json['amount'] ?? 0,
      accountNumber: json['accountNumber'],
      description: json['description'] ?? '',
      transactionDateTime: json['transactionDateTime'] != null
          ? DateTime.parse(json['transactionDateTime'])
          : DateTime.now(),
      virtualAccountName: json['virtualAccountName'],
      virtualAccountNumber: json['virtualAccountNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'amount': amount,
      'accountNumber': accountNumber,
      'description': description,
      'transactionDateTime': transactionDateTime.toIso8601String(),
      'virtualAccountName': virtualAccountName,
      'virtualAccountNumber': virtualAccountNumber,
    };
  }
}

/// PayOS Create Payment Request
class PayOSCreatePaymentRequest {
  final String orderCode;
  final int amount;
  final String description;
  final String? buyerName;
  final String? buyerEmail;
  final String? buyerPhone;
  final String? buyerAddress;
  final List<PayOSItem>? items;
  final String? returnUrl;
  final String? cancelUrl;

  PayOSCreatePaymentRequest({
    required this.orderCode,
    required this.amount,
    required this.description,
    this.buyerName,
    this.buyerEmail,
    this.buyerPhone,
    this.buyerAddress,
    this.items,
    this.returnUrl,
    this.cancelUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderCode': int.parse(orderCode),
      'amount': amount,
      'description': description,
      'buyerName': buyerName,
      'buyerEmail': buyerEmail,
      'buyerPhone': buyerPhone,
      'buyerAddress': buyerAddress,
      'items': items?.map((item) => item.toJson()).toList(),
      'returnUrl': returnUrl,
      'cancelUrl': cancelUrl,
    };
  }
}

/// PayOS Item Model
class PayOSItem {
  final String name;
  final int quantity;
  final int price;

  PayOSItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}
