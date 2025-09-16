import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Tài khoản',
          style: AppTypography.h4.copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s5),
        child: Column(
          children: [
            // User Info Card
            Container(
              padding: EdgeInsets.all(AppSpacing.s4),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (user?.displayName?.isNotEmpty == true)
                          ? user!.displayName![0].toUpperCase()
                          : user?.email?[0].toUpperCase() ?? 'U',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.white,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'User',
                          style: AppTypography.bodyL.copyWith(
                            fontWeight: AppTypography.semiBold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.s1),
                        Text(
                          user?.email ?? '',
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.s6),

            // Logout Button
            AppButton.danger(
              text: 'Đăng xuất',
              onPressed: _handleLogout,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(Routes.LOGIN);
      AppSnackbar.showSuccess(
        message: 'Đăng xuất thành công',
      );
    } catch (e) {
      AppSnackbar.showError(
        message: 'Không thể đăng xuất',
      );
    }
  }
}