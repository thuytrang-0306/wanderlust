import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/presentation/controllers/account/account_controller.dart';

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
                          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.r),
                          child: Obx(
                            () =>
                                controller.hasAvatar
                                    ? Image.memory(
                                      controller.avatarBytes.value!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Container(
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
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 12.sp),
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
                        Obx(
                          () => Text(
                            controller.userName,
                            style: AppTypography.bodyL.copyWith(
                              color: AppColors.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Obx(
                          () => Text(
                            controller.userEmail,
                            style: AppTypography.bodyS.copyWith(color: AppColors.neutral600),
                          ),
                        ),
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
                    title: 'Chỉnh sửa hồ sơ',
                    subtitle: 'Cập nhật thông tin cá nhân',
                    onTap: () => controller.navigateToEditProfile(),
                  ),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    subtitle: 'Thay đổi mật khẩu tài khoản',
                    onTap: () => controller.navigateToChangePassword(),
                  ),
                  _buildMenuItem(
                    icon: Icons.hotel_outlined,
                    title: 'Lịch sử đặt phòng',
                    subtitle: 'Xem các booking đã đặt',
                    onTap: () => controller.navigateToBookingHistory(),
                  ),
                  _buildMenuItem(
                    icon: Icons.bookmark_outline,
                    title: 'Bài viết đã lưu',
                    subtitle: 'Bộ sưu tập của bạn',
                    onTap: () => controller.navigateToSavedPosts(),
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Thông báo',
                    subtitle: 'Bật/tắt thông báo ứng dụng',
                    trailing: Obx(
                      () => Switch(
                        value: controller.notificationsEnabled.value,
                        onChanged: controller.toggleNotifications,
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),

                  // Business Center
                  Obx(() {
                    if (controller.isBusinessUser.value) {
                      return Column(
                        children: [
                          SizedBox(height: AppSpacing.s4),
                          _buildSectionTitle('Doanh nghiệp'),
                          _buildMenuItem(
                            icon: Icons.business_center,
                            title: 'Business Dashboard',
                            subtitle: 'Quản lý doanh nghiệp của bạn',
                            onTap: () => controller.navigateToBusinessDashboard(),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                'Business',
                                style: AppTypography.bodyXS.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          SizedBox(height: AppSpacing.s4),
                          _buildSectionTitle('Đối tác kinh doanh'),
                          _buildMenuItem(
                            icon: Icons.store_outlined,
                            title: 'Đăng ký Business',
                            subtitle: 'Trở thành đối tác với Wanderlust',
                            onTap: () => controller.navigateToBusinessRegistration(),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                'Mới',
                                style: AppTypography.bodyXS.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }),

                  SizedBox(height: AppSpacing.s4),

                  // Support Section
                  _buildSectionTitle('Hỗ trợ'),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Trung tâm trợ giúp',
                    subtitle: 'FAQ và hướng dẫn sử dụng',
                    onTap: () => controller.navigateToHelp(),
                  ),
                  _buildMenuItem(
                    icon: Icons.email_outlined,
                    title: 'Gửi phản hồi',
                    subtitle: 'Email: nttt3690@gmail.com',
                    onTap: () => controller.sendFeedback(),
                  ),

                  SizedBox(height: AppSpacing.s4),

                  // About & Legal Section
                  _buildSectionTitle('Thông tin'),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'Về Wanderlust',
                    subtitle: 'Phiên bản 1.0.0',
                    onTap: () => controller.navigateToAbout(),
                  ),
                  _buildMenuItem(
                    icon: Icons.article_outlined,
                    title: 'Điều khoản sử dụng',
                    subtitle: 'Điều khoản và điều kiện',
                    onTap: () => controller.navigateToTerms(),
                  ),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Chính sách bảo mật',
                    subtitle: 'Bảo vệ dữ liệu cá nhân',
                    onTap: () => controller.navigateToPrivacy(),
                  ),
                  _buildMenuItem(
                    icon: Icons.copyright,
                    title: 'Giấy phép',
                    subtitle: 'Thông tin mã nguồn mở',
                    onTap: () => controller.showLicenses(),
                  ),

                  SizedBox(height: AppSpacing.s4),

                  // Data Management Section
                  _buildSectionTitle('Dữ liệu'),
                  Obx(() => _buildMenuItem(
                        icon: Icons.cached,
                        title: 'Xóa bộ nhớ cache',
                        subtitle: '${controller.cacheSize.value} đang sử dụng',
                        onTap: () => controller.clearCache(),
                      )),
                  _buildMenuItem(
                    icon: Icons.delete_forever,
                    title: 'Xóa tất cả dữ liệu',
                    subtitle: 'Xóa toàn bộ và đăng xuất',
                    onTap: () => controller.clearAllData(),
                    iconColor: AppColors.error,
                    titleColor: AppColors.error,
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
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 40.w,
                          height: 40.w,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image,
                            size: 40.w,
                            color: AppColors.neutral300,
                          ),
                        ),
                        SizedBox(height: AppSpacing.s2),
                        Text(
                          'Wanderlust',
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Phiên bản 1.0.0',
                          style: AppTypography.bodyXS.copyWith(color: AppColors.neutral400),
                        ),
                      ],
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
    Color? iconColor,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s3),
        child: Row(
          children: [
            Icon(icon, size: 24.sp, color: iconColor ?? AppColors.neutral700),
            SizedBox(width: AppSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyM.copyWith(
                      color: titleColor ?? AppColors.neutral900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTypography.bodyXS.copyWith(color: AppColors.neutral500),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(Icons.chevron_right, size: 20.sp, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }
}
