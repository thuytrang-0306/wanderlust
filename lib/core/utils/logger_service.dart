import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();
  
  late final Logger _logger;
  
  static void init() {
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
  }
  
  static void d(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _instance._logger.d(message, error: error, stackTrace: stackTrace);
  }
  
  static void i(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _instance._logger.i(message, error: error, stackTrace: stackTrace);
  }
  
  static void w(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _instance._logger.w(message, error: error, stackTrace: stackTrace);
  }
  
  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _instance._logger.e(message, error: error, stackTrace: stackTrace);
  }
  
  static void wtf(dynamic message, {dynamic error, StackTrace? stackTrace}) {
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
    if (params != null) buffer.writeln('  Params: $params');
    if (data != null) buffer.writeln('  Data: $data');
    if (response != null) buffer.writeln('  Response: $response');
    if (error != null) buffer.writeln('  Error: $error');
    
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
    if (data != null) buffer.writeln('  Data: $data');
    if (error != null) buffer.writeln('  Error: $error');
    
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
    if (arguments != null) buffer.writeln('  Arguments: $arguments');
    
    _instance._logger.d(buffer.toString());
  }
}