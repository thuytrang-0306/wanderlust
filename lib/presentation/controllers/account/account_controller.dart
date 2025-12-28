import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/services/user_profile_service.dart';
import 'package:wanderlust/data/services/business_service.dart';
import 'package:wanderlust/data/models/user_profile_model.dart';
import 'package:wanderlust/data/models/business_profile_model.dart';
import 'package:wanderlust/core/services/unified_image_service.dart';
import 'package:wanderlust/core/services/storage_service.dart';
import 'package:wanderlust/presentation/controllers/account/user_profile_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountController extends GetxController {
  final UserProfileService _profileService = Get.find<UserProfileService>();
  final UnifiedImageService _imageService = Get.find<UnifiedImageService>();
  BusinessService? _businessService;

  // User profile data - sync with UserProfileController
  final Rxn<UserProfileModel> userProfile = Rxn<UserProfileModel>();
  final Rxn<Uint8List> avatarBytes = Rxn<Uint8List>();
  final RxBool isLoadingAvatar = false.obs;
  
  // Business status
  final RxBool isBusinessUser = false.obs;
  final Rxn<BusinessProfileModel> businessProfile = Rxn<BusinessProfileModel>();

  // Getters for compatibility
  String get userName => userProfile.value?.displayName ?? 'User';
  String get userEmail => userProfile.value?.email ?? '';
  bool get hasAvatar => avatarBytes.value != null;

  // Settings
  final RxBool notificationsEnabled = true.obs;
  final RxString cacheSize = '0 MB'.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize BusinessService if available
    try {
      _businessService = Get.find<BusinessService>();
    } catch (e) {
      // BusinessService might not be registered yet
      Get.lazyPut(() => BusinessService());
      _businessService = Get.find<BusinessService>();
    }

    _loadUserData();
    _calculateCacheSize();

    // Stream profile changes for real-time updates
    _profileService.streamCurrentUserProfile().listen((profile) {
      if (profile != null) {
        userProfile.value = profile;
        _loadAvatarBytes(profile);
      }
    });
  }

  void _loadUserData() async {
    try {
      // Load profile from Firestore
      final profile = await _profileService.getCurrentUserProfile();

      if (profile != null) {
        userProfile.value = profile;
        _loadAvatarBytes(profile);
        
        // Check if user is business type
        isBusinessUser.value = await _profileService.isBusinessUser();
        
        // Load business profile if business user
        if (isBusinessUser.value) {
          await _loadBusinessProfile();
        }
      } else {
        // Initialize profile for new user
        await _profileService.initializeNewUserProfile();
        _loadUserData(); // Reload after initialization
      }

      // Load settings from local storage with defaults
      final savedNotifications = StorageService.to.read('notifications_enabled');
      if (savedNotifications != null) {
        notificationsEnabled.value = savedNotifications;
      } else {
        // Initialize default value on first use
        notificationsEnabled.value = true;
        StorageService.to.write('notifications_enabled', true);
      }
    } catch (e) {
      LoggerService.e('Error loading user data', error: e);
    }
  }

  void _loadAvatarBytes(UserProfileModel profile) {
    // Load avatar bytes if exists (prefer thumbnail for performance)
    if (profile.avatarThumbnail != null) {
      avatarBytes.value = _imageService.base64ToImage(profile.avatarThumbnail);
    } else if (profile.avatar != null) {
      avatarBytes.value = _imageService.base64ToImage(profile.avatar);
    } else {
      avatarBytes.value = null;
    }

    // Also update UserProfileController if it exists
    if (Get.isRegistered<UserProfileController>()) {
      final userProfileCtrl = Get.find<UserProfileController>();
      userProfileCtrl.avatarBytes.value = avatarBytes.value;
      userProfileCtrl.update();
    }
  }

  void changeAvatar() async {
    try {
      // Show source selection dialog
      final source = await _showImageSourceDialog();
      if (source == null) return;

      isLoadingAvatar.value = true;
      AppSnackbar.showInfo(message: 'Đang xử lý ảnh...');

      // Update avatar using UserProfileService
      final success = await _profileService.updateAvatar(source);

      if (success) {
        // Profile will be updated via stream
        AppSnackbar.showSuccess(message: 'Cập nhật ảnh đại diện thành công!');
      } else {
        AppSnackbar.showError(message: 'Không thể cập nhật ảnh đại diện');
      }
    } catch (e) {
      LoggerService.e('Error changing avatar', error: e);
      AppSnackbar.showError(message: 'Có lỗi xảy ra');
    } finally {
      isLoadingAvatar.value = false;
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.bottomSheet<ImageSource>(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chọn nguồn ảnh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Chụp ảnh'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Chọn từ thư viện'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    StorageService.to.write('notifications_enabled', value);
    AppSnackbar.showInfo(message: value ? 'Đã bật thông báo' : 'Đã tắt thông báo');
  }

  // Navigation methods
  void navigateToEditProfile() {
    Get.toNamed('/edit-profile');
  }

  void navigateToChangePassword() {
    Get.toNamed('/change-password');
  }

  void navigateToBookingHistory() {
    Get.toNamed('/booking-history');
  }

  void navigateToSavedPosts() {
    Get.toNamed('/saved-collections');
  }

  void navigateToHelp() {
    Get.toNamed('/help-support');
  }

  void navigateToPrivacy() {
    Get.toNamed('/privacy-policy');
  }

  void navigateToTerms() {
    Get.toNamed('/terms-of-service');
  }

  Future<void> navigateToAbout() async {
    String version = '1.0.0';
    String buildNumber = '2024.1';

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    } catch (e) {
      LoggerService.e('Error loading package info', error: e);
    }

    AppDialogs.showAlert(
      title: 'Về Wanderlust',
      message: '''Wanderlust - Ứng dụng du lịch hàng đầu Việt Nam

Phiên bản: $version
Build: $buildNumber

Được phát triển bởi đội ngũ Wanderlust Team với mục tiêu mang đến trải nghiệm du lịch tốt nhất cho người dùng Việt Nam.

© 2024 Wanderlust. All rights reserved.''',
    );
  }

  Future<void> sendFeedback() async {
    String version = '1.0.0';
    String buildNumber = '2024.1';

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    } catch (e) {
      LoggerService.e('Error loading package info', error: e);
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'nttt3690@gmail.com',
      queryParameters: {
        'subject': 'Feedback từ Wanderlust App',
        'body': '''Xin chào,

Tôi muốn gửi phản hồi về ứng dụng Wanderlust:

[Nhập nội dung phản hồi của bạn ở đây]

---
App Version: $version
Build: $buildNumber
Platform: ${Platform.operatingSystem}
''',
      },
    );

    try {
      // Không dùng canLaunchUrl vì nó không đáng tin cậy cho mailto
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Nếu không mở được, show dialog với email info
        _showEmailFallback();
      }
    } catch (e) {
      LoggerService.e('Error opening email app', error: e);
      // Show fallback dialog nếu không có email app
      _showEmailFallback();
    }
  }

  void _showEmailFallback() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email_outlined, color: Color(0xFF9455FD)),
            SizedBox(width: 8),
            Text('Gửi phản hồi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thiết bị chưa cài ứng dụng email.\nVui lòng gửi phản hồi trực tiếp qua:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF9455FD).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email, color: Color(0xFF9455FD), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      'nttt3690@gmail.com',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9455FD),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Subject: Feedback từ Wanderlust App',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void showLicenses() {
    Get.to(() => const LicensePage(
          applicationName: 'Wanderlust',
          applicationVersion: '1.0.0',
        ));
  }

  Future<void> _calculateCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int totalSize = 0;

      if (await tempDir.exists()) {
        await for (var entity in tempDir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      cacheSize.value = _formatBytes(totalSize);
    } catch (e) {
      cacheSize.value = '0 MB';
      LoggerService.e('Error calculating cache size', error: e);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> clearCache() async {
    final confirm = await AppDialogs.showConfirm(
      title: 'Xóa bộ nhớ cache',
      message: 'Bạn có chắc chắn muốn xóa ${cacheSize.value} bộ nhớ cache?',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
    );

    if (confirm) {
      try {
        AppDialogs.showLoading(message: 'Đang xóa cache...');

        // Clear cached network images
        await DefaultCacheManager().emptyCache();

        // Clear temporary directory
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          await for (var entity in tempDir.list()) {
            if (entity is File) {
              try {
                await entity.delete();
              } catch (e) {
                // Skip files that can't be deleted
              }
            } else if (entity is Directory) {
              try {
                await entity.delete(recursive: true);
              } catch (e) {
                // Skip directories that can't be deleted
              }
            }
          }
        }

        // Recalculate cache size
        await _calculateCacheSize();

        AppDialogs.hideLoading();
        AppSnackbar.showSuccess(message: 'Đã xóa bộ nhớ cache thành công');
      } catch (e) {
        AppDialogs.hideLoading();
        AppSnackbar.showError(message: 'Không thể xóa cache: $e');
        LoggerService.e('Error clearing cache', error: e);
      }
    }
  }

  Future<void> clearAllData() async {
    final confirm = await AppDialogs.showConfirm(
      title: 'Xóa tất cả dữ liệu',
      message: 'Hành động này sẽ xóa toàn bộ dữ liệu cục bộ và đăng xuất khỏi tài khoản. Bạn có chắc chắn?',
      confirmText: 'Xóa tất cả',
      cancelText: 'Hủy',
    );

    if (confirm) {
      try {
        AppDialogs.showLoading(message: 'Đang xóa dữ liệu...');

        // Clear all data and sign out
        await StorageService.to.clearAll();
        await FirebaseAuth.instance.signOut();
        _imageService.clearCache();

        AppDialogs.hideLoading();

        Get.offAllNamed(Routes.LOGIN);
        AppSnackbar.showInfo(message: 'Đã xóa tất cả dữ liệu');
      } catch (e) {
        AppDialogs.hideLoading();
        AppSnackbar.showError(message: 'Không thể xóa dữ liệu: $e');
        LoggerService.e('Error clearing all data', error: e);
      }
    }
  }
  
  // Business-related methods
  Future<void> _loadBusinessProfile() async {
    try {
      if (_businessService == null) return;
      
      await _businessService!.loadCurrentBusinessProfile();
      businessProfile.value = _businessService!.currentBusinessProfile.value;
    } catch (e) {
      LoggerService.e('Error loading business profile', error: e);
    }
  }
  
  void navigateToBusinessRegistration() {
    Get.toNamed('/business-registration');
  }
  
  void navigateToBusinessDashboard() {
    Get.toNamed('/business-dashboard');
  }

  void logout() async {
    // Show confirmation dialog
    final result = await AppDialogs.showConfirm(
      title: 'Đăng xuất',
      message: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
    );

    if (result == true) {
      try {
        AppDialogs.showLoading(message: 'Đang đăng xuất...');

        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        // Clear local storage
        await StorageService.to.clearAll();

        // Clear image cache
        _imageService.clearCache();

        AppDialogs.hideLoading();

        Get.offAllNamed(Routes.LOGIN);
        AppSnackbar.showSuccess(message: 'Đăng xuất thành công');
      } catch (e) {
        AppDialogs.hideLoading();
        LoggerService.e('Failed to logout', error: e);
        AppSnackbar.showError(message: 'Không thể đăng xuất');
      }
    }
  }
}
