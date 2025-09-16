import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/services/firebase_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/app/routes/app_pages.dart';

class LoginController extends BaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Form key for validation
  final formKey = GlobalKey<FormState>();
  
  // Password visibility
  final RxBool isPasswordVisible = false.obs;
  
  // Remember me
  final RxBool isRememberMe = false.obs;
  
  // Loading state for social login
  final RxBool isSocialLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Don't pre-fill email - better UX
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  // Toggle remember me
  void toggleRememberMe() {
    isRememberMe.value = !isRememberMe.value;
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
  
  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }
  
  // Login with email and password
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    setLoading();
    
    try {
      // Sign in with email and password
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      LoggerService.i('User logged in successfully: ${userCredential.user?.email}');
      
      // Check if email is verified
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        // Navigate to email verification screen
        Get.offNamed(Routes.VERIFY_EMAIL);
        
        Get.snackbar(
          'Xác thực email',
          'Vui lòng xác thực email của bạn',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        // Navigate to home screen
        Get.offAllNamed(Routes.HOME);
        
        Get.snackbar(
          'Đăng nhập thành công',
          'Chào mừng bạn trở lại!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
        );
      }
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Đã xảy ra lỗi';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Không tìm thấy tài khoản với email này';
          break;
        case 'wrong-password':
          errorMessage = 'Mật khẩu không chính xác';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          errorMessage = 'Tài khoản đã bị vô hiệu hóa';
          break;
        case 'too-many-requests':
          errorMessage = 'Quá nhiều lần thử. Vui lòng thử lại sau';
          break;
        default:
          errorMessage = e.message ?? 'Đã xảy ra lỗi';
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
      LoggerService.e('Login error: $e');
      setError('Đã xảy ra lỗi không xác định');
    } finally {
      setIdle();
    }
  }
  
  // Sign in with Google
  Future<void> signInWithGoogle() async {
    isSocialLoading.value = true;
    
    try {
      // Configure Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      // If user cancels
      if (googleUser == null) {
        isSocialLoading.value = false;
        return;
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      LoggerService.i('Google sign in successful: ${userCredential.user?.email}');
      
      // Navigate to home
      Get.offAllNamed(Routes.HOME);
      
      Get.snackbar(
        'Đăng nhập thành công',
        'Chào mừng ${userCredential.user?.displayName ?? 'bạn'}!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );
      
    } catch (e) {
      LoggerService.e('Google sign in error: $e');
      
      String errorMessage = 'Không thể đăng nhập với Google';
      if (e.toString().contains('network')) {
        errorMessage = 'Lỗi kết nối mạng';
      } else if (e.toString().contains('canceled')) {
        errorMessage = 'Đăng nhập đã bị hủy';
      }
      
      Get.snackbar(
        'Lỗi',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSocialLoading.value = false;
    }
  }
  
  // Navigate to register
  void navigateToRegister() {
    Get.offNamed(Routes.REGISTER);
  }
  
  // Navigate to forgot password
  void navigateToForgotPassword() {
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }
}