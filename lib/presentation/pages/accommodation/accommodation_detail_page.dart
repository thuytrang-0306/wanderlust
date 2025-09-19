import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/presentation/controllers/accommodation/accommodation_detail_controller.dart';

class AccommodationDetailPage extends GetView<AccommodationDetailController> {
  const AccommodationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => AccommodationDetailController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Header image
                Stack(
                  children: [
                    SizedBox(
                      height: 280.h,
                      width: double.infinity,
                      child: Obx(() {
                        final imageData = controller.accommodation.value?.images.isNotEmpty == true
                            ? controller.accommodation.value!.images.first
                            : null;

                        if (imageData == null) {
                          return Container(
                            color: AppColors.neutral200,
                            child: Icon(Icons.image, size: 50.sp, color: AppColors.neutral400),
                          );
                        }

                        // Use AppImage which handles both base64 and URLs
                        return AppImage(
                          imageData: imageData,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorWidget: Container(
                            color: AppColors.neutral200,
                            child: Icon(Icons.image, size: 50.sp, color: AppColors.neutral400),
                          ),
                        );
                      }),
                    ),

                    // Header buttons overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back button
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.chevron_left,
                                    color: Colors.black87,
                                    size: 30.sp,
                                  ),
                                  onPressed: () => Get.back(),
                                ),
                              ),

                              // Bookmark button
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Obx(
                                  () => IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      controller.isBookmarked.value
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color:
                                          controller.isBookmarked.value
                                              ? const Color(0xFFFBBF24)
                                              : Colors.black87,
                                      size: 24.sp,
                                    ),
                                    onPressed: controller.toggleBookmark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Content with curved top
                Container(
                  transform: Matrix4.translationValues(0, -20.h, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic info
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location and rating
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16.sp,
                                  color: const Color(0xFF9CA3AF),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Obx(
                                    () => Text(
                                      controller.accommodation.value?.fullAddress ?? 'Đang tải...',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Icon(Icons.star, size: 16.sp, color: const Color(0xFFFBBF24)),
                                SizedBox(width: 4.w),
                                Obx(
                                  () => Text(
                                    controller.accommodation.value?.rating.toString() ?? '0.0',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF374151),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8.h),

                            // Name
                            Obx(
                              () => Text(
                                controller.accommodation.value?.name ?? 'Đang tải...',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Description
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giới thiệu nơi lưu trú',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Obx(
                              () => Text(
                                controller.accommodation.value?.description ?? 'Đang tải...',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF6B7280),
                                  height: 1.5,
                                ),
                                maxLines: controller.isDescriptionExpanded.value ? null : 3,
                                overflow:
                                    controller.isDescriptionExpanded.value
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: controller.toggleDescription,
                              child: Text(
                                'Xem thêm',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Amenities
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dịch vụ & Tiện nghi',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Amenities grid - dynamic
                            Obx(() {
                              final amenities = controller.accommodation.value?.amenities ?? [];
                              if (amenities.isEmpty) {
                                return Text(
                                  'Đang tải...',
                                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                                );
                              }

                              return Wrap(
                                spacing: 24.w,
                                runSpacing: 20.h,
                                children:
                                    amenities.take(6).map((amenity) {
                                      IconData icon = Icons.check_circle_outline;
                                      if (amenity.toLowerCase().contains('wifi')) {
                                        icon = Icons.wifi;
                                      } else if (amenity.toLowerCase().contains('ti vi') ||
                                          amenity.toLowerCase().contains('tv'))
                                        icon = Icons.tv;
                                      else if (amenity.toLowerCase().contains('bể bơi') ||
                                          amenity.toLowerCase().contains('hồ bơi'))
                                        icon = Icons.pool;
                                      else if (amenity.toLowerCase().contains('điều hòa') ||
                                          amenity.toLowerCase().contains('ac'))
                                        icon = Icons.ac_unit;
                                      else if (amenity.toLowerCase().contains('nhà hàng') ||
                                          amenity.toLowerCase().contains('bữa'))
                                        icon = Icons.restaurant;
                                      else if (amenity.toLowerCase().contains('đỗ xe') ||
                                          amenity.toLowerCase().contains('parking'))
                                        icon = Icons.local_parking;
                                      else if (amenity.toLowerCase().contains('gym'))
                                        icon = Icons.fitness_center;
                                      else if (amenity.toLowerCase().contains('spa'))
                                        icon = Icons.spa;
                                      else if (amenity.toLowerCase().contains('bar'))
                                        icon = Icons.local_bar;

                                      return SizedBox(
                                        width: 100.w,
                                        child: _buildAmenityItem(icon, amenity),
                                      );
                                    }).toList(),
                              );
                            }),
                          ],
                        ),
                      ),

                      // Gallery preview
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 20.w),
                              child: Text(
                                'Xem trước Homestay',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // Gallery horizontal scroll
                            SizedBox(
                              height: 80.h,
                              child: Obx(() {
                                final images = controller.accommodation.value?.images ?? [];
                                if (images.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'Không có hình ảnh',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.only(right: 20.w),
                                  itemCount: images.length,
                                  itemBuilder: (context, index) {
                                    if (index == 4 && images.length > 5) {
                                      // Last item with +X overlay
                                      return GestureDetector(
                                        onTap: controller.openGallery,
                                        child: Container(
                                          width: 80.w,
                                          margin: EdgeInsets.only(right: 8.w),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8.r),
                                                child: AppImage(
                                                  imageData: images[index],
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8.r),
                                                  color: Colors.black.withOpacity(0.5),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '+${images.length - 5}',
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    return Container(
                                      width: 80.w,
                                      margin: EdgeInsets.only(right: 8.w),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8.r),
                                        child: AppImage(
                                          imageData: images[index],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      // Room selection
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nhận và Trả phòng',
                              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                            ),
                            SizedBox(height: 8.h),

                            // Date selection
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F0FF),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '1 thg1 - 2 thg 1',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16.h),

                            Text(
                              'Phòng và khách',
                              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                            ),
                            SizedBox(height: 8.h),

                            // Room and guest selection
                            Row(
                              children: [
                                // Room count
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '1 đêm',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF374151),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.bedroom_parent_outlined,
                                              size: 18.sp,
                                              color: const Color(0xFF9CA3AF),
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              '1',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: const Color(0xFF374151),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(width: 12.w),

                                // Guest count
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 18.sp,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          '1',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF374151),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Container(
                                          width: 4.w,
                                          height: 4.w,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF9CA3AF),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Text(
                                          '0',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF374151),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bottom spacing
                      SizedBox(height: 120.h),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom booking bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFB794F4), AppColors.primary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Giá ước tính:',
                            style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.9)),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Obx(
                                () => Text(
                                  controller.accommodation.value?.displayPrice ?? '0 VND',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                '/đêm',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Book button
                      GestureDetector(
                        onTap: controller.bookRoom,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'Đặt phòng',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
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

  Widget _buildAmenityItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24.sp, color: AppColors.primary),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
