import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/core/utils/logger_service.dart';
import '../../shared/core/models/admin_model.dart';

class AdminAuthService extends GetxService {
  static AdminAuthService get to => Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final Rx<User?> _currentUser = Rx<User?>(null);
  final Rx<AdminModel?> _currentAdmin = Rx<AdminModel?>(null);
  final RxBool _isAdmin = false.obs;
  final RxString _adminRole = ''.obs;
  final RxBool _isLoading = false.obs;
  
  User? get currentUser => _currentUser.value;
  AdminModel? get currentAdmin => _currentAdmin.value;
  bool get isAdmin => _isAdmin.value;
  String get adminRole => _adminRole.value;
  bool get isLoggedIn => currentUser != null && isAdmin;
  bool get isLoading => _isLoading.value;
  
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
      _isLoading.value = true;
      LoggerService.d('Checking admin permissions for user: $userId');
      
      final adminDoc = await _firestore
          .collection('admins')
          .doc(userId)
          .get();
          
      if (adminDoc.exists && adminDoc.data()?['isActive'] == true) {
        final admin = AdminModel.fromFirestore(adminDoc);
        _currentAdmin.value = admin;
        _isAdmin.value = true;
        _adminRole.value = admin.role;
        
        // Update last login timestamp
        await _updateLastLogin(userId);
        
        LoggerService.i('Admin authenticated: ${admin.name} (${admin.role})');
      } else {
        _currentAdmin.value = null;
        _isAdmin.value = false;
        _adminRole.value = '';
        LoggerService.w('User is not an admin or is inactive');
      }
    } catch (e, stackTrace) {
      LoggerService.e('Error checking admin permissions', error: e, stackTrace: stackTrace);
      _currentAdmin.value = null;
      _isAdmin.value = false;
      _adminRole.value = '';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore.collection('admins').doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggerService.w('Failed to update last login timestamp', error: e);
    }
  }
  
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      _isLoading.value = true;
      LoggerService.i('Admin login attempt: $email');
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _checkAdminPermissions(credential.user!.uid);
        
        if (_isAdmin.value) {
          LoggerService.i('Admin login successful: ${_currentAdmin.value?.name}');
          await _logAdminActivity('login', {'email': email});
          return true;
        } else {
          // Sign out if user is not an admin
          await _auth.signOut();
          LoggerService.w('Login denied: User is not an admin');
          return false;
        }
      }
      return false;
    } catch (e, stackTrace) {
      LoggerService.e('Admin login failed', error: e, stackTrace: stackTrace);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    try {
      LoggerService.i('Admin logout: ${_currentAdmin.value?.name}');
      await _logAdminActivity('logout', {});
      
      await _auth.signOut();
      _currentAdmin.value = null;
      _isAdmin.value = false;
      _adminRole.value = '';
      
      LoggerService.i('Admin logout successful');
    } catch (e, stackTrace) {
      LoggerService.e('Admin logout failed', error: e, stackTrace: stackTrace);
    }
  }
  
  bool hasPermission(String permission) {
    if (!isAdmin || _currentAdmin.value == null) return false;
    return _currentAdmin.value!.hasBasePermission(permission);
  }

  // Get all permissions for current admin
  List<String> getAllPermissions() {
    if (!isAdmin || _currentAdmin.value == null) return [];
    return _currentAdmin.value!.getAllPermissions();
  }

  // Check multiple permissions at once
  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((permission) => hasPermission(permission));
  }

  bool hasAllPermissions(List<String> permissions) {
    return permissions.every((permission) => hasPermission(permission));
  }
  
  // Create admin user (only super_admin can do this)
  Future<bool> createAdminUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
  }) async {
    if (!hasPermission('create_admin')) {
      LoggerService.w('Permission denied: create_admin');
      return false;
    }
    
    try {
      LoggerService.i('Creating admin user: $email with role: $role');
      
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
          'phone': phone,
          'role': role,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': currentUser?.uid,
          'permissions': null, // Will use default role permissions
          'metadata': {
            'createdByName': _currentAdmin.value?.name,
            'createdByRole': _currentAdmin.value?.role,
          },
        });
        
        // Log admin activity
        await _logAdminActivity('create_admin', {
          'targetEmail': email,
          'targetRole': role,
          'targetName': name,
        });
        
        LoggerService.i('Admin user created successfully: $email');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      LoggerService.e('Failed to create admin user', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Update admin user
  Future<bool> updateAdminUser(String adminId, Map<String, dynamic> updates) async {
    if (!hasPermission('edit_admin')) {
      LoggerService.w('Permission denied: edit_admin');
      return false;
    }

    try {
      LoggerService.i('Updating admin user: $adminId');
      
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('admins').doc(adminId).update(updates);
      
      await _logAdminActivity('update_admin', {
        'targetAdminId': adminId,
        'updates': updates.keys.toList(),
      });
      
      LoggerService.i('Admin user updated successfully');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Failed to update admin user', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Deactivate admin user
  Future<bool> deactivateAdminUser(String adminId) async {
    if (!hasPermission('delete_admin')) {
      LoggerService.w('Permission denied: delete_admin');
      return false;
    }

    try {
      LoggerService.i('Deactivating admin user: $adminId');
      
      await _firestore.collection('admins').doc(adminId).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
        'deactivatedBy': currentUser?.uid,
      });
      
      await _logAdminActivity('deactivate_admin', {
        'targetAdminId': adminId,
      });
      
      LoggerService.i('Admin user deactivated successfully');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Failed to deactivate admin user', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Get all admin users
  Future<List<AdminModel>> getAllAdmins() async {
    if (!hasPermission('view_admins')) {
      LoggerService.w('Permission denied: view_admins');
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('admins')
          .orderBy('createdAt', descending: true)
          .get();
      
      final admins = snapshot.docs
          .map((doc) => AdminModel.fromFirestore(doc))
          .toList();
      
      LoggerService.d('Loaded ${admins.length} admin users');
      return admins;
    } catch (e, stackTrace) {
      LoggerService.e('Failed to load admin users', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Log admin activity
  Future<void> _logAdminActivity(String action, Map<String, dynamic> details) async {
    try {
      if (_currentAdmin.value == null) return;
      
      await _firestore.collection('admin_activities').add({
        'adminId': currentUser?.uid,
        'adminName': _currentAdmin.value!.name,
        'adminRole': _currentAdmin.value!.role,
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': null, // TODO: Get client IP if needed
        'userAgent': null, // TODO: Get user agent if needed
      });
      
      LoggerService.d('Admin activity logged: $action');
    } catch (e) {
      LoggerService.w('Failed to log admin activity', error: e);
    }
  }

  // Get admin activity logs
  Future<List<Map<String, dynamic>>> getAdminActivityLogs({
    int limit = 50,
    String? adminId,
  }) async {
    if (!hasPermission('view_logs')) {
      LoggerService.w('Permission denied: view_logs');
      return [];
    }

    try {
      Query query = _firestore
          .collection('admin_activities')
          .orderBy('timestamp', descending: true)
          .limit(limit);
      
      if (adminId != null) {
        query = query.where('adminId', isEqualTo: adminId);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e, stackTrace) {
      LoggerService.e('Failed to load admin activity logs', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Validate admin setup (for initial setup)
  Future<bool> isAdminSetupRequired() async {
    try {
      final snapshot = await _firestore
          .collection('admins')
          .where('role', isEqualTo: 'super_admin')
          .limit(1)
          .get();
      
      return snapshot.docs.isEmpty;
    } catch (e) {
      LoggerService.e('Failed to check admin setup', error: e);
      return true; // Assume setup required if check fails
    }
  }

  // Create initial super admin
  Future<bool> createInitialSuperAdmin({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      LoggerService.i('Creating initial super admin: $email');
      
      // Check if super admin already exists
      final existingSuperAdmin = await _firestore
          .collection('admins')
          .where('role', isEqualTo: 'super_admin')
          .limit(1)
          .get();
      
      if (existingSuperAdmin.docs.isNotEmpty) {
        LoggerService.w('Super admin already exists');
        return false;
      }
      
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
          'role': 'super_admin',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': null, // Initial super admin has no creator
          'permissions': null, // Will use default super_admin permissions
          'metadata': {
            'initialSetup': true,
          },
        });
        
        LoggerService.i('Initial super admin created successfully');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      LoggerService.e('Failed to create initial super admin', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}