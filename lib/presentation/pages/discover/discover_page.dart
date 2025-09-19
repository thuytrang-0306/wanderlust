import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/presentation/controllers/discover/discover_controller.dart';
import 'package:wanderlust/presentation/controllers/account/user_profile_controller.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
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

                // Featured Tours
                _buildFeaturedTours(),

                SizedBox(height: AppSpacing.s6),

                // Planning Section
                _buildPlanningSection(),

                SizedBox(height: AppSpacing.s6),

                // Explore by Region
                _buildExploreByRegion(),

                SizedBox(height: AppSpacing.s6),

                // Combo Tours Section
                _buildComboToursSection(),

                SizedBox(height: AppSpacing.s6),

                // Recent Blogs
                _buildRecentBlogs(),

                SizedBox(height: AppSpacing.s6),

                // Popular Destinations
                _buildPopularDestinations(),

                SizedBox(height: AppSpacing.s6),

                // Business Listings Section
                _buildBusinessListings(),

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

          // Notification Icon
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24.sp),
            onPressed: () => Get.toNamed('/notifications'),
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
        // Single welcome banner
        return Container(
          height: 200.h,
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
            ),
          ),
          child: Stack(
            children: [
              // Pattern decoration
              Positioned(
                right: -50.w,
                top: -50.h,
                child: Container(
                  width: 200.w,
                  height: 200.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(AppSpacing.s5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào mừng đến với\nWanderlust',
                      style: AppTypography.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s3),
                    Text(
                      'Khám phá thế giới cùng chúng tôi',
                      style: AppTypography.bodyM.copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                    SizedBox(height: AppSpacing.s4),
                    ElevatedButton(
                      onPressed: controller.onPlanTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.s5,
                          vertical: AppSpacing.s3,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      ),
                      child: Text(
                        'Lên kế hoạch ngay',
                        style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      child: GestureDetector(
        onTap: () => Get.toNamed('/search-filter'),
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(24.r),
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
    );
  }

  Widget _buildFeaturedTours() {
    return Obx(() {
      final tours = controller.featuredTours;

      if (tours.isEmpty) {
        return _buildEmptyTours();
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
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      padding: EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFE6F5C5), const Color(0xFFD0FCEF)]),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lập kế hoạch\ncho chuyến đi',
                  style: AppTypography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.s3),
                ElevatedButton(
                  onPressed: controller.createTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s5,
                      vertical: AppSpacing.s3,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                  ),
                  child: Text(
                    'Bắt đầu',
                    style: AppTypography.bodyM.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.map_outlined, size: 80.sp, color: AppColors.primary.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildRecentBlogs() {
    return Obx(() {
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
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = blogs[index];

                return GestureDetector(
                  onTap: () => controller.onBlogTapped(blog),
                  child: Container(
                    width: 260.w,
                    margin: EdgeInsets.only(right: AppSpacing.s4),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Container(
                          height: 120.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                            color: AppColors.neutral100,
                          ),
                          child:
                              blog.coverImage.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                                    child: AppImage(
                                      imageData: blog.coverImage,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Center(
                                    child: Icon(
                                      Icons.article,
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
                                blog.title,
                                style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: AppSpacing.s1),
                              Text(
                                blog.formattedDate,
                                style: AppTypography.bodyXS.copyWith(color: AppColors.textTertiary),
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

  Widget _buildPopularDestinations() {
    return Obx(() {
      final destinations = controller.popularDestinations;

      if (destinations.isEmpty) {
        return _buildEmptyDestinations();
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

  Widget _buildEmptyDestinations() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      padding: EdgeInsets.all(AppSpacing.s6),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.explore_outlined, size: 48.sp, color: AppColors.neutral400),
          SizedBox(height: AppSpacing.s3),
          Text(
            'Khám phá thế giới',
            style: AppTypography.bodyL.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Chưa có điểm đến nào được thêm.\nHãy bắt đầu khám phá ngay!',
            style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTours() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      padding: EdgeInsets.all(AppSpacing.s6),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.tour_outlined, size: 48.sp, color: AppColors.neutral400),
          SizedBox(height: AppSpacing.s3),
          Text(
            'Chưa có tour nào',
            style: AppTypography.bodyL.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Các tour du lịch sẽ sớm được cập nhật.\nVui lòng quay lại sau!',
            style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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

  Widget _buildEmptyRegions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      padding: EdgeInsets.all(AppSpacing.s6),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.map_outlined, size: 48.sp, color: AppColors.neutral400),
          SizedBox(height: AppSpacing.s3),
          Text(
            'Khám phá theo vùng',
            style: AppTypography.bodyL.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Tính năng đang được phát triển.\nVui lòng quay lại sau!',
            style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCombos() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      padding: EdgeInsets.all(AppSpacing.s6),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.card_giftcard_outlined, size: 48.sp, color: AppColors.neutral400),
          SizedBox(height: AppSpacing.s3),
          Text(
            'Combo tour đặc biệt',
            style: AppTypography.bodyL.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Combo tour giá ưu đãi sẽ sớm ra mắt.\nĐừng bỏ lỡ!',
            style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExploreByRegion() {
    return Obx(() {
      final regions = controller.exploreRegions;

      if (regions.isEmpty) {
        return _buildEmptyRegions();
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

      if (combos.isEmpty) {
        return _buildEmptyCombos();
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
      if (controller.businessListings.isEmpty) {
        return SizedBox();
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
            height: 280.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              itemCount: controller.businessListings.take(6).length,
              itemBuilder: (context, index) {
                final listing = controller.businessListings[index];
                return Container(
                  width: 200.w,
                  margin: EdgeInsets.only(right: AppSpacing.s3),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to accommodation detail (reuse existing UI)
                      Get.toNamed('/accommodation-detail', arguments: {
                        'listingId': listing.id,
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Container(
                          height: 140.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: AppColors.neutral200,
                          ),
                          child: Stack(
                            children: [
                              if (listing.images.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: AppImage(
                                    imageData: listing.images.first,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
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
                        
                        SizedBox(height: AppSpacing.s2),
                        
                        // Business Name
                        Text(
                          listing.businessName,
                          style: AppTypography.bodyXS.copyWith(
                            color: AppColors.neutral600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Title
                        Text(
                          listing.title,
                          style: AppTypography.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        SizedBox(height: AppSpacing.s1),
                        
                        // Rating
                        if (listing.rating > 0)
                          Row(
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
                          ),
                        
                        Spacer(),
                        
                        // Price
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
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
