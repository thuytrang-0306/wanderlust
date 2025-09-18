import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/utils/logger_utils.dart';
import 'package:wanderlust/data/models/user_model.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable user
  final Rxn<User> _firebaseUser = Rxn<User>();
  final Rxn<UserModel> _userModel = Rxn<UserModel>();

  User? get currentUser => _firebaseUser.value;
  UserModel? get userModel => _userModel.value;
  bool get isAuthenticated => currentUser != null;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _firebaseUser.bindStream(_auth.authStateChanges());

    // When auth state changes, fetch user data
    ever(_firebaseUser, _setUserModel);
  }

  // Fetch user model from Firestore
  void _setUserModel(User? user) async {
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _userModel.value = UserModel.fromJson({'id': doc.id, ...doc.data()!});
        }
      } catch (e) {
        LoggerUtils.logErrorSafely('Error fetching user model', e);
      }
    } else {
      _userModel.value = null;
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Create auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(fullName);

        // Create user document in Firestore
        await _createUserDocument(uid: credential.user!.uid, email: email, fullName: fullName);

        // Send verification email
        await credential.user!.sendEmailVerification();

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      LoggerService.e('Sign up error', error: e);
      Get.snackbar('Error', 'Đăng ký thất bại. Vui lòng thử lại.');
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmail({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        // Update last active
        await _updateLastActive(credential.user!.uid);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      LoggerService.e('Sign in error', error: e);
      Get.snackbar('Error', 'Đăng nhập thất bại. Vui lòng thử lại.');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      LoggerService.e('Sign out error', error: e);
      Get.snackbar('Error', 'Không thể đăng xuất. Vui lòng thử lại.');
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      LoggerService.e('Reset password error', error: e);
      Get.snackbar('Error', 'Không thể gửi email reset. Vui lòng thử lại.');
      return false;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String fullName,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(uid);

      final userData = {
        'uid': uid,
        'email': email,
        'displayName': fullName,
        'photoURL': '',
        'phoneNumber': '',
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
      };

      await userDoc.set(userData);
    } catch (e) {
      LoggerUtils.logErrorSafely('Error creating user document', e);
    }
  }

  // Update last active timestamp
  Future<void> _updateLastActive(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggerService.e('Error updating last active', error: e);
    }
  }

  // Handle Firebase Auth exceptions
  void _handleAuthException(FirebaseAuthException e) {
    String message = '';

    switch (e.code) {
      case 'weak-password':
        message = 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
        break;
      case 'email-already-in-use':
        message = 'Email này đã được sử dụng. Vui lòng dùng email khác.';
        break;
      case 'invalid-email':
        message = 'Email không hợp lệ.';
        break;
      case 'user-not-found':
        message = 'Không tìm thấy tài khoản với email này.';
        break;
      case 'wrong-password':
        message = 'Mật khẩu không chính xác.';
        break;
      case 'user-disabled':
        message = 'Tài khoản này đã bị vô hiệu hóa.';
        break;
      case 'too-many-requests':
        message = 'Quá nhiều lần thử. Vui lòng thử lại sau.';
        break;
      default:
        message = 'Đã xảy ra lỗi: ${e.message}';
    }

    Get.snackbar('Lỗi', message);
    LoggerService.e('Auth exception: ${e.code}', error: e.message);
  }
}
