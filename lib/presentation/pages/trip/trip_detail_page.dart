import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_assets.dart';
import 'package:wanderlust/core/widgets/shimmer_loading.dart';
import 'package:wanderlust/presentation/controllers/trip/trip_detail_controller.dart';
import 'package:wanderlust/presentation/controllers/search/search_filter_controller.dart';
import 'package:wanderlust/presentation/widgets/ai_trip_planner_sheet.dart';

class TripDetailPage extends StatefulWidget {
  const TripDetailPage({super.key});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  late TripDetailController controller;
  late ScrollController _scrollController;

  // Animation values
  double _scrollOffset = 0;
  bool _isCollapsed = false;
  double _titleOpacity = 0.0;

  // Constants
  static final double _headerHeight = 280.h;
  static final double _collapseTrigger = 180.h;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TripDetailController());
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _isCollapsed = _scrollOffset > _collapseTrigger;
      _titleOpacity = ((_scrollOffset - _collapseTrigger) / 50).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ===== MAIN SCROLLABLE CONTENT =====
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Header Image (fixed height, scrolls with content)
                SizedBox(
                  height: _headerHeight,
                  width: double.infinity,
                  child: Obx(() {
                    final tripData = controller.trip.value;
                    final imageData = controller.tripImage.value;

                    if (imageData.isNotEmpty && tripData != null) {
                      return Hero(
                        tag: 'trip-cover-${tripData.id}',
                        child: AppImage(
                          imageData: imageData,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.8),
                            AppColors.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.travel_explore,
                          size: 60.sp,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    );
                  }),
                ),

                // ===== CONTENT CARD WITH OVERLAP & RADIUS =====
                Container(
                  transform: Matrix4.translationValues(0, -24.h, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Title and date section
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Obx(() => Text(
                                        controller.tripName.value,
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF392856),
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 16.sp,
                                            color: AppColors.primary,
                                          ),
                                          SizedBox(width: 4.w),
                                          Obx(() => Text(
                                            controller.tripDateRange.value,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // People count badge
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 18.sp,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 4.w),
                                      Obx(() => Text(
                                        controller.peopleCount.value.toString(),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            // Divider
                            Container(
                              height: 1.h,
                              color: const Color(0xFFEEE8FF),
                            ),

                            SizedBox(height: 16.h),

                            // Tab navigation
                            SizedBox(
                              height: 40.h,
                              child: Obx(() {
                                final totalDays = controller.totalDays.value;
                                if (totalDays <= 5) {
                                  return Row(
                                    children: List.generate(
                                      totalDays,
                                      (index) => Expanded(
                                        child: _buildDayTab(controller, index),
                                      ),
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: totalDays,
                                    itemBuilder: (context, index) => SizedBox(
                                      width: 80.w,
                                      child: _buildDayTab(controller, index),
                                    ),
                                  );
                                }
                              }),
                            ),
                          ],
                        ),
                      ),

                      // Content area
                      Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Obx(() {
                          if (controller.isInitialLoading.value) {
                            return _buildContentShimmer();
                          }

                          if (controller.isError) {
                            return _buildErrorState(controller);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ngày ${controller.selectedDay.value + 1}',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 4.h),

                              Text(
                                controller.getDayDate(controller.selectedDay.value),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),

                              SizedBox(height: 20.h),
                              _buildNoteSection(controller),
                              SizedBox(height: 24.h),

                              if (controller.dayHasItems(controller.selectedDay.value))
                                _buildTimelineView(controller)
                              else
                                _buildEmptyPlaceholder(),

                              SizedBox(height: 24.h),
                              _buildActionButtons(controller),
                            ],
                          );
                        }),
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===== AI FAB BUTTON =====
          Positioned(
            bottom: 24.h,
            right: 20.w,
            child: _buildAiFab(),
          ),

          // ===== ANIMATED HEADER BAR (ALWAYS ON TOP) =====
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _isCollapsed ? Colors.white : Colors.transparent,
                boxShadow: _isCollapsed
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: 56.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      // Back button
                      _isCollapsed
                          ? _buildCollapsedButton(
                              icon: Icons.chevron_left_rounded,
                              onTap: () => Get.back(),
                            )
                          : _buildBlurButton(
                              icon: Icons.chevron_left_rounded,
                              onTap: () => Get.back(),
                            ),

                      // Title (fade in when collapsed)
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _titleOpacity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Obx(() => Text(
                              controller.tripName.value,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF392856),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            )),
                          ),
                        ),
                      ),

                      // Edit button
                      _isCollapsed
                          ? _buildCollapsedButton(
                              icon: Icons.edit_outlined,
                              onTap: controller.editTrip,
                            )
                          : _buildBlurButton(
                              icon: Icons.edit_outlined,
                              onTap: controller.editTrip,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTab(TripDetailController controller, int index) {
    return GestureDetector(
      onTap: () => controller.selectDay(index),
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: controller.selectedDay.value == index
                    ? AppColors.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              'Ngày ${index + 1}',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: controller.selectedDay.value == index
                    ? AppColors.primary
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // AI FAB Button
  Widget _buildAiFab() {
    return GestureDetector(
      onTap: _showAiTripPlanner,
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Image.asset(
            AppAssets.aiFabIcon,
            width: 56.w,
            height: 56.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.smart_toy,
                  size: 28.sp,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Show AI Trip Planner Bottom Sheet
  void _showAiTripPlanner() async {
    if (controller.trip.value == null) return;

    final result = await AiTripPlannerSheet.show(
      trip: controller.trip.value!,
      selectedDay: controller.selectedDay.value,
      tripDays: controller.tripDays.toList(),
      onSaveNote: (content) {
        // Save AI content to day note
        controller.updateDayNote({'note': content});
      },
    );

    // Handle result if needed
    if (result != null && result['action'] == 'save_to_note') {
      controller.updateDayNote({'note': result['content']});
    }
  }

  // Blur button for expanded state (on image)
  Widget _buildBlurButton({required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(21.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: const Color(0x4DFFFFFF),
            borderRadius: BorderRadius.circular(21.r),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              icon,
              color: Colors.white,
              size: icon == Icons.chevron_left_rounded ? 31.sp : 24.sp,
            ),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }

  // Solid button for collapsed state (on white background)
  Widget _buildCollapsedButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          color: const Color(0xFF392856),
          size: icon == Icons.chevron_left_rounded ? 28.sp : 22.sp,
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200.h,
          child: Image.asset(
            AppAssets.tripEmptyState,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.travel_explore,
                size: 100.sp,
                color: AppColors.neutral300,
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            'Bạn chưa có điểm đến nào, hãy thêm để hoàn thiện chuyến đi!',
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF374151), height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(TripDetailController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.search,
            text: 'Tìm kiếm địa điểm',
            onTap: () async {
              Get.delete<SearchFilterController>(force: true);

              final args = {
                'mode': 'selection',
                'tripId': controller.trip.value?.id,
                'dayNumber': controller.selectedDay.value,
              };

              final result = await Get.toNamed(
                '/search-filter',
                arguments: args,
                preventDuplicates: false,
                parameters: args.map((key, value) => MapEntry(key, value?.toString() ?? '')),
              );

              if (result != null) {
                await controller.addLocationFromSearch(result);
              }
            },
          ),
          SizedBox(height: 12.h),
          _buildActionButton(
            icon: Icons.add,
            text: 'Thêm địa điểm riêng tư',
            onTap: () {
              Get.toNamed('/add-private-location')?.then((result) {
                if (result != null) {
                  controller.addPrivateLocation(result);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(TripDetailController controller) {
    return Obx(() {
      final note = controller.getDayNote(controller.selectedDay.value);
      final hasNote = note.isNotEmpty;

      return GestureDetector(
        onTap: () {
          Get.toNamed(
            '/add-note',
            arguments: {
              'dayNumber': controller.selectedDay.value + 1,
              'existingNote': note,
            },
          )?.then((result) {
            if (result != null) {
              controller.updateDayNote(result);
            }
          });
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: hasNote ? const Color(0xFFFFFBEB) : AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasNote ? const Color(0xFFFBBF24) : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                hasNote ? Icons.event_note : Icons.note_add_outlined,
                size: 20.sp,
                color: hasNote ? const Color(0xFFFBBF24) : const Color(0xFF6B7280),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasNote ? 'Ghi chú' : 'Thêm ghi chú cho ngày này',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: hasNote ? const Color(0xFFF59E0B) : const Color(0xFF6B7280),
                      ),
                    ),
                    if (hasNote) ...[
                      SizedBox(height: 4.h),
                      Text(
                        note,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF374151),
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                hasNote ? Icons.edit_outlined : Icons.add,
                size: 20.sp,
                color: hasNote ? const Color(0xFFF59E0B) : const Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: const Color(0xFF6B7280)),
            SizedBox(width: 12.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineView(TripDetailController controller) {
    final locations = controller.getLocationsForDay(controller.selectedDay.value);
    return Column(
      children: List.generate(locations.length, (index) {
        final location = locations[index];
        return _buildTimelineItem(
          controller: controller,
          locationIndex: index,
          location: location,
          title: location['title'],
          address: location['address'],
          description: location['description'],
          image: location['image'],
          isLast: index == locations.length - 1,
        );
      }),
    );
  }

  Widget _buildTimelineItem({
    required TripDetailController controller,
    required int locationIndex,
    required Map<String, dynamic> location,
    required String title,
    required String address,
    required String? description,
    required String? image,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
            ),
            if (!isLast) Container(width: 2.w, height: 100.h, color: const Color(0xFFE5E7EB)),
          ],
        ),
        SizedBox(width: 16.w),
        // Location card
        Expanded(
          child: GestureDetector(
            onTap: () {
              final locationType = location['type'] as String?;
              if (locationType == 'listing') {
                final listingId = location['listingId'] as String?;
                if (listingId != null) {
                  Get.toNamed('/accommodation-detail', arguments: {'listingId': listingId});
                }
              } else if (locationType == 'private') {
                _showPrivateLocationDetail(controller, locationIndex, location);
              }
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: Row(
                children: [
                  if (image != null && image.isNotEmpty)
                    Container(
                      width: 60.w,
                      height: 60.w,
                      margin: EdgeInsets.only(right: 12.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: AppImage(
                          imageData: image,
                          width: 60.w,
                          height: 60.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14.sp, color: const Color(0xFF6B7280)),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                address,
                                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (description != null) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(Icons.notes, size: 14.sp, color: const Color(0xFF6B7280)),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  description,
                                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz, size: 20.sp, color: const Color(0xFF6B7280)),
                    onPressed: () => _showLocationMenu(controller, locationIndex, location, title),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(TripDetailController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Không thể tải dữ liệu',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.black),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.errorMessage.isNotEmpty
                  ? controller.errorMessage
                  : 'Đã xảy ra lỗi khi tải thông tin chuyến đi',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => controller.retryLoadTrip(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerLoading(
          child: Container(
            width: 100.w,
            height: 28.h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.r)),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerLoading(
              child: Container(
                width: 150.w,
                height: 16.h,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.r)),
              ),
            ),
            ShimmerLoading(
              child: Container(
                width: 100.w,
                height: 16.h,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.r)),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        ShimmerLoading(
          child: Container(
            width: double.infinity,
            height: 80.h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
        SizedBox(height: 24.h),
        ...List.generate(
          2,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: ShimmerLoading(
              child: Container(
                width: double.infinity,
                height: 100.h,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPrivateLocationDetail(
    TripDetailController controller,
    int locationIndex,
    Map<String, dynamic> location,
  ) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Text(
                  location['title'] ?? 'Địa điểm riêng tư',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (location['address'] != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16.sp, color: AppColors.neutral600),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          location['address'],
                          style: TextStyle(fontSize: 14.sp, color: AppColors.neutral600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Divider(height: 24.h, color: const Color(0xFFE5E7EB)),
              _buildMenuOption(
                icon: Icons.edit_outlined,
                text: 'Chỉnh sửa địa điểm',
                color: AppColors.primary,
                onTap: () async {
                  Get.back();
                  final result = await Get.toNamed(
                    '/add-private-location',
                    arguments: {'mode': 'edit', 'location': location},
                  );
                  if (result != null) {
                    controller.updatePrivateLocation(locationIndex, result);
                  }
                },
              ),
              _buildMenuOption(
                icon: Icons.delete_outline,
                text: 'Xóa địa điểm',
                color: AppColors.error,
                onTap: () async {
                  Get.back();
                  final confirmed = await Get.dialog<bool>(
                    AlertDialog(
                      title: Text('Xóa địa điểm', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                      content: Text(
                        'Bạn có chắc chắn muốn xóa địa điểm "${location['title']}" khỏi lịch trình?',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: Text('Hủy', style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp)),
                        ),
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: Text('Xóa', style: TextStyle(color: AppColors.error, fontSize: 16.sp)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    controller.deleteLocation(locationIndex);
                  }
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _showLocationMenu(
    TripDetailController controller,
    int locationIndex,
    Map<String, dynamic> location,
    String locationTitle,
  ) {
    final locationType = location['type'] as String?;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Text(
                locationTitle,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Divider(height: 1.h, color: const Color(0xFFE5E7EB)),
            if (locationType == 'listing') ...[
              _buildMenuOption(
                icon: Icons.visibility_outlined,
                text: 'Xem chi tiết',
                color: AppColors.primary,
                onTap: () {
                  Get.back();
                  final listingId = location['listingId'] as String?;
                  if (listingId != null) {
                    Get.toNamed('/accommodation-detail', arguments: {'listingId': listingId});
                  }
                },
              ),
            ] else if (locationType == 'private') ...[
              _buildMenuOption(
                icon: Icons.edit_outlined,
                text: 'Chỉnh sửa',
                color: AppColors.primary,
                onTap: () async {
                  Get.back();
                  final result = await Get.toNamed(
                    '/add-private-location',
                    arguments: {'mode': 'edit', 'location': location},
                  );
                  if (result != null) {
                    controller.updatePrivateLocation(locationIndex, result);
                  }
                },
              ),
            ],
            _buildMenuOption(
              icon: Icons.delete_outline,
              text: 'Xóa địa điểm',
              color: AppColors.error,
              onTap: () async {
                Get.back();
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    title: Text('Xóa địa điểm', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                    content: Text(
                      'Bạn có chắc chắn muốn xóa địa điểm "$locationTitle" khỏi lịch trình?',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text('Hủy', style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp)),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: Text('Xóa', style: TextStyle(color: AppColors.error, fontSize: 16.sp)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  controller.deleteLocation(locationIndex);
                }
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(icon, size: 24.sp, color: color),
            SizedBox(width: 12.w),
            Text(text, style: TextStyle(fontSize: 16.sp, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
