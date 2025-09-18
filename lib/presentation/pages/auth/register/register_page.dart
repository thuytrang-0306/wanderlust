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
import 'package:wanderlust/presentation/controllers/auth/register_controller.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());

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
                SizedBox(height: 40.h),

                // Logo and app name - Smaller size
                AppLogo.auth(),

                SizedBox(height: AppSpacing.s4),

                // Title
                Text(
                  'Hãy bắt đầu với việc đăng ký tài khoản',
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
                    // Name input
                    AppTextField.name(
                      controller: controller.nameController,
                      label: 'Tên đăng ký',
                      hintText: 'Nhập tên của bạn',
                      validator: controller.validateName,
                      textInputAction: TextInputAction.next,
                    ),

                    SizedBox(height: AppSpacing.s4),

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
                        onFieldSubmitted: (_) => controller.register(),
                      ),
                    ),

                    SizedBox(height: AppSpacing.s5),

                    // Register button
                    Obx(
                      () => AppButton.primary(
                        text: 'Đăng ký',
                        onPressed: controller.register,
                        isLoading: controller.isLoading,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Or login with - with divider lines
                DividerWithText.orRegisterWith(),

                SizedBox(height: AppSpacing.s4),

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

                SizedBox(height: AppSpacing.s5),

                // Terms and conditions
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                        fontSize: 12.sp,
                      ),
                      children: [
                        const TextSpan(text: 'Bằng việc đăng ký, bạn đã đồng ý với\n'),
                        TextSpan(
                          text: 'Điều khoản và dịch vụ',
                          style: TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to terms
                                },
                        ),
                        const TextSpan(text: ' & '),
                        TextSpan(
                          text: 'Chính sách riêng tư',
                          style: TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to privacy policy
                                },
                        ),
                        const TextSpan(text: ' của ứng dụng'),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.s4),

                // Already have account
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
                    children: [
                      const TextSpan(text: 'Bạn đã có tài khoản? '),
                      TextSpan(
                        text: 'Đăng nhập ngay',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: AppTypography.medium,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = controller.navigateToLogin,
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
