import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/data/models/listing_model.dart';

/// Shared Business Listing Card Widget
/// Used in Discover Page and Blog Detail Page
class BusinessListingCard extends StatelessWidget {
  final ListingModel listing;
  final double? width;

  const BusinessListingCard({
    super.key,
    required this.listing,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200.w,
      margin: EdgeInsets.only(right: AppSpacing.s3, bottom: 8.h),
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
              _buildImageSection(),

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
                                Flexible(
                                  child: Text(
                                    '${listing.rating.toStringAsFixed(1)} (${listing.reviews})',
                                    style: AppTypography.bodyS.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                          Flexible(
                            child: Text(
                              listing.formattedPrice,
                              style: AppTypography.bodyS.copyWith(
                                color: AppColors.neutral500,
                                decoration: TextDecoration.lineThrough,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (listing.hasDiscount) SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            listing.hasDiscount
                                ? listing.formattedDiscountPrice
                                : listing.formattedPrice,
                            style: AppTypography.bodyM.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
  }

  Widget _buildImageSection() {
    return Container(
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

          // Discount badge
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
    );
  }
}
