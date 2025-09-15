import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/auth/verify_email_controller.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyEmailController());
    
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s6),
          child: Column(
            children: [
              // Header with close button
              SizedBox(height: AppSpacing.s3),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                    onPressed: controller.closePage,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 24.w,
                      minHeight: 24.w,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Xác thực email của bạn',
                      style: AppTypography.bodyL.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: AppTypography.semiBold,
                        fontSize: 17.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 24.w), // Balance the close button
                ],
              ),
              
              SizedBox(height: 60.h),
              
              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                child: Obx(() => RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                      fontSize: 15.sp,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Chúng tôi vừa gửi link xác thực đến ',
                      ),
                      TextSpan(
                        text: controller.email.value,
                        style: TextStyle(
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                      const TextSpan(
                        text: '. Vui lòng kiểm tra hộp thư và nhấn vào link để xác thực.',
                      ),
                    ],
                  ),
                )),
              ),
              
              SizedBox(height: 40.h),
              
              // Email verification illustration
              Container(
                padding: EdgeInsets.all(AppSpacing.s6),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(AppSpacing.s4),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.mark_email_unread_outlined,
                      size: 64.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: AppSpacing.s4),
                    Text(
                      'Kiểm tra hộp thư',
                      style: AppTypography.bodyL.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: AppTypography.semiBold,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s2),
                    Text(
                      'Nhấn vào link trong email để xác thực tài khoản',
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.s3),
                    Obx(() => Text(
                      controller.isEmailVerified.value 
                        ? '✓ Email đã được xác thực'
                        : 'Đang chờ xác thực...',
                      style: AppTypography.bodyM.copyWith(
                        color: controller.isEmailVerified.value 
                          ? AppColors.success 
                          : AppColors.textSecondary,
                        fontWeight: AppTypography.medium,
                        fontSize: 14.sp,
                      ),
                    )),
                  ],
                ),
              ),
              
              SizedBox(height: 40.h),
              
              // Verify button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: controller.isVerifying.value 
                      ? null 
                      : controller.verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isVerifying.value
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Tôi đã xác thực',
                          style: AppTypography.button.copyWith(
                            color: AppColors.white,
                            fontSize: 16.sp,
                            fontWeight: AppTypography.semiBold,
                          ),
                        ),
                ),
              )),
              
              SizedBox(height: AppSpacing.s5),
              
              // Resend Email
              Obx(() => GestureDetector(
                onTap: controller.canResend.value ? controller.resendOTP : null,
                child: Text(
                  controller.canResend.value 
                      ? 'Gửi lại email' 
                      : 'Gửi lại email trong ${controller.secondsRemaining.value}s',
                  style: AppTypography.bodyM.copyWith(
                    color: controller.canResend.value ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 14.sp,
                    fontWeight: controller.canResend.value ? AppTypography.semiBold : AppTypography.regular,
                  ),
                ),
              )),
              
              const Spacer(),
              
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
              
              SizedBox(height: AppSpacing.s5),
              
              // Login link
              RichText(
                text: TextSpan(
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15.sp,
                  ),
                  children: [
                    const TextSpan(text: 'Bạn đã có tài khoản? '),
                    TextSpan(
                      text: 'Đăng nhập ngay',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: AppTypography.semiBold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = controller.navigateToLogin,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSpacing.s4),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOTPBox(VerifyEmailController controller, int index) {
    return SizedBox(
      width: 48.w,
      height: 48.h,
      child: TextFormField(
        controller: controller.otpControllers[index],
        focusNode: controller.focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: AppTypography.h4.copyWith(
          color: AppColors.textPrimary,
          fontWeight: AppTypography.semiBold,
          fontSize: 20.sp,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          controller.onOTPChanged(index, value);
        },
        decoration: InputDecoration(
          counterText: '',
          filled: false,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.s2),
            borderSide: BorderSide(
              color: AppColors.neutral200,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.s2),
            borderSide: BorderSide(
              color: AppColors.neutral200,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.s2),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.s2),
            borderSide: BorderSide(
              color: AppColors.error,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}