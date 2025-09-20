import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/admin_auth_service.dart';
import '../routes/admin_routes.dart';
import '../../shared/core/widgets/app_snackbar.dart';

class AdminAuthController extends GetxController {
  final AdminAuthService _authService = Get.find<AdminAuthService>();
  
  // Login form
  final loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // State
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  
  // Getters
  bool get isLoggedIn => _authService.isLoggedIn;
  String get adminRole => _authService.adminRole;
  dynamic get currentUser => _authService.currentUser;
  
  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  void _checkAuthState() {
    // Check initial auth state
    if (_authService.isLoggedIn) {
      Get.offAllNamed(AdminRoutes.DASHBOARD);
    }
  }
  
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    
    isLoading.value = true;
    
    try {
      final success = await _authService.loginWithEmail(
        emailController.text.trim(),
        passwordController.text,
      );
      
      if (success) {
        AppSnackbar.showSuccess(
          message: 'Welcome back, ${_authService.adminRole.capitalizeFirst}!',
        );
        Get.offAllNamed(AdminRoutes.DASHBOARD);
      } else {
        AppSnackbar.showError(
          message: 'Invalid credentials or insufficient permissions',
        );
      }
    } catch (e) {
      AppSnackbar.showError(
        message: 'Login failed: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    try {
      await _authService.logout();
      AppSnackbar.showInfo(
        message: 'Logged out successfully',
      );
      Get.offAllNamed(AdminRoutes.LOGIN);
    } catch (e) {
      AppSnackbar.showError(
        message: 'Logout failed: ${e.toString()}',
      );
    }
  }
  
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  // Form validators
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  
  // Check permissions
  bool hasPermission(String permission) {
    return _authService.hasPermission(permission);
  }
  
  // Create new admin (only for super admins)
  Future<void> createAdmin({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    if (!hasPermission('create_admin')) {
      AppSnackbar.showError(
        message: 'Insufficient permissions to create admin users',
      );
      return;
    }
    
    try {
      final success = await _authService.createAdminUser(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      
      if (success) {
        AppSnackbar.showSuccess(
          message: 'Admin user created successfully',
        );
      } else {
        AppSnackbar.showError(
          message: 'Failed to create admin user',
        );
      }
    } catch (e) {
      AppSnackbar.showError(
        message: 'Error creating admin: ${e.toString()}',
      );
    }
  }
}