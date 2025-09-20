import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderlust/admin/services/admin_auth_service.dart';
import 'package:wanderlust/admin/controllers/admin_settings_controller.dart';
import 'package:wanderlust/shared/core/models/admin_model.dart';
import 'package:wanderlust/shared/core/widgets/app_snackbar.dart';

class AdminSettingsTab extends GetView<AdminSettingsController> {
  const AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adminAuthService = Get.find<AdminAuthService>();
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      return Row(
        children: [
          // Left Navigation Panel
          Container(
            width: 280.w,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: const Color(0xFFF3F4F6), width: 1.w),
              ),
            ),
            child: _buildNavigationPanel(),
          ),
          
          // Main Content Area
          Expanded(
            child: _buildMainContent(adminAuthService),
          ),
        ],
      );
    });
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileCard(AdminModel? admin) {
    if (admin == null) return const SizedBox();
    
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: const Color(0xFF3B82F6),
            child: Text(
              admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin.name.isNotEmpty ? admin.name : 'Admin User',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  admin.email,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4.h),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    admin.role.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFF3F4F6)),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20.sp,
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDangerItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: const Color(0xFFEF4444),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20.sp,
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavigationPanel() {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFF3F4F6)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.settings,
                size: 24.sp,
                color: const Color(0xFF374151),
              ),
              SizedBox(width: 12.w),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        
        // Navigation Items
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _buildNavItem('Profile', 'profile', Icons.person_outline),
              _buildNavItem('Change Password', 'password', Icons.lock_outline),
              _buildNavItem('Login History', 'history', Icons.history_outlined),
              _buildNavItem('Email Templates', 'templates', Icons.email_outlined),
              _buildNavItem('System Settings', 'system', Icons.settings_outlined),
              _buildNavItem('Two-Factor Auth', 'security', Icons.security_outlined),
            ],
          ),
        ),
        
        // Sign Out
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFF3F4F6)),
            ),
          ),
          child: _buildDangerItem(
            'Sign Out',
            'Sign out from admin account',
            Icons.logout,
            () => Get.find<AdminAuthService>().logout(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNavItem(String title, String view, IconData icon) {
    return Obx(() => Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.changeView(view),
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          margin: EdgeInsets.only(bottom: 4.h),
          decoration: BoxDecoration(
            color: controller.currentView.value == view
                ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: controller.currentView.value == view
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF6B7280),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: controller.currentView.value == view
                      ? FontWeight.w500
                      : FontWeight.w400,
                  color: controller.currentView.value == view
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
  
  Widget _buildMainContent(AdminAuthService adminAuthService) {
    return Obx(() {
      switch (controller.currentView.value) {
        case 'profile':
          return _buildProfileView(adminAuthService);
        case 'password':
          return _buildPasswordView();
        case 'history':
          return _buildLoginHistoryView();
        case 'templates':
          return _buildEmailTemplatesView();
        case 'system':
          return _buildSystemSettingsView();
        case 'security':
          return _build2FAView();
        default:
          return _buildProfileView(adminAuthService);
      }
    });
  }
  
  Widget _buildProfileView(AdminAuthService adminAuthService) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Profile',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 24.h),
          
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() => _buildProfileCard(adminAuthService.currentAdmin)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPasswordView() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Password',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 24.h),
          
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() => TextFormField(
                  controller: currentPasswordController,
                  obscureText: !controller.showCurrentPassword.value,
                  decoration: InputDecoration(
                    hintText: 'Enter current password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.showCurrentPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => controller.togglePasswordVisibility('current'),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                )),
                SizedBox(height: 16.h),
                
                Text(
                  'New Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() => TextFormField(
                  controller: newPasswordController,
                  obscureText: !controller.showNewPassword.value,
                  decoration: InputDecoration(
                    hintText: 'Enter new password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.showNewPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => controller.togglePasswordVisibility('new'),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                )),
                SizedBox(height: 16.h),
                
                Text(
                  'Confirm New Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() => TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !controller.showConfirmPassword.value,
                  decoration: InputDecoration(
                    hintText: 'Confirm new password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.showConfirmPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => controller.togglePasswordVisibility('confirm'),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                )),
                SizedBox(height: 24.h),
                
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isChangingPassword.value
                        ? null
                        : () async {
                            final success = await controller.changePassword(
                              currentPassword: currentPasswordController.text,
                              newPassword: newPasswordController.text,
                              confirmPassword: confirmPasswordController.text,
                            );
                            if (success) {
                              currentPasswordController.clear();
                              newPasswordController.clear();
                              confirmPasswordController.clear();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: controller.isChangingPassword.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoginHistoryView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Login History',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => controller.loadLoginHistory(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                  SizedBox(width: 8.w),
                  TextButton.icon(
                    onPressed: () => controller.clearLoginHistory(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear History'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() {
              if (controller.isLoadingHistory.value) {
                return Container(
                  height: 200.h,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              
              if (controller.loginHistory.isEmpty) {
                return Container(
                  height: 200.h,
                  child: const Center(child: Text('No login history found')),
                );
              }
              
              return Column(
                children: controller.loginHistory.take(20).map((entry) {
                  final timestamp = entry['timestamp'] as Timestamp?;
                  final date = timestamp?.toDate() ?? DateTime.now();
                  
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF3F4F6)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: entry['success'] == true
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : const Color(0xFFEF4444).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            entry['success'] == true
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            size: 20.sp,
                            color: entry['success'] == true
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry['device']} Login',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              Text(
                                '${entry['ipAddress']} • ${entry['location']}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmailTemplatesView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Email Templates',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Obx(() => ElevatedButton.icon(
                onPressed: controller.isSaving.value
                    ? null
                    : () => controller.saveEmailTemplates(),
                icon: controller.isSaving.value
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(controller.isSaving.value ? 'Saving...' : 'Save Templates'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                ),
              )),
            ],
          ),
          SizedBox(height: 24.h),
          
          Obx(() {
            if (controller.isLoadingTemplates.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return Column(
              children: controller.emailTemplates.entries.map((entry) {
                final templateKey = entry.key;
                final template = entry.value as Map<String, dynamic>;
                
                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            templateKey.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          Switch(
                            value: template['enabled'] ?? true,
                            onChanged: (value) {
                              template['enabled'] = value;
                              controller.updateEmailTemplate(templateKey, template);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      
                      Text(
                        'Subject',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        initialValue: template['subject'] ?? '',
                        onChanged: (value) {
                          template['subject'] = value;
                          controller.updateEmailTemplate(templateKey, template);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      
                      Text(
                        'Body',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        initialValue: template['body'] ?? '',
                        maxLines: 4,
                        onChanged: (value) {
                          template['body'] = value;
                          controller.updateEmailTemplate(templateKey, template);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          hintText: 'Use {{variableName}} for dynamic content',
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildSystemSettingsView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'System Settings',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Obx(() => ElevatedButton.icon(
                onPressed: controller.isSaving.value
                    ? null
                    : () => controller.saveSystemSettings(),
                icon: controller.isSaving.value
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(controller.isSaving.value ? 'Saving...' : 'Save Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                ),
              )),
            ],
          ),
          SizedBox(height: 24.h),
          
          Obx(() {
            if (controller.isLoadingSystemSettings.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return Column(
              children: [
                _buildSystemSettingCard('User Management', 'userManagement'),
                SizedBox(height: 16.h),
                _buildSystemSettingCard('Business Verification', 'businessVerification'),
                SizedBox(height: 16.h),
                _buildSystemSettingCard('Content Moderation', 'contentModeration'),
                SizedBox(height: 16.h),
                _buildSystemSettingCard('Security', 'security'),
              ],
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildSystemSettingCard(String title, String category) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16.h),
          
          Obx(() {
            final settings = controller.systemSettings[category] as Map<String, dynamic>? ?? {};
            
            return Column(
              children: settings.entries.map((entry) {
                final key = entry.key;
                final value = entry.value;
                
                if (value is bool) {
                  return _buildBooleanSetting(category, key, value);
                } else if (value is int) {
                  return _buildIntegerSetting(category, key, value);
                } else if (value is double) {
                  return _buildDoubleSetting(category, key, value);
                } else {
                  return const SizedBox();
                }
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildBooleanSetting(String category, String key, bool value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              key.replaceAll(RegExp(r'([a-z])([A-Z])'), r'\$1 \$2').toUpperCase(),
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              controller.updateSystemSetting(category, key, newValue);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildIntegerSetting(String category, String key, int value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              key.replaceAll(RegExp(r'([a-z])([A-Z])'), r'\$1 \$2').toUpperCase(),
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          SizedBox(
            width: 100.w,
            child: TextFormField(
              initialValue: value.toString(),
              keyboardType: TextInputType.number,
              onChanged: (newValue) {
                final intValue = int.tryParse(newValue);
                if (intValue != null) {
                  controller.updateSystemSetting(category, key, intValue);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDoubleSetting(String category, String key, double value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              key.replaceAll(RegExp(r'([a-z])([A-Z])'), r'\$1 \$2').toUpperCase(),
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          SizedBox(
            width: 100.w,
            child: TextFormField(
              initialValue: value.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (newValue) {
                final doubleValue = double.tryParse(newValue);
                if (doubleValue != null) {
                  controller.updateSystemSetting(category, key, doubleValue);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _build2FAView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Two-Factor Authentication',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 24.h),
          
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() {
              if (controller.twoFactorEnabled.value) {
                return _build2FAEnabledView();
              } else {
                return _build2FASetupView();
              }
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _build2FAEnabledView() {
    return Column(
      children: [
        Icon(
          Icons.security,
          size: 64.sp,
          color: const Color(0xFF10B981),
        ),
        SizedBox(height: 16.h),
        Text(
          '2FA Enabled',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Your account is protected with two-factor authentication',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => controller.disable2FA(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Disable 2FA',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _build2FASetupView() {
    final verificationController = TextEditingController();
    
    return Column(
      children: [
        Icon(
          Icons.security_outlined,
          size: 64.sp,
          color: const Color(0xFF6B7280),
        ),
        SizedBox(height: 16.h),
        Text(
          'Setup Two-Factor Authentication',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Add an extra layer of security to your admin account',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        
        Obx(() {
          if (controller.qrCodeData.isEmpty) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isEnabling2FA.value
                    ? null
                    : () => controller.enable2FA(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: controller.isEnabling2FA.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Enable 2FA',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            );
          }
          
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Scan this QR code with your authenticator app',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: 200.w,
                      height: 200.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: const Center(
                        child: Text('QR Code\n(Authenticator App Required)'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              
              Text(
                'Enter verification code',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: verificationController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await controller.verify2FAAndEnable(
                      verificationController.text,
                    );
                    if (success) {
                      verificationController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Verify and Enable',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}