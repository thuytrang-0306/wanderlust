import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class ChangePasswordController extends BaseController {
  final formKey = GlobalKey<FormState>();
  
  // Controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // Observables
  final RxBool showCurrentPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  final RxBool isChangePasswordLoading = false.obs;
  final RxDouble passwordStrength = 0.0.obs;
  final RxString newPasswordText = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Listen to new password changes for strength calculation
    newPasswordController.addListener(_calculatePasswordStrength);
  }
  
  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  void toggleCurrentPassword() {
    showCurrentPassword.value = !showCurrentPassword.value;
  }
  
  void toggleNewPassword() {
    showNewPassword.value = !showNewPassword.value;
  }
  
  void toggleConfirmPassword() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }
  
  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu hiện tại';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }
  
  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(value)) {
      return 'Mật khẩu phải có chữ hoa, chữ thường và số';
    }
    if (value == currentPasswordController.text) {
      return 'Mật khẩu mới không được giống mật khẩu cũ';
    }
    return null;
  }
  
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu mới';
    }
    if (value != newPasswordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }
  
  void _calculatePasswordStrength() {
    final password = newPasswordController.text;
    newPasswordText.value = password; // Update observable
    if (password.isEmpty) {
      passwordStrength.value = 0.0;
      return;
    }
    
    double strength = 0.0;
    
    // Length check
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.2;
    
    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'\d').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.15;
    
    passwordStrength.value = strength.clamp(0.0, 1.0);
  }
  
  Color getPasswordStrengthColor() {
    if (passwordStrength.value < 0.3) {
      return Colors.red;
    } else if (passwordStrength.value < 0.6) {
      return Colors.orange;
    } else if (passwordStrength.value < 0.8) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
  
  String getPasswordStrengthText() {
    if (passwordStrength.value < 0.3) {
      return 'Yếu';
    } else if (passwordStrength.value < 0.6) {
      return 'Trung bình';
    } else if (passwordStrength.value < 0.8) {
      return 'Mạnh';
    } else {
      return 'Rất mạnh';
    }
  }
  
  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      isChangePasswordLoading.value = true;
      AppDialogs.showLoading(message: 'Đang cập nhật mật khẩu...');
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }
      
      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPasswordController.text);
      
      AppDialogs.hideLoading();
      
      // Clear form
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      passwordStrength.value = 0.0;
      
      AppSnackbar.showSuccess(message: 'Đổi mật khẩu thành công!');
      
      // Navigate back after short delay
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
      
    } on FirebaseAuthException catch (e) {
      AppDialogs.hideLoading();
      
      String errorMessage = 'Có lỗi xảy ra khi đổi mật khẩu';
      
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Mật khẩu hiện tại không đúng';
          break;
        case 'weak-password':
          errorMessage = 'Mật khẩu mới quá yếu';
          break;
        case 'requires-recent-login':
          errorMessage = 'Vui lòng đăng nhập lại để thực hiện thao tác này';
          break;
        case 'network-request-failed':
          errorMessage = 'Lỗi kết nối mạng. Vui lòng thử lại';
          break;
        default:
          errorMessage = 'Lỗi: ${e.message}';
      }
      
      AppSnackbar.showError(message: errorMessage);
      LoggerService.e('Change password error', error: e);
      
    } catch (e) {
      AppDialogs.hideLoading();
      AppSnackbar.showError(message: 'Có lỗi xảy ra');
      LoggerService.e('Change password error', error: e);
    } finally {
      isChangePasswordLoading.value = false;
    }
  }
  
  void forgotPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) {
      AppSnackbar.showError(message: 'Không tìm thấy email người dùng');
      return;
    }
    
    final result = await AppDialogs.showConfirm(
      title: 'Quên mật khẩu',
      message: 'Chúng tôi sẽ gửi link đặt lại mật khẩu về email ${user!.email}',
      confirmText: 'Gửi email',
      cancelText: 'Hủy',
    );
    
    if (result == true) {
      try {
        AppDialogs.showLoading(message: 'Đang gửi email...');
        
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: user.email!,
        );
        
        AppDialogs.hideLoading();
        
        AppSnackbar.showSuccess(
          message: 'Đã gửi email đặt lại mật khẩu. Vui lòng kiểm tra hộp thư',
        );
        
      } on FirebaseAuthException catch (e) {
        AppDialogs.hideLoading();
        
        String errorMessage = 'Có lỗi xảy ra';
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Email không hợp lệ';
            break;
          case 'user-not-found':
            errorMessage = 'Không tìm thấy tài khoản với email này';
            break;
          default:
            errorMessage = 'Lỗi: ${e.message}';
        }
        
        AppSnackbar.showError(message: errorMessage);
        LoggerService.e('Forgot password error', error: e);
        
      } catch (e) {
        AppDialogs.hideLoading();
        AppSnackbar.showError(message: 'Có lỗi xảy ra');
        LoggerService.e('Forgot password error', error: e);
      }
    }
  }
}