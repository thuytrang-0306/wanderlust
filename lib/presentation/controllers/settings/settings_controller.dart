import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:wanderlust/core/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:in_app_review/in_app_review.dart';

class SettingsController extends BaseController {
  // App Settings
  final notificationsEnabled = true.obs;
  final darkModeEnabled = false.obs;
  final currentLanguage = 'Tiếng Việt'.obs;
  final defaultCurrency = 'VND'.obs;

  // App Info
  final appVersion = '1.0.0'.obs;
  final buildNumber = '2024.1'.obs;
  final cacheSize = '12.5 MB'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadAppInfo();
    _calculateCacheSize();
  }

  void loadSettings() {
    // Load from storage
    notificationsEnabled.value = StorageService.to.notificationEnabled;

    final savedLanguage = StorageService.to.language;
    currentLanguage.value = savedLanguage == 'vi' ? 'Tiếng Việt' : 'English';

    final savedTheme = StorageService.to.theme;
    darkModeEnabled.value = savedTheme == 'dark';

    defaultCurrency.value = StorageService.to.read('currency') ?? 'VND';
  }

  void loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
      buildNumber.value = packageInfo.buildNumber;
    } catch (e) {
      // Use default values if package info fails
    }
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

  void navigateToHelp() {
    Get.toNamed('/help-support');
  }

  // Toggle methods
  void toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    await StorageService.to.setNotificationEnabled(value);

    AppSnackbar.showInfo(message: value ? 'Đã bật thông báo' : 'Đã tắt thông báo');
  }

  void toggleDarkMode(bool value) async {
    darkModeEnabled.value = value;
    await StorageService.to.saveTheme(value ? 'dark' : 'light');

    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);

    AppSnackbar.showInfo(message: value ? 'Đã bật chế độ tối' : 'Đã tắt chế độ tối');
  }

  // Picker methods
  void showLanguagePicker() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(AppSpacing.s5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chọn ngôn ngữ', style: AppTypography.heading5),
            SizedBox(height: AppSpacing.s4),
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: currentLanguage.value == 'Tiếng Việt' ? 'vi' : 'en',
              onChanged: (value) async {
                currentLanguage.value = 'Tiếng Việt';
                await StorageService.to.saveLanguage('vi');
                Get.back();
                AppSnackbar.showSuccess(message: 'Đã chuyển sang Tiếng Việt');
              },
              activeColor: AppColors.primary,
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLanguage.value == 'Tiếng Việt' ? 'vi' : 'en',
              onChanged: (value) async {
                currentLanguage.value = 'English';
                await StorageService.to.saveLanguage('en');
                Get.back();
                AppSnackbar.showSuccess(message: 'Changed to English');
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void showCurrencyPicker() {
    final currencies = {
      'VND': 'Việt Nam Đồng',
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'JPY': 'Japanese Yen',
    };

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(AppSpacing.s5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chọn tiền tệ', style: AppTypography.heading5),
            SizedBox(height: AppSpacing.s4),
            ...currencies.entries.map((entry) {
              return RadioListTile<String>(
                title: Text('${entry.key} - ${entry.value}'),
                value: entry.key,
                groupValue: defaultCurrency.value,
                onChanged: (value) async {
                  defaultCurrency.value = value!;
                  await StorageService.to.write('currency', value);
                  Get.back();
                  AppSnackbar.showSuccess(message: 'Đã chọn $value');
                },
                activeColor: AppColors.primary,
              );
            }),
          ],
        ),
      ),
    );
  }

  // Action methods
  void sendFeedback() {
    Get.dialog(
      AlertDialog(
        title: const Text('Gửi phản hồi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Nhập phản hồi của bạn...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Get.back();
              AppSnackbar.showSuccess(message: 'Cảm ơn phản hồi của bạn!');
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  Future<void> rateApp() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;

      // Check if in-app review is available (only works on published apps)
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        // Fallback for apps not on store yet - show feedback dialog
        _showRateFallbackDialog();
      }
    } catch (e) {
      // Safe fallback if anything goes wrong
      _showRateFallbackDialog();
    }
  }

  void _showRateFallbackDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: AppColors.warning, size: 24.sp),
            SizedBox(width: AppSpacing.s2),
            const Text('Đánh giá Wanderlust'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cảm ơn bạn đã sử dụng Wanderlust!',
              style: AppTypography.bodyMedium,
            ),
            SizedBox(height: AppSpacing.s3),
            Text(
              'Ứng dụng đang trong giai đoạn phát triển. Tính năng đánh giá sẽ khả dụng khi app chính thức lên App Store/Play Store.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppSpacing.s4),
            Text(
              'Bạn có muốn gửi phản hồi cho chúng tôi không?',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Để sau', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              sendFeedback(); // Reuse existing feedback dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Gửi phản hồi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showAbout() {
    AppDialogs.showAlert(
      title: 'Về Wanderlust',
      message: '''Wanderlust - Ứng dụng du lịch hàng đầu Việt Nam

Phiên bản: ${appVersion.value}
Build: ${buildNumber.value}

Được phát triển bởi đội ngũ Wanderlust Team với mục tiêu mang đến trải nghiệm du lịch tốt nhất cho người dùng Việt Nam.

© 2024 Wanderlust. All rights reserved.''',
    );
  }

  void showTerms() {
    Get.toNamed('/terms-of-service');
  }

  void showPrivacyPolicy() {
    Get.toNamed('/privacy-policy');
  }

  void showLicenses() {
    // Show Flutter licenses
    Get.to(() => const LicensePage(applicationName: 'Wanderlust', applicationVersion: '1.0.0'));
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
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void clearCache() async {
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
      }
    }
  }

  void clearAllData() async {
    final confirm = await AppDialogs.showConfirm(
      title: 'Xóa tất cả dữ liệu',
      message:
          'Hành động này sẽ xóa toàn bộ dữ liệu cục bộ và đăng xuất khỏi tài khoản. Bạn có chắc chắn?',
      confirmText: 'Xóa tất cả',
      cancelText: 'Hủy',
      confirmColor: AppColors.error,
    );

    if (confirm) {
      try {
        AppDialogs.showLoading(message: 'Đang xóa dữ liệu...');

        // Clear all data and sign out
        await StorageService.to.clearAll();
        await FirebaseAuth.instance.signOut();

        AppDialogs.hideLoading();

        // Navigate to login
        Get.offAllNamed('/login');

        AppSnackbar.showInfo(message: 'Đã xóa tất cả dữ liệu');
      } catch (e) {
        AppDialogs.hideLoading();
        AppSnackbar.showError(message: 'Không thể xóa dữ liệu: $e');
      }
    }
  }
}
