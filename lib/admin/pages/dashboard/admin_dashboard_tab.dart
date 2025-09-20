import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_dashboard_controller.dart';
import 'package:wanderlust/admin/widgets/stats_card.dart';
import 'package:wanderlust/admin/widgets/recent_activities_card.dart';
import 'package:wanderlust/admin/widgets/charts/interactive_line_chart.dart';
import 'package:wanderlust/admin/widgets/charts/pie_chart.dart';
import 'package:wanderlust/admin/widgets/charts/bar_chart.dart';
import 'package:wanderlust/shared/core/services/user_service.dart';

class AdminDashboardTab extends GetView<AdminDashboardController> {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
            
            // Real-time stats from UserService
            _buildRealTimeStats(),
            
            SizedBox(height: 32.h),
            
            // Charts and analytics
            Row(
              children: [
                // User Growth Chart
                Expanded(
                  flex: 2,
                  child: _buildUserGrowthChart(),
                ),
                SizedBox(width: 24.w),
                
                // Recent Activities
                Expanded(
                  child: RecentActivitiesCard(
                    activities: controller.recentActivities,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 32.h),
            
            // Bottom row with Platform and Activity charts
            Row(
              children: [
                // Platform Statistics
                Expanded(
                  child: _buildPlatformStats(),
                ),
                SizedBox(width: 24.w),
                
                // User Activity Chart
                Expanded(
                  child: _buildUserActivityChart(),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRealTimeStats() {
    final userService = Get.find<UserService>();
    
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: Row(
          children: [
        SizedBox(
          width: 280.w,
          child: StatsCard(
            title: 'Total Users',
            value: userService.totalUsers.value.toString(),
            icon: Icons.people,
            color: const Color(0xFF3B82F6),
            trend: '+12%',
            subtitle: 'vs last month',
          ),
        ),
        SizedBox(width: 16.w),
        SizedBox(
          width: 280.w,
          child: StatsCard(
            title: 'Active Users',
            value: userService.activeUsers.value.toString(),
            icon: Icons.verified_user,
            color: const Color(0xFF10B981),
            trend: '+8%',
            subtitle: 'vs last month',
          ),
        ),
        SizedBox(width: 16.w),
        SizedBox(
          width: 280.w,
          child: StatsCard(
            title: 'New Today',
            value: userService.newUsersToday.value.toString(),
            icon: Icons.person_add,
            color: const Color(0xFF8B5CF6),
            trend: '+2',
            subtitle: 'since yesterday',
          ),
        ),
        SizedBox(width: 16.w),
        SizedBox(
          width: 280.w,
          child: Obx(() => StatsCard(
            title: 'Banned Users',
            value: userService.bannedUsers.value.toString(),
            icon: Icons.block,
            color: const Color(0xFFEF4444),
            trend: controller.getBannedUsersTrend(),
            subtitle: 'moderation actions',
          )),
        ),
          ],
        ),
      ),
    ));
  }

  Widget _buildUserGrowthChart() {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Growth',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  controller.selectedTimeRange.value.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              )),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Chart area
          SizedBox(
            height: 250.h,
            child: Obx(() {
              final chartData = controller.chartData;
              if (chartData.isEmpty) {
                return const Center(
                  child: Text('No data available'),
                );
              }
              
              return InteractiveLineChart(
                data: chartData,
                title: 'User Growth Over Time',
                lineColor: const Color(0xFF3B82F6),
                areaColor: const Color(0xFF3B82F6),
                showArea: true,
                showPoints: true,
                showTooltip: true,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserActivityChart() {
    return Container(
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
            'User Activity Metrics',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 24.h),
          
          SizedBox(
            height: 250.h,
            child: InteractiveBarChart(
              data: [
                BarChartData(
                  label: 'Daily',
                  value: 85.0,
                  color: const Color(0xFF10B981),
                ),
                BarChartData(
                  label: 'Weekly',
                  value: 72.0,
                  color: const Color(0xFF3B82F6),
                ),
                BarChartData(
                  label: 'Monthly',
                  value: 68.0,
                  color: const Color(0xFF8B5CF6),
                ),
                BarChartData(
                  label: 'Retention',
                  value: 45.0,
                  color: const Color(0xFFF59E0B),
                ),
              ],
              title: 'Activity Rates',
              showValues: true,
              showTooltip: true,
              horizontal: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformStats() {
    return Container(
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
            'Platform Statistics',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 24.h),
          
          SizedBox(
            height: 300.h,
            child: InteractivePieChart(
              data: [
                PieChartData(
                  label: 'Mobile App',
                  value: 850,
                  percentage: 85.0,
                  color: const Color(0xFF10B981),
                ),
                PieChartData(
                  label: 'Web Platform',
                  value: 150,
                  percentage: 15.0,
                  color: const Color(0xFF3B82F6),
                ),
              ],
              title: 'Platform Distribution',
              showLabels: true,
              showLegend: true,
              showPercentage: true,
            ),
          ),
        ],
      ),
    );
  }

}