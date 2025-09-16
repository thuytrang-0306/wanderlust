import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/presentation/controllers/main_navigation_controller.dart';
import 'package:wanderlust/presentation/pages/discover/discover_page.dart';
import 'package:wanderlust/presentation/pages/community/community_page.dart';
import 'package:wanderlust/presentation/pages/planning/planning_page.dart';
import 'package:wanderlust/presentation/pages/notifications/notifications_page.dart';
import 'package:wanderlust/presentation/pages/account/account_page.dart';
import 'package:wanderlust/core/constants/app_assets.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainNavigationController());

    // List of pages
    final List<Widget> pages = [
      const DiscoverPage(),
      const CommunityPage(),
      const PlanningPage(),
      const NotificationsPage(),
      const AccountPage(),
    ];

    return Obx(() => Scaffold(
      body: IndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          selectedLabelStyle: AppTypography.bodyXS.copyWith(
            fontWeight: AppTypography.medium,
            fontSize: 11.sp,
          ),
          unselectedLabelStyle: AppTypography.bodyXS.copyWith(
            fontSize: 11.sp,
          ),
          elevation: 0,
          items: [
            _buildNavItem(
              icon: AppAssets.iconTabHome,
              label: 'Khám phá',
              index: 0,
              currentIndex: controller.currentIndex.value,
            ),
            _buildNavItem(
              icon: AppAssets.iconTabCommunity,
              label: 'Cộng đồng',
              index: 1,
              currentIndex: controller.currentIndex.value,
            ),
            _buildNavItem(
              icon: AppAssets.iconTabPlanning,
              label: 'Lập kế hoạch',
              index: 2,
              currentIndex: controller.currentIndex.value,
            ),
            _buildNavItem(
              icon: AppAssets.iconTabNotifications,
              label: 'Thông báo',
              index: 3,
              currentIndex: controller.currentIndex.value,
            ),
            _buildNavItem(
              icon: AppAssets.iconTabAccount,
              label: 'Tài khoản',
              index: 4,
              currentIndex: controller.currentIndex.value,
            ),
          ],
        ),
      ),
    ));
  }

  BottomNavigationBarItem _buildNavItem({
    required String icon,
    required String label,
    required int index,
    required int currentIndex,
  }) {
    final isSelected = index == currentIndex;
    
    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: Image.asset(
          icon,
          width: 24.w,
          height: 24.w,
          color: isSelected ? AppColors.primary : AppColors.textTertiary,
          errorBuilder: (context, error, stackTrace) {
            // Fallback icon if image not found
            IconData fallbackIcon;
            switch (index) {
              case 0:
                fallbackIcon = Icons.explore;
                break;
              case 1:
                fallbackIcon = Icons.people;
                break;
              case 2:
                fallbackIcon = Icons.calendar_today;
                break;
              case 3:
                fallbackIcon = Icons.notifications;
                break;
              case 4:
                fallbackIcon = Icons.person;
                break;
              default:
                fallbackIcon = Icons.home;
            }
            return Icon(
              fallbackIcon,
              size: 24.w,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            );
          },
        ),
      ),
      label: label,
    );
  }
}