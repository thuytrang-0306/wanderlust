import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/settings/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Cài đặt', style: AppTypography.heading5),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.s4),

            // Account Settings
            _buildSectionTitle('Tài khoản'),
            _buildSettingsSection([
              _buildSettingItem(
                icon: Icons.person_outline,
                title: 'Thông tin cá nhân',
                subtitle: 'Cập nhật thông tin tài khoản',
                onTap: controller.navigateToEditProfile,
              ),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                subtitle: 'Thay đổi mật khẩu tài khoản',
                onTap: controller.navigateToChangePassword,
              ),
              _buildSettingItem(
                icon: Icons.hotel_outlined,
                title: 'Lịch sử đặt phòng',
                subtitle: 'Xem các booking đã đặt',
                onTap: controller.navigateToBookingHistory,
              ),
            ]),

            SizedBox(height: AppSpacing.s6),

            // App Settings
            _buildSectionTitle('Ứng dụng'),
            _buildSettingsSection([
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: 'Thông báo',
                subtitle: 'Bật/tắt thông báo',
                trailing: Obx(
                  () => Switch(
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.toggleNotifications,
                    activeColor: AppColors.primary,
                  ),
                ),
              ),
              _buildSettingItem(
                icon: Icons.language,
                title: 'Ngôn ngữ',
                subtitle: controller.currentLanguage.value,
                onTap: controller.showLanguagePicker,
              ),
              _buildSettingItem(
                icon: Icons.dark_mode_outlined,
                title: 'Chế độ tối',
                subtitle: 'Chuyển đổi giao diện tối/sáng',
                trailing: Obx(
                  () => Switch(
                    value: controller.darkModeEnabled.value,
                    onChanged: controller.toggleDarkMode,
                    activeColor: AppColors.primary,
                  ),
                ),
              ),
              _buildSettingItem(
                icon: Icons.attach_money,
                title: 'Tiền tệ',
                subtitle: controller.defaultCurrency.value,
                onTap: controller.showCurrencyPicker,
              ),
            ]),

            SizedBox(height: AppSpacing.s6),

            // Support
            _buildSectionTitle('Hỗ trợ'),
            _buildSettingsSection([
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'Trung tâm trợ giúp',
                subtitle: 'FAQ và hướng dẫn sử dụng',
                onTap: controller.navigateToHelp,
              ),
              _buildSettingItem(
                icon: Icons.feedback_outlined,
                title: 'Gửi phản hồi',
                subtitle: 'Giúp chúng tôi cải thiện ứng dụng',
                onTap: controller.sendFeedback,
              ),
              _buildSettingItem(
                icon: Icons.star_outline,
                title: 'Đánh giá ứng dụng',
                subtitle: 'Đánh giá trên App Store/Play Store',
                onTap: controller.rateApp,
              ),
            ]),

            SizedBox(height: AppSpacing.s6),

            // About
            _buildSectionTitle('Thông tin'),
            _buildSettingsSection([
              _buildSettingItem(
                icon: Icons.info_outline,
                title: 'Về Wanderlust',
                subtitle: 'Phiên bản ${controller.appVersion.value}',
                onTap: controller.showAbout,
              ),
              _buildSettingItem(
                icon: Icons.article_outlined,
                title: 'Điều khoản sử dụng',
                subtitle: 'Điều khoản và điều kiện',
                onTap: controller.showTerms,
              ),
              _buildSettingItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Chính sách bảo mật',
                subtitle: 'Chính sách về quyền riêng tư',
                onTap: controller.showPrivacyPolicy,
              ),
              _buildSettingItem(
                icon: Icons.copyright,
                title: 'Giấy phép',
                subtitle: 'Thông tin giấy phép mã nguồn mở',
                onTap: controller.showLicenses,
              ),
            ]),

            SizedBox(height: AppSpacing.s6),

            // Clear Data
            _buildDangerSection(),

            SizedBox(height: AppSpacing.s8),

            // Version Info
            _buildVersionInfo(),

            SizedBox(height: AppSpacing.s8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s3),
      child: Text(
        title,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsSection(List<Widget> items) {
    return Container(
      color: Colors.white,
      child: Column(
        children:
            items.map((item) {
              final isLast = items.last == item;
              return Column(
                children: [
                  item,
                  if (!isLast)
                    Divider(height: 1, thickness: 1, color: AppColors.neutral200, indent: 56.w),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s4),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 20.sp, color: AppColors.primary),
            ),
            SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(Icons.chevron_right, size: 24.sp, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Dữ liệu'),
        Container(
          color: Colors.white,
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.cached,
                title: 'Xóa bộ nhớ cache',
                subtitle: '${controller.cacheSize.value} đang sử dụng',
                onTap: controller.clearCache,
              ),
              const Divider(height: 1, thickness: 1),
              InkWell(
                onTap: controller.clearAllData,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s4),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.delete_forever, size: 20.sp, color: AppColors.error),
                      ),
                      SizedBox(width: AppSpacing.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xóa tất cả dữ liệu',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Xóa toàn bộ dữ liệu và đăng xuất',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 24.sp, color: AppColors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/images/logo.png', width: 60.w, height: 60.w),
          SizedBox(height: AppSpacing.s3),
          Text('Wanderlust', style: AppTypography.heading6),
          SizedBox(height: AppSpacing.s1),
          Obx(
            () => Text(
              'Phiên bản ${controller.appVersion.value}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            'Build ${controller.buildNumber.value}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
