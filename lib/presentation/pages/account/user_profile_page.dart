import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/presentation/controllers/account/user_profile_controller.dart';

class UserProfilePage extends GetView<UserProfileController> {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UserProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: CustomScrollView(
        slivers: [
          // App bar with profile header
          _buildSliverAppBar(),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: AppSpacing.s4),

                // Stats section
                _buildStatsSection(),

                SizedBox(height: AppSpacing.s5),

                // Menu sections
                _buildMenuSection(
                  title: 'Hoạt động của tôi',
                  items: [
                    MenuItemModel(
                      icon: Icons.luggage_outlined,
                      title: 'Chuyến đi của tôi',
                      subtitle: 'Xem lịch sử và kế hoạch',
                      onTap: controller.navigateToMyTrips,
                      badge:
                          controller.activeTripsCount.value > 0
                              ? controller.activeTripsCount.value.toString()
                              : null,
                    ),
                    MenuItemModel(
                      icon: Icons.bookmark_outline,
                      title: 'Đã lưu',
                      subtitle: 'Địa điểm và tour yêu thích',
                      onTap: controller.navigateToSaved,
                    ),
                    MenuItemModel(
                      icon: Icons.hotel_outlined,
                      title: 'Lịch sử đặt phòng',
                      subtitle: 'Xem các booking đã đặt',
                      onTap: controller.navigateToBookingHistory,
                    ),
                    MenuItemModel(
                      icon: Icons.rate_review_outlined,
                      title: 'Đánh giá của tôi',
                      subtitle: 'Xem và quản lý đánh giá',
                      onTap: controller.navigateToMyReviews,
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.s5),

                _buildMenuSection(
                  title: 'Tài khoản',
                  items: [
                    MenuItemModel(
                      icon: Icons.person_outline,
                      title: 'Thông tin cá nhân',
                      subtitle: 'Cập nhật profile',
                      onTap: controller.navigateToEditProfile,
                    ),
                    MenuItemModel(
                      icon: Icons.security_outlined,
                      title: 'Bảo mật',
                      subtitle: 'Mật khẩu và xác thực',
                      onTap: controller.navigateToSecurity,
                    ),
                    MenuItemModel(
                      icon: Icons.notifications_outlined,
                      title: 'Thông báo',
                      subtitle: 'Cài đặt thông báo',
                      onTap: controller.navigateToNotificationSettings,
                      trailing: Obx(
                        () => Switch(
                          value: controller.notificationsEnabled.value,
                          onChanged: controller.toggleNotifications,
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ),
                    MenuItemModel(
                      icon: Icons.language_outlined,
                      title: 'Ngôn ngữ',
                      subtitle: controller.currentLanguage.value,
                      onTap: controller.changeLanguage,
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.s5),

                _buildMenuSection(
                  title: 'Hỗ trợ',
                  items: [
                    MenuItemModel(
                      icon: Icons.help_outline,
                      title: 'Trung tâm hỗ trợ',
                      subtitle: 'FAQ và hướng dẫn',
                      onTap: controller.navigateToHelp,
                    ),
                    MenuItemModel(
                      icon: Icons.chat_bubble_outline,
                      title: 'Liên hệ',
                      subtitle: 'Chat với support team',
                      onTap: controller.navigateToContact,
                    ),
                    MenuItemModel(
                      icon: Icons.info_outline,
                      title: 'Về Wanderlust',
                      subtitle: 'Phiên bản ${controller.appVersion}',
                      onTap: controller.navigateToAbout,
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.s5),

                // Logout button
                _buildLogoutButton(),

                SizedBox(height: AppSpacing.s8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, const Color(0xFFB794F4)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.s6),

                // Avatar
                Obx(
                  () => GestureDetector(
                    onTap: controller.changeAvatar,
                    child: Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            controller.hasAvatar
                                ? Image.memory(
                                  controller.avatarBytes.value!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        color: AppColors.neutral200,
                                        child: Icon(
                                          Icons.person,
                                          size: 40.sp,
                                          color: AppColors.neutral500,
                                        ),
                                      ),
                                )
                                : Container(
                                  color: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: 40.sp,
                                    color: AppColors.neutral500,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.s3),

                // Name
                Obx(
                  () => Text(
                    controller.userName,
                    style: AppTypography.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.s1),

                // Email
                Obx(
                  () => Text(
                    controller.userEmail,
                    style: AppTypography.bodyS.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              value: controller.totalTrips.value.toString(),
              label: 'Chuyến đi',
              icon: Icons.explore_outlined,
            ),
            _buildStatDivider(),
            _buildStatItem(
              value: controller.totalBookings.value.toString(),
              label: 'Đặt phòng',
              icon: Icons.hotel_outlined,
            ),
            _buildStatDivider(),
            _buildStatItem(
              value: controller.totalReviews.value.toString(),
              label: 'Đánh giá',
              icon: Icons.star_outline,
            ),
            _buildStatDivider(),
            _buildStatItem(
              value: controller.totalPoints.value.toString(),
              label: 'Điểm',
              icon: Icons.emoji_events_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required String value, required String label, required IconData icon}) {
    return Column(
      children: [
        Icon(icon, size: 24.sp, color: AppColors.primary),
        SizedBox(height: AppSpacing.s2),
        Text(
          value,
          style: AppTypography.bodyL.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutral900,
          ),
        ),
        Text(label, style: AppTypography.bodyXS.copyWith(color: AppColors.neutral500)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1.w, height: 40.h, color: AppColors.neutral200);
  }

  Widget _buildMenuSection({required String title, required List<MenuItemModel> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
          child: Text(
            title,
            style: AppTypography.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral600,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.s3),
        Container(
          color: Colors.white,
          child: Column(children: items.map((item) => _buildMenuItem(item)).toList()),
        ),
      ],
    );
  }

  Widget _buildMenuItem(MenuItemModel item) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: item.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s4),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.neutral100, width: 1.h)),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(item.icon, size: 22.sp, color: AppColors.primary),
              ),

              SizedBox(width: AppSpacing.s3),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: AppTypography.bodyM.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral900,
                          ),
                        ),
                        if (item.badge != null) ...[
                          SizedBox(width: AppSpacing.s2),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              item.badge!,
                              style: AppTypography.bodyXS.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        item.subtitle!,
                        style: AppTypography.bodyXS.copyWith(color: AppColors.neutral500),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing
              if (item.trailing != null)
                item.trailing!
              else
                Icon(Icons.chevron_right, size: 24.sp, color: AppColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      child: GestureDetector(
        onTap: controller.logout,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.error),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Center(
            child: Text(
              'Đăng xuất',
              style: AppTypography.bodyL.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MenuItemModel {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? badge;

  MenuItemModel({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.badge,
  });
}
