import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/presentation/controllers/trip/trip_detail_controller.dart';

class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TripDetailController());

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: Stack(
        children: [
          // Main content with header image
          CustomScrollView(
            slivers: [
              // Header with image
              SliverAppBar(
                expandedHeight: 207.h,
                pinned: false,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Obx(
                    () => SizedBox(
                      height: 207.h,
                      child:
                          controller.tripImage.value.isNotEmpty
                              ? AppImage(
                                imageData: controller.tripImage.value,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              )
                              : Container(
                                color: AppColors.primary.withOpacity(0.8),
                                child: Center(
                                  child: Icon(
                                    Icons.travel_explore,
                                    size: 50.sp,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                    ),
                  ),
                ),
              ),

              // White card content
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: Offset(0, -20.h),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
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
                                        Text(
                                          controller.tripName.value,
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_outlined,
                                              size: 16.sp,
                                              color: AppColors.primary,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              controller.tripDateRange.value,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: const Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // People count
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 20.sp,
                                        color: const Color(0xFF6B7280),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        controller.peopleCount.value.toString(),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              // Tab navigation
                              SizedBox(
                                height: 40.h,
                                child: Row(
                                  children: List.generate(
                                    controller.totalDays.value,
                                    (index) => Expanded(
                                      child: GestureDetector(
                                        onTap: () => controller.selectDay(index),
                                        child: Obx(
                                          () => Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color:
                                                      controller.selectedDay.value == index
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
                                                  color:
                                                      controller.selectedDay.value == index
                                                          ? AppColors.primary
                                                          : const Color(0xFF6B7280),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content area
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Obx(() {
                            // Day header
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Day label
                                Text(
                                  'Ngày ${controller.selectedDay.value + 1}',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 8.h),

                                // Date and time row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      controller.getDayDate(controller.selectedDay.value),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                    Text(
                                      'Bắt đầu: ${controller.getStartTime(controller.selectedDay.value)}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 24.h),

                                // Day note section
                                _buildNoteSection(controller),

                                SizedBox(height: 24.h),

                                // Check if day has items
                                if (controller.dayHasItems(controller.selectedDay.value))
                                  _buildTimelineView(controller)
                                else
                                  _buildEmptyState(controller),
                              ],
                            );
                          }),
                        ),

                        // Bottom padding
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating action buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 16.w,
            child: _buildBlurButton(icon: Icons.chevron_left, onTap: () => Get.back()),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            right: 16.w,
            child: _buildBlurButton(icon: Icons.edit_outlined, onTap: controller.editTrip),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.3)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              color: Colors.white.withOpacity(0.3),
              child: Icon(icon, color: Colors.white, size: 24.sp),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(TripDetailController controller) {
    return Column(
      children: [
        // Illustration - Car travel scene
        Container(
          width: double.infinity,
          height: 180.h,
          margin: EdgeInsets.only(top: 40.h, bottom: 24.h),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Mountain background
              Positioned(
                bottom: 0,
                child: CustomPaint(size: Size(300.w, 120.h), painter: _MountainPainter()),
              ),
              // Car illustration
              Positioned(
                bottom: 20.h,
                child: Container(
                  width: 100.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24), // Yellow car
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Stack(
                    children: [
                      // Car windows
                      Positioned(
                        top: 5.h,
                        left: 20.w,
                        child: Container(
                          width: 60.w,
                          height: 25.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF60A5FA),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      // Wheels
                      Positioned(
                        bottom: -5.h,
                        left: 15.w,
                        child: Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -5.h,
                        right: 15.w,
                        child: Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Trees
              Positioned(
                left: 40.w,
                bottom: 10.h,
                child: Icon(Icons.park, size: 40.sp, color: const Color(0xFF10B981)),
              ),
              Positioned(
                right: 40.w,
                bottom: 10.h,
                child: Icon(Icons.park, size: 50.sp, color: const Color(0xFF059669)),
              ),
            ],
          ),
        ),

        // Empty state text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            'Bạn chưa có điểm đến nào, hãy thêm để hoàn thiện chuyến đi!',
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF374151), height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 32.h),

        // Action buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _buildActionButton(
                icon: Icons.search,
                text: 'Tìm kiếm địa điểm',
                onTap: () {
                  Get.toNamed('/search-location')?.then((result) {
                    if (result != null) {
                      // Add selected location to trip
                      controller.addLocationFromSearch(result);
                    }
                  });
                },
              ),
              SizedBox(height: 12.h),
              _buildActionButton(
                icon: Icons.add,
                text: 'Thêm địa điểm riêng tư',
                onTap: () {
                  Get.toNamed('/add-private-location')?.then((result) {
                    if (result != null) {
                      // Handle the returned location data
                      controller.addPrivateLocation(result);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ],
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
    return Column(
      children: List.generate(controller.getLocationsForDay(controller.selectedDay.value).length, (
        index,
      ) {
        final location = controller.getLocationsForDay(controller.selectedDay.value)[index];
        return _buildTimelineItem(
          controller: controller,
          locationIndex: index,
          time: location['time'],
          title: location['title'],
          address: location['address'],
          description: location['description'],
          image: location['image'],
          isLast: index == controller.getLocationsForDay(controller.selectedDay.value).length - 1,
        );
      }),
    );
  }

  Widget _buildTimelineItem({
    required TripDetailController controller,
    required int locationIndex,
    required String time,
    required String title,
    required String address,
    required String? description,
    required String? image,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and dot
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

        SizedBox(width: 12.w),

        // Time
        Container(
          padding: EdgeInsets.only(top: 0),
          width: 50.w,
          child: Text(
            time,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.black),
          ),
        ),

        SizedBox(width: 12.w),

        // Location card
        Expanded(
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
                // Image
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

                // Content
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
                          Icon(
                            Icons.location_on_outlined,
                            size: 14.sp,
                            color: const Color(0xFF6B7280),
                          ),
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

                // More button
                IconButton(
                  icon: Icon(Icons.more_horiz, size: 20.sp, color: const Color(0xFF6B7280)),
                  onPressed: () => _showLocationMenu(controller, locationIndex, title),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for mountain background
class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // First mountain layer (lighter)
    paint.color = const Color(0xFF93C5FD);
    final path1 = Path();
    path1.moveTo(0, size.height);
    path1.lineTo(0, size.height * 0.4);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.5,
    );
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.3, size.width, size.height * 0.6);
    path1.lineTo(size.width, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    // Second mountain layer (darker)
    paint.color = const Color(0xFF60A5FA);
    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.7,
    );
    path2.quadraticBezierTo(size.width * 0.8, size.height * 0.5, size.width, size.height * 0.8);
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Show location menu bottom sheet
void _showLocationMenu(TripDetailController controller, int locationIndex, String locationTitle) {
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
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Text(
              locationTitle,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),

          Divider(height: 1.h, color: const Color(0xFFE5E7EB)),

          // Menu options
          _buildMenuOption(
            icon: Icons.delete_outline,
            text: 'Xóa địa điểm',
            color: AppColors.error,
            onTap: () async {
              Get.back(); // Close bottom sheet first

              // Show confirmation dialog
              final confirmed = await Get.dialog<bool>(
                AlertDialog(
                  title: Text(
                    'Xóa địa điểm',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                  ),
                  content: Text(
                    'Bạn có chắc chắn muốn xóa địa điểm "$locationTitle" khỏi lịch trình?',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        'Hủy',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: Text(
                        'Xóa',
                        style: TextStyle(color: AppColors.error, fontSize: 16.sp),
                      ),
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
          Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
