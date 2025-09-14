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
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.textTertiary,
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
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.s6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image - 40% of available height
                        SizedBox(
                          height: 0.4.sh,
                          child: Image.asset(
                            page.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                        
                        SizedBox(height: AppSpacing.s10),
                        
                        // Title - Bold, primary color as per design
                        Text(
                          page.title,
                          style: AppTypography.h1.copyWith(
                            color: AppColors.secondary, // Deep purple #3D1A73
                            fontWeight: AppTypography.bold,
                            fontSize: 28.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: AppSpacing.s4),
                        
                        // Subtitle - Light gray as per design
                        Text(
                          page.subtitle,
                          style: AppTypography.bodyL.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom section: dots and buttons
            Padding(
              padding: EdgeInsets.all(AppSpacing.s6),
              child: Column(
                children: [
                  // Page indicators (3 dots)
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.onboardingPages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        height: 8.h,
                        width: controller.currentPage.value == index ? 24.w : 8.w,
                        decoration: BoxDecoration(
                          color: controller.currentPage.value == index
                              ? AppColors.primary
                              : AppColors.greyLight,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  )),
                  
                  SizedBox(height: AppSpacing.s8),
                  
                  // Action buttons
                  Obx(() {
                    final isLast = controller.currentPage.value == 
                        controller.onboardingPages.length - 1;
                    
                    return Column(
                      children: [
                        // Primary button - "Tạo tài khoản" on last page
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: controller.navigateToRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isLast ? 'Tạo tài khoản' : 'Tiếp theo',
                              style: AppTypography.button.copyWith(
                                color: AppColors.white,
                                fontSize: 16.sp,
                                fontWeight: AppTypography.semiBold,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: AppSpacing.s4),
                        
                        // Secondary button - "Đăng nhập" (outlined)
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: OutlinedButton(
                            onPressed: controller.navigateToLogin,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.r),
                              ),
                            ),
                            child: Text(
                              'Đăng nhập',
                              style: AppTypography.button.copyWith(
                                color: AppColors.primary,
                                fontSize: 16.sp,
                                fontWeight: AppTypography.semiBold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  
                  SizedBox(height: AppSpacing.s2),
                  
                  // Bottom indicator bar (iPhone style)
                  Container(
                    width: 134.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(2.5.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}