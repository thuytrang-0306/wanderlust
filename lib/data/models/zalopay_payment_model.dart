/// ZaloPay Order Model - Response from create order API
class ZaloPayOrder {
  final String appTransId;
  final String zpTransToken;
  final String orderUrl;
  final String orderToken;
  final int returnCode;
  final String returnMessage;

  ZaloPayOrder({
    required this.appTransId,
    required this.zpTransToken,
    required this.orderUrl,
    required this.orderToken,
    required this.returnCode,
    required this.returnMessage,
  });

  bool get isSuccess => returnCode == 1;

  factory ZaloPayOrder.fromJson(Map<String, dynamic> json) {
    return ZaloPayOrder(
      appTransId: json['app_trans_id'] ?? '',
      zpTransToken: json['zp_trans_token'] ?? '',
      orderUrl: json['order_url'] ?? '',
      orderToken: json['order_token'] ?? '',
      returnCode: json['return_code'] ?? -1,
      returnMessage: json['return_message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_trans_id': appTransId,
      'zp_trans_token': zpTransToken,
      'order_url': orderUrl,
      'order_token': orderToken,
      'return_code': returnCode,
      'return_message': returnMessage,
    };
  }
}

/// ZaloPay Payment Status Enum
enum ZaloPayStatus {
  success,
  failed,
  cancelled,
  processing,
  unknown,
}

/// ZaloPay Payment Result
class ZaloPayResult {
  final ZaloPayStatus status;
  final String message;
  final String? transactionId;

  ZaloPayResult({
    required this.status,
    required this.message,
    this.transactionId,
  });

  bool get isSuccess => status == ZaloPayStatus.success;
  bool get isFailed => status == ZaloPayStatus.failed;
  bool get isCancelled => status == ZaloPayStatus.cancelled;
  bool get isProcessing => status == ZaloPayStatus.processing;
}

/// ZaloPay Order Status - Response from query API
class ZaloPayOrderStatus {
  final int returnCode;
  final String returnMessage;
  final bool isProcessing;
  final int amount;
  final String? zpTransId;
  final int serverTime;
  final int discountAmount;

  ZaloPayOrderStatus({
    required this.returnCode,
    required this.returnMessage,
    required this.isProcessing,
    required this.amount,
    this.zpTransId,
    required this.serverTime,
    required this.discountAmount,
  });

  /// Return code meanings:
  /// 1: Success
  /// 2: Failed
  /// 3: Processing (order exists but not yet paid)
  bool get isPaid => returnCode == 1;
  bool get isFailed => returnCode == 2;
  bool get isPending => returnCode == 3 || isProcessing;

  factory ZaloPayOrderStatus.fromJson(Map<String, dynamic> json) {
    return ZaloPayOrderStatus(
      returnCode: json['return_code'] ?? -1,
      returnMessage: json['return_message'] ?? '',
      isProcessing: json['is_processing'] ?? false,
      amount: json['amount'] ?? 0,
      zpTransId: json['zp_trans_id']?.toString(),
      serverTime: json['server_time'] ?? 0,
      discountAmount: json['discount_amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'return_code': returnCode,
      'return_message': returnMessage,
      'is_processing': isProcessing,
      'amount': amount,
      'zp_trans_id': zpTransId,
      'server_time': serverTime,
      'discount_amount': discountAmount,
    };
  }
}

/// Payment Method Enum for selection
enum PaymentMethod {
  vietQR,   // PayOS QR
  zaloPay,  // ZaloPay App-to-App
  momo,     // MoMo (future)
  cash,     // Pay at hotel
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.vietQR:
        return 'Quét mã QR (VietQR)';
      case PaymentMethod.zaloPay:
        return 'ZaloPay';
      case PaymentMethod.momo:
        return 'MoMo';
      case PaymentMethod.cash:
        return 'Thanh toán tại nơi';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.vietQR:
        return 'Quét bằng app ngân hàng';
      case PaymentMethod.zaloPay:
        return 'Thanh toán qua ví ZaloPay';
      case PaymentMethod.momo:
        return 'Thanh toán qua ví MoMo';
      case PaymentMethod.cash:
        return 'Thanh toán khi nhận phòng';
    }
  }

  String get iconPath {
    switch (this) {
      case PaymentMethod.vietQR:
        return 'assets/icons/payment_qr.png';
      case PaymentMethod.zaloPay:
        return 'assets/icons/payment_zalopay.png';
      case PaymentMethod.momo:
        return 'assets/icons/payment_momo.png';
      case PaymentMethod.cash:
        return 'assets/icons/payment_cash.png';
    }
  }

  bool get isEnabled {
    switch (this) {
      case PaymentMethod.vietQR:
        return true;
      case PaymentMethod.zaloPay:
        return true;
      case PaymentMethod.momo:
        return false; // Coming soon
      case PaymentMethod.cash:
        return true;
    }
  }
}
