import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/payos_payment_model.dart';

class PayOSService extends GetxService {
  static PayOSService get to => Get.find();

  late final Dio _dio;
  late final String _clientId;
  late final String _apiKey;
  late final String _checksumKey;

  // PayOS API Base URL
  static const String _baseUrl = 'https://api-merchant.payos.vn';

  @override
  void onInit() {
    super.onInit();
    _initializeConfig();
    _initializeDio();
  }

  void _initializeConfig() {
    _clientId = dotenv.env['PAYOS_CLIENT_ID'] ?? '';
    _apiKey = dotenv.env['PAYOS_API_KEY'] ?? '';
    _checksumKey = dotenv.env['PAYOS_CHECKSUM_KEY'] ?? '';

    if (_clientId.isEmpty || _apiKey.isEmpty || _checksumKey.isEmpty) {
      LoggerService.w('PayOS credentials not found in .env file');
    }
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'x-client-id': _clientId,
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => LoggerService.d(obj.toString()),
      ),
    );
  }

  /// Generate signature for PayOS request
  String _generateSignature(Map<String, dynamic> data) {
    // Sort data by keys
    final sortedKeys = data.keys.toList()..sort();
    final sortedData = {for (var key in sortedKeys) key: data[key]};

    // Create signature string
    final signatureString = sortedData.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');

    // Create HMAC SHA256 signature
    final key = utf8.encode(_checksumKey);
    final bytes = utf8.encode(signatureString);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    return digest.toString();
  }

  /// Create payment link
  Future<PayOSPaymentLink?> createPaymentLink({
    required String orderCode,
    required int amount,
    required String description,
    String? buyerName,
    String? buyerEmail,
    String? buyerPhone,
    String? buyerAddress,
    List<PayOSItem>? items,
    String? returnUrl,
    String? cancelUrl,
  }) async {
    try {
      final requestData = PayOSCreatePaymentRequest(
        orderCode: orderCode,
        amount: amount,
        description: description,
        buyerName: buyerName,
        buyerEmail: buyerEmail,
        buyerPhone: buyerPhone,
        buyerAddress: buyerAddress,
        items: items,
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
      ).toJson();

      // Generate signature
      final signatureData = {
        'amount': amount,
        'cancelUrl': cancelUrl ?? '',
        'description': description,
        'orderCode': int.parse(orderCode),
        'returnUrl': returnUrl ?? '',
      };
      final signature = _generateSignature(signatureData);
      requestData['signature'] = signature;

      LoggerService.i('Creating PayOS payment link for order: $orderCode');

      final response = await _dio.post(
        '/v2/payment-requests',
        data: requestData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          final paymentLink = PayOSPaymentLink.fromJson(data);
          LoggerService.i('Payment link created successfully: ${paymentLink.id}');
          return paymentLink;
        }
      }

      LoggerService.e('Failed to create payment link: Invalid response');
      return null;
    } on DioException catch (e) {
      LoggerService.e(
        'DioException creating payment link',
        error: e,
        stackTrace: e.stackTrace,
      );
      return null;
    } catch (e, stackTrace) {
      LoggerService.e(
        'Error creating payment link',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get payment status by order code
  Future<PayOSPaymentStatus?> getPaymentStatus(String orderCode) async {
    try {
      LoggerService.i('Checking payment status for order: $orderCode');

      final response = await _dio.get('/v2/payment-requests/$orderCode');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          final paymentStatus = PayOSPaymentStatus.fromJson(data);
          LoggerService.i(
            'Payment status retrieved: ${paymentStatus.status} for order: $orderCode',
          );
          return paymentStatus;
        }
      }

      LoggerService.e('Failed to get payment status: Invalid response');
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        LoggerService.w('Payment not found for order: $orderCode');
      } else {
        LoggerService.e(
          'DioException getting payment status',
          error: e,
          stackTrace: e.stackTrace,
        );
      }
      return null;
    } catch (e, stackTrace) {
      LoggerService.e(
        'Error getting payment status',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Cancel payment link
  Future<bool> cancelPaymentLink(
    String orderCode, {
    String? cancellationReason,
  }) async {
    try {
      LoggerService.i('Cancelling payment for order: $orderCode');

      final response = await _dio.put(
        '/v2/payment-requests/$orderCode/cancel',
        data: {
          if (cancellationReason != null) 'cancellationReason': cancellationReason,
        },
      );

      if (response.statusCode == 200) {
        LoggerService.i('Payment cancelled successfully for order: $orderCode');
        return true;
      }

      LoggerService.e('Failed to cancel payment: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      LoggerService.e(
        'DioException cancelling payment',
        error: e,
        stackTrace: e.stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      LoggerService.e(
        'Error cancelling payment',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Generate unique order code
  String generateOrderCode() {
    // Use timestamp to generate unique order code (max 9 digits for PayOS)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Take last 9 digits
    final orderCode = (timestamp % 1000000000).toString();
    return orderCode;
  }

  /// Verify webhook signature
  bool verifyWebhookSignature(Map<String, dynamic> data, String signature) {
    try {
      final computedSignature = _generateSignature(data);
      return computedSignature == signature;
    } catch (e) {
      LoggerService.e('Error verifying webhook signature', error: e);
      return false;
    }
  }
}
