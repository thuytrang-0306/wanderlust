import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/core/widgets/app_text_field.dart';
import 'package:wanderlust/presentation/controllers/settings/change_password_controller.dart';

class ChangePasswordPage extends GetView<ChangePasswordController> {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Đổi mật khẩu',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info message
                Container(
                  padding: EdgeInsets.all(AppSpacing.s4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 20.sp),
                      SizedBox(width: AppSpacing.s3),
                      Expanded(
                        child: Text(
                          'Mật khẩu mới phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường và số',
                          style: AppTypography.bodyS.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: AppSpacing.s6),
                
                // Current password
                Text(
                  'Mật khẩu hiện tại',
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.s2),
                Obx(() => AppTextField.password(
                  controller: controller.currentPasswordController,
                  label: 'Mật khẩu hiện tại',
                  hintText: 'Nhập mật khẩu hiện tại',
                  validator: controller.validateCurrentPassword,
                  isPasswordVisible: controller.showCurrentPassword.value,
                  togglePasswordVisibility: controller.toggleCurrentPassword,
                )),
                
                SizedBox(height: AppSpacing.s5),
                
                // New password
                Text(
                  'Mật khẩu mới',
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.s2),
                Obx(() => AppTextField.password(
                  controller: controller.newPasswordController,
                  label: 'Mật khẩu mới',
                  hintText: 'Nhập mật khẩu mới',
                  validator: controller.validateNewPassword,
                  isPasswordVisible: controller.showNewPassword.value,
                  togglePasswordVisibility: controller.toggleNewPassword,
                )),
                
                SizedBox(height: AppSpacing.s5),
                
                // Confirm password
                Text(
                  'Xác nhận mật khẩu mới',
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.s2),
                Obx(() => AppTextField.password(
                  controller: controller.confirmPasswordController,
                  label: 'Xác nhận mật khẩu',
                  hintText: 'Nhập lại mật khẩu mới',
                  validator: controller.validateConfirmPassword,
                  isPasswordVisible: controller.showConfirmPassword.value,
                  togglePasswordVisibility: controller.toggleConfirmPassword,
                )),
                
                // Password strength indicator
                SizedBox(height: AppSpacing.s4),
                Obx(() {
                  if (controller.newPasswordText.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Độ mạnh mật khẩu',
                        style: AppTypography.bodyS.copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: AppSpacing.s2),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: controller.passwordStrength.value,
                              minHeight: 4.h,
                              backgroundColor: AppColors.neutral200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                controller.getPasswordStrengthColor(),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.s3),
                          Text(
                            controller.getPasswordStrengthText(),
                            style: AppTypography.bodyS.copyWith(
                              color: controller.getPasswordStrengthColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                
                SizedBox(height: AppSpacing.s8),
                
                // Submit button
                Obx(() => AppButton.primary(
                  text: 'Đổi mật khẩu',
                  onPressed: controller.changePassword,
                  isLoading: controller.isChangePasswordLoading.value,
                )),
                
                SizedBox(height: AppSpacing.s4),
                
                // Forgot password link
                Center(
                  child: TextButton(
                    onPressed: controller.forgotPassword,
                    child: Text(
                      'Quên mật khẩu?',
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}