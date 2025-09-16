import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
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
                _buildLogoSection(),
                
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
                    _buildTextField(
                      controller: controller.emailController,
                      label: 'Email',
                      hintText: 'Nhập email của bạn',
                      validator: controller.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    
                    SizedBox(height: AppSpacing.s4),
                    
                    // Password input
                    Obx(() => _buildTextField(
                      controller: controller.passwordController,
                      label: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu của bạn',
                      validator: controller.validatePassword,
                      obscureText: !controller.isPasswordVisible.value,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => controller.login(),
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
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: controller.isLoading ? null : controller.login,
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
                                'Đăng nhập',
                                style: AppTypography.button.copyWith(
                                  color: AppColors.white,
                                  fontSize: 16.sp,
                                ),
                              ),
                      ),
                    )),
                  ],
                ),
                
                const Spacer(),
                
                // Or login with - with divider lines
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.neutral200,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                      child: Text(
                        'Hoặc đăng nhập với',
                        style: AppTypography.bodyM.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.neutral200,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.s5),
                
                // Social login buttons
                _buildSocialButtons(controller),
                
                
                SizedBox(height: AppSpacing.s6),
                
                // Don't have account
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Bạn chưa có tài khoản? '),
                      TextSpan(
                        text: 'Đăng ký ngay',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: AppTypography.medium,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = controller.navigateToRegister,
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
  
  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo image
        Image.asset(
          'assets/images/logo.png',
          width: 80.w,
          height: 80.w,
          fit: BoxFit.contain,
        ),
        
        SizedBox(height: AppSpacing.s3),
        
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
    TextInputAction? textInputAction,
    Function(String)? onFieldSubmitted,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
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
  
  Widget _buildSocialButtons(LoginController controller) {
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