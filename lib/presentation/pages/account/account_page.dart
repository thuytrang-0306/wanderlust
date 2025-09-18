import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/presentation/controllers/account/account_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccountPage extends GetView<AccountController> {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Simple Header
            Container(
              padding: EdgeInsets.all(AppSpacing.s5),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.r),
                          child: Obx(() => controller.hasAvatar
                              ? Image.memory(
                                  controller.avatarBytes.value!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: AppColors.neutral100,
                                    child: Icon(
                                      Icons.person,
                                      size: 30.sp,
                                      color: AppColors.neutral400,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    size: 30.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => controller.changeAvatar(),
                          child: Container(
                            width: 20.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 12.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(width: AppSpacing.s4),
                  
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                          controller.userName,
                          style: AppTypography.bodyL.copyWith(
                            color: AppColors.neutral900,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                        SizedBox(height: 2.h),
                        Obx(() => Text(
                          controller.userEmail,
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.neutral600,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, color: AppColors.neutral100),
            
            // Menu List
            Expanded(
              child: ListView(
                children: [
                  // Account Section
                  _buildSectionTitle('Tài khoản'),
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Thông tin cá nhân',
                    onTap: () => controller.navigateToProfile(),
                  ),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    onTap: () => controller.navigateToChangePassword(),
                  ),
                  _buildMenuItem(
                    icon: Icons.bookmark_outline,
                    title: 'Đã lưu',
                    onTap: () => controller.navigateToSavedPosts(),
                  ),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Lịch sử',
                    onTap: () => controller.navigateToTripHistory(),
                  ),
                  
                  SizedBox(height: AppSpacing.s4),
                  
                  // Settings Section
                  _buildSectionTitle('Cài đặt'),
                  _buildMenuItem(
                    icon: Icons.notifications_none,
                    title: 'Thông báo',
                    trailing: Obx(() => Switch(
                      value: controller.notificationsEnabled.value,
                      onChanged: controller.toggleNotifications,
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )),
                  ),
                  _buildMenuItem(
                    icon: Icons.language,
                    title: 'Ngôn ngữ',
                    subtitle: 'Tiếng Việt',
                    onTap: () => controller.navigateToLanguage(),
                  ),
                  _buildMenuItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Chế độ tối',
                    trailing: Obx(() => Switch(
                      value: controller.darkModeEnabled.value,
                      onChanged: controller.toggleDarkMode,
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )),
                  ),
                  
                  SizedBox(height: AppSpacing.s4),
                  
                  // Support Section
                  _buildSectionTitle('Hỗ trợ'),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Trợ giúp',
                    onTap: () => controller.navigateToHelp(),
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'Về chúng tôi',
                    onTap: () => controller.navigateToAbout(),
                  ),
                  
                  SizedBox(height: AppSpacing.s6),
                  
                  // Logout Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
                    child: GestureDetector(
                      onTap: () => controller.logout(),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            'Đăng xuất',
                            style: AppTypography.bodyL.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppSpacing.s4),
                  
                  // Version
                  Center(
                    child: Text(
                      'Phiên bản 1.0.0',
                      style: AppTypography.bodyXS.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppSpacing.s6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.s5,
        right: AppSpacing.s5,
        top: AppSpacing.s4,
        bottom: AppSpacing.s2,
      ),
      child: Text(
        title,
        style: AppTypography.bodyS.copyWith(
          color: AppColors.neutral600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s5,
          vertical: AppSpacing.s3,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: AppColors.neutral700,
            ),
            SizedBox(width: AppSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.neutral900,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppTypography.bodyXS.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 20.sp,
                color: AppColors.neutral400,
              ),
          ],
        ),
      ),
    );
  }
}