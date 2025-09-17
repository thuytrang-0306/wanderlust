import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/community/community_controller.dart';
import 'package:wanderlust/core/widgets/app_image.dart';

class CommunityPage extends GetView<CommunityController> {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => CommunityController());
    
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F7F8),
              child: Obx(() {
                if (controller.posts.isEmpty) {
                  return _buildEmptyState();
                }
                
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Posts Feed
                      ...controller.posts.map((post) => _buildPostCard(post)),
                      
                      // Review Section
                      _buildReviewSection(),
                      
                      SizedBox(height: 100.h), // Bottom padding for navigation
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8E0FF),
            Color(0xFFF5F0FF),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s5,
            vertical: AppSpacing.s4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cộng đồng',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: controller.createPost,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  GestureDetector(
                    onTap: controller.openBookmarks,
                    child: Icon(
                      Icons.bookmark_outline,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return GestureDetector(
      onTap: () => Get.toNamed('/blog-detail', arguments: {'postId': post.id}),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.s3),
        padding: EdgeInsets.all(AppSpacing.s4),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 0.5,
                  ),
                ),
                child: ClipOval(
                  child: AppImage(
                    imageData: post.userAvatar,
                    width: 40.w,
                    height: 40.w,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      color: AppColors.neutral200,
                      child: Icon(
                        Icons.person,
                        color: AppColors.neutral400,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      post.timeAndLocation,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Post Content
          SizedBox(height: AppSpacing.s3),
          Text(
            post.content,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF374151),
              height: 1.5,
            ),
          ),
          
          // Post Images
          if (post.images.isNotEmpty) ...[
            SizedBox(height: AppSpacing.s3),
            _buildPostImages(post.images),
          ],
          
          // Interactions
          SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              // Like
              GestureDetector(
                onTap: () => controller.toggleLike(post.id),
                child: Row(
                  children: [
                    Icon(
                      post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 20.sp,
                      color: post.isLiked ? AppColors.primary : const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _formatCount(post.likeCount),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.s5),
              
              // Comment
              GestureDetector(
                onTap: () => controller.openComments(post.id),
                child: Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 20.sp,
                      color: const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      post.commentCount.toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Bookmark
              GestureDetector(
                onTap: () => controller.toggleBookmark(post.id),
                child: Icon(
                  post.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  size: 22.sp,
                  color: post.isBookmarked ? AppColors.primary : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPostImages(List<String> images) {
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: AppImage(
          imageData: images[0],
          height: 200.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (images.length == 2) {
      return Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AppImage(
                imageData: images[0],
                height: 150.h,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s2),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AppImage(
                imageData: images[1],
                height: 150.h,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildReviewSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review nơi cư trú',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: AppSpacing.s4),
          
          // Review Cards Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.reviews.map((review) => 
                _buildReviewCard(review)
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return GestureDetector(
      onTap: () => Get.toNamed('/accommodation-detail', arguments: {
        'accommodationId': review.id,
        'accommodationName': review.name,
      }),
      child: Container(
        width: 200.w,
        height: 240.h,
        margin: EdgeInsets.only(right: AppSpacing.s3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: AppImage(
              imageData: review.imageUrl,
              width: 200.w,
              height: 240.h,
              fit: BoxFit.cover,
            ),
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
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
          
          // Badge
          if (review.duration != null)
            Positioned(
              top: AppSpacing.s3,
              right: AppSpacing.s3,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s2,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  review.duration!,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          
          // Content
          Positioned(
            bottom: AppSpacing.s3,
            left: AppSpacing.s3,
            right: AppSpacing.s3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  review.location,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: AppSpacing.s2),
                Row(
                  children: [
                    // Rating
                    Icon(
                      Icons.star,
                      size: 16.sp,
                      color: const Color(0xFFFBBF24),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      review.rating.toString(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Price
                    Text(
                      review.price,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return count.toString();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 80.sp,
              color: AppColors.neutral300,
            ),
            SizedBox(height: AppSpacing.s4),
            Text(
              'Chưa có bài viết nào',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: AppSpacing.s2),
            Text(
              'Hãy là người đầu tiên chia sẻ trải nghiệm của bạn',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Models
class PostModel {
  final String id;
  final String userName;
  final String userAvatar;
  final String timeAndLocation;
  final String content;
  final List<String> images;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isBookmarked;

  PostModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.timeAndLocation,
    required this.content,
    required this.images,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.isBookmarked,
  });
}

class ReviewModel {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final String price;
  final String? duration;

  ReviewModel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.price,
    this.duration,
  });
}