import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../routes/admin_routes.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          _buildActionButton(
            icon: Icons.people,
            title: 'Manage Users',
            subtitle: 'View and moderate users',
            onTap: () => Get.toNamed(AdminRoutes.USERS),
          ),
          
          SizedBox(height: 12.h),
          
          _buildActionButton(
            icon: Icons.business,
            title: 'Business Approvals',
            subtitle: 'Review pending requests',
            badge: '3',
            onTap: () => Get.toNamed(AdminRoutes.BUSINESS_APPROVAL),
          ),
          
          SizedBox(height: 12.h),
          
          _buildActionButton(
            icon: Icons.article,
            title: 'Content Moderation',
            subtitle: 'Review blog posts',
            onTap: () => Get.toNamed(AdminRoutes.BLOG_MODERATION),
          ),
          
          SizedBox(height: 12.h),
          
          _buildActionButton(
            icon: Icons.analytics,
            title: 'View Analytics',
            subtitle: 'Detailed insights',
            onTap: () => Get.toNamed(AdminRoutes.ANALYTICS),
          ),
          
          SizedBox(height: 12.h),
          
          _buildActionButton(
            icon: Icons.settings,
            title: 'System Settings',
            subtitle: 'Configure platform',
            onTap: () => Get.toNamed(AdminRoutes.SYSTEM_SETTINGS),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF9455FD).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF9455FD),
                  size: 20.sp,
                ),
              ),
              
              SizedBox(width: 12.w),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
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
              
              SizedBox(width: 8.w),
              
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF94A3B8),
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}