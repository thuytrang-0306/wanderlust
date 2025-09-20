import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_dashboard_controller.dart';
import 'package:wanderlust/admin/widgets/stats_card.dart';
import 'package:wanderlust/admin/widgets/recent_activities_card.dart';
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
            
            // Platform Statistics
            _buildPlatformStats(),
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
            height: 200.h,
            child: Obx(() {
              final chartData = controller.chartData;
              if (chartData.isEmpty) {
                return const Center(
                  child: Text('No data available'),
                );
              }
              
              return _buildSimpleLineChart(chartData);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleLineChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox();
    
    return Container(
      height: 200.h,
      child: CustomPaint(
        painter: SimpleLineChartPainter(data),
        size: Size.infinite,
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
          
          Row(
            children: [
              Expanded(
                child: _buildPlatformStatItem(
                  'Mobile App',
                  '85%',
                  Icons.phone_android,
                  const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: _buildPlatformStatItem(
                  'Web Platform',
                  '15%',
                  Icons.web,
                  const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformStatItem(String title, String percentage, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32.sp,
            color: color,
          ),
          SizedBox(height: 12.h),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple line chart painter for demonstration
class SimpleLineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  SimpleLineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final paint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    
    // Safe value extraction with null checks
    final values = data.map((e) {
      final value = e['value'];
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return 0.0;
    }).toList();
    
    if (values.isEmpty) return;
    
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 0) return; // Prevent division by zero
    
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final normalizedValue = values[i] / maxValue;
      final y = size.height - (normalizedValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Draw points using safe values
    final pointPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final normalizedValue = values[i] / maxValue;
      final y = size.height - (normalizedValue * size.height);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}