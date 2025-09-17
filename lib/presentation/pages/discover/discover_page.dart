import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/presentation/controllers/discover/discover_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DiscoverPage extends GetView<DiscoverController> {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              
              SizedBox(height: AppSpacing.s4),
              
              // Hero Banner with Carousel
              _buildHeroBanner(),
              
              SizedBox(height: AppSpacing.s5),
              
              // Search Bar
              _buildSearchBar(),
              
              SizedBox(height: AppSpacing.s6),
              
              // Hot Destinations
              _buildHotDestinations(),
              
              SizedBox(height: AppSpacing.s6),
              
              // Planning Section
              _buildPlanningSection(),
              
              SizedBox(height: AppSpacing.s6),
              
              // Explore by Region
              _buildExploreByRegion(),
              
              SizedBox(height: AppSpacing.s6),
              
              // Blog Section
              _buildBlogSection(),
              
              SizedBox(height: AppSpacing.s8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: CachedNetworkImage(
                imageUrl: 'https://i.pravatar.cc/150?img=5',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.neutral100,
                ),
              ),
            ),
          ),
          
          SizedBox(width: AppSpacing.s3),
          
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Naomi!',
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                Text(
                  'Explore beautiful world',
                  style: AppTypography.bodyL.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 200.h,
      child: Stack(
        children: [
          // Banner Carousel
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(AppSpacing.s5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trải nghiệm với những\nchuyến đi nổi bật',
                        style: AppTypography.h4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.s3),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Phone Mockup - Fallback to icon if image not available
          Positioned(
            right: 30.w,
            bottom: 20.h,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 60.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.phone_iphone,
                  color: Colors.white.withOpacity(0.8),
                  size: 40.sp,
                ),
              ),
            ),
          ),
          
          // Page Indicator
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(() => AnimatedSmoothIndicator(
                activeIndex: controller.currentPage.value,
                count: 3,
                effect: WormEffect(
                  dotWidth: 8.w,
                  dotHeight: 8.h,
                  activeDotColor: Colors.white,
                  dotColor: Colors.white.withOpacity(0.4),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: TextField(
          controller: controller.searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm theo địa điểm',
            hintStyle: AppTypography.bodyM.copyWith(
              color: AppColors.neutral400,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.neutral400,
              size: 24.sp,
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

  Widget _buildHotDestinations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
          child: Text(
            'Chuyến đi nổi bật',
            style: AppTypography.h4.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.s4),
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
            itemCount: 5,
            itemBuilder: (context, index) {
              final destinations = [
                {'name': 'Vịnh Hạ Long', 'price': '550.000', 'duration': '5N/6D', 'rating': '4.9', 'location': 'Quảng Ninh'},
                {'name': 'Biển Nha Trang', 'price': '400.000', 'duration': '4N/5D', 'rating': '4.9', 'location': 'Khánh Hòa'},
                {'name': 'Đà Lạt', 'price': '350.000', 'duration': '3N/4D', 'rating': '4.8', 'location': 'Lâm Đồng'},
                {'name': 'Phú Quốc', 'price': '600.000', 'duration': '5N/6D', 'rating': '4.9', 'location': 'Kiên Giang'},
                {'name': 'Sa Pa', 'price': '450.000', 'duration': '4N/5D', 'rating': '4.7', 'location': 'Lào Cai'},
              ];
              
              final dest = destinations[index];
              
              return Container(
                width: 150.w,
                margin: EdgeInsets.only(right: AppSpacing.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with badge
                    Stack(
                      children: [
                        Container(
                          height: 120.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12.r),
                            ),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Duration badge
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              dest['duration']!,
                              style: AppTypography.bodyXS.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Content
                    Container(
                      padding: EdgeInsets.all(AppSpacing.s2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(12.r),
                        ),
                        border: Border.all(
                          color: AppColors.neutral100,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dest['name']!,
                            style: AppTypography.bodyM.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${dest['price']} VND',
                            style: AppTypography.bodyS.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12.sp,
                                color: AppColors.neutral400,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  dest['location']!,
                                  style: AppTypography.bodyXS.copyWith(
                                    color: AppColors.neutral500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.star,
                                size: 12.sp,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                dest['rating']!,
                                style: AppTypography.bodyXS.copyWith(
                                  color: AppColors.neutral600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlanningSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8D5FF),
            Color(0xFFD4B5FF),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhanh chóng chỉ với 1 thao tác',
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
                SizedBox(height: AppSpacing.s1),
                Text(
                  'Lên lịch trình cho chuyến đi tiếp theo của bạn',
                  style: AppTypography.bodyL.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.s3),
                GestureDetector(
                  onTap: () => controller.createTrip(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s3,
                      vertical: AppSpacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🗺️', style: TextStyle(fontSize: 16.sp)),
                        SizedBox(width: AppSpacing.s2),
                        Text(
                          'Tạo lịch trình mới',
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.primary,
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
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.travel_explore,
              size: 60.sp,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreByRegion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
          child: Text(
            'Khám phá theo vùng',
            style: AppTypography.h4.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.s4),
        Container(
          height: 240.h,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: AppSpacing.s3,
              mainAxisSpacing: AppSpacing.s3,
            ),
            itemCount: 2,
            itemBuilder: (context, index) {
              final regions = [
                {'name': 'Miền Bắc', 'desc': 'Lorem ipsum dolor'},
                {'name': 'Miền Trung', 'desc': 'Lorem ipsum dolor'},
              ];
              
              final region = regions[index];
              
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      index == 0
                          ? 'https://images.unsplash.com/photo-1528127269322-539801943592?w=400'
                          : 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(AppSpacing.s3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        region['name']!,
                        style: AppTypography.bodyL.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        region['desc']!,
                        style: AppTypography.bodyXS.copyWith(
                          color: Colors.white.withOpacity(0.8),
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
  }

  Widget _buildBlogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
          child: Text(
            'Blog nhanh',
            style: AppTypography.h4.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.s4),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
          itemCount: 2,
          itemBuilder: (context, index) {
            final blogs = [
              {
                'title': 'Lorem ipsum dolor sit amet, cons.',
                'desc': 'Lorem ipsum dolor sit amet, consectetur adipi...',
                'author': 'Thế Hùng',
              },
              {
                'title': 'Lorem ipsum dolor sit amet, cons.',
                'desc': 'Lorem ipsum dolor sit amet, consectetur adipi...',
                'author': 'Jung Môi An',
              },
            ];
            
            final blog = blogs[index];
            
            return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.s3),
              child: Row(
                children: [
                  // Image
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=200',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blog['title']!,
                          style: AppTypography.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          blog['desc']!,
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.neutral500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Container(
                              width: 20.w,
                              height: 20.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    'https://i.pravatar.cc/150?img=${index + 1}',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              blog['author']!,
                              style: AppTypography.bodyXS.copyWith(
                                color: AppColors.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Bookmark icon
                  Icon(
                    Icons.bookmark_border,
                    size: 20.sp,
                    color: AppColors.neutral400,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}