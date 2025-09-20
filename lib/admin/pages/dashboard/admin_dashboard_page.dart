import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widgets/admin_layout.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/recent_activities_card.dart';
import '../../widgets/quick_actions_card.dart';

class AdminDashboardPage extends GetView<AdminDashboardController> {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Dashboard',
      actions: [
        IconButton(
          onPressed: controller.refreshDashboard,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
        SizedBox(width: 8.w),
        ElevatedButton.icon(
          onPressed: controller.exportDashboardData,
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Export'),
        ),
      ],
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats overview
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Stats cards grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: context.width > 1200 ? 4 : 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1.5,
                children: [
                  StatsCard(
                    title: 'Total Users',
                    value: controller.dashboardStats['totalUsers']?.toString() ?? '0',
                    icon: Icons.people,
                    color: const Color(0xFF3B82F6),
                    trend: '+12%',
                  ),
                  StatsCard(
                    title: 'Total Businesses',
                    value: controller.dashboardStats['totalBusinesses']?.toString() ?? '0',
                    icon: Icons.business,
                    color: const Color(0xFF10B981),
                    trend: '+8%',
                  ),
                  StatsCard(
                    title: 'Total Blogs',
                    value: controller.dashboardStats['totalBlogs']?.toString() ?? '0',
                    icon: Icons.article,
                    color: const Color(0xFF9455FD),
                    trend: '+24%',
                  ),
                  StatsCard(
                    title: 'Monthly Revenue',
                    value: '\$${(controller.dashboardStats['monthlyRevenue'] ?? 0).toStringAsFixed(0)}',
                    icon: Icons.monetization_on,
                    color: const Color(0xFFF59E0B),
                    trend: '+15%',
                  ),
                ],
              ),
              
              SizedBox(height: 32.h),
              
              // Content row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent activities
                  Expanded(
                    flex: 2,
                    child: RecentActivitiesCard(
                      activities: controller.recentActivities,
                    ),
                  ),
                  
                  SizedBox(width: 16.w),
                  
                  // Quick actions
                  Expanded(
                    flex: 1,
                    child: QuickActionsCard(),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}