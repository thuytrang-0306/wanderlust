import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

class VerifyEmailController extends BaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // OTP Controllers (6 digits) - keeping for UI compatibility
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  
  // Focus nodes for OTP fields
  final List<FocusNode> focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  
  // Timer for resend OTP
  Timer? _timer;
  Timer? _verificationCheckTimer;
  final RxInt secondsRemaining = 60.obs;
  final RxBool canResend = false.obs;
  
  // Email to verify
  final RxString email = ''.obs;
  
  // Verification state
  final RxBool isVerifying = false.obs;
  final RxBool isEmailVerified = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Get current user email
    final user = _auth.currentUser;
    if (user == null) {
      LoggerService.e('No user found for email verification');
      Get.offAllNamed(Routes.LOGIN);
      return;
    }
    
    email.value = user.email ?? '';
    
    // Check if already verified
    if (user.emailVerified) {
      LoggerService.i('User email already verified');
      isEmailVerified.value = true;
      Get.offAllNamed(Routes.MAIN_NAVIGATION);
      return;
    }
    
    // Don't send email automatically - wait for onReady
  }
  
  @override
  void onClose() {
    _timer?.cancel();
    _verificationCheckTimer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }
  
  // Start countdown timer
  void startTimer() {
    canResend.value = false;
    // Don't reset if already has a higher value (rate limiting)
    if (secondsRemaining.value <= 0) {
      secondsRemaining.value = 60; // 60 seconds default
    }
    
    _timer?.cancel(); // Cancel existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }
  
  // Send verification email
  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        LoggerService.e('No current user to send verification email');
        return;
      }
      
      if (user.emailVerified) {
        LoggerService.i('User email already verified');
        isEmailVerified.value = true;
        Get.offAllNamed(Routes.MAIN_NAVIGATION);
        return;
      }
      
      await user.sendEmailVerification();
      
      LoggerService.i('Verification email sent to: ${user.email}');
      
      // Start timer after successful send
      startTimer();
      
      AppSnackbar.showSuccess(
        message: 'Vui lòng kiểm tra hộp thư ${user.email}',
        title: 'Email đã gửi',
        position: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      
    } on FirebaseAuthException catch (e) {
      LoggerService.e('Firebase error sending verification email: ${e.code} - ${e.message}');
      
      String errorMessage = 'Không thể gửi email xác thực';
      
      if (e.code == 'too-many-requests') {
        errorMessage = 'Quá nhiều yêu cầu. Vui lòng đợi 2 phút trước khi thử lại.';
        // Force longer wait time for rate limiting
        secondsRemaining.value = 120; // 2 minutes
        startTimer();
      } else if (e.code == 'user-not-found') {
        errorMessage = 'Người dùng không tồn tại';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email không hợp lệ';
      }
      
      Get.snackbar(
        'Lỗi',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      LoggerService.e('Error sending verification email: $e');
      
      Get.snackbar(
        'Lỗi',
        'Không thể gửi email xác thực',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }
  
  // Resend verification email
  Future<void> resendOTP() async {
    if (!canResend.value) {
      LoggerService.w('Cannot resend yet, ${secondsRemaining.value} seconds remaining');
      return;
    }
    
    // Show loading indicator
    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.all(AppSpacing.s4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.s3),
          ),
          child: const CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
    );
    
    // Clear OTP fields (not needed for email link but keeping for UI)
    for (var controller in otpControllers) {
      controller.clear();
    }
    
    // Send email (timer will be started in sendVerificationEmail)
    await sendVerificationEmail();
    
    // Close loading dialog
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
  
  // Handle OTP input change (not used with email link verification)
  void onOTPChanged(int index, String value) {
    // Firebase uses email links, not OTP codes
    // This method is kept for UI compatibility
  }
  
  // Check verification status manually
  Future<void> checkVerificationStatus() async {
    isVerifying.value = true;
    setLoading();
    
    try {
      // Reload user to check verification status
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;
      
      if (user != null && user.emailVerified) {
        isEmailVerified.value = true;
        setSuccess();
        
        LoggerService.i('Email verified successfully');
        
        Get.snackbar(
          'Xác thực thành công',
          'Email của bạn đã được xác thực',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
        );
        
        // Navigate to home
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed(Routes.MAIN_NAVIGATION);
        
      } else {
        setError('Email chưa được xác thực');
        
        Get.snackbar(
          'Chưa xác thực',
          'Vui lòng kiểm tra email và nhấn vào link xác thực',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warning,
          colorText: AppColors.black,
        );
      }
      
    } catch (e) {
      LoggerService.e('Verification error: $e');
      setError('Không thể xác thực');
      
      Get.snackbar(
        'Lỗi',
        'Không thể kiểm tra trạng thái xác thực',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isVerifying.value = false;
      setIdle();
    }
  }
  
  // Keep verifyOTP for backward compatibility with UI
  Future<void> verifyOTP() async {
    await checkVerificationStatus();
  }
  
  // Navigate to login
  void navigateToLogin() {
    Get.offAllNamed(Routes.LOGIN);
  }
  
  // Close page
  void closePage() {
    // Sign out and go to login page
    _auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
  
  // Start checking email verification status periodically
  void startEmailVerificationCheck() {
    _verificationCheckTimer?.cancel(); // Cancel any existing timer
    _verificationCheckTimer = Timer.periodic(
      const Duration(seconds: 5), // Check every 5 seconds
      (timer) async {
        try {
          await _auth.currentUser?.reload();
          final user = _auth.currentUser;
          
          if (user != null && user.emailVerified) {
            isEmailVerified.value = true;
            timer.cancel();
            _timer?.cancel();
            
            LoggerService.i('Email verified successfully through background check');
            
            Get.snackbar(
              'Thành công',
              'Email của bạn đã được xác thực!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.success,
              colorText: AppColors.white,
            );
            
            // Navigate to home
            await Future.delayed(const Duration(seconds: 1));
            Get.offAllNamed(Routes.MAIN_NAVIGATION);
          }
        } catch (e) {
          LoggerService.e('Error checking email verification: $e');
        }
      },
    );
  }
  
  @override
  void onReady() {
    super.onReady();
    
    // Send verification email once when page is ready
    // This gives time for the UI to load
    Future.delayed(const Duration(milliseconds: 500), () {
      sendVerificationEmail();
    });
    
    // Start checking verification status
    startEmailVerificationCheck();
  }
}