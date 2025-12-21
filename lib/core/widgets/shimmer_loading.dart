import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({super.key, required this.child, this.baseColor, this.highlightColor});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? AppColors.neutral200,
      highlightColor: highlightColor ?? AppColors.neutral100,
      child: child,
    );
  }
}

// Shimmer for list items
class ShimmerListItem extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const ShimmerListItem({
    super.key,
    this.height = 120,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        height: height.h,
        width: width == double.infinity ? width : width.w,
        margin: EdgeInsets.only(bottom: AppSpacing.s3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}

// Shimmer for cards
class ShimmerCard extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const ShimmerCard({super.key, this.height = 200, this.width = 150, this.borderRadius = 12});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        height: height.h,
        width: width.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}

// Shimmer for horizontal list
class ShimmerHorizontalList extends StatelessWidget {
  final int itemCount;
  final double itemWidth;
  final double itemHeight;
  final double spacing;

  const ShimmerHorizontalList({
    super.key,
    this.itemCount = 3,
    this.itemWidth = 150,
    this.itemHeight = 200,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: spacing.w),
        itemBuilder: (_, index) => ShimmerCard(width: itemWidth, height: itemHeight),
      ),
    );
  }
}

// Shimmer for text lines
class ShimmerText extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerText({super.key, this.width = 100, this.height = 14, this.borderRadius = 4});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}

// Shimmer for avatar
class ShimmerAvatar extends StatelessWidget {
  final double size;

  const ShimmerAvatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: size.w,
        height: size.w,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }
}

// Shimmer for banner
class ShimmerBanner extends StatelessWidget {
  final double height;
  final double borderRadius;

  const ShimmerBanner({super.key, this.height = 180, this.borderRadius = 16});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        height: height.h,
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}

// Shimmer for grid items
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.spacing = 12,
    this.childAspectRatio = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing.h,
          crossAxisSpacing: spacing.w,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: itemCount,
        itemBuilder: (_, index) => const ShimmerCard(),
      ),
    );
  }
}

// ============= DISCOVERY PAGE SPECIFIC SHIMMERS =============

// Shimmer for tour cards (featured tours section)
class ShimmerTourCard extends StatelessWidget {
  final int itemCount;

