import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/data/services/user_profile_service.dart';
import 'package:wanderlust/data/models/user_profile_model.dart';
import 'package:wanderlust/core/services/unified_image_service.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:wanderlust/core/services/storage_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class UserProfileController extends BaseController {
  final UserProfileService _profileService = Get.find<UserProfileService>();
  final UnifiedImageService _imageService = Get.find<UnifiedImageService>();

  // User profile
  final Rxn<UserProfileModel> userProfile = Rxn<UserProfileModel>();
  final Rxn<Uint8List> avatarBytes = Rxn<Uint8List>();
  final Rxn<Uint8List> coverPhotoBytes = Rxn<Uint8List>();
  final RxBool isLoadingAvatar = false.obs;
  final RxBool isLoadingCover = false.obs;

  // Stats
  final totalTrips = 0.obs;
  final totalBookings = 0.obs;
  final totalReviews = 0.obs;
  final totalPoints = 0.obs;
  final activeTripsCount = 0.obs;

  // Settings
  final notificationsEnabled = true.obs;
  final currentLanguage = 'Tiếng Việt'.obs;
  final appVersion = '1.0.0'.obs;

  // Getters for easy access
  String get userName => userProfile.value?.displayName ?? 'User';
  String get userEmail => userProfile.value?.email ?? '';
  String get userBio => userProfile.value?.bio ?? '';
  String get userLocation => userProfile.value?.location ?? '';
  bool get hasAvatar => avatarBytes.value != null;
  bool get hasCoverPhoto => coverPhotoBytes.value != null;

  @override
  void onInit() {
    super.onInit();
    loadUserData();

    // Stream profile changes
    _profileService.streamCurrentUserProfile().listen((profile) {
      if (profile != null) {
        userProfile.value = profile;
        _loadAvatarBytes(profile);
        _loadCoverBytes(profile);
        loadStats();
      }
    });
  }

  void loadUserData() async {
    try {
      setLoading();

      // Load profile from Firestore
      final profile = await _profileService.getCurrentUserProfile();

      if (profile != null) {
        userProfile.value = profile;
        _loadAvatarBytes(profile);
        _loadCoverBytes(profile);
        loadStats();
        setSuccess();
      } else {
        // Initialize profile for new user
        final success = await _profileService.initializeNewUserProfile();
        if (success) {
          loadUserData(); // Reload after initialization
        } else {
          setError('Could not initialize profile');
        }
      }

      // Load settings from local storage
      _loadLocalSettings();
    } catch (e) {
      LoggerService.e('Error loading user data', error: e);
      setError('Error loading profile');
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
    update(); // Notify GetBuilder listeners
  }

  void _loadCoverBytes(UserProfileModel profile) {
    if (profile.coverPhoto != null) {
      coverPhotoBytes.value = _imageService.base64ToImage(profile.coverPhoto);
    }
  }

  void _loadLocalSettings() {
    // Load notification settings with default true
    final savedNotifications = StorageService.to.read('notifications_enabled');
    if (savedNotifications != null) {
      notificationsEnabled.value = savedNotifications;
    } else {
      // Initialize default value on first use
      notificationsEnabled.value = true;
      StorageService.to.write('notifications_enabled', true);
    }

    // Load language settings with default Vietnamese
    final savedLanguage = StorageService.to.read('app_language');
    if (savedLanguage != null) {
      currentLanguage.value = savedLanguage == 'vi' ? 'Tiếng Việt' : 'English';
    } else {
      // Initialize default language on first use
      currentLanguage.value = 'Tiếng Việt';
      StorageService.to.write('app_language', 'vi');
    }
  }

  void loadStats() {
    // Load stats from user profile
    if (userProfile.value != null) {
      final stats = userProfile.value!.stats;
      totalTrips.value = stats.tripsCount;
      totalReviews.value = stats.reviewsCount;
      // Other stats will be loaded from respective services
      totalBookings.value = 0; // TODO: Load from BookingService
      totalPoints.value = 0; // TODO: Load from PointsService
      activeTripsCount.value = 0; // TODO: Calculate from TripService
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

  void changeCoverPhoto() async {
    try {
      final source = await _showImageSourceDialog();
      if (source == null) return;

      isLoadingCover.value = true;
      AppSnackbar.showInfo(message: 'Đang xử lý ảnh...');

      // Update cover photo using UserProfileService
      final success = await _profileService.updateCoverPhoto(source);

      if (success) {
        AppSnackbar.showSuccess(message: 'Cập nhật ảnh bìa thành công!');
      } else {
        AppSnackbar.showError(message: 'Không thể cập nhật ảnh bìa');
      }
    } catch (e) {
      LoggerService.e('Error changing cover photo', error: e);
      AppSnackbar.showError(message: 'Có lỗi xảy ra');
    } finally {
      isLoadingCover.value = false;
    }
  }

  void removeAvatar() async {
    final confirm = await AppDialogs.showConfirm(
      title: 'Xóa ảnh đại diện',
      message: 'Bạn có chắc chắn muốn xóa ảnh đại diện?',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
    );

    if (!confirm) return;

    try {
      isLoadingAvatar.value = true;
      final success = await _profileService.removeAvatar();

      if (success) {
        avatarBytes.value = null;
        AppSnackbar.showSuccess(message: 'Đã xóa ảnh đại diện');
      } else {
        AppSnackbar.showError(message: 'Không thể xóa ảnh đại diện');
      }
    } catch (e) {
      LoggerService.e('Error removing avatar', error: e);
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

  void navigateToMyTrips() {
    Get.toNamed('/my-trips');
  }

  void navigateToSaved() {
    Get.toNamed('/saved-collections');
  }

  void navigateToBookingHistory() {
    Get.toNamed('/booking-history');
  }

  void navigateToMyReviews() {
    Get.toNamed('/my-reviews');
  }

  void navigateToEditProfile() {
    Get.toNamed('/edit-profile');
  }

  void navigateToSecurity() {
    Get.toNamed('/security-settings');
  }

  void navigateToNotificationSettings() {
    Get.toNamed('/notification-settings');
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    StorageService.to.write('notifications_enabled', value);

    AppSnackbar.showInfo(message: value ? 'Đã bật thông báo' : 'Đã tắt thông báo');
  }

  void changeLanguage() {
    Get.dialog(
      AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: currentLanguage.value == 'Tiếng Việt' ? 'vi' : 'en',
              onChanged: (value) {
                currentLanguage.value = 'Tiếng Việt';
                StorageService.to.write('app_language', 'vi');
                Get.back();
                AppSnackbar.showSuccess(message: 'Đã chuyển sang Tiếng Việt');
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLanguage.value == 'Tiếng Việt' ? 'vi' : 'en',
              onChanged: (value) {
                currentLanguage.value = 'English';
                StorageService.to.write('app_language', 'en');
                Get.back();
                AppSnackbar.showSuccess(message: 'Changed to English');
              },
            ),
          ],
        ),
      ),
    );
  }

  void navigateToHelp() {
    Get.toNamed('/help-center');
  }

  void navigateToContact() {
    Get.toNamed('/contact-support');
  }

  void navigateToAbout() {
    Get.toNamed('/about');
  }

  void navigateToSettings() {
    Get.toNamed('/settings');
  }

  void logout() async {
    final confirm = await AppDialogs.showConfirm(
      title: 'Đăng xuất',
      message: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
    );

    if (confirm) {
      try {
        AppDialogs.showLoading(message: 'Đang đăng xuất...');

        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        // Clear local storage
        await StorageService.to.clearAll();

        // Clear image cache
        _imageService.clearCache();

        AppDialogs.hideLoading();

        // Navigate to login
        Get.offAllNamed('/login');

        AppSnackbar.showInfo(message: 'Đã đăng xuất thành công');
      } catch (e) {
        AppDialogs.hideLoading();
        AppSnackbar.showError(message: 'Không thể đăng xuất: $e');
      }
    }
  }
}
