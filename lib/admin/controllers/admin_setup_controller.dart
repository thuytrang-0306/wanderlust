import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/admin_auth_service.dart';
import '../routes/admin_routes.dart';
import '../../shared/core/widgets/app_snackbar.dart';
import '../../shared/core/utils/logger_service.dart';

class AdminSetupController extends GetxController {
  final AdminAuthService _authService = Get.find<AdminAuthService>();
  
  // Form controllers
  final setupFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // State
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isSetupRequired = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    _checkIfSetupRequired();
    LoggerService.i('AdminSetupController initialized');
  }
  
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  Future<void> _checkIfSetupRequired() async {
    try {
      final setupRequired = await _authService.isAdminSetupRequired();
      isSetupRequired.value = setupRequired;
      
      if (!setupRequired) {
        LoggerService.i('Admin setup not required, redirecting to login');
        Get.offAllNamed(AdminRoutes.LOGIN);
      }
    } catch (e) {
      LoggerService.e('Error checking setup requirement', error: e);
      // If error, assume setup is required for safety
      isSetupRequired.value = true;
    }
  }
  
  Future<void> createSuperAdmin() async {
    if (!setupFormKey.currentState!.validate()) return;
    
    isLoading.value = true;
    
    try {
      LoggerService.i('Creating initial super admin: ${emailController.text}');
      
      final success = await _authService.createInitialSuperAdmin(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
      );
      
      if (success) {
        AppSnackbar.showSuccess(
          message: 'Super Admin created successfully!',
        );
        
        LoggerService.i('Super admin created, redirecting to login');
        
        // Clear form
        _clearForm();
        
        // Redirect to login page
        Get.offAllNamed(AdminRoutes.LOGIN);
        
        // Show login hint
        Future.delayed(const Duration(milliseconds: 500), () {
          AppSnackbar.showInfo(
            message: 'Please login with your new admin credentials',
          );
        });
      } else {
        AppSnackbar.showError(
          message: 'Failed to create Super Admin. Please try again.',
        );
      }
    } catch (e, stackTrace) {
      LoggerService.e('Error creating super admin', error: e, stackTrace: stackTrace);
      
      String errorMessage = 'Failed to create Super Admin';
      
      // Parse Firebase error messages
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'This email is already registered';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak. Please use a stronger password';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Please enter a valid email address';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = 'Network error. Please check your connection and try again';
      }
      
      AppSnackbar.showError(message: errorMessage);
    } finally {
      isLoading.value = false;
    }
  }
  
  void _clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }
  
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }
  
  // Form validators
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must not exceed 50 characters';
    }
    return null;
  }
  
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }
  
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  // Auto-fill demo data for testing
  void fillDemoData() {
    nameController.text = 'Super Admin';
    emailController.text = 'admin@wanderlust.com';
    passwordController.text = 'Admin123!@#';
    confirmPasswordController.text = 'Admin123!@#';
    
    AppSnackbar.showInfo(
      message: 'Demo data filled. You can modify or use as-is.',
    );
  }
}