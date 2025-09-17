import 'package:wanderlust/core/utils/logger_service.dart';

/// Utility class to filter sensitive data from logs
class LoggerUtils {
  /// Sanitize string data before logging
  /// Removes base64 strings and long data URLs
  static String sanitize(dynamic data) {
    if (data == null) return 'null';
    
    String str = data.toString();
    
    // If it's a base64 data URL, replace with placeholder
    if (str.startsWith('data:image') && str.length > 100) {
      return '[BASE64_IMAGE_DATA]';
    }
    
    // If it's a very long string (likely base64), truncate
    if (str.length > 500) {
      // Check if it might be base64
      if (_looksLikeBase64(str)) {
        return '[BASE64_DATA_${str.length}_CHARS]';
      }
      // Otherwise truncate normally
      return '${str.substring(0, 100)}...[truncated ${str.length - 100} chars]';
    }
    
    return str;
  }
  
  /// Check if string looks like base64
  static bool _looksLikeBase64(String str) {
    // Base64 pattern check
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]{100,}={0,2}$');
    return base64Pattern.hasMatch(str.substring(0, 100.clamp(0, str.length)));
  }
  
  /// Log user data safely (remove sensitive info)
  static void logUserSafely(String message, dynamic user) {
    if (user == null) {
      LoggerService.d('$message: null');
      return;
    }
    
    Map<String, dynamic> safeData = {};
    
    if (user is Map) {
      user.forEach((key, value) {
        // Skip sensitive fields
        if (key == 'photoURL' || key == 'password' || key == 'token') {
          if (value != null && value.toString().length > 50) {
            safeData[key] = '[REDACTED]';
          } else {
            safeData[key] = value;
          }
        } else {
          safeData[key] = sanitize(value);
        }
      });
    } else {
      safeData = {'data': sanitize(user)};
    }
    
    LoggerService.d('$message: $safeData');
  }
  
  /// Log error safely
  static void logErrorSafely(String message, dynamic error) {
    LoggerService.e(message, error: error);
  }
}