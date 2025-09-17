import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/planning/planning_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlanningPage extends GetView<PlanningController> {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => PlanningController());
    
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F7F8),
                  child: Obx(() {
                    if (controller.filteredTrips.isEmpty && controller.trips.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    if (controller.filteredTrips.isEmpty && controller.trips.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.s8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: AppSpacing.s4),
                              Text(
                                'Không tìm thấy chuyến đi',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: AppSpacing.s2),
                              Text(
                                'Thử tìm kiếm với từ khóa khác',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: EdgeInsets.only(
                        left: AppSpacing.s4,
                        right: AppSpacing.s4,
                        top: AppSpacing.s2,
                        bottom: 100.h, // Space for FAB
                      ),
                      itemCount: controller.filteredTrips.length,
                      itemBuilder: (context, index) {
                        return _buildTripCard(controller.filteredTrips[index]);
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
          // Floating Action Button
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: _buildCreateTripButton(),
          ),
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
          colors: [
            Color(0xFFE8E0FF),
            Color(0xFFF5F0FF),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s5,
            vertical: AppSpacing.s4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tạo chuyến đi',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFFF5F7F8),
      padding: EdgeInsets.all(AppSpacing.s4),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: TextField(
          controller: controller.searchController,
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm chuyến đi',
            hintStyle: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: const Color(0xFF9CA3AF),
              size: 22.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: AppSpacing.s3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    return GestureDetector(
      onTap: () {
        // Navigate to Trip Detail page
        Get.toNamed('/trip-detail', arguments: {
          'tripName': trip.name,
          'dateRange': trip.dateRange,
          'peopleCount': 2, // Default value, will be updated when TripModel has this field
          'tripImage': trip.imageUrl,
        });
      },
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
            // Background Image
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: trip.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.neutral200,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.neutral200,
                  child: const Icon(Icons.image, color: AppColors.neutral400),
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
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
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
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.s3,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: trip.status == TripStatus.ongoing
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            trip.statusText,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // More Options
                        GestureDetector(
                          onTap: () => controller.showTripOptions(trip),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Bottom Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          trip.dateRange,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          trip.description,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildCreateTripButton() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.createNewTrip,
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s5,
              vertical: AppSpacing.s3,
            ),
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
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 20.sp,
                ),
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
            Icon(
              Icons.explore_outlined,
              size: 80.sp,
              color: AppColors.neutral300,
            ),
            SizedBox(height: AppSpacing.s4),
            Text(
              'Chưa có chuyến đi nào',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: AppSpacing.s2),
            Text(
              'Bắt đầu lên kế hoạch cho chuyến đi của bạn',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Trip Model
class TripModel {
  final String id;
  final String name;
  final String imageUrl;
  final String dateRange;
  final String description;
  final TripStatus status;
  final String statusText;

  TripModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.dateRange,
    required this.description,
    required this.status,
    required this.statusText,
  });
}

enum TripStatus { ongoing, planned, upcoming }