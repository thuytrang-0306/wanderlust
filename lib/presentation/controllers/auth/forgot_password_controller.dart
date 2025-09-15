import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class ForgotPasswordController extends BaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Form controller
  final emailController = TextEditingController();
  
  // Form key for validation
  final formKey = GlobalKey<FormState>();
  
  // Success state
  final RxBool isEmailSent = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
  
  // Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }
  
  // Send password reset email
  Future<void> sendPasswordResetEmail() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    setLoading();
    
    try {
      await _auth.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      
      isEmailSent.value = true;
      setSuccess();
      
      LoggerService.i('Password reset email sent to: ${emailController.text}');
      
      Get.snackbar(
        'Thành công',
        'Email đặt lại mật khẩu đã được gửi đến ${emailController.text}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      
      // Navigate back after success
      await Future.delayed(const Duration(seconds: 2));
      Get.back();
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Đã xảy ra lỗi';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Không tìm thấy tài khoản với email này';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ';
          break;
        case 'too-many-requests':
          errorMessage = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
          break;
        default:
          errorMessage = e.message ?? 'Không thể gửi email đặt lại mật khẩu';
      }
      
      setError(errorMessage);
      Get.snackbar(
        'Lỗi',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
    } catch (e) {
      LoggerService.e('Password reset error: $e');
      setError('Đã xảy ra lỗi không xác định');
      
      Get.snackbar(
        'Lỗi',
        'Không thể gửi email đặt lại mật khẩu',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (!isEmailSent.value) {
        setIdle();
      }
    }
  }
  
  // Navigate back
  void navigateBack() {
    Get.back();
  }
}