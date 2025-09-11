import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AppController extends GetxController {
  final RxBool isDarkMode = false.obs;
  final RxString currentLanguage = 'en'.obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }
  
  void _loadSettings() {
    // Load saved settings from local storage
  }
  
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
    _saveThemePreference();
  }
  
  void changeLanguage(String languageCode) {
    currentLanguage.value = languageCode;
    // Get.updateLocale(Locale(languageCode));
    _saveLanguagePreference();
  }
  
  void _saveThemePreference() {
    // Save theme preference to local storage
  }
  
  void _saveLanguagePreference() {
    // Save language preference to local storage
  }
  
  void showLoading() {
    isLoading.value = true;
  }
  
  void hideLoading() {
    isLoading.value = false;
  }
  
  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
  
  void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
  
  void showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}