import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/services/admin_auth_service.dart';
import 'package:wanderlust/shared/core/models/admin_model.dart';

class AdminSettingsTab extends StatelessWidget {
  const AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adminAuthService = Get.find<AdminAuthService>();
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          
          // Profile Section
          _buildSection(
            'Admin Profile',
            [
              Obx(() => _buildProfileCard(adminAuthService.currentAdmin)),
            ],
          ),
          
          // System Settings Section
          _buildSection(
            'System Settings',
            [
              _buildSettingItem(
                'User Management',
                'Manage user permissions and access',
                Icons.people_outline,
                () => _showComingSoon(),
              ),
              _buildSettingItem(
                'Business Verification',
                'Configure business verification process',
                Icons.verified_outlined,
                () => _showComingSoon(),
              ),
              _buildSettingItem(
                'Content Moderation',
                'Set content moderation rules and policies',
                Icons.policy_outlined,
                () => _showComingSoon(),
              ),
              _buildSettingItem(
                'Email Templates',
                'Customize notification email templates',
                Icons.email_outlined,
                () => _showComingSoon(),
              ),
            ],
          ),
          
          // Security Section
          _buildSection(
            'Security',
            [
              _buildSettingItem(
                'Change Password',
                'Update your admin account password',
                Icons.lock_outline,
                () => _showComingSoon(),
              ),
              _buildSettingItem(
                'Two-Factor Authentication',
                'Enable 2FA for enhanced security',
                Icons.security_outlined,
                () => _showComingSoon(),
              ),
              _buildSettingItem(
                'Login History',
                'View recent admin login activities',
                Icons.history_outlined,
                () => _showComingSoon(),
              ),
            ],
          ),
          
          // Danger Zone
          _buildSection(
            'Danger Zone',
            [
              _buildDangerItem(
                'Sign Out',
                'Sign out from admin account',
                Icons.logout,
                () => adminAuthService.logout(),
              ),
            ],
          ),
          
          SizedBox(height: 40.h),
        ],
      ),
    );
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
  
  void _showComingSoon() {
    Get.snackbar(
      'Coming Soon',
      'This feature will be available in the next update',
      backgroundColor: const Color(0xFF3B82F6),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}