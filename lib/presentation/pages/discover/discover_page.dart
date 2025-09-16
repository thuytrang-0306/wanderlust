import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/widgets/app_button.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with purple background
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.s5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFE8DAFF),
                      const Color(0xFFD4C4FF),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nhanh chóng chỉ với 1 thao tác',
                      style: AppTypography.bodyM.copyWith(
                        color: const Color(0xFF6B4FA0),
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s2),
                    Text(
                      'Lên lịch trình cho chuyến đi\ntiếp theo của bạn',
                      style: AppTypography.h3.copyWith(
                        color: const Color(0xFF5B3E8F),
                        fontWeight: AppTypography.bold,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Tạo lịch trình mới',
                            onPressed: () {
                              // TODO: Navigate to create itinerary
                            },
                            size: ButtonSize.medium,
                            backgroundColor: const Color(0xFF9455FD),
                            icon: Icons.add_location_alt_outlined,
                          ),
                        ),
                        SizedBox(width: AppSpacing.s3),
                        Image.asset(
                          'assets/images/travel_illustration.png',
                          width: 100.w,
                          height: 80.h,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100.w,
                              height: 80.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.flight_takeoff,
                                color: const Color(0xFF9455FD),
                                size: 40.sp,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.s6),

              // Explore by Region Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
                child: Text(
                  'Khám phá theo vùng',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.s4),

              // Region Cards
              SizedBox(
                height: 200.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
                  children: [
                    _buildRegionCard(
                      title: 'Miền Bắc',
                      subtitle: 'Lorem ipsum dolor...',
                      imagePath: 'assets/images/north_vietnam.jpg',
                      onTap: () {},
                    ),
                    SizedBox(width: AppSpacing.s4),
                    _buildRegionCard(
                      title: 'Miền Trung',
                      subtitle: 'Lorem ipsum dolor...',
                      imagePath: 'assets/images/central_vietnam.jpg',
                      onTap: () {},
                    ),
                    SizedBox(width: AppSpacing.s4),
                    _buildRegionCard(
                      title: 'Miền Nam',
                      subtitle: 'Lorem ipsum dolor...',
                      imagePath: 'assets/images/south_vietnam.jpg',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.s6),

              // Quick Blog Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
                child: Text(
                  'Blog nhanh',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.s4),

              // Blog Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.s3,
                    mainAxisSpacing: AppSpacing.s3,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildBlogCard();
                  },
                ),
              ),

              SizedBox(height: AppSpacing.s6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegionCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // Handle error
            },
          ),
        ),
        child: Stack(
          children: [
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: AppSpacing.s4,
              left: AppSpacing.s3,
              right: AppSpacing.s3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyL.copyWith(
                      color: AppColors.white,
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s1),
                  Text(
                    subtitle,
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow icon
            Positioned(
              bottom: AppSpacing.s4,
              right: AppSpacing.s3,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.s2),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: AppColors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        image: const DecorationImage(
          image: AssetImage('assets/images/blog_placeholder.jpg'),
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
              Colors.black.withValues(alpha: 0.5),
            ],
          ),
        ),
      ),
    );
  }
}