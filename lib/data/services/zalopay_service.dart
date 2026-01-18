import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import 'package:url_launcher/url_launcher.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/zalopay_payment_model.dart';

/// ZaloPay Service for payment integration using Web Redirect flow
/// Supports both Sandbox and Production environments
/// Uses web checkout URL instead of native SDK for better compatibility
class ZaloPayService extends GetxService {
  static ZaloPayService get to => Get.find();

  late final Dio _dio;

  // ZaloPay Sandbox Credentials (Demo) - Updated from zalopay-samples/test-apps
  // For production, these should come from .env file
  static const String _sandboxAppId = '2554';
  static const String _sandboxKey1 = 'sdngKKJmqEMzvh5QQcdD2A9XBSKUNaYn';
  static const String _sandboxKey2 = 'trMrHtvjo6myautxDUiAcYsVtaeQ8nhf';

  // API Endpoints
  static const String _sandboxEndpoint = 'https://sb-openapi.zalopay.vn/v2';
  static const String _productionEndpoint = 'https://openapi.zalopay.vn/v2';

  // Current environment
  bool get isSandbox => dotenv.env['ZALOPAY_ENVIRONMENT'] != 'production';

  String get _appId => isSandbox
      ? _sandboxAppId
      : (dotenv.env['ZALOPAY_APP_ID'] ?? _sandboxAppId);

  String get _key1 => isSandbox
      ? _sandboxKey1
      : (dotenv.env['ZALOPAY_KEY1'] ?? _sandboxKey1);

  String get _key2 => isSandbox
      ? _sandboxKey2
      : (dotenv.env['ZALOPAY_KEY2'] ?? _sandboxKey2);

