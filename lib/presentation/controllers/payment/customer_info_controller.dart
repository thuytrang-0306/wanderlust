import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

class CustomerInfoController extends GetxController {
  // Text controllers
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  // Loading state
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill if user data exists
    _loadUserData();
  }

  @override
  void onClose() {
    lastNameController.dispose();
    firstNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void _loadUserData() {
    // TODO: Load from user profile if logged in
    // Example:
    // lastNameController.text = userProfile.lastName;
    // firstNameController.text = userProfile.firstName;
    // phoneController.text = userProfile.phone;
    // emailController.text = userProfile.email;
  }

  bool _validateFields() {
    if (lastNameController.text.trim().isEmpty) {
      AppSnackbar.showError(message: 'Vui lòng nhập họ');
      return false;
    }

    if (firstNameController.text.trim().isEmpty) {
      AppSnackbar.showError(message: 'Vui lòng nhập tên đệm và tên');
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      AppSnackbar.showError(message: 'Vui lòng nhập số điện thoại');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      AppSnackbar.showError(message: 'Vui lòng nhập email');
      return false;
    }

    // Validate email format
    if (!GetUtils.isEmail(emailController.text.trim())) {
      AppSnackbar.showError(message: 'Email không hợp lệ');
      return false;
    }

    // Validate phone format (Vietnamese phone)
    final phoneRegex = RegExp(r'^(0|\+84)[0-9]{9,10}$');
    if (!phoneRegex.hasMatch(phoneController.text.trim().replaceAll(' ', ''))) {
      AppSnackbar.showError(message: 'Số điện thoại không hợp lệ');
      return false;
    }

    return true;
  }

  void saveCustomerInfo() {
    if (!_validateFields()) return;

    isLoading.value = true;

    // Simulate saving
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;

      // Pass customer info back to booking page
      Get.back(
        result: {
          'lastName': lastNameController.text.trim(),
          'firstName': firstNameController.text.trim(),
          'phone': phoneController.text.trim(),
          'email': emailController.text.trim(),
        },
      );

      AppSnackbar.showSuccess(message: 'Đã lưu thông tin khách hàng');
    });
  }
}
