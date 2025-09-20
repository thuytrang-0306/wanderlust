import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../shared/core/widgets/app_button.dart';
import '../../../shared/core/widgets/app_text_field.dart';
import '../../../shared/core/widgets/app_logo.dart';
import '../../../shared/core/widgets/app_snackbar.dart';
import '../../controllers/admin_setup_controller.dart';
import '../../theme/admin_theme.dart';

class AdminSetupPage extends StatelessWidget {
  const AdminSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminSetupController());

    return Scaffold(
      backgroundColor: AdminTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32.w),
            child: Container(
              constraints: BoxConstraints(maxWidth: 500.w),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(48.w),
                  child: Form(
                    key: controller.setupFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        AppLogo.auth(),
                        SizedBox(height: 32.h),
                        
                        // Title
                        Text(
                          'Admin Setup',
                          style: AdminTheme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AdminTheme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        
                        // Subtitle
                        Text(
                          'Create the first Super Admin account',
                          style: AdminTheme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32.h),
                        
                        // Setup Notice
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[700],
                                size: 20.w,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'This is a one-time setup. The Super Admin account will have full access to all admin features.',
                                  style: AdminTheme.textTheme.bodySmall?.copyWith(
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),
                        
                        // Name field
                        AppTextField.name(
                          controller: controller.nameController,
                          label: 'Full Name',
                          validator: controller.validateName,
                        ),
                        SizedBox(height: 20.h),
                        
                        // Email field
                        AppTextField.email(
                          controller: controller.emailController,
                          validator: controller.validateEmail,
                        ),
                        SizedBox(height: 20.h),
                        
                        // Password field
                        Obx(() => AppTextField.password(
                          controller: controller.passwordController,
                          validator: controller.validatePassword,
                          isPasswordVisible: controller.isPasswordVisible.value,
                          togglePasswordVisibility: controller.togglePasswordVisibility,
                          label: 'Password',
                        )),
                        SizedBox(height: 20.h),
                        
                        // Confirm Password field
                        Obx(() => AppTextField(
                          label: 'Confirm Password',
                          controller: controller.confirmPasswordController,
                          validator: controller.validateConfirmPassword,
                          obscureText: !controller.isConfirmPasswordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordVisible.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: controller.toggleConfirmPasswordVisibility,
                          ),
                        )),
                        SizedBox(height: 20.h),
                        
                        // Demo button for testing (only in debug mode)
                        if (const bool.fromEnvironment('dart.vm.product') == false) ...[
                          OutlinedButton(
                            onPressed: controller.fillDemoData,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AdminTheme.primaryColor,
                              side: BorderSide(color: AdminTheme.primaryColor),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Fill Demo Data',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                        
                        // Setup button
                        Obx(() => SizedBox(
                          width: double.infinity,
                          child: AppButton.primary(
                            text: 'Create Super Admin',
                            onPressed: controller.isLoading.value 
                                ? null 
                                : controller.createSuperAdmin,
                            isLoading: controller.isLoading.value,
                          ),
                        )),
                        SizedBox(height: 24.h),
                        
                        // Security notice
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.security,
                                color: Colors.orange[700],
                                size: 20.w,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'Please use a strong password and keep your credentials secure. This account will have administrative privileges.',
                                  style: AdminTheme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}