  const ShimmerTourCard({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            width: 280.w,
            margin: EdgeInsets.only(right: AppSpacing.s4),
            child: ShimmerLoading(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.s3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 16.h, width: 200.w, color: Colors.white),
                        SizedBox(height: AppSpacing.s1),
                        Row(
                          children: [
                            Container(height: 14.h, width: 80.w, color: Colors.white),
                            const Spacer(),
                            Container(height: 16.h, width: 100.w, color: Colors.white),
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
    );
  }
}

// Shimmer for blog cards
class ShimmerBlogCard extends StatelessWidget {
  final int itemCount;

  const ShimmerBlogCard({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            width: 260.w,
            margin: EdgeInsets.only(right: AppSpacing.s4),
            child: ShimmerLoading(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.s3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14.h, width: double.infinity, color: Colors.white),
                        SizedBox(height: AppSpacing.s1),
                        Container(height: 12.h, width: 80.w, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Shimmer for destination list
class ShimmerDestinationList extends StatelessWidget {
  final int itemCount;

  const ShimmerDestinationList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.s3),
          child: ShimmerLoading(
            child: Row(
              children: [
                // Image
                Container(
                  width: 100.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(12.r)),
                  ),
                ),
                SizedBox(width: AppSpacing.s3),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16.h, width: double.infinity, color: Colors.white),
                      SizedBox(height: AppSpacing.s2),
                      Container(height: 14.h, width: 200.w, color: Colors.white),
                      SizedBox(height: AppSpacing.s1),
                      Container(height: 14.h, width: 150.w, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Shimmer for business listing cards
class ShimmerBusinessCard extends StatelessWidget {
  final int itemCount;

  const ShimmerBusinessCard({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            width: 200.w,
            margin: EdgeInsets.only(right: AppSpacing.s3),
            child: ShimmerLoading(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s2),
                  // Business name
                  Container(height: 12.h, width: 100.w, color: Colors.white),
                  SizedBox(height: AppSpacing.s1),
                  // Title
                  Container(height: 14.h, width: double.infinity, color: Colors.white),
                  SizedBox(height: AppSpacing.s1),
                  Container(height: 14.h, width: 150.w, color: Colors.white),
                  SizedBox(height: AppSpacing.s2),
                  // Rating
                  Container(height: 12.h, width: 80.w, color: Colors.white),
                  const Spacer(),
                  // Price
                  Container(height: 16.h, width: 100.w, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Shimmer for combo tour cards
class ShimmerComboCard extends StatelessWidget {
  final int itemCount;

  const ShimmerComboCard({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            width: 240.w,
            margin: EdgeInsets.only(right: AppSpacing.s4),
            child: ShimmerLoading(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    height: 160.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.s3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14.h, width: double.infinity, color: Colors.white),
                        SizedBox(height: AppSpacing.s2),
                        Container(height: 14.h, width: 180.w, color: Colors.white),
                        SizedBox(height: AppSpacing.s2),
                        Container(height: 12.h, width: 120.w, color: Colors.white),
                        SizedBox(height: AppSpacing.s2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(height: 12.h, width: 60.w, color: Colors.white),
                            Container(height: 16.h, width: 80.w, color: Colors.white),
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
    );
  }
}

// ============= COMMUNITY PAGE SPECIFIC SHIMMERS =============

// Shimmer for blog post cards - matches BlogPostCard structure
class ShimmerBlogPostCard extends StatelessWidget {
  final int itemCount;

  const ShimmerBlogPostCard({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.s3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ShimmerLoading(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image
                Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(AppSpacing.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author info row (avatar + name + time)
                      Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: AppSpacing.s3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(height: 16.h, width: 120.w, color: Colors.white),
                                SizedBox(height: 4.h),
                                Container(height: 14.h, width: 80.w, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppSpacing.s3),

                      // Title
                      Container(height: 18.h, width: double.infinity, color: Colors.white),
                      SizedBox(height: 8.h),
                      Container(height: 18.h, width: 200.w, color: Colors.white),

                      SizedBox(height: AppSpacing.s2),

                      // Content
                      Container(height: 16.h, width: double.infinity, color: Colors.white),
                      SizedBox(height: 6.h),
                      Container(height: 16.h, width: double.infinity, color: Colors.white),
                      SizedBox(height: 6.h),
                      Container(height: 16.h, width: 250.w, color: Colors.white),

                      SizedBox(height: AppSpacing.s3),

                      // Interaction buttons row
                      Row(
                        children: [
                          Row(
                            children: [
                              Container(height: 20.h, width: 20.w, color: Colors.white),
                              SizedBox(width: 6.w),
                              Container(height: 14.h, width: 30.w, color: Colors.white),
                            ],
                          ),
                          SizedBox(width: AppSpacing.s5),
                          Row(
                            children: [
                              Container(height: 20.h, width: 20.w, color: Colors.white),
                              SizedBox(width: 6.w),
                              Container(height: 14.h, width: 30.w, color: Colors.white),
                            ],
                          ),
                          const Spacer(),
                          Container(height: 22.h, width: 22.w, color: Colors.white),
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
    );
  }
}

// Shimmer for community post cards (user feed style - avatar first)
class ShimmerCommunityPost extends StatelessWidget {
  final int itemCount;

  const ShimmerCommunityPost({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.s3),
          padding: EdgeInsets.all(AppSpacing.s4),
          decoration: const BoxDecoration(color: Colors.white),
          child: ShimmerLoading(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info row (avatar + name + time)
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 15.h, width: 120.w, color: Colors.white),
                          SizedBox(height: 2.h),
                          Container(height: 13.h, width: 80.w, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.s3),
                // Content text
                Container(height: 14.h, width: double.infinity, color: Colors.white),
                SizedBox(height: 6.h),
                Container(height: 14.h, width: 250.w, color: Colors.white),
                SizedBox(height: AppSpacing.s3),
                // Image
                Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(height: AppSpacing.s3),
                // Interaction buttons row
                Row(
                  children: [
                    Row(
                      children: [
                        Container(height: 20.h, width: 20.w, color: Colors.white),
                        SizedBox(width: 6.w),
                        Container(height: 14.h, width: 30.w, color: Colors.white),
                      ],
                    ),
                    SizedBox(width: AppSpacing.s5),
                    Row(
                      children: [
                        Container(height: 20.h, width: 20.w, color: Colors.white),
                        SizedBox(width: 6.w),
                        Container(height: 14.h, width: 30.w, color: Colors.white),
                      ],
                    ),
                    const Spacer(),
                    Container(height: 22.h, width: 22.w, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Shimmer for saved collections grid
class ShimmerCollectionGrid extends StatelessWidget {
  final int itemCount;

  const ShimmerCollectionGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.s5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.s4,
        crossAxisSpacing: AppSpacing.s4,
        childAspectRatio: 1.0,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerLoading(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Stack(
              children: [
                // Background image placeholder
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                // Bottom gradient overlay area
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 60.h,
                    padding: EdgeInsets.all(AppSpacing.s3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14.h, width: 100.w, color: Colors.white),
                        SizedBox(height: AppSpacing.s1),
                        Container(height: 12.h, width: 60.w, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
