import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/admin/services/admin_auth_service.dart';
import 'package:wanderlust/shared/core/utils/logger_service.dart';
import 'package:wanderlust/shared/core/widgets/app_snackbar.dart';

class AdminSettingsController extends GetxController {
  final AdminAuthService _authService = Get.find<AdminAuthService>();
  
  // UI State
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString currentView = 'profile'.obs; // profile, password, history, templates, system, security
  
  // Login History
  final RxList<Map<String, dynamic>> loginHistory = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingHistory = false.obs;
  
  // Email Templates
  final RxMap<String, dynamic> emailTemplates = <String, dynamic>{}.obs;
  final RxBool isLoadingTemplates = false.obs;
  
  // System Settings
  final RxMap<String, dynamic> systemSettings = <String, dynamic>{}.obs;
  final RxBool isLoadingSystemSettings = false.obs;
  
  // Password Change
  final RxBool isChangingPassword = false.obs;
  final RxBool showCurrentPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  
  // 2FA Settings
  final RxBool twoFactorEnabled = false.obs;
  final RxBool isEnabling2FA = false.obs;
  final RxString qrCodeData = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    LoggerService.i('AdminSettingsController initialized');
  }
  
  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadLoginHistory(),
        loadEmailTemplates(),
        loadSystemSettings(),
        check2FAStatus(),
      ]);
    } catch (e) {
      LoggerService.e('Error loading initial settings data', error: e);
    } finally {
      isLoading.value = false;
    }
  }
  
  // ============ PASSWORD MANAGEMENT ============
  
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      AppSnackbar.showError(message: 'New passwords do not match');
      return false;
    }
    
    if (newPassword.length < 8) {
      AppSnackbar.showError(message: 'Password must be at least 8 characters');
      return false;
    }
    
    try {
      isChangingPassword.value = true;
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppSnackbar.showError(message: 'No authenticated user found');
        return false;
      }
      
      // Re-authenticate with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Change password
      await user.updatePassword(newPassword);
      
      // Log the password change
      await _logAdminActivity('password_changed', {
        'timestamp': FieldValue.serverTimestamp(),
        'adminId': _authService.currentAdmin?.id,
        'adminEmail': user.email,
      });
      
      AppSnackbar.showSuccess(message: 'Password changed successfully');
      LoggerService.i('Admin password changed successfully');
      return true;
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to change password';
      
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Current password is incorrect';
          break;
        case 'weak-password':
          errorMessage = 'New password is too weak';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please log out and log in again before changing password';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }
      
      AppSnackbar.showError(message: errorMessage);
      LoggerService.e('Password change failed', error: e);
      return false;
    } catch (e) {
      AppSnackbar.showError(message: 'An unexpected error occurred');
      LoggerService.e('Unexpected error during password change', error: e);
      return false;
    } finally {
      isChangingPassword.value = false;
    }
  }
  
  // ============ LOGIN HISTORY ============
  
  Future<void> loadLoginHistory() async {
    try {
      isLoadingHistory.value = true;
      
      final adminId = _authService.currentAdmin?.id;
      if (adminId == null) return;
      
      final snapshot = await FirebaseFirestore.instance
          .collection('admin_activities')
          .where('adminId', isEqualTo: adminId)
          .where('action', isEqualTo: 'login')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      final history = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'timestamp': data['timestamp'],
          'ipAddress': data['ipAddress'] ?? 'Unknown',
          'userAgent': data['userAgent'] ?? 'Unknown',
          'location': data['location'] ?? 'Unknown',
          'device': _parseDeviceFromUserAgent(data['userAgent'] ?? ''),
          'success': data['success'] ?? true,
        };
      }).toList();
      
      loginHistory.value = history;
      LoggerService.d('Loaded ${history.length} login history entries');
      
    } catch (e) {
      LoggerService.e('Error loading login history', error: e);
      loginHistory.value = [];
    } finally {
      isLoadingHistory.value = false;
    }
  }
  
  String _parseDeviceFromUserAgent(String userAgent) {
    if (userAgent.contains('Mobile')) return 'Mobile';
    if (userAgent.contains('Tablet')) return 'Tablet';
    if (userAgent.contains('Chrome')) return 'Chrome Browser';
    if (userAgent.contains('Firefox')) return 'Firefox Browser';
    if (userAgent.contains('Safari')) return 'Safari Browser';
    return 'Desktop';
  }
  
  Future<void> clearLoginHistory() async {
    try {
      final adminId = _authService.currentAdmin?.id;
      if (adminId == null) return;
      
      final batch = FirebaseFirestore.instance.batch();
      
      final snapshot = await FirebaseFirestore.instance
          .collection('admin_activities')
          .where('adminId', isEqualTo: adminId)
          .where('action', isEqualTo: 'login')
          .get();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      loginHistory.clear();
      
      AppSnackbar.showSuccess(message: 'Login history cleared');
      LoggerService.i('Admin login history cleared');
      
    } catch (e) {
      AppSnackbar.showError(message: 'Failed to clear login history');
      LoggerService.e('Error clearing login history', error: e);
    }
  }
  
  // ============ EMAIL TEMPLATES ============
  
  Future<void> loadEmailTemplates() async {
    try {
      isLoadingTemplates.value = true;
      
      final doc = await FirebaseFirestore.instance
          .collection('admin_settings')
          .doc('email_templates')
          .get();
      
      if (doc.exists) {
        emailTemplates.value = doc.data() ?? {};
      } else {
        // Initialize with default templates
        emailTemplates.value = _getDefaultEmailTemplates();
        await saveEmailTemplates();
      }
      
      LoggerService.d('Email templates loaded: ${emailTemplates.keys.length} templates');
      
    } catch (e) {
      LoggerService.e('Error loading email templates', error: e);
      emailTemplates.value = _getDefaultEmailTemplates();
    } finally {
      isLoadingTemplates.value = false;
    }
  }
  
  Map<String, dynamic> _getDefaultEmailTemplates() {
    return {
      'user_welcome': {
        'subject': 'Welcome to Wanderlust!',
        'body': 'Welcome {{userName}} to Wanderlust travel platform. We\'re excited to have you on board!',
        'enabled': true,
      },
      'business_approved': {
        'subject': 'Business Verification Approved',
        'body': 'Congratulations {{businessName}}! Your business has been verified and approved.',
        'enabled': true,
      },
      'business_rejected': {
        'subject': 'Business Verification Update',
        'body': 'Hello {{businessName}}, we need additional information for your verification. Reason: {{rejectionReason}}',
        'enabled': true,
      },
      'content_approved': {
        'subject': 'Content Approved',
        'body': 'Your content "{{contentTitle}}" has been approved and is now live.',
        'enabled': true,
      },
      'content_rejected': {
        'subject': 'Content Review Update',
        'body': 'Your content "{{contentTitle}}" needs revision. Reason: {{rejectionReason}}',
        'enabled': true,
      },
      'account_suspended': {
        'subject': 'Account Suspension Notice',
        'body': 'Your account has been suspended. Reason: {{suspensionReason}}. Contact support for assistance.',
        'enabled': true,
      },
    };
  }
  
  Future<void> saveEmailTemplates() async {
    try {
      isSaving.value = true;
      
      await FirebaseFirestore.instance
          .collection('admin_settings')
          .doc('email_templates')
          .set(emailTemplates.value, SetOptions(merge: true));
      
      await _logAdminActivity('email_templates_updated', {
        'templatesCount': emailTemplates.keys.length,
      });
      
      AppSnackbar.showSuccess(message: 'Email templates saved successfully');
      LoggerService.i('Email templates saved');
      
    } catch (e) {
      AppSnackbar.showError(message: 'Failed to save email templates');
      LoggerService.e('Error saving email templates', error: e);
    } finally {
      isSaving.value = false;
    }
  }
  
  void updateEmailTemplate(String templateKey, Map<String, dynamic> template) {
    emailTemplates[templateKey] = template;
  }
  
  // ============ SYSTEM SETTINGS ============
  
  Future<void> loadSystemSettings() async {
    try {
      isLoadingSystemSettings.value = true;
      
      final doc = await FirebaseFirestore.instance
          .collection('admin_settings')
          .doc('system')
          .get();
      
      if (doc.exists) {
        systemSettings.value = doc.data() ?? {};
      } else {
        // Initialize with default settings
        systemSettings.value = _getDefaultSystemSettings();
        await saveSystemSettings();
      }
      
      LoggerService.d('System settings loaded');
      
    } catch (e) {
      LoggerService.e('Error loading system settings', error: e);
      systemSettings.value = _getDefaultSystemSettings();
    } finally {
      isLoadingSystemSettings.value = false;
    }
  }
  
  Map<String, dynamic> _getDefaultSystemSettings() {
    return {
      'userManagement': {
        'autoApproveUsers': true,
        'requireEmailVerification': true,
        'maxLoginAttempts': 5,
        'sessionTimeout': 24, // hours
      },
      'businessVerification': {
        'autoApprove': false,
        'requireDocuments': true,
        'verificationTimeout': 7, // days
        'minimumRating': 4.0,
      },
      'contentModeration': {
        'autoApprove': false,
        'requireReview': true,
        'flaggedContentThreshold': 3,
        'aiModerationEnabled': false,
      },
      'notifications': {
        'emailNotifications': true,
        'pushNotifications': true,
        'smsNotifications': false,
        'adminNotifications': true,
      },
      'security': {
        'passwordMinLength': 8,
        'requireSpecialChars': true,
        'sessionTimeout': 12, // hours
        'maxConcurrentSessions': 3,
      },
    };
  }
  
  Future<void> saveSystemSettings() async {
    try {
      isSaving.value = true;
      
      await FirebaseFirestore.instance
          .collection('admin_settings')
          .doc('system')
          .set(systemSettings.value, SetOptions(merge: true));
      
      await _logAdminActivity('system_settings_updated', {
        'settings': systemSettings.keys.toList(),
      });
      
      AppSnackbar.showSuccess(message: 'System settings saved successfully');
      LoggerService.i('System settings saved');
      
    } catch (e) {
      AppSnackbar.showError(message: 'Failed to save system settings');
      LoggerService.e('Error saving system settings', error: e);
    } finally {
      isSaving.value = false;
    }
  }
  
  void updateSystemSetting(String category, String key, dynamic value) {
    if (systemSettings[category] == null) {
      systemSettings[category] = <String, dynamic>{};
    }
    systemSettings[category][key] = value;
  }
  
  // ============ TWO-FACTOR AUTHENTICATION ============
  
  Future<void> check2FAStatus() async {
    try {
      final adminId = _authService.currentAdmin?.id;
      if (adminId == null) return;
      
      final doc = await FirebaseFirestore.instance
          .collection('admin_2fa')
          .doc(adminId)
          .get();
      
      twoFactorEnabled.value = doc.exists && (doc.data()?['enabled'] == true);
      
    } catch (e) {
      LoggerService.e('Error checking 2FA status', error: e);
    }
  }
  
  Future<void> enable2FA() async {
    try {
      isEnabling2FA.value = true;
      
      final adminId = _authService.currentAdmin?.id;
      if (adminId == null) {
        AppSnackbar.showError(message: 'Admin ID not found');
        return;
      }
      
      // Generate secret key and QR code data
      final secretKey = _generateSecretKey();
      final issuer = 'Wanderlust Admin';
      final accountName = _authService.currentAdmin?.email ?? 'admin';
      
      qrCodeData.value = 'otpauth://totp/$issuer:$accountName?secret=$secretKey&issuer=$issuer';
      
      // Save 2FA settings (but don't enable until verified)
      await FirebaseFirestore.instance
          .collection('admin_2fa')
          .doc(adminId)
          .set({
            'secretKey': secretKey,
            'enabled': false,
            'setupDate': FieldValue.serverTimestamp(),
            'adminId': adminId,
          });
      
      LoggerService.i('2FA setup initiated');
      
    } catch (e) {
      AppSnackbar.showError(message: 'Failed to setup 2FA');
      LoggerService.e('Error setting up 2FA', error: e);
    } finally {
      isEnabling2FA.value = false;
    }
  }
  
  Future<bool> verify2FAAndEnable(String verificationCode) async {
    try {
      final adminId = _authService.currentAdmin?.id;
      if (adminId == null) return false;
      
      // In a real implementation, you would verify the TOTP code here
      // For now, we'll simulate verification
      if (verificationCode.length != 6) {
        AppSnackbar.showError(message: 'Invalid verification code');
        return false;
      }
      
      // Enable 2FA
      await FirebaseFirestore.instance
          .collection('admin_2fa')
          .doc(adminId)
          .update({
            'enabled': true,
            'enabledDate': FieldValue.serverTimestamp(),
          });
      
      twoFactorEnabled.value = true;
      
      await _logAdminActivity('2fa_enabled', {
        'adminId': adminId,
      });
      
      AppSnackbar.showSuccess(message: '2FA enabled successfully');
      LoggerService.i('2FA enabled for admin');
      return true;
      
    } catch (e) {
      AppSnackbar.showError(message: 'Failed to enable 2FA');
      LoggerService.e('Error enabling 2FA', error: e);
      return false;
    }
  }
  
  Future<void> disable2FA() async {
    try {
      final adminId = _authService.currentAdmin?.id;
      if (adminId == null) return;
      
      await FirebaseFirestore.instance
          .collection('admin_2fa')
          .doc(adminId)
          .update({
            'enabled': false,
            'disabledDate': FieldValue.serverTimestamp(),
          });
      
      twoFactorEnabled.value = false;
      qrCodeData.value = '';
      
      await _logAdminActivity('2fa_disabled', {
        'adminId': adminId,
      });
      
      AppSnackbar.showSuccess(message: '2FA disabled successfully');
      LoggerService.i('2FA disabled for admin');
      
    } catch (e) {
      AppSnackbar.showError(message: 'Failed to disable 2FA');
      LoggerService.e('Error disabling 2FA', error: e);
    }
  }
  
  String _generateSecretKey() {
    // Generate a random 32-character base32 secret key
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = DateTime.now().millisecondsSinceEpoch;
    String secret = '';
    
    for (int i = 0; i < 32; i++) {
      secret += chars[(random + i) % chars.length];
    }
    
    return secret;
  }
  
  // ============ ADMIN ACTIVITY LOGGING ============
  
  Future<void> _logAdminActivity(String action, Map<String, dynamic> details) async {
    try {
      await FirebaseFirestore.instance
          .collection('admin_activities')
          .add({
            'action': action,
            'adminId': _authService.currentAdmin?.id,
            'adminEmail': _authService.currentAdmin?.email,
            'timestamp': FieldValue.serverTimestamp(),
            'details': details,
          });
    } catch (e) {
      LoggerService.w('Failed to log admin activity', error: e);
    }
  }
  
  // ============ UI HELPERS ============
  
  void changeView(String view) {
    currentView.value = view;
  }
  
  void togglePasswordVisibility(String field) {
    switch (field) {
      case 'current':
        showCurrentPassword.value = !showCurrentPassword.value;
        break;
      case 'new':
        showNewPassword.value = !showNewPassword.value;
        break;
      case 'confirm':
        showConfirmPassword.value = !showConfirmPassword.value;
        break;
    }
  }
  
  Future<void> refreshAllData() async {
    await loadInitialData();
  }
  
  @override
  void onClose() {
    LoggerService.i('AdminSettingsController disposed');
    super.onClose();
  }
}