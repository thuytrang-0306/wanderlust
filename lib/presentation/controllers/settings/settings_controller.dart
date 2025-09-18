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

class SettingsController extends BaseController {
  // App Settings
  final notificationsEnabled = true.obs;
  final darkModeEnabled = false.obs;
  final offlineModeEnabled = false.obs;
  final currentLanguage = 'Tiếng Việt'.obs;

  // Preferences
  final defaultMapProvider = 'Google Maps'.obs;
  final defaultCurrency = 'VND'.obs;
  final measurementUnit = 'Metric'.obs;

  // App Info
  final appVersion = '1.0.0'.obs;
  final buildNumber = '2024.1'.obs;
  final cacheSize = '12.5 MB'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadAppInfo();
  }

  void loadSettings() {
    // Load from storage
    notificationsEnabled.value = StorageService.to.notificationEnabled;

    final savedLanguage = StorageService.to.language;
    currentLanguage.value = savedLanguage == 'vi' ? 'Tiếng Việt' : 'English';

    final savedTheme = StorageService.to.theme;
    darkModeEnabled.value = savedTheme == 'dark';

    // Load other preferences
    defaultMapProvider.value = StorageService.to.read('map_provider') ?? 'Google Maps';
    defaultCurrency.value = StorageService.to.read('currency') ?? 'VND';
    measurementUnit.value = StorageService.to.read('measurement_unit') ?? 'Metric';
    offlineModeEnabled.value = StorageService.to.read('offline_mode') ?? false;
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

  void navigateToSecurity() {
    Get.toNamed('/security-settings');
  }

  void navigateToPrivacy() {
    Get.toNamed('/privacy-settings');
  }

  void navigateToBookingHistory() {
    Get.toNamed('/booking-history');
  }

  void navigateToNotificationSettings() {
    Get.toNamed('/notification-settings');
  }

  void navigateToDownloads() {
    AppSnackbar.showInfo(message: 'Tính năng đang phát triển');
  }

  void navigateToHelp() {
    Get.toNamed('/help-center');
  }

  void navigateToSupport() {
    AppSnackbar.showInfo(message: 'Tính năng chat hỗ trợ đang phát triển');
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

  void toggleOfflineMode(bool value) async {
    offlineModeEnabled.value = value;
    await StorageService.to.write('offline_mode', value);

    AppSnackbar.showInfo(message: value ? 'Đã bật chế độ offline' : 'Đã tắt chế độ offline');
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

  void showMapProviderPicker() {
    final providers = ['Google Maps', 'Apple Maps', 'OpenStreetMap'];

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
            Text('Chọn nhà cung cấp bản đồ', style: AppTypography.heading5),
            SizedBox(height: AppSpacing.s4),
            ...providers.map((provider) {
              return RadioListTile<String>(
                title: Text(provider),
                value: provider,
                groupValue: defaultMapProvider.value,
                onChanged: (value) async {
                  defaultMapProvider.value = value!;
                  await StorageService.to.write('map_provider', value);
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

  void showUnitPicker() {
    final units = {'Metric': 'Metric (km, m)', 'Imperial': 'Imperial (miles, ft)'};

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
            Text('Chọn đơn vị đo lường', style: AppTypography.heading5),
            SizedBox(height: AppSpacing.s4),
            ...units.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: measurementUnit.value,
                onChanged: (value) async {
                  measurementUnit.value = value!;
                  await StorageService.to.write('measurement_unit', value);
                  Get.back();
                  AppSnackbar.showSuccess(message: 'Đã chọn ${entry.value}');
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

  void rateApp() {
    // TODO: Implement app store/play store rating
    AppSnackbar.showInfo(message: 'Chuyển đến App Store/Play Store...');
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
    // TODO: Navigate to terms page or show web view
    AppSnackbar.showInfo(message: 'Mở điều khoản sử dụng...');
  }

  void showPrivacyPolicy() {
    // TODO: Navigate to privacy policy page or show web view
    AppSnackbar.showInfo(message: 'Mở chính sách bảo mật...');
  }

  void showLicenses() {
    // Show Flutter licenses
    Get.to(() => const LicensePage(applicationName: 'Wanderlust', applicationVersion: '1.0.0'));
  }

  void clearCache() async {
    final confirm = await AppDialogs.showConfirm(
      title: 'Xóa bộ nhớ cache',
      message: 'Bạn có chắc chắn muốn xóa ${cacheSize.value} bộ nhớ cache?',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
    );

    if (confirm) {
      AppDialogs.showLoading(message: 'Đang xóa cache...');

      // Simulate cache clearing
      await Future.delayed(const Duration(seconds: 2));

      cacheSize.value = '0 MB';

      AppDialogs.hideLoading();
      AppSnackbar.showSuccess(message: 'Đã xóa bộ nhớ cache thành công');
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
