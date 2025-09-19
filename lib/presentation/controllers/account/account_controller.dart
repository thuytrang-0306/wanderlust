import 'dart:typed_data';
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
  final RxBool darkModeEnabled = false.obs;

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
      
      // Load dark mode preference
      final savedDarkMode = StorageService.to.read('dark_mode_enabled');
      if (savedDarkMode != null) {
        darkModeEnabled.value = savedDarkMode;
      } else {
        darkModeEnabled.value = false;
        StorageService.to.write('dark_mode_enabled', false);
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

  void toggleDarkMode(bool value) {
    // TEMPORARILY DISABLED - Need proper dark theme design
    AppSnackbar.showInfo(
      message: 'Chế độ tối đang được phát triển. Sẽ sớm ra mắt!',
    );
    
    // Reset to false to keep switch in correct state
    darkModeEnabled.value = false;
    return;
    
    // Keep code for future implementation
    /*
    darkModeEnabled.value = value;
    StorageService.to.write('dark_mode_enabled', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    AppSnackbar.showInfo(message: value ? 'Đã bật chế độ tối' : 'Đã tắt chế độ tối');
    */
  }

  void navigateToProfile() {
    Get.toNamed('/user-profile');
  }

  void navigateToChangePassword() {
    Get.toNamed('/change-password');
  }

  void navigateToSavedPosts() {
    Get.toNamed('/saved-collections');
  }

  void navigateToTripHistory() {
    Get.toNamed('/my-trips');
  }

  void navigateToFavorites() {
    AppSnackbar.showInfo(message: 'Tính năng đang phát triển');
  }

  void navigateToLanguage() {
    AppSnackbar.showInfo(message: 'Tính năng đang phát triển');
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

  void navigateToAbout() {
    AppDialogs.showAlert(
      title: 'Về Wanderlust',
      message: '''Wanderlust - Ứng dụng du lịch hàng đầu Việt Nam
      
Phiên bản: 1.0.0
Build: 2024.1

Được phát triển bởi đội ngũ Wanderlust Team với mục tiêu mang đến trải nghiệm du lịch tốt nhất cho người dùng Việt Nam.

© 2024 Wanderlust. All rights reserved.''',
    );
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
