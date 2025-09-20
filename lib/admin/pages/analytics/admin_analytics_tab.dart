import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_analytics_controller.dart';
import 'package:wanderlust/admin/widgets/stats_card.dart';
import 'package:wanderlust/admin/widgets/charts/interactive_line_chart.dart';
import 'package:wanderlust/admin/widgets/charts/pie_chart.dart';
import 'package:wanderlust/admin/widgets/charts/bar_chart.dart';

class AdminAnalyticsTab extends GetView<AdminAnalyticsController> {
  const AdminAnalyticsTab({super.key});

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
            // Header with time range selector
            _buildHeader(),
            SizedBox(height: 24.h),
            
            // Key metrics
            _buildKeyMetrics(),
            SizedBox(height: 32.h),
            
            // Charts section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User analytics chart
                Expanded(
                  flex: 2,
                  child: _buildUserAnalyticsChart(),
                ),
                SizedBox(width: 24.w),
                
                // Engagement metrics
                Expanded(
                  child: _buildEngagementMetrics(),
                ),
              ],
            ),
            
            SizedBox(height: 32.h),
            
            // Platform breakdown and retention
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPlatformBreakdown(),
                ),
                SizedBox(width: 24.w),
                Expanded(
                  child: _buildRetentionChart(),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Analytics Overview',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        
        // Time range selector
        Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButton<String>(
            value: controller.selectedTimeRange.value,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: '7days', child: Text('Last 7 Days')),
              DropdownMenuItem(value: '30days', child: Text('Last 30 Days')),
              DropdownMenuItem(value: '90days', child: Text('Last 90 Days')),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.onTimeRangeChanged(value);
              }
            },
          ),
        )),
      ],
    );
  }

  Widget _buildKeyMetrics() {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'User Growth',
            value: '${controller.userGrowthRate.toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            color: const Color(0xFF10B981),
            trend: controller.userGrowthRate > 0 ? '+${controller.userGrowthRate.toStringAsFixed(1)}%' : '${controller.userGrowthRate.toStringAsFixed(1)}%',
            subtitle: 'vs previous period',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: StatsCard(
            title: 'Engagement Rate',
            value: '${controller.engagementRate.toStringAsFixed(1)}%',
            icon: Icons.favorite,
            color: const Color(0xFFEF4444),
            trend: '+5%',
            subtitle: 'vs last period',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: StatsCard(
            title: 'Avg Session Time',
            value: controller.averageSessionTime,
            icon: Icons.access_time,
            color: const Color(0xFF8B5CF6),
            trend: '+2m',
            subtitle: 'vs last period',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Obx(() => StatsCard(
            title: 'Total Sessions',
            value: controller.engagementData.isNotEmpty 
                ? controller.engagementData.fold<int>(0, (sum, item) => sum + (item['sessions'] as int)).toString()
                : '0',
            icon: Icons.computer,
            color: const Color(0xFF3B82F6),
            trend: '+12%',
            subtitle: 'vs last period',
          )),
        ),
      ],
    );
  }

  Widget _buildUserAnalyticsChart() {
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
                'User Analytics',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'New Users',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          SizedBox(
            height: 250.h,
            child: Obx(() {
              final data = controller.userAnalytics;
              if (data.isEmpty) {
                return const Center(child: Text('No data available'));
              }
              
              return InteractiveLineChart(
                data: data,
                title: 'User Analytics',
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

  Widget _buildEngagementMetrics() {
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
            'Engagement Metrics',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 24.h),
          
          Obx(() {
            if (controller.engagementData.isEmpty) {
              return const Center(child: Text('No data available'));
            }
            
            final latest = controller.engagementData.last;
            return Column(
              children: [
                _buildEngagementItem(
                  'Daily Active Users',
                  '${latest['engagement']}%',
                  Icons.people_alt,
                  const Color(0xFF10B981),
                ),
                SizedBox(height: 16.h),
                _buildEngagementItem(
                  'Total Sessions',
                  '${latest['sessions']}',
                  Icons.computer,
                  const Color(0xFF3B82F6),
                ),
                SizedBox(height: 16.h),
                _buildEngagementItem(
                  'Avg Session Time',
                  '${(latest['avgSessionTime'] / 60).round()}m',
                  Icons.access_time,
                  const Color(0xFF8B5CF6),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEngagementItem(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: color,
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
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformBreakdown() {
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
            'Platform Breakdown',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 24.h),
          
          SizedBox(
            height: 250.h,
            child: Obx(() {
              final platforms = controller.platformStats['platforms'] as List<dynamic>? ?? [];
              if (platforms.isEmpty) {
                return const Center(child: Text('No data available'));
              }
              
              final total = platforms.fold<int>(0, (sum, p) => sum + (p['users'] as int));
              final pieData = platforms.map<PieChartData>((platform) {
                final percentage = total > 0 ? (platform['users'] / total * 100) : 0.0;
                return PieChartData(
                  label: platform['name'],
                  value: platform['users'].toDouble(),
                  percentage: percentage,
                  color: Color(platform['color']),
                );
              }).toList();
              
              return InteractivePieChart(
                data: pieData,
                title: 'Platform Distribution',
                showLabels: true,
                showLegend: true,
                showPercentage: true,
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget _buildRetentionChart() {
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
            'User Retention',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 24.h),
          
          SizedBox(
            height: 200.h,
            child: Obx(() {
              final retentionData = controller.retentionData;
              if (retentionData.isEmpty) {
                return const Center(child: Text('No data available'));
              }
              
              final barData = retentionData.map<BarChartData>((data) {
                final retention = data['retention'] as int;
                Color color;
                if (retention > 70) {
                  color = const Color(0xFF10B981); // Green
                } else if (retention > 50) {
                  color = const Color(0xFFF59E0B); // Yellow
                } else if (retention > 30) {
                  color = const Color(0xFFEF4444); // Red
                } else {
                  color = const Color(0xFF9CA3AF); // Gray
                }
                
                return BarChartData(
                  label: data['period'],
                  value: retention.toDouble(),
                  color: color,
                );
              }).toList();
              
              return InteractiveBarChart(
                data: barData,
                title: 'User Retention',
                barColor: const Color(0xFF3B82F6),
                showValues: true,
                showTooltip: true,
                horizontal: true,
              );
            }),
          ),
        ],
      ),
    );
  }


}