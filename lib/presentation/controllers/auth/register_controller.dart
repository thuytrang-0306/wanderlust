import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/app/routes/app_pages.dart';

class RegisterController extends BaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Password visibility
  final RxBool isPasswordVisible = false.obs;

  // Terms acceptance
  final RxBool isTermsAccepted = false.obs;

  // Loading state for social login
  final RxBool isSocialLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên của bạn';
    }
    if (value.length < 2) {
      return 'Tên phải có ít nhất 2 ký tự';
    }
    return null;
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

  // Register with email and password
  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setLoading();

    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(nameController.text.trim());

      // Create user document in Firestore
      await _createUserDocument(userCredential.user!);

      // Don't send email verification here - let VerifyEmailController handle it
      // This prevents duplicate sends and rate limiting

      LoggerService.i('User registered successfully: ${userCredential.user?.email}');

      // Navigate to email verification screen
      Get.offNamed(Routes.VERIFY_EMAIL);

      AppSnackbar.showSuccess(
        message: 'Vui lòng kiểm tra email để xác thực tài khoản',
        title: 'Đăng ký thành công',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Đã xảy ra lỗi';

      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Mật khẩu quá yếu';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email đã được sử dụng';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ';
          break;
        default:
          errorMessage = e.message ?? 'Đã xảy ra lỗi';
      }

      setError(errorMessage);
      AppSnackbar.showError(message: errorMessage);
    } catch (e) {
      LoggerService.e('Register error: $e');
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
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

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

      // Navigate to main navigation (user is already registered via Google)
      Get.offAllNamed(Routes.MAIN_NAVIGATION);

      Get.snackbar(
        'Đăng ký thành công',
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

      AppSnackbar.showError(message: errorMessage);
    } finally {
      isSocialLoading.value = false;
    }
  }

  // Navigate to login
  void navigateToLogin() {
    Get.offNamed(Routes.LOGIN);
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      // Check if user document already exists
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        // Create new user document
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? nameController.text.trim(),
          'photoURL': user.photoURL ?? '',
          'phoneNumber': user.phoneNumber ?? '',
          'bio': '',
          'address': '',
          'city': '',
          'country': 'Vietnam',
          'totalTrips': 0,
          'totalBookings': 0,
          'totalPosts': 0,
          'totalFollowers': 0,
          'totalFollowing': 0,
          'language': 'vi',
          'currency': 'VND',
          'notificationSettings': {'push': true, 'email': true, 'sms': false, 'marketing': false},
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
          'isVerified': false,
          'role': 'user',
        });

        LoggerService.i('User document created in Firestore for ${user.email}');
      }
    } catch (e) {
      LoggerService.e('Error creating user document: $e');
      // Don't throw - user can still use the app even if Firestore fails
    }
  }
}
