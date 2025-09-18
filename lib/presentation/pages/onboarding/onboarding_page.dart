import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/onboarding_controller.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button - top right as per design
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.s4),
                child: TextButton(
                  onPressed: controller.skipOnboarding,
                  child: Text(
                    'Bỏ qua',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2F3137), // Exact color from design
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.onboardingPages.length,
                itemBuilder: (context, index) {
                  final page = controller.onboardingPages[index];
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.s6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image - centered and responsive
                        Container(
                          height: 0.35.sh,
                          constraints: BoxConstraints(maxHeight: 280.h, minHeight: 200.h),
                          child: Center(child: Image.asset(page.image, fit: BoxFit.contain)),
                        ),

                        SizedBox(height: AppSpacing.s10),

                        // Title - centered
                        Text(
                          page.title,
                          style: AppTypography.h2.copyWith(
                            color: AppColors.secondary,
                            fontWeight: AppTypography.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: AppSpacing.s3),

                        // Subtitle - centered with padding
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                          child: Text(
                            page.subtitle,
                            style: AppTypography.bodyM.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom section: dots and buttons with 67h padding from bottom
            Container(
              padding: EdgeInsets.only(
                left: AppSpacing.s6,
                right: AppSpacing.s6,
                bottom: 67.h, // Exact padding from bottom as requested
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Important: minimize height
                children: [
                  // Page indicators (3 dots)
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.onboardingPages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: AppSpacing.s1),
                          height: 8.h,
                          width: controller.currentPage.value == index ? 24.w : 8.w,
                          decoration: BoxDecoration(
                            color:
                                controller.currentPage.value == index
                                    ? AppColors.primary
                                    : AppColors.neutral300,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.s6),

                  // Action buttons
                  Obx(() {
                    final isLast =
                        controller.currentPage.value == controller.onboardingPages.length - 1;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Primary button
                        SizedBox(
                          width: double.infinity,
                          height: 48.h, // Reduced from 56 for better fit
                          child: ElevatedButton(
                            onPressed: isLast ? controller.navigateToRegister : controller.nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.s6),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isLast ? 'Tạo tài khoản' : 'Tiếp theo',
                              style: AppTypography.button.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),

                        SizedBox(height: AppSpacing.s3),

                        // Secondary button
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: OutlinedButton(
                            onPressed: controller.navigateToLogin,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.s6),
                              ),
                            ),
                            child: Text(
                              'Đăng nhập',
                              style: AppTypography.button.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
