import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  late final Logger _logger;
  bool _isInitialized = false;

  // Helper to truncate base64 and long strings
  static String _truncateLongStrings(dynamic input, {int maxLength = 100}) {
    if (input == null) return 'null';

    String str = input.toString();

    // Check if it's base64 data URL
    if (str.startsWith('data:image') && str.contains('base64,')) {
      return 'data:image/[base64 truncated...]';
    }

    // Check if it's just base64 string
    if (str.length > 500 && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(str)) {
      return '[base64 data truncated...]';
    }

    // Truncate other long strings
    if (str.length > maxLength) {
      return '${str.substring(0, maxLength)}...[truncated]';
    }

    return str;
  }

  // Clean data for logging
  static dynamic _cleanDataForLogging(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      return data.map((key, value) {
        // Skip image/avatar fields entirely or truncate them
        if (key.toString().toLowerCase().contains('image') ||
            key.toString().toLowerCase().contains('avatar') ||
            key.toString().toLowerCase().contains('photo')) {
          if (value != null && value.toString().isNotEmpty) {
            return MapEntry(key, _truncateLongStrings(value));
          }
        }

        // Recursively clean nested maps
        if (value is Map || value is List) {
          return MapEntry(key, _cleanDataForLogging(value));
        }

        return MapEntry(key, _truncateLongStrings(value));
      });
    }

    if (data is List) {
      return data.map((item) => _cleanDataForLogging(item)).toList();
    }

    return _truncateLongStrings(data);
  }

  static void init() {
    if (_instance._isInitialized) return;
    
    _instance._logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: kDebugMode ? Level.trace : Level.off,
      filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
    );
    _instance._isInitialized = true;
  }

  static void d(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (!_instance._isInitialized) init();
    _instance._logger.d(_cleanDataForLogging(message), error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (!_instance._isInitialized) init();
    _instance._logger.i(_cleanDataForLogging(message), error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (!_instance._isInitialized) init();
    _instance._logger.w(_cleanDataForLogging(message), error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (!_instance._isInitialized) init();
    _instance._logger.e(_cleanDataForLogging(message), error: error, stackTrace: stackTrace);
  }

  static void wtf(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (!_instance._isInitialized) init();
    _instance._logger.f(message, error: error, stackTrace: stackTrace);
  }

  static void api({
    required String method,
    required String url,
    Map<String, dynamic>? params,
    dynamic data,
    dynamic response,
    dynamic error,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🌐 API Call:');
    buffer.writeln('  Method: $method');
    buffer.writeln('  URL: $url');
    if (params != null) buffer.writeln('  Params: ${_cleanDataForLogging(params)}');
    if (data != null) buffer.writeln('  Data: ${_cleanDataForLogging(data)}');
    if (response != null) buffer.writeln('  Response: ${_cleanDataForLogging(response)}');
    if (error != null) buffer.writeln('  Error: $error');

    if (!_instance._isInitialized) init();
    if (error != null) {
      _instance._logger.e(buffer.toString());
    } else {
      _instance._logger.i(buffer.toString());
    }
  }

  static void firebase({
    required String operation,
    String? collection,
    String? documentId,
    dynamic data,
    dynamic error,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🔥 Firebase Operation:');
    buffer.writeln('  Operation: $operation');
    if (collection != null) buffer.writeln('  Collection: $collection');
    if (documentId != null) buffer.writeln('  Document: $documentId');
    if (data != null) buffer.writeln('  Data: ${_cleanDataForLogging(data)}');
    if (error != null) buffer.writeln('  Error: $error');

    if (!_instance._isInitialized) init();
    if (error != null) {
      _instance._logger.e(buffer.toString());
    } else {
      _instance._logger.d(buffer.toString());
    }
  }

  static void navigation({
    required String from,
    required String to,
    Map<String, dynamic>? arguments,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🧭 Navigation:');
    buffer.writeln('  From: $from');
    buffer.writeln('  To: $to');
    if (arguments != null) buffer.writeln('  Arguments: ${_cleanDataForLogging(arguments)}');

    if (!_instance._isInitialized) init();
    _instance._logger.d(buffer.toString());
  }
}
