import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/trips/my_trips_controller.dart';

class MyTripsPage extends GetView<MyTripsController> {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Chuyến đi của tôi', style: AppTypography.heading5),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.primary, size: 24.sp),
            onPressed: controller.createNewTrip,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: controller.tabController,
              tabs: const [
                Tab(text: 'Sắp tới'),
                Tab(text: 'Đang diễn ra'),
                Tab(text: 'Đã hoàn thành'),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: AppTypography.bodyMedium,
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildTripsList(controller.upcomingTrips),
                _buildTripsList(controller.ongoingTrips),
                _buildTripsList(controller.completedTrips),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(RxList<Map<String, dynamic>> trips) {
    return Obx(() {
      if (controller.isLoadingTrips.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (trips.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppSpacing.s5),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildTripCard(trip);
        },
      );
    });
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final daysLeft = _calculateDaysLeft(trip['startDate']);
    final tripDuration = _calculateTripDuration(trip['startDate'], trip['endDate']);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.navigateToTripDetail(trip),
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay
            Stack(
              children: [
                Container(
                  height: 160.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    color: AppColors.neutral200,
                  ),
                  child: Center(child: Icon(Icons.image, size: 48.sp, color: AppColors.neutral400)),
                ),

                // Status badge
                Positioned(
                  top: AppSpacing.s3,
                  left: AppSpacing.s3,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s3,
                      vertical: AppSpacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(trip['status']),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(trip['status']), size: 14.sp, color: Colors.white),
                        SizedBox(width: AppSpacing.s1),
                        Text(
                          _getStatusText(trip['status']),
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Days left badge (for upcoming trips)
                if (trip['status'] == 'upcoming' && daysLeft > 0)
                  Positioned(
                    top: AppSpacing.s3,
                    right: AppSpacing.s3,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s3,
                        vertical: AppSpacing.s2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Còn $daysLeft ngày',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Trip info
            Padding(
              padding: EdgeInsets.all(AppSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and location
                  Text(
                    trip['name'],
                    style: AppTypography.heading6,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: AppSpacing.s2),

                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16.sp, color: AppColors.grey),
                      SizedBox(width: AppSpacing.s1),
                      Expanded(
                        child: Text(
                          trip['destination'],
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.s3),

                  // Dates and duration
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14.sp, color: AppColors.grey),
                      SizedBox(width: AppSpacing.s1),
                      Text(
                        '${trip['startDate']} - ${trip['endDate']}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(width: AppSpacing.s3),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '$tripDuration ngày',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.s3),

                  // Members and activities
                  Row(
                    children: [
                      // Members
                      Row(
                        children: [
                          Icon(Icons.people_outline, size: 16.sp, color: AppColors.grey),
                          SizedBox(width: AppSpacing.s1),
                          Text(
                            '${trip['members']} người',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),

                      SizedBox(width: AppSpacing.s4),

                      // Activities
                      Row(
                        children: [
                          Icon(Icons.explore_outlined, size: 16.sp, color: AppColors.grey),
                          SizedBox(width: AppSpacing.s1),
                          Text(
                            '${trip['activities']} hoạt động',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // More button
                      IconButton(
                        icon: Icon(Icons.more_vert, size: 20.sp, color: AppColors.grey),
                        onPressed: () => _showTripOptions(trip),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_off, size: 80.sp, color: AppColors.neutral400),
            SizedBox(height: AppSpacing.s4),
            Text('Chưa có chuyến đi nào', style: AppTypography.heading5),
            SizedBox(height: AppSpacing.s2),
            Text(
              'Bắt đầu lên kế hoạch cho chuyến đi tiếp theo của bạn',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.s6),
            ElevatedButton.icon(
              onPressed: controller.createNewTrip,
              icon: const Icon(Icons.add),
              label: const Text('Tạo chuyến đi mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s6, vertical: AppSpacing.s3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTripOptions(Map<String, dynamic> trip) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(AppSpacing.s5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Chỉnh sửa'),
              onTap: () {
                Get.back();
                controller.editTrip(trip);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Chia sẻ'),
              onTap: () {
                Get.back();
                controller.shareTrip(trip);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Sao chép'),
              onTap: () {
                Get.back();
                controller.duplicateTrip(trip);
              },
            ),
            if (trip['status'] != 'completed')
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Lưu trữ'),
                onTap: () {
                  Get.back();
                  controller.archiveTrip(trip);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Xóa', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Get.back();
                controller.deleteTrip(trip);
              },
            ),
          ],
        ),
      ),
    );
  }

  int _calculateDaysLeft(String startDate) {
    // TODO: Calculate actual days
    return 7;
  }

  int _calculateTripDuration(String startDate, String endDate) {
    // TODO: Calculate actual duration
    return 5;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return AppColors.info;
      case 'ongoing':
        return AppColors.success;
      case 'completed':
        return AppColors.grey;
      default:
        return AppColors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'upcoming':
        return Icons.schedule;
      case 'ongoing':
        return Icons.play_circle_outline;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming':
        return 'Sắp tới';
      case 'ongoing':
        return 'Đang diễn ra';
      case 'completed':
        return 'Đã hoàn thành';
      default:
        return '';
    }
  }
}
