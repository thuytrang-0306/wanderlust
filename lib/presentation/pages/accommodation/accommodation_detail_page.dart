import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/presentation/controllers/accommodation/accommodation_detail_controller.dart';

class AccommodationDetailPage extends StatefulWidget {
  const AccommodationDetailPage({super.key});

  @override
  State<AccommodationDetailPage> createState() => _AccommodationDetailPageState();
}

class _AccommodationDetailPageState extends State<AccommodationDetailPage> {
  late AccommodationDetailController controller;
  late ScrollController _scrollController;
  late String heroTag;

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
    controller = Get.put(AccommodationDetailController());
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Get Hero tag from arguments
    final args = Get.arguments;
    heroTag = 'accommodation-image-default';

    if (args != null) {
      if (args is String) {
        heroTag = 'business-listing-image-$args';
      } else if (args is Map) {
        if (args['heroTag'] != null) {
          heroTag = args['heroTag'] as String;
        } else if (args['listingId'] != null) {
          heroTag = 'business-listing-image-${args['listingId']}';
        } else if (args['accommodationId'] != null) {
          heroTag = 'accommodation-image-${args['accommodationId']}';
        } else if (args['id'] != null) {
          heroTag = 'accommodation-image-${args['id']}';
        }
      }
    }
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Header image with Hero
                      Hero(
                        tag: heroTag,
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

                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 100.h,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Discount badge
                      Obx(() {
                        final accommodation = controller.accommodation.value;
                        if (accommodation != null &&
                            accommodation.originalPrice > accommodation.pricePerNight) {
                          final discount =
                              ((accommodation.originalPrice - accommodation.pricePerNight) /
                                      accommodation.originalPrice *
                                      100)
                                  .round();
                          return Positioned(
                            bottom: 40.h,
                            right: 16.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                '-$discount%',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic info
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
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
                                Obx(() {
                                  final reviews = controller.accommodation.value?.totalReviews ?? 0;
                                  if (reviews > 0) {
                                    return Text(
                                      ' ($reviews)',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
                            ),

                            SizedBox(height: 8.h),

                            // Name
                            Obx(
                              () => Text(
                                controller.accommodation.value?.name ?? 'Đang tải...',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF392856),
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                        child: Container(
                          height: 1.h,
                          color: const Color(0xFFEEE8FF),
                        ),
                      ),

                      // Description
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giới thiệu',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Obx(
                              () {
                                final description =
                                    controller.accommodation.value?.description ?? 'Đang tải...';
                                final isLongText = description.length > 150;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF6B7280),
                                        height: 1.5,
                                      ),
                                      maxLines: controller.isDescriptionExpanded.value ? null : 3,
                                      overflow: controller.isDescriptionExpanded.value
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                    ),
                                    if (isLongText) ...[
                                      SizedBox(height: 8.h),
                                      GestureDetector(
                                        onTap: controller.toggleDescription,
                                        child: Text(
                                          controller.isDescriptionExpanded.value
                                              ? 'Thu gọn'
                                              : 'Xem thêm',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Business/Host info
                      _buildHostInfo(),

                      // Amenities
                      _buildAmenities(),

                      // Type-specific details
                      if (controller.isTourType) _buildTourDetails(),
                      if (controller.isFoodType) _buildFoodDetails(),
                      if (controller.isServiceType) _buildServiceDetails(),

                      // Gallery preview
                      _buildGalleryPreview(),

                      // Booking options
                      _buildBookingOptions(),

                      // Bottom spacing for booking bar
                      SizedBox(height: 120.h),
                    ],
                  ),
                ),
              ],
            ),
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
                              controller.accommodation.value?.name ?? '',
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

                      // Bookmark button
                      _isCollapsed
                          ? _buildCollapsedBookmarkButton()
                          : _buildBlurBookmarkButton(),

                      SizedBox(width: 8.w),

                      // Add to Trip button (hidden for tours)
                      Obx(() {
                        if (controller.isTourType) {
                          return const SizedBox.shrink();
                        }
                        return _isCollapsed
                            ? _buildCollapsedButton(
                                icon: Icons.add_circle_outline,
                                onTap: controller.addToTrip,
                              )
                            : _buildBlurButton(
                                icon: Icons.add_circle_outline,
                                onTap: controller.addToTrip,
                              );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===== BOTTOM BOOKING BAR =====
          _buildBottomBookingBar(),
        ],
      ),
    );
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
              size: icon == Icons.chevron_left_rounded ? 31.sp : 26.sp,
            ),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }

  // Blur bookmark button
  Widget _buildBlurBookmarkButton() {
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
          child: Obx(
            () => IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                controller.isBookmarked.value
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: controller.isBookmarked.value
                    ? const Color(0xFFFBBF24)
                    : Colors.white,
                size: 26.sp,
              ),
              onPressed: controller.toggleBookmark,
            ),
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

  // Collapsed bookmark button
  Widget _buildCollapsedBookmarkButton() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Obx(
        () => IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            controller.isBookmarked.value
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: controller.isBookmarked.value
                ? const Color(0xFFFBBF24)
                : const Color(0xFF392856),
            size: 22.sp,
          ),
          onPressed: controller.toggleBookmark,
        ),
      ),
    );
  }

  Widget _buildHostInfo() {
    return Obx(() {
      final accommodation = controller.accommodation.value;
      final hostName = accommodation?.hostName ?? '';
      if (hostName.isEmpty || accommodation == null) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.business,
                  size: 24.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Được cung cấp bởi',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      hostName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              if (accommodation.isVerified == true)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 14.sp,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Đã xác minh',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAmenities() {
    return Obx(() {
      final amenities = controller.accommodation.value?.amenities ?? [];
      if (amenities.isEmpty) {
        return const SizedBox.shrink();
      }

      // Dynamic section title based on listing type
      String sectionTitle = 'Dịch vụ & Tiện nghi';
      if (controller.isTourType) {
        sectionTitle = 'Bao gồm trong tour';
      } else if (controller.isFoodType) {
        sectionTitle = 'Thông tin món ăn';
      } else if (controller.isServiceType) {
        sectionTitle = 'Bao gồm dịch vụ';
      }

      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sectionTitle,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 24.w,
              runSpacing: 20.h,
              children: amenities.take(6).map((amenity) {
                IconData icon = Icons.check_circle_outline;
                if (amenity.toLowerCase().contains('wifi')) {
                  icon = Icons.wifi;
                } else if (amenity.toLowerCase().contains('ti vi') ||
                    amenity.toLowerCase().contains('tv')) {
                  icon = Icons.tv;
                } else if (amenity.toLowerCase().contains('bể bơi') ||
                    amenity.toLowerCase().contains('hồ bơi')) {
                  icon = Icons.pool;
                } else if (amenity.toLowerCase().contains('điều hòa') ||
                    amenity.toLowerCase().contains('ac')) {
                  icon = Icons.ac_unit;
                } else if (amenity.toLowerCase().contains('nhà hàng') ||
                    amenity.toLowerCase().contains('bữa')) {
                  icon = Icons.restaurant;
                } else if (amenity.toLowerCase().contains('đỗ xe') ||
                    amenity.toLowerCase().contains('parking')) {
                  icon = Icons.local_parking;
                } else if (amenity.toLowerCase().contains('gym')) {
                  icon = Icons.fitness_center;
                } else if (amenity.toLowerCase().contains('spa')) {
                  icon = Icons.spa;
                } else if (amenity.toLowerCase().contains('bar')) {
                  icon = Icons.local_bar;
                }

                return SizedBox(
                  width: 100.w,
                  child: _buildAmenityItem(icon, amenity),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
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

  Widget _buildGalleryPreview() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Obx(() {
              // Dynamic gallery title based on listing type
              String galleryTitle = 'Xem trước Phòng';
              if (controller.isTourType) {
                galleryTitle = 'Xem trước Tour';
              } else if (controller.isFoodType) {
                galleryTitle = 'Xem trước Món ăn';
              } else if (controller.isServiceType) {
                galleryTitle = 'Xem trước Dịch vụ';
              }

              return Text(
                galleryTitle,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              );
            }),
          ),
          SizedBox(height: 12.h),
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
                itemCount: images.length > 5 ? 5 : images.length,
                itemBuilder: (context, index) {
                  if (index == 4 && images.length > 5) {
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
    );
  }

  Widget _buildBookingOptions() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date/Time selection
          Obx(() {
            String label = 'Nhận và Trả phòng';
            if (controller.isFoodType) {
              label = 'Thời gian đặt món';
            } else if (controller.isServiceType) {
              label = 'Ngày hẹn';
            } else if (controller.isTourType) {
              label = 'Ngày khởi hành';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: controller.selectDates,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0FF),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      controller.selectedDates.value.isNotEmpty
                          ? controller.selectedDates.value
                          : 'Chọn ngày',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            );
          }),

          // Quantity/Room/Guest selection based on type
          Obx(() {
            if (controller.isFoodType || controller.isServiceType) {
              return _buildQuantitySelector(
                label: controller.isFoodType ? 'Số lượng món' : 'Số lượng dịch vụ',
                icon: controller.isFoodType ? Icons.restaurant_menu : Icons.build_outlined,
                value: controller.quantity.value,
                onDecrement: controller.decrementQuantity,
                onIncrement: controller.incrementQuantity,
              );
            } else if (controller.isTourType) {
              return _buildQuantitySelector(
                label: 'Số người tham gia',
                icon: Icons.person_outline,
                value: controller.guestCount.value,
                onDecrement: controller.decrementGuestCount,
                onIncrement: controller.incrementGuestCount,
              );
            } else {
              // Room type
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.isRoomType ? 'Phòng và khách' :
                    controller.isTourType ? 'Số người tham gia' :
                    controller.isFoodType ? 'Số lượng món' :
                    'Số lượng dịch vụ',
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 8.h),
                  _buildCounterRow(
                    icon: Icons.bedroom_parent_outlined,
                    label: 'Số phòng',
                    value: controller.roomCount.value,
                    onDecrement: controller.decrementRoomCount,
                    onIncrement: controller.incrementRoomCount,
                  ),
                  SizedBox(height: 12.h),
                  _buildCounterRow(
                    icon: Icons.person_outline,
                    label: 'Số người',
                    value: controller.guestCount.value,
                    onDecrement: controller.decrementGuestCount,
                    onIncrement: controller.incrementGuestCount,
                  ),
                ],
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector({
    required String label,
    required IconData icon,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
        ),
        SizedBox(height: 8.h),
        _buildCounterRow(
          icon: icon,
          label: label.contains('Số') ? label.replaceFirst('Số ', '') : label,
          value: value,
          onDecrement: onDecrement,
          onIncrement: onIncrement,
        ),
      ],
    );
  }

  Widget _buildCounterRow({
    required IconData icon,
    required String label,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.sp, color: const Color(0xFF9CA3AF)),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
          Row(
            children: [
              InkWell(
                onTap: onDecrement,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.remove, size: 16.sp, color: AppColors.primary),
                ),
              ),
              SizedBox(width: 16.w),
              SizedBox(
                width: 24.w,
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 16.w),
              InkWell(
                onTap: onIncrement,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.add, size: 16.sp, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBookingBar() {
    return Positioned(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => Text(
                          controller.priceBreakdown,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Tổng: ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Flexible(
                            child: Obx(
                              () => Text(
                                controller.totalPriceFormatted,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: controller.bookRoom,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Obx(
                      () => Text(
                        controller.bookingButtonText,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== TYPE-SPECIFIC DETAIL SECTIONS ==========

  /// Tour-specific details: duration, departure, included services
  Widget _buildTourDetails() {
    return Obx(() {
      final listing = controller.listing.value;
      if (listing == null) return const SizedBox.shrink();

      final details = listing.details;
      final duration = details['duration'] as String?;
      final departure = details['departure'] as String?;
      final includeTransport = details['includeTransport'] as bool? ?? false;
      final includeMeals = details['includeMeals'] as bool? ?? false;
      final includeGuide = details['includeGuide'] as bool? ?? false;
      final groupSize = details['groupSize'] as int?;

      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chi tiết tour',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 16.h),

            // Duration badge
            if (duration != null) ...[
              _buildInfoRow(
                icon: Icons.schedule,
                label: 'Thời lượng',
                value: duration,
              ),
              SizedBox(height: 12.h),
            ],

            // Departure point
            if (departure != null) ...[
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Điểm khởi hành',
                value: departure,
              ),
              SizedBox(height: 12.h),
            ],

            // Group size
            if (groupSize != null) ...[
              _buildInfoRow(
                icon: Icons.group,
                label: 'Số người tối đa',
                value: '$groupSize người/đoàn',
              ),
              SizedBox(height: 12.h),
            ],

            // Included services
            Text(
              'Bao gồm:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 8.h,
              children: [
                if (includeTransport) _buildIncludedBadge(Icons.directions_bus, 'Xe đưa đón'),
                if (includeMeals) _buildIncludedBadge(Icons.restaurant, 'Bữa ăn'),
                if (includeGuide) _buildIncludedBadge(Icons.person, 'Hướng dẫn viên'),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Food-specific details: category, serving, dietary info
  Widget _buildFoodDetails() {
    return Obx(() {
      final listing = controller.listing.value;
      if (listing == null) return const SizedBox.shrink();

      final details = listing.details;
      final category = details['category'] as String?;
      final serving = details['serving'] as String?;
      final isVegetarian = details['isVegetarian'] as bool? ?? false;
      final isSpicy = details['isSpicy'] as bool? ?? false;
      final prepTime = details['prepTime'] as String?;

      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin chi tiết',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 16.h),

            // Category
            if (category != null) ...[
              _buildInfoRow(
                icon: Icons.category,
                label: 'Loại món',
                value: category,
              ),
              SizedBox(height: 12.h),
            ],

            // Serving size
            if (serving != null) ...[
              _buildInfoRow(
                icon: Icons.people,
                label: 'Khẩu phần',
                value: serving,
              ),
              SizedBox(height: 12.h),
            ],

            // Preparation time
            if (prepTime != null) ...[
              _buildInfoRow(
                icon: Icons.timer,
                label: 'Thời gian chuẩn bị',
                value: prepTime,
              ),
              SizedBox(height: 12.h),
            ],

            // Dietary indicators
            if (isVegetarian || isSpicy) ...[
              Text(
                'Đặc điểm:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 8.h,
                children: [
                  if (isVegetarian) _buildIncludedBadge(Icons.eco, 'Chay'),
                  if (isSpicy) _buildIncludedBadge(Icons.whatshot, 'Cay'),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Service-specific details: duration, location
  Widget _buildServiceDetails() {
    return Obx(() {
      final listing = controller.listing.value;
      if (listing == null) return const SizedBox.shrink();

      final details = listing.details;
      final duration = details['duration'] as String?;
      final location = details['location'] as String?;

      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin dịch vụ',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 16.h),

            // Duration
            if (duration != null) ...[
              _buildInfoRow(
                icon: Icons.schedule,
                label: 'Thời lượng',
                value: duration,
              ),
              SizedBox(height: 12.h),
            ],

            // Location
            if (location != null) ...[
              _buildInfoRow(
                icon: Icons.place,
                label: 'Địa điểm',
                value: location,
              ),
            ],
          ],
        ),
      );
    });
  }

  // Helper widgets for type-specific sections
  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF374151)),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncludedBadge(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
