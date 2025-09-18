import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/core/widgets/app_text_field.dart';
import 'package:wanderlust/core/widgets/app_logo.dart';
import 'package:wanderlust/core/widgets/social_login_buttons.dart';
import 'package:wanderlust/core/widgets/divider_with_text.dart';
import 'package:wanderlust/presentation/controllers/auth/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s6),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                SizedBox(height: 60.h),

                // Logo and app name
                AppLogo.auth(),

                SizedBox(height: AppSpacing.s6),

                // Title
                Text(
                  'Chào mừng bạn trở lại với Wanderlust!',
                  style: AppTypography.bodyL.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTypography.medium,
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Form section - centered
                Column(
                  children: [
                    // Email input
                    AppTextField.email(
                      controller: controller.emailController,
                      validator: controller.validateEmail,
                      textInputAction: TextInputAction.next,
                    ),

                    SizedBox(height: AppSpacing.s4),

                    // Password input
                    Obx(
                      () => AppTextField.password(
                        controller: controller.passwordController,
                        isPasswordVisible: controller.isPasswordVisible.value,
                        togglePasswordVisibility: controller.togglePasswordVisibility,
                        validator: controller.validatePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => controller.login(),
                      ),
                    ),

                    SizedBox(height: AppSpacing.s4),

                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.navigateToForgotPassword,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Bạn quên mật khẩu?',
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.primary,
                            fontWeight: AppTypography.medium,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.s6),

                    // Login button
                    Obx(
                      () => AppButton.primary(
                        text: 'Đăng nhập',
                        onPressed: controller.login,
                        isLoading: controller.isLoading,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Or login with - with divider lines
                DividerWithText.orLoginWith(),

                SizedBox(height: AppSpacing.s5),

                // Social login buttons
                SocialLoginButtons(
                  onGooglePressed: controller.signInWithGoogle,
                  onFacebookPressed: () {
                    // TODO: Facebook login
                  },
                  onApplePressed: () {
                    // TODO: Apple login
                  },
                ),

                SizedBox(height: AppSpacing.s6),

                // Don't have account
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
                    children: [
                      const TextSpan(text: 'Bạn chưa có tài khoản? '),
                      TextSpan(
                        text: 'Đăng ký ngay',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: AppTypography.medium,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = controller.navigateToRegister,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
