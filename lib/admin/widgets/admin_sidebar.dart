import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../routes/admin_routes.dart';
import '../controllers/admin_auth_controller.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AdminAuthController>();
    
    return Container(
      width: 280.w,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo and title
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9455FD),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wanderlust',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Navigation menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              children: [
                _buildMenuSection('Analytics', [
                  _buildMenuItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    route: AdminRoutes.DASHBOARD,
                  ),
                  _buildMenuItem(
                    icon: Icons.analytics_outlined,
                    title: 'Analytics',
                    route: AdminRoutes.ANALYTICS,
                  ),
                ]),
                
                _buildMenuSection('Management', [
                  _buildMenuItem(
                    icon: Icons.people_outline,
                    title: 'Users',
                    route: AdminRoutes.USERS,
                  ),
                  _buildMenuItem(
                    icon: Icons.business_outlined,
                    title: 'Businesses',
                    route: AdminRoutes.BUSINESS,
                  ),
                  _buildMenuItem(
                    icon: Icons.approval_outlined,
                    title: 'Approvals',
                    route: AdminRoutes.BUSINESS_APPROVAL,
                    badge: '3',
                  ),
                ]),
                
                _buildMenuSection('Content', [
                  _buildMenuItem(
                    icon: Icons.article_outlined,
                    title: 'Blog Moderation',
                    route: AdminRoutes.BLOG_MODERATION,
                  ),
                  _buildMenuItem(
                    icon: Icons.list_alt_outlined,
                    title: 'Listing Moderation',
                    route: AdminRoutes.LISTING_MODERATION,
                  ),
                  _buildMenuItem(
                    icon: Icons.report_outlined,
                    title: 'Content Reports',
                    route: AdminRoutes.CONTENT_REPORTS,
                    badge: '7',
                  ),
                ]),
                
                _buildMenuSection('System', [
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    route: AdminRoutes.SETTINGS,
                  ),
                  _buildMenuItem(
                    icon: Icons.assessment_outlined,
                    title: 'Reports',
                    route: AdminRoutes.REPORTS,
                  ),
                ]),
              ],
            ),
          ),
          
          // User info and logout
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Obx(() => Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: const Color(0xFF9455FD),
                      child: Text(
                        authController.currentUser?.email?.substring(0, 1).toUpperCase() ?? 'A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authController.currentUser?.email ?? 'Admin',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            authController.adminRole.capitalizeFirst ?? 'Admin',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: authController.logout,
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
        SizedBox(height: 8.h),
      ],
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String route,
    String? badge,
  }) {
    final isActive = Get.currentRoute == route;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: Material(
        color: isActive ? const Color(0xFF9455FD).withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        child: InkWell(
          onTap: () => Get.toNamed(route),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: isActive ? const Color(0xFF9455FD) : const Color(0xFF64748B),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? const Color(0xFF9455FD) : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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