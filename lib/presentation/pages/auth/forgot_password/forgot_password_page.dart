import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
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
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
            size: 24.sp,
          ),
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
                _buildEmailField(controller),
                
                const Spacer(flex: 1),
                
                // Send button
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: controller.isLoading 
                        ? null 
                        : controller.sendPasswordResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Gửi',
                            style: AppTypography.button.copyWith(
                              color: AppColors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                  ),
                )),
                
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
                        const TextSpan(
                          text: 'Bằng việc đăng ký, bạn đã đồng ý với\n',
                        ),
                        TextSpan(
                          text: 'Điều khoản và dịch vụ',
                          style: TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
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
                          recognizer: TapGestureRecognizer()
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
  
  Widget _buildEmailField(ForgotPasswordController controller) {
    return TextFormField(
      controller: controller.emailController,
      validator: controller.validateEmail,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => controller.sendPasswordResetEmail(),
      style: AppTypography.bodyM.copyWith(
        color: AppColors.textPrimary,
        fontSize: 16.sp,
      ),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: AppTypography.bodyM.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
        ),
        hintText: 'Nhập email của bạn',
        hintStyle: AppTypography.bodyM.copyWith(
          color: AppColors.textHint.withValues(alpha: 0.5),
          fontSize: 16.sp,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: AppTypography.bodyS.copyWith(
          color: AppColors.textSecondary,
          fontSize: 12.sp,
          fontWeight: AppTypography.medium,
        ),
        filled: true,
        fillColor: AppColors.neutral50.withValues(alpha: 0.5),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: 18.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.s3),
          borderSide: BorderSide(
            color: AppColors.neutral200.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.s3),
          borderSide: BorderSide(
            color: AppColors.neutral200.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.s3),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.s3),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.s3),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}