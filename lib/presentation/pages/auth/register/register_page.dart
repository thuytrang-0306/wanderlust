import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
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
                SizedBox(height: 30.h),
                
                // Logo and app name - Smaller size
                _buildCompactLogoSection(),
                
                SizedBox(height: AppSpacing.s3),
                
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
                
                // Name input
                _buildTextField(
                  controller: controller.nameController,
                  label: 'Tên đăng ký',
                  hintText: 'Nhập tên của bạn',
                  validator: controller.validateName,
                  keyboardType: TextInputType.name,
                ),
                
                SizedBox(height: AppSpacing.s4),
                
                // Email input
                _buildTextField(
                  controller: controller.emailController,
                  label: 'Email',
                  hintText: 'Nhập email của bạn',
                  validator: controller.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                SizedBox(height: AppSpacing.s4),
                
                // Password input
                Obx(() => _buildTextField(
                  controller: controller.passwordController,
                  label: 'Mật khẩu',
                  hintText: '••••••••',
                  validator: controller.validatePassword,
                  obscureText: !controller.isPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textTertiary,
                      size: 20.sp,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                )),
                
                SizedBox(height: AppSpacing.s3),
                
                // Register button
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: controller.isLoading ? null : controller.register,
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
                            'Đăng ký',
                            style: AppTypography.button.copyWith(
                              color: AppColors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                  ),
                )),
                
                SizedBox(height: AppSpacing.s3),
                
                // Or login with
                Text(
                  'Hoặc đăng nhập với',
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                SizedBox(height: AppSpacing.s3),
                
                // Social login buttons
                _buildSocialButtons(controller),
                
                SizedBox(height: AppSpacing.s3),
                
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
                
                SizedBox(height: AppSpacing.s6),
                
                // Already have account
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Bạn đã có tài khoản? '),
                      TextSpan(
                        text: 'Đăng nhập ngay',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: AppTypography.medium,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = controller.navigateToLogin,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: AppSpacing.s2),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo icon
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.location_on_rounded,
            color: AppColors.white,
            size: 48.sp,
          ),
        ),
        
        SizedBox(height: AppSpacing.s4),
        
        // App name
        Text(
          'Wanderlust',
          style: AppTypography.h1.copyWith(
            color: AppColors.primary,
            fontWeight: AppTypography.bold,
            fontSize: 32.sp,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompactLogoSection() {
    return Column(
      children: [
        // Logo image
        Image.asset(
          'assets/images/logo.png',
          width: 80.w,
          height: 80.w,
          fit: BoxFit.contain,
        ),
        
        SizedBox(height: AppSpacing.s2),
        
        // App name
        Text(
          'Wanderlust',
          style: AppTypography.h2.copyWith(
            color: AppColors.primary,
            fontWeight: AppTypography.bold,
            fontSize: 28.sp,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTypography.bodyM.copyWith(
        color: AppColors.textPrimary,
        fontSize: 16.sp,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodyM.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
        ),
        hintText: hintText,
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
        suffixIcon: suffixIcon,
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
  
  Widget _buildSocialButtons(RegisterController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google button
        _buildSocialButton(
          onTap: controller.signInWithGoogle,
          child: Image.asset(
            'assets/icons/google.png',
            width: 24.w,
            height: 24.w,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.g_mobiledata,
                size: 28.sp,
                color: Colors.red,
              );
            },
          ),
        ),
        
        SizedBox(width: AppSpacing.s6),
        
        // Facebook button
        _buildSocialButton(
          onTap: () {
            // TODO: Facebook login
          },
          child: Icon(
            Icons.facebook,
            size: 28.sp,
            color: const Color(0xFF1877F2),
          ),
        ),
        
        SizedBox(width: AppSpacing.s6),
        
        // Apple button
        _buildSocialButton(
          onTap: () {
            // TODO: Apple login
          },
          child: Icon(
            Icons.apple,
            size: 28.sp,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSocialButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.neutral200,
            width: 1,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}