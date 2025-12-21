import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/planning/planning_controller.dart';
import 'package:wanderlust/data/models/trip_model.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/core/widgets/shimmer_loading.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:intl/intl.dart';

class PlanningPage extends GetView<PlanningController> {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is already initialized in MainNavigationBinding
    // Get.lazyPut(() => PlanningController());

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F7F8),
                  child: Obx(() {
                    // Handle loading state
                    if (controller.isLoadingTrips.value) {
                      return _buildLoadingState();
                    }

                    // Handle error state
                    if (controller.viewState == ViewState.error) {
                      return _buildErrorState();
                    }

                    // Handle empty state
                    if (controller.displayedTrips.isEmpty) {
                      return _buildEmptyState();
                    }

                    // Show trips list
                    return RefreshIndicator(
                      onRefresh: controller.loadTrips,
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          left: AppSpacing.s4,
                          right: AppSpacing.s4,
                          top: AppSpacing.s2,
                          bottom: 100.h, // Space for FAB
                        ),
                        itemCount: controller.displayedTrips.length,
                        itemBuilder: (context, index) {
                          return _buildTripCard(controller.displayedTrips[index]);
                        },
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          // Floating Action Button
          Positioned(bottom: 20.h, left: 0, right: 0, child: _buildCreateTripButton()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8E0FF), Color(0xFFF5F0FF)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kế hoạch du lịch',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppSpacing.s2),
              Obx(
                () => Row(
                  children: [
                    _buildStatCard(Icons.luggage, '${controller.totalTrips}', 'Chuyến đi'),
                    SizedBox(width: AppSpacing.s3),
                    _buildStatCard(
                      Icons.location_on,
                      '${controller.totalDestinations}',
                      'Điểm đến',
                    ),
                    SizedBox(width: AppSpacing.s3),
                    _buildStatCard(
                      Icons.account_balance_wallet,
                      '${(controller.totalBudget / 1000000).toStringAsFixed(1)}M',
                      'Ngân sách',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(width: AppSpacing.s2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral800,
                ),
              ),
              Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.neutral500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFFF5F7F8),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
      child: Obx(
        () => Row(
          children: List.generate(4, (index) {
            final isSelected = controller.selectedTab.value == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTab(index),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    controller.getTabTitle(index),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.neutral600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    final dateFormat = DateFormat('dd/MM');
    final startDate = dateFormat.format(trip.startDate);
    final endDate = dateFormat.format(trip.endDate);

    return GestureDetector(
      onTap: () => controller.viewTripDetail(trip),
      child: Container(
        height: 180.h,
        margin: EdgeInsets.only(bottom: AppSpacing.s3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Background Image - Support both base64 and URL
              Positioned.fill(
                child:
                    trip.coverImage.isNotEmpty
                        ? Hero(
                          tag: 'trip-cover-${trip.id}',
                          child: AppImage(
                            imageData: trip.coverImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                        : Container(
                          color: AppColors.neutral200,
                          child: Center(
                            child: Icon(
                              Icons.travel_explore,
                              size: 40.sp,
                              color: AppColors.neutral400,
                            ),
                          ),
                        ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Status Badge and More Options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: _getStatusColor(trip),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              trip.statusDisplay,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // More Options
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Colors.white, size: 24.sp),
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  controller.editTrip(trip);
                                  break;
                                case 'delete':
                                  controller.deleteTrip(trip.id);
                                  break;
                                case 'share':
                                  controller.shareTrip(trip);
                                  break;
                              }
                            },
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                                  const PopupMenuItem(value: 'share', child: Text('Chia sẻ')),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Xóa', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                          ),
                        ],
                      ),

                      // Bottom Content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14.sp,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  trip.destination,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14.sp,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  '$startDate - $endDate • ${trip.durationText}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (trip.travelers.isNotEmpty) ...[
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.people_outline,
                                  size: 14.sp,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${trip.travelers.length}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Budget Progress Bar (optional)
              if (trip.budget > 0)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4.h,
                    color: Colors.black.withValues(alpha: 0.2),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: trip.budgetProgress.clamp(0.0, 1.0),
                      child: Container(
                        color: trip.isOverBudget ? Colors.red : const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TripModel trip) {
    if (trip.status == 'cancelled') return Colors.grey;
    if (trip.isOngoing) return const Color(0xFF10B981);
    if (trip.isUpcoming) return const Color(0xFFF97316);
    if (trip.isPast) return AppColors.neutral500;
    return AppColors.primary;
  }

  Widget _buildCreateTripButton() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.createNewTrip,
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.white, size: 20.sp),
                SizedBox(width: AppSpacing.s2),
                Text(
                  'Tạo lịch trình mới',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 80.sp, color: AppColors.neutral300),
            SizedBox(height: AppSpacing.s4),
            Text(
              controller.selectedTab.value == 0 ? 'Chưa có chuyến đi nào' : _getEmptyMessage(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: AppSpacing.s2),
            Text(
              'Bắt đầu lên kế hoạch cho chuyến đi của bạn',
              style: TextStyle(fontSize: 14.sp, color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyMessage() {
    switch (controller.selectedTab.value) {
      case 1:
        return 'Không có chuyến đi sắp tới';
      case 2:
        return 'Không có chuyến đi đang diễn ra';
      case 3:
        return 'Chưa có chuyến đi đã hoàn thành';
      default:
        return 'Chưa có chuyến đi nào';
    }
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.s4),
      itemCount: 3,
      itemBuilder: (context, index) {
        return ShimmerLoading(
          child: Container(
            height: 180.h,
            margin: EdgeInsets.only(bottom: AppSpacing.s3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: AppSpacing.s4),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700,
              ),
            ),
            SizedBox(height: AppSpacing.s2),
            Text(
              controller.errorMessage ?? 'Không thể tải danh sách chuyến đi',
              style: TextStyle(fontSize: 14.sp, color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.s4),
            ElevatedButton(
              onPressed: controller.loadTrips,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
