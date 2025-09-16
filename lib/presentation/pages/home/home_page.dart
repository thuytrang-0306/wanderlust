import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/core/services/storage_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _handleLogout() async {
    try {
      // Show confirmation dialog
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Text(
            'Đăng xuất',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất?',
            style: AppTypography.bodyM.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Hủy',
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(
                'Đăng xuất',
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.error,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await FirebaseAuth.instance.signOut();
        LoggerService.i('User logged out successfully');
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      LoggerService.e('Logout error: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể đăng xuất',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }

  void _resetOnboarding() {
    // For testing: Reset onboarding flag
    StorageService.to.write('hasSeenOnboarding', false);
    Get.snackbar(
      'Debug',
      'Onboarding đã được reset. Khởi động lại app để xem.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.warning,
      colorText: AppColors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Wanderlust',
          style: AppTypography.h3.copyWith(
            color: AppColors.primary,
            fontWeight: AppTypography.bold,
          ),
        ),
        actions: [
          // Debug button to reset onboarding
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.textSecondary,
            ),
            onPressed: _resetOnboarding,
            tooltip: 'Reset Onboarding',
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: AppColors.error,
            ),
            onPressed: _handleLogout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.s5),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.s4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào,',
                      style: AppTypography.bodyL.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    SizedBox(height: AppSpacing.s1),
                    Text(
                      user?.displayName ?? user?.email ?? 'Khách',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.white,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s3),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s3,
                        vertical: AppSpacing.s2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.s2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            user?.emailVerified == true 
                              ? Icons.verified_user 
                              : Icons.warning,
                            size: 16.sp,
                            color: AppColors.white,
                          ),
                          SizedBox(width: AppSpacing.s2),
                          Text(
                            user?.emailVerified == true 
                              ? 'Đã xác thực' 
                              : 'Chưa xác thực',
                            style: AppTypography.bodyS.copyWith(
                              color: AppColors.white,
                              fontWeight: AppTypography.medium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSpacing.s6),
              
              // Quick stats
              Text(
                'Thống kê nhanh',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppTypography.bold,
                ),
              ),
              SizedBox(height: AppSpacing.s4),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.flight,
                      label: 'Chuyến đi',
                      value: '0',
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.bookmark,
                      label: 'Đã lưu',
                      value: '0',
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.star,
                      label: 'Đánh giá',
                      value: '0',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpacing.s6),
              
              // Features coming soon
              Text(
                'Tính năng sắp ra mắt',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppTypography.bold,
                ),
              ),
              SizedBox(height: AppSpacing.s4),
              
              _buildFeatureCard(
                icon: Icons.explore,
                title: 'Khám phá điểm đến',
                description: 'Tìm kiếm những địa điểm du lịch tuyệt vời',
              ),
              SizedBox(height: AppSpacing.s3),
              _buildFeatureCard(
                icon: Icons.calendar_month,
                title: 'Lập kế hoạch chuyến đi',
                description: 'Tạo lịch trình chi tiết cho kỳ nghỉ của bạn',
              ),
              SizedBox(height: AppSpacing.s3),
              _buildFeatureCard(
                icon: Icons.people,
                title: 'Cộng đồng du lịch',
                description: 'Chia sẻ kinh nghiệm với những người đam mê du lịch',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.s3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: color,
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTypography.bold,
            ),
          ),
          SizedBox(height: AppSpacing.s1),
          Text(
            label,
            style: AppTypography.bodyXS.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.s3),
        border: Border.all(
          color: AppColors.neutral100,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.s3),
            ),
            child: Icon(
              icon,
              size: 24.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppSpacing.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyL.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
                SizedBox(height: AppSpacing.s1),
                Text(
                  description,
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}