  String get _baseUrl => isSandbox ? _sandboxEndpoint : _productionEndpoint;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    LoggerService.i('ZaloPayService initialized - Environment: ${isSandbox ? "Sandbox" : "Production"}');
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => LoggerService.d(obj.toString()),
        ),
      );
    }
  }

  /// Generate HMAC SHA256 signature
  String _generateMac(String data) {
    final key = utf8.encode(_key1);
    final bytes = utf8.encode(data);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  /// Generate unique transaction ID in format: yyMMdd_random
  /// ZaloPay requires format: yymmdd_OrderID
  String _generateTransId() {
    final now = DateTime.now();
    final yyMMdd = '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final random = now.millisecondsSinceEpoch % 1000000;
    return '${yyMMdd}_$random';
  }

  /// Create ZaloPay order and get checkout URL
  /// Returns ZaloPayOrder with orderUrl for web redirect payment
  Future<ZaloPayOrder?> createOrder({
    required int amount,
    required String description,
    String? orderId,
    Map<String, dynamic>? embedData,
    List<Map<String, dynamic>>? items,
    String? callbackUrl,
  }) async {
    try {
      // app_trans_id format: yyMMdd_OrderID (required by ZaloPay)
      final appTransId = orderId ?? _generateTransId();
      final appTime = DateTime.now().millisecondsSinceEpoch;

      // Embed data - keep minimal for sandbox
      // Use provided embedData or default empty object
      final embedDataMap = embedData ?? {};
      final embedDataJson = jsonEncode(embedDataMap);

      // Items - must be a JSON array string
      final itemsJson = jsonEncode(items ?? []);

      // Build MAC data string (must be in exact order)
      // Format: app_id|app_trans_id|app_user|amount|app_time|embed_data|item
      final macData = '${_appId}|${appTransId}|user_wanderlust|${amount}|${appTime}|${embedDataJson}|${itemsJson}';
      final mac = _generateMac(macData);

      LoggerService.i('Creating ZaloPay order: $appTransId, amount: $amount');
      LoggerService.d('MAC data: $macData');
      LoggerService.d('MAC: $mac');

      // Request data - app_id, app_time, amount must be integers
      final requestData = {
        'app_id': int.parse(_appId),
        'app_user': 'user_wanderlust',
        'app_trans_id': appTransId,
        'app_time': appTime,
        'amount': amount,
        'description': description,
        'embed_data': embedDataJson,
        'item': itemsJson,
        'mac': mac,
      };

      LoggerService.d('Request data: $requestData');

      final response = await _dio.post(
        '$_baseUrl/create',
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['return_code'] == 1) {
          final order = ZaloPayOrder(
            appTransId: appTransId,
            zpTransToken: data['zp_trans_token'] ?? '',
            orderUrl: data['order_url'] ?? '',
            orderToken: data['order_token'] ?? '',
            returnCode: data['return_code'],
            returnMessage: data['return_message'] ?? 'Success',
          );

          LoggerService.i('ZaloPay order created successfully: ${order.appTransId}');
          LoggerService.i('Checkout URL: ${order.orderUrl}');
          return order;
        } else {
          LoggerService.e('ZaloPay create order failed: ${data['return_message']} (code: ${data['return_code']})');
          return ZaloPayOrder(
            appTransId: appTransId,
            zpTransToken: '',
            orderUrl: '',
            orderToken: '',
            returnCode: data['return_code'] ?? -1,
            returnMessage: data['return_message'] ?? 'Unknown error',
          );
        }
      }

      LoggerService.e('ZaloPay create order failed: Invalid response');
      return null;
    } on DioException catch (e) {
      LoggerService.e('DioException creating ZaloPay order', error: e, stackTrace: e.stackTrace);
      return null;
    } catch (e, stackTrace) {
      LoggerService.e('Error creating ZaloPay order', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Open ZaloPay checkout URL in browser/webview
  /// This redirects user to ZaloPay web checkout
  Future<ZaloPayResult> openCheckout(String orderUrl) async {
    try {
      LoggerService.i('Opening ZaloPay checkout: $orderUrl');

      final uri = Uri.parse(orderUrl);

      // Don't use canLaunchUrl on Android 11+ as it requires explicit queries
      // Just try to launch and handle errors
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          return ZaloPayResult(
            status: ZaloPayStatus.processing,
            message: 'Đã mở trang thanh toán ZaloPay',
          );
        }

        // Try with platform default if external app fails
        final launchedDefault = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );

        if (launchedDefault) {
          return ZaloPayResult(
            status: ZaloPayStatus.processing,
            message: 'Đã mở trang thanh toán ZaloPay',
          );
        }
      } catch (e) {
        LoggerService.w('Failed to launch URL with externalApplication: $e');
        // Try with in-app browser as fallback
        try {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppBrowserView,
          );
          if (launched) {
            return ZaloPayResult(
              status: ZaloPayStatus.processing,
              message: 'Đã mở trang thanh toán ZaloPay',
            );
          }
        } catch (_) {}
      }

      return ZaloPayResult(
        status: ZaloPayStatus.failed,
        message: 'Không thể mở trang thanh toán',
      );
    } catch (e, stackTrace) {
      LoggerService.e('Error opening ZaloPay checkout', error: e, stackTrace: stackTrace);
      return ZaloPayResult(
        status: ZaloPayStatus.failed,
        message: 'Lỗi khi mở trang thanh toán: $e',
      );
    }
  }

  /// Query order status
  Future<ZaloPayOrderStatus?> queryOrder(String appTransId) async {
    try {
      final macData = '$_appId|$appTransId|$_key1';
      final mac = _generateMac(macData);

      LoggerService.i('Querying ZaloPay order status: $appTransId');
      LoggerService.d('Query MAC data: $macData');

      final response = await _dio.post(
        '$_baseUrl/query',
        data: {
          'app_id': _appId,
          'app_trans_id': appTransId,
          'mac': mac,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        return ZaloPayOrderStatus(
          returnCode: data['return_code'] ?? -1,
          returnMessage: data['return_message'] ?? '',
          isProcessing: data['is_processing'] ?? false,
          amount: data['amount'] ?? 0,
          zpTransId: data['zp_trans_id']?.toString(),
          serverTime: data['server_time'] ?? 0,
          discountAmount: data['discount_amount'] ?? 0,
        );
      }

      return null;
    } on DioException catch (e) {
      LoggerService.e('DioException querying ZaloPay order', error: e, stackTrace: e.stackTrace);
      return null;
    } catch (e, stackTrace) {
      LoggerService.e('Error querying ZaloPay order', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Check if ZaloPay app is installed (for potential future native support)
  Future<bool> isZaloPayInstalled() async {
    try {
      // Try to check if zalopay:// scheme can be launched
      final uri = Uri.parse('zalopay://');
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }
}
