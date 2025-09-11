import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/presentation/controllers/app_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppController _appController = Get.find<AppController>();
  
  Rxn<User> firebaseUser = Rxn<User>();
  RxBool isAuthenticated = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }
  
  void _setInitialScreen(User? user) {
    if (user == null) {
      isAuthenticated.value = false;
      Get.offAllNamed(Routes.LOGIN);
    } else {
      isAuthenticated.value = true;
      Get.offAllNamed(Routes.MAIN);
    }
  }
  
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _appController.showLoading();
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.sendEmailVerification();
      
      _appController.hideLoading();
      _appController.showSuccess('Account created successfully! Please verify your email.');
      
      Get.toNamed(Routes.VERIFY_EMAIL);
    } on FirebaseAuthException catch (e) {
      _appController.hideLoading();
      _appController.showError(e.message ?? 'Sign up failed');
    }
  }
  
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _appController.showLoading();
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _appController.hideLoading();
    } on FirebaseAuthException catch (e) {
      _appController.hideLoading();
      _appController.showError(e.message ?? 'Sign in failed');
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _appController.showError('Sign out failed');
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      _appController.showLoading();
      
      await _auth.sendPasswordResetEmail(email: email);
      
      _appController.hideLoading();
      _appController.showSuccess('Password reset email sent!');
      
      Get.back();
    } on FirebaseAuthException catch (e) {
      _appController.hideLoading();
      _appController.showError(e.message ?? 'Password reset failed');
    }
  }
  
  User? get currentUser => _auth.currentUser;
}