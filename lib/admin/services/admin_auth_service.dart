import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/core/utils/logger_service.dart';

class AdminAuthService extends GetxService {
  static AdminAuthService get to => Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isAdmin = false.obs;
  final RxString _adminRole = ''.obs; // 'super_admin', 'moderator', 'analyst'
  
  User? get currentUser => _currentUser.value;
  bool get isAdmin => _isAdmin.value;
  String get adminRole => _adminRole.value;
  bool get isLoggedIn => currentUser != null && isAdmin;
  
  @override
  void onInit() {
    super.onInit();
    _currentUser.bindStream(_auth.authStateChanges());
    ever(_currentUser, _onUserChanged);
  }
  
  void _onUserChanged(User? user) async {
    if (user != null) {
      await _checkAdminPermissions(user.uid);
    } else {
      _isAdmin.value = false;
      _adminRole.value = '';
    }
  }
  
  Future<void> _checkAdminPermissions(String userId) async {
    try {
      final adminDoc = await _firestore
          .collection('admins')
          .doc(userId)
          .get();
          
      if (adminDoc.exists) {
        _isAdmin.value = true;
        _adminRole.value = adminDoc.data()?['role'] ?? 'moderator';
        LoggerService.i('Admin authenticated: ${_adminRole.value}');
      } else {
        _isAdmin.value = false;
        _adminRole.value = '';
        LoggerService.w('User is not an admin');
      }
    } catch (e) {
      LoggerService.e('Error checking admin permissions', error: e);
      _isAdmin.value = false;
      _adminRole.value = '';
    }
  }
  
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _checkAdminPermissions(credential.user!.uid);
        return _isAdmin.value;
      }
      return false;
    } catch (e) {
      LoggerService.e('Admin login failed', error: e);
      return false;
    }
  }
  
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _isAdmin.value = false;
      _adminRole.value = '';
    } catch (e) {
      LoggerService.e('Admin logout failed', error: e);
    }
  }
  
  bool hasPermission(String permission) {
    if (!isAdmin) return false;
    
    // Super admin has all permissions
    if (_adminRole.value == 'super_admin') return true;
    
    // Define role-based permissions
    final rolePermissions = {
      'moderator': [
        'view_users',
        'view_businesses',
        'moderate_content',
        'view_reports',
      ],
      'analyst': [
        'view_analytics',
        'view_reports',
        'export_data',
      ],
      'business_manager': [
        'view_businesses',
        'approve_businesses',
        'manage_listings',
      ],
    };
    
    final permissions = rolePermissions[_adminRole.value] ?? [];
    return permissions.contains(permission);
  }
  
  // Create admin user (only super_admin can do this)
  Future<bool> createAdminUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    if (!hasPermission('create_admin')) return false;
    
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Add to admins collection
        await _firestore.collection('admins').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': currentUser?.uid,
          'isActive': true,
        });
        
        LoggerService.i('Admin user created: $email with role: $role');
        return true;
      }
      return false;
    } catch (e) {
      LoggerService.e('Failed to create admin user', error: e);
      return false;
    }
  }
}