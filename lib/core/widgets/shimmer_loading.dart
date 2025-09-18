import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

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

  const ShimmerCard({
    super.key,
    this.height = 200,
    this.width = 150,
    this.borderRadius = 12,
  });

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
        itemBuilder: (_, index) => ShimmerCard(
          width: itemWidth,
          height: itemHeight,
        ),
      ),
    );
  }
}

// Shimmer for text lines
class ShimmerText extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerText({
    super.key,
    this.width = 100,
    this.height = 14,
    this.borderRadius = 4,
  });

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

  const ShimmerAvatar({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: size.w,
        height: size.w,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// Shimmer for banner
class ShimmerBanner extends StatelessWidget {
  final double height;
  final double borderRadius;

  const ShimmerBanner({
    super.key,
    this.height = 180,
    this.borderRadius = 16,
  });

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