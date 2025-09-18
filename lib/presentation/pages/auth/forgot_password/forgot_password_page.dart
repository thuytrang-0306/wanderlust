import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/core/widgets/app_text_field.dart';
import 'package:wanderlust/presentation/controllers/auth/forgot_password_controller.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 24.sp),
          onPressed: controller.navigateBack,
        ),
        title: Text(
          'Đặt lại mật khẩu',
          style: AppTypography.bodyL.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppTypography.semiBold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s6),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Title with gradient
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return AppColors.primaryGradient.createShader(bounds);
                  },
                  child: Text(
                    'Quên mật khẩu',
                    style: AppTypography.h1.copyWith(
                      color: AppColors.white,
                      fontWeight: AppTypography.bold,
                      fontSize: 36.sp,
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.s4),

                // Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                  child: Text(
                    'Bạn hãy nhập email để nhận đường dẫn\nđặt lại mật khẩu',
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(flex: 2),

                // Email input
                AppTextField.email(
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => controller.sendPasswordResetEmail(),
                ),

                const Spacer(flex: 1),

                // Send button
                Obx(
                  () => AppButton.primary(
                    text: 'Gửi',
                    onPressed: controller.sendPasswordResetEmail,
                    isLoading: controller.isLoading,
                  ),
                ),

                const Spacer(flex: 4),

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
