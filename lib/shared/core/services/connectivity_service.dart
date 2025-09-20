import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find();

  final RxBool _isConnected = false.obs; // Start with unknown state
  final RxBool _isChecking = false.obs;
  bool _hasEstablishedInitialConnection = false;
  bool _hasShownDisconnectedMessage = false;

  bool get isConnected => _isConnected.value;
  bool get isChecking => _isChecking.value;

  Timer? _connectivityTimer;
  static const Duration _checkInterval = Duration(seconds: 30); // Reduced frequency

  @override
  void onInit() {
    super.onInit();
    _startConnectivityCheck();
    checkConnectivity();
  }

  @override
  void onClose() {
    _connectivityTimer?.cancel();
    super.onClose();
  }

  void _startConnectivityCheck() {
    // Skip periodic checks on web platform
    if (kIsWeb) return;

    _connectivityTimer = Timer.periodic(_checkInterval, (_) {
      checkConnectivity();
    });
  }

  Future<bool> checkConnectivity() async {
    if (_isChecking.value) return _isConnected.value;

    _isChecking.value = true;

    try {
      // For web platform, assume connected (browser handles connectivity)
      if (kIsWeb) {
        _isConnected.value = true;
        _isChecking.value = false;
        return true;
      }

      // For mobile platforms, check actual connectivity with longer timeout
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 10));

      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      if (_isConnected.value != isConnected) {
        _isConnected.value = isConnected;
        
        // Mark initial connection as established when first connected
        if (isConnected && !_hasEstablishedInitialConnection) {
          _hasEstablishedInitialConnection = true;
        }
        
        _notifyConnectivityChange(isConnected);
      }

      return isConnected;
    } on SocketException catch (_) {
      if (_isConnected.value) {
        _isConnected.value = false;
        _notifyConnectivityChange(false);
      }
      return false;
    } on TimeoutException catch (_) {
      if (_isConnected.value) {
        _isConnected.value = false;
        _notifyConnectivityChange(false);
      }
      return false;
    } catch (e) {
      // On web, InternetAddress.lookup will always fail
      // Don't log error for web platform
      if (!kIsWeb) {
        LoggerService.e('Connectivity check error', error: e);
      }
      // Assume connected for web
      _isConnected.value = kIsWeb ? true : _isConnected.value;
      return _isConnected.value;
    } finally {
      _isChecking.value = false;
    }
  }

  void _notifyConnectivityChange(bool isConnected) {
    LoggerService.i('Connectivity changed: ${isConnected ? 'Connected' : 'Disconnected'}');

    if (isConnected) {
      // Only show restoration message if we were previously disconnected
      if (_hasShownDisconnectedMessage) {
        Get.snackbar(
          'Connection Restored',
          'You are back online',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          icon: const Icon(Icons.wifi, color: Colors.white),
        );
        _hasShownDisconnectedMessage = false;
      }
    } else {
      // Only show disconnection message after initial connectivity is established
      if (_hasEstablishedInitialConnection) {
        Get.snackbar(
          'No Internet Connection',
          'Please check your connection',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          icon: const Icon(Icons.wifi_off, color: Colors.white),
          isDismissible: false,
        );
        _hasShownDisconnectedMessage = true;
      }
    }
  }

  Future<T?> executeWithConnectivity<T>(
    Future<T> Function() function, {
    bool showError = true,
    String? errorMessage,
    int maxRetries = 3,
  }) async {
    // Try multiple times with exponential backoff
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      if (!await checkConnectivity()) {
        if (attempt == maxRetries && showError) {
          Get.snackbar(
            'No Internet',
            errorMessage ?? 'This action requires internet connection',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        }
        
        if (attempt < maxRetries) {
          // Wait before retry with exponential backoff
          await Future.delayed(Duration(seconds: attempt * 2));
          continue;
        }
        return null;
      }

      try {
        return await function();
      } catch (e) {
        if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
          _isConnected.value = false;
          _notifyConnectivityChange(false);
          
          if (attempt < maxRetries) {
            // Wait before retry
            await Future.delayed(Duration(seconds: attempt * 2));
            continue;
          }
        }
        rethrow;
      }
    }
    
    return null;
  }

  Stream<bool> get connectivityStream => _isConnected.stream;

  // Force check connectivity manually (useful for retry buttons)
  Future<bool> forceCheck() async {
    _isChecking.value = false; // Reset checking flag
    return await checkConnectivity();
  }

  // Get connectivity status as readable string
  String get connectionStatus {
    if (_isChecking.value) return 'Checking...';
    return _isConnected.value ? 'Connected' : 'No Internet';
  }
}
