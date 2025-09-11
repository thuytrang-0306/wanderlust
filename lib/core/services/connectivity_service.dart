import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find();
  
  final RxBool _isConnected = true.obs;
  final RxBool _isChecking = false.obs;
  
  bool get isConnected => _isConnected.value;
  bool get isChecking => _isChecking.value;
  
  Timer? _connectivityTimer;
  static const Duration _checkInterval = Duration(seconds: 5);
  
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
        return true;
      }
      
      // For mobile platforms, check actual connectivity
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (_isConnected.value != isConnected) {
        _isConnected.value = isConnected;
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
      // On web, this will always throw, so assume connected
      if (kIsWeb) {
        _isConnected.value = true;
        return true;
      }
      LoggerService.e('Connectivity check error', error: e);
      return _isConnected.value;
    } finally {
      _isChecking.value = false;
    }
  }
  
  void _notifyConnectivityChange(bool isConnected) {
    LoggerService.i('Connectivity changed: ${isConnected ? 'Connected' : 'Disconnected'}');
    
    if (isConnected) {
      Get.snackbar(
        'Connection Restored',
        'You are back online',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        icon: const Icon(Icons.wifi, color: Colors.white),
      );
    } else {
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
    }
  }
  
  Future<T?> executeWithConnectivity<T>(
    Future<T> Function() function, {
    bool showError = true,
    String? errorMessage,
  }) async {
    if (!await checkConnectivity()) {
      if (showError) {
        Get.snackbar(
          'No Internet',
          errorMessage ?? 'This action requires internet connection',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
      return null;
    }
    
    try {
      return await function();
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        _isConnected.value = false;
        _notifyConnectivityChange(false);
      }
      rethrow;
    }
  }
  
  Stream<bool> get connectivityStream => _isConnected.stream;
}