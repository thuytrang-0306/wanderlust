import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_assets.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/presentation/controllers/discover/discover_controller.dart';
import 'package:wanderlust/presentation/controllers/account/user_profile_controller.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/core/widgets/shimmer_loading.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DiscoverPage extends GetView<DiscoverController> {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadAllData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),

                SizedBox(height: AppSpacing.s4),

                // Hero Banner - Only show if we have content
                _buildHeroBanner(),

                SizedBox(height: AppSpacing.s5),

                // Search Bar
                _buildSearchBar(),

                SizedBox(height: AppSpacing.s6),

                // Business Listings Section
                Obx(() {
                  if (controller.isLoadingBusinessListings.value || controller.businessListings.isNotEmpty) {
                    return _buildBusinessListings();
                  }
                  return const SizedBox.shrink();
                }),

                // Featured Tours (optional - with balanced spacing)
                Obx(() {
                  if (controller.isLoadingTours.value || controller.featuredTours.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: AppSpacing.s3, bottom: AppSpacing.s3),
                      child: _buildFeaturedTours(),
                    );
                  }
                  // If Featured Tours empty, add 24h spacing
                  return SizedBox(height: AppSpacing.s6);
                }),

                // Planning Section
                _buildPlanningSection(),

                SizedBox(height: AppSpacing.s6),

                // Explore by Region
                _buildExploreByRegion(),

                // Combo Tours Section (optional - with own spacing)
                Obx(() {
                  if (controller.isLoadingCombos.value || controller.comboTours.isNotEmpty) {
                    return Column(
                      children: [
                        SizedBox(height: AppSpacing.s6),
                        _buildComboToursSection(),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                SizedBox(height: AppSpacing.s6),

                // Recent Blogs
                _buildRecentBlogs(),

                SizedBox(height: AppSpacing.s6),

                // Popular Destinations
                Obx(() {
                  if (controller.isLoadingDestinations.value || controller.popularDestinations.isNotEmpty) {
                    return _buildPopularDestinations();
                  }
                  return const SizedBox.shrink();
                }),

                // Bottom padding
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final userProfileController = Get.find<UserProfileController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      child: Row(
        children: [
          // User Avatar
          Obx(() {
            final profile = userProfileController.userProfile.value;
            return GestureDetector(
              onTap: () => Get.toNamed('/user-profile'),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                ),
                child: ClipOval(
                  child:
                      profile?.avatar != null && profile!.avatar!.isNotEmpty
                          ? AppImage.avatar(imageData: profile.avatar!, size: 36)
                          : Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: Icon(Icons.person, size: 20.sp, color: AppColors.primary),
                          ),
                ),
              ),
            );
          }),

          SizedBox(width: AppSpacing.s3),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.greeting,
                  style: AppTypography.bodyS.copyWith(color: AppColors.textSecondary),
                ),
                Obx(() {
                  final profile = userProfileController.userProfile.value;
                  return Text(
                    profile?.displayName ?? controller.userName,
                    style: AppTypography.bodyL.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Obx(() {
      // Show welcome banner if no tours available
      final tours = controller.featuredTours;

      if (tours.isEmpty) {
        // Hero banner with image
        return Container(
          height: 200.h,
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.asset(
              AppAssets.heroBanner,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to old design if image not found
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.image, size: 40.sp, color: Colors.white.withOpacity(0.5)),
                  ),
                );
              },
            ),
          ),
        );
      }

      // Show tour carousel if available
      return SizedBox(
        height: 200.h,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: tours.length.clamp(1, 5),
              itemBuilder: (context, index) {
                final tour = tours[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    image:
                        tour.images.isNotEmpty
                            ? DecorationImage(
                              image: NetworkImage(tour.images.first),
                              fit: BoxFit.cover,
                            )
                            : null,
                    color: AppColors.primary.withOpacity(0.8),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                    padding: EdgeInsets.all(AppSpacing.s5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tour.name,
                          style: AppTypography.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.s2),
                        Text(
                          '${tour.displayPrice} • ${tour.displayDuration}',
                          style: AppTypography.bodyM.copyWith(color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Page Indicator
            if (tours.length > 1)
              Positioned(
                bottom: 20.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Obx(
                    () => AnimatedSmoothIndicator(
                      activeIndex: controller.currentPage.value,
                      count: tours.length.clamp(1, 5),
                      effect: WormEffect(
                        dotWidth: 8.w,
                        dotHeight: 8.h,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      child: Hero(
        tag: 'search-bar-hero',
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () => Get.toNamed('/search-filter'),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                gradient: const LinearGradient(
                  colors: [Color(0xFFC4CDF4), Color(0xFFEDE0FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF54189A).withValues(alpha: 0.2),
                    offset: const Offset(-1, 0),
                    blurRadius: 7,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Container(
                margin: EdgeInsets.all(1.5.w), // Border width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD - 1.5.w),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                      child: Icon(Icons.search, color: AppColors.textTertiary, size: 24.sp),
                    ),
                    Expanded(
                      child: Text(
                        'Tìm kiếm địa điểm, tour...',
                        style: AppTypography.bodyM.copyWith(color: AppColors.textTertiary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedTours() {
    return Obx(() {
      final tours = controller.featuredTours;

      // Don't show shimmer - only show content when data available
      if (controller.isLoadingTours.value || tours.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tour nổi bật', style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: controller.onSeeAllTours,
                  child: Text(
                    'Xem tất cả',
                    style: AppTypography.bodyM.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.s3),

          SizedBox(
            height: 220.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              itemCount: tours.length,
              itemBuilder: (context, index) {
                final tour = tours[index];

                return GestureDetector(
                  onTap: () => controller.onTourTapped(tour),
                  child: Container(
                    width: 280.w,
                    margin: EdgeInsets.only(right: AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Container(
                          height: 140.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                            color: AppColors.neutral100,
                          ),
                          child:
                              tour.images.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                                    child: AppImage(
                                      imageData: tour.images.first,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 40.sp,
                                      color: AppColors.neutral400,
                                    ),
                                  ),
                        ),

                        // Content
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.s3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tour.name,
                                style: AppTypography.bodyL.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: AppSpacing.s1),
                              Row(
                                children: [
                                  Icon(Icons.schedule, size: 14.sp, color: AppColors.textTertiary),
                                  SizedBox(width: 4.w),
                                  Text(
                                    tour.displayDuration,
                                    style: AppTypography.bodyS.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    tour.displayPrice,
                                    style: AppTypography.bodyL.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
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
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPlanningSection() {
    return Container(
      width: 343.w,
      height: 183.h,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.95, -0.31), // 248.78 degrees
          end: Alignment(-0.95, 0.31),
          stops: [0.1553, 0.719],
          colors: [Color(0xFFC4CDF4), Color(0xFFEDE0FF)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXXL),
      ),
      child: Stack(
        children: [
          // Decoration image at bottom right
          Positioned(
            bottom: -15.h,
            right: 0,
            child: Image.asset(
              AppAssets.planningDecoration,
              width: 147.w,
              height: 147.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.s5,
              right: AppSpacing.s5,
              top: AppSpacing.s4,
              bottom: 24.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    Text(
                      'Nhanh chóng chỉ với 1 thao tác',
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.5, // 21px / 14px
                        color: const Color(0xFF74798E),
                      ),
                    ),
                    SizedBox(height: AppSpacing.s1_5),

                    // Main title
                    Text(
                      'Lên lịch trình cho chuyến đi\ntiếp theo của bạn',
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.2, // 24px / 20px
                        color: const Color(0xFF9455FD),
                      ),
                    ),
                  ],
                ),

                // Button with exact size
                SizedBox(
                  width: 176.w,
                  height: 42.h,
                  child: ElevatedButton(
                    onPressed: controller.createTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9455FD).withValues(alpha: 0.8), // #9455FDCC
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flight,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: AppSpacing.s2),
                        Text(
                          'Tạo lịch trình mới',
                          style: AppTypography.bodyM.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBlogs() {
    return Obx(() {
      // Show shimmer while loading
      if (controller.isLoadingBlogs.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              child: ShimmerText(width: 150, height: 20),
            ),
            SizedBox(height: AppSpacing.s3),
            const ShimmerBlogCard(itemCount: 3),
          ],
        );
      }

      final blogs = controller.recentBlogs;

      if (blogs.isEmpty) {
        return _buildEmptyBlogs();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
            child: Text(
              'Bài viết gần đây',
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: AppSpacing.s3),

          SizedBox(
            height: 292.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              clipBehavior: Clip.none,
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = blogs[index];

                return Container(
                  width: 280.w,
                  margin: EdgeInsets.only(right: AppSpacing.s4, bottom: 8.h),
                  child: GestureDetector(
                    onTap: () => controller.onBlogTapped(blog),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        // Image with Hero animation and hashtag overlay
                        Hero(
                          tag: 'discover-blog-image-${blog.id}',
                          child: Container(
                            height: 180.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                              color: AppColors.neutral100,
                            ),
                            child: Stack(
                              children: [
                                if (blog.coverImage.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                                    child: AppImage(
                                      imageData: blog.coverImage,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Center(
                                    child: Icon(
                                      Icons.article,
                                      size: 40.sp,
                                      color: AppColors.neutral400,
                                    ),
                                  ),

                                // Hashtag overlay (first tag)
                                if (blog.tags.isNotEmpty)
                                  Positioned(
                                    left: 12.w,
                                    bottom: 12.h,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        '#${blog.tags.first}',
                                        style: AppTypography.bodyXS.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title - Fixed height for alignment
                              SizedBox(
                                height: 44.h,
                                child: Text(
                                  blog.title,
                                  style: AppTypography.bodyM.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.neutral900,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              SizedBox(height: 8.h),

                              // Author info with time - Always at same position
                              Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 12.r,
                                    backgroundColor: AppColors.neutral200,
                                    child: blog.authorAvatar.isNotEmpty
                                        ? ClipOval(
                                            child: AppImage(
                                              imageData: blog.authorAvatar,
                                              width: 24.r,
                                              height: 24.r,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 14.sp,
                                            color: AppColors.neutral500,
                                          ),
                                  ),

                                  SizedBox(width: 6.w),

                                  // Author name
                                  Expanded(
                                    child: Text(
                                      blog.authorName,
                                      style: AppTypography.bodyXS.copyWith(
                                        color: AppColors.neutral700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Time
                                  Text(
                                    blog.formattedDate,
                                    style: AppTypography.bodyXS.copyWith(
                                      color: AppColors.neutral500,
                                    ),
                                  ),

                                  SizedBox(width: 8.w),

                                  // Save/Bookmark button
                                  Obx(() {
                                    final isBookmarked = controller.bookmarkedPostIds.contains(blog.id);
                                    return GestureDetector(
                                      onTap: () => controller.toggleBookmark(blog.id),
                                      child: Icon(
                                        isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                        size: 18.sp,
                                        color: isBookmarked ? AppColors.primary : AppColors.neutral500,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPopularDestinations() {
    return Obx(() {
      // Show shimmer while loading
      if (controller.isLoadingDestinations.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerText(width: 160, height: 20),
                  ShimmerText(width: 70, height: 16),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.s3),
            const ShimmerDestinationList(itemCount: 3),
          ],
        );
      }

      final destinations = controller.popularDestinations;

      if (destinations.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Điểm đến phổ biến',
                  style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: controller.onSeeAllDestinations,
                  child: Text(
                    'Xem tất cả',
                    style: AppTypography.bodyM.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final destination = destinations[index];

              return GestureDetector(
                onTap: () => controller.onDestinationTapped(destination),
                child: Container(
                  margin: EdgeInsets.only(bottom: AppSpacing.s3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Image
                      Container(
                        width: 100.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(12.r)),
                          color: AppColors.neutral100,
                        ),
                        child:
                            destination.primaryImage.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(12.r),
                                  ),
                                  child: AppImage(
                                    imageData: destination.primaryImage,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Center(
                                  child: Icon(
                                    Icons.place,
                                    size: 30.sp,
                                    color: AppColors.neutral400,
                                  ),
                                ),
                      ),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.s3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                destination.name,
                                style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                destination.description,
                                style: AppTypography.bodyS.copyWith(color: AppColors.textTertiary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }


  Widget _buildEmptyBlogs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      padding: EdgeInsets.all(AppSpacing.s6),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.article_outlined, size: 48.sp, color: AppColors.neutral400),
          SizedBox(height: AppSpacing.s3),
          Text(
            'Chưa có bài viết',
            style: AppTypography.bodyL.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Hãy là người đầu tiên chia sẻ trải nghiệm du lịch!',
            style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.s4),
          ElevatedButton(
            onPressed: () => Get.toNamed('/create-post'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            ),
            child: Text(
              'Viết bài ngay',
              style: AppTypography.bodyM.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildExploreByRegion() {
    // Static region cards - always show
    final regionCards = [
      AppAssets.regionCard1,
      AppAssets.regionCard2,
      AppAssets.regionCard3,
    ];

    final regionNames = [
      'Miền Bắc',
      'Miền Trung',
      'Miền Nam',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
          child: Text(
            'Khám phá theo vùng',
            style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        SizedBox(height: AppSpacing.s3),

        // Region Cards - Horizontal Scroll
        SizedBox(
          height: 227.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
            itemCount: regionCards.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Navigate to search filter with region preset
                  Get.toNamed(
                    '/search-filter',
                    arguments: {
                      'regionFilter': regionNames[index],
                      'autoSearch': true,
                    },
                  );
                },
                child: Container(
                  width: 164.w,
                  margin: EdgeInsets.only(right: 10.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                    child: Image.asset(
                      regionCards[index],
                      width: 164.w,
                      height: 227.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 164.w,
                          height: 227.h,
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                          ),
                          child: Icon(
                            Icons.image,
                            size: 40.sp,
                            color: AppColors.neutral400,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Keep old dynamic implementation for future use
  Widget _buildExploreByRegionDynamic() {
    return Obx(() {
      final regions = controller.exploreRegions;

      if (regions.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Khám phá theo vùng',
                  style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: controller.onSeeAllRegions,
                  child: Text(
                    'Xem tất cả',
                    style: AppTypography.bodyM.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.s3),

          SizedBox(
            height: 140.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              itemCount: regions.length,
              itemBuilder: (context, index) {
                final region = regions[index];

                return GestureDetector(
                  onTap: () => controller.onRegionTapped(region),
                  child: Container(
                    width: 120.w,
                    margin: EdgeInsets.only(right: AppSpacing.s3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neutral100,
                            border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                          ),
                          child: ClipOval(
                            child:
                                region['image'] != null
                                    ? AppImage(
                                      imageData: region['image'],
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                    : Icon(
                                      Icons.landscape,
                                      size: 40.sp,
                                      color: AppColors.neutral400,
                                    ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.s2),
                        Expanded(
                          child: Text(
                            region['name'] ?? '',
                            style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildComboToursSection() {
    return Obx(() {
      final combos = controller.comboTours;

      // Don't show shimmer - only show content when data available
      if (controller.isLoadingCombos.value || combos.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Combo tour nổi bật',
                  style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: controller.onSeeAllCombos,
                  child: Text(
                    'Xem tất cả',
                    style: AppTypography.bodyM.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.s3),

          SizedBox(
            height: 280.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              itemCount: combos.length,
              itemBuilder: (context, index) {
                final combo = combos[index];

                return GestureDetector(
                  onTap: () => controller.onComboTourTapped(combo),
                  child: Container(
                    width: 240.w,
                    margin: EdgeInsets.only(right: AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Container(
                          height: 160.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                            color: AppColors.neutral100,
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                                child:
                                    combo.images.isNotEmpty
                                        ? AppImage(
                                          imageData: combo.images.first,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                        : Center(
                                          child: Icon(
                                            Icons.tour,
                                            size: 40.sp,
                                            color: AppColors.neutral400,
                                          ),
                                        ),
                              ),

                              // Badge
                              Positioned(
                                top: AppSpacing.s2,
                                left: AppSpacing.s2,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.s2,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    'COMBO',
                                    style: AppTypography.bodyXS.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.s3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                combo.name,
                                style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: AppSpacing.s1),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14.sp,
                                    color: AppColors.textTertiary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      combo.destinations.isNotEmpty
                                          ? combo.destinations.join(', ')
                                          : combo.startLocation,
                                      style: AppTypography.bodyS.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.s2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    combo.displayDuration,
                                    style: AppTypography.bodyS.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    combo.displayPrice,
                                    style: AppTypography.bodyL.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
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
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBusinessListings() {
    return Obx(() {
      // Show shimmer while loading
      if (controller.isLoadingBusinessListings.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header Shimmer
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerText(width: 150, height: 24),
                      SizedBox(height: 4.h),
                      ShimmerText(width: 180, height: 14),
                    ],
                  ),
                  ShimmerText(width: 70, height: 16),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.s4),
            // Business Cards Shimmer
            const ShimmerBusinessCard(itemCount: 3),
          ],
        );
      }

      // Hide if no data after loading
      if (controller.businessListings.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dịch vụ nổi bật',
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Khám phá các dịch vụ tốt nhất',
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all listings
                    Get.toNamed('/search-filter', arguments: {'type': 'business'});
                  },
                  child: Text(
                    'Xem tất cả',
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppSpacing.s4),

          // Business Listings Horizontal List
          SizedBox(
            height: 260.h, // Optimized height with reduced spacing
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              clipBehavior: Clip.none, // Prevent shadow clipping
              itemCount: controller.businessListings.take(6).length,
              itemBuilder: (context, index) {
                final listing = controller.businessListings[index];
                return Container(
                  width: 200.w,
                  margin: EdgeInsets.only(right: AppSpacing.s3, bottom: 8.h), // Increased bottom margin for shadow
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed('/accommodation-detail', arguments: {
                        'listingId': listing.id,
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC097EA).withValues(alpha: 0.15),
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          Container(
                            height: 140.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.r),
                                topRight: Radius.circular(12.r),
                              ),
                              color: AppColors.neutral200,
                            ),
                          child: Stack(
                            children: [
                              if (listing.images.isNotEmpty)
                                Hero(
                                  tag: 'business-listing-image-${listing.id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.r),
                                      topRight: Radius.circular(12.r),
                                    ),
                                    child: AppImage(
                                      imageData: listing.images.first,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              
                              // Type badge
                              Positioned(
                                top: 8.h,
                                left: 8.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        listing.typeIcon,
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        listing.typeDisplayName,
                                        style: AppTypography.bodyXS.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Price
                              if (listing.hasDiscount)
                                Positioned(
                                  top: 8.h,
                                  right: 8.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      '-${listing.discountPercentage.toStringAsFixed(0)}%',
                                      style: AppTypography.bodyXS.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Content with padding
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 10.h,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Business Name - Fixed height for alignment
                              SizedBox(
                                height: 16.h,
                                child: Text(
                                  listing.businessName,
                                  style: AppTypography.bodyXS.copyWith(
                                    color: AppColors.neutral600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              SizedBox(height: 2.h),

                              // Title - Fixed height for alignment
                              SizedBox(
                                height: 40.h,
                                child: Text(
                                  listing.title,
                                  style: AppTypography.bodyM.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.neutral900,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              SizedBox(height: 3.h),

                              // Rating - Fixed height for alignment
                              SizedBox(
                                height: 10.h,
                                child: listing.rating > 0
                                    ? Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 14.sp,
                                            color: AppColors.warning,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            listing.rating.toStringAsFixed(1),
                                            style: AppTypography.bodyS.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            ' (${listing.reviews})',
                                            style: AppTypography.bodyS.copyWith(
                                              color: AppColors.neutral600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),

                              SizedBox(height: 3.h),

                              // Price - Always at same position
                              Row(
                                children: [
                                  if (listing.hasDiscount)
                                    Text(
                                      listing.formattedPrice,
                                      style: AppTypography.bodyS.copyWith(
                                        color: AppColors.neutral500,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  if (listing.hasDiscount)
                                    SizedBox(width: 6.w),
                                  Text(
                                    listing.hasDiscount
                                        ? listing.formattedDiscountPrice
                                        : listing.formattedPrice,
                                    style: AppTypography.bodyM.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
