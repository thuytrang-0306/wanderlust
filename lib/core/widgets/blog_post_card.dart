import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';

class BlogPostCard extends StatelessWidget {
  final BlogPostModel? blogPost;
  final String? postId;
  final String? authorName;
  final String? authorAvatar;
  final String? title;
  final String? content;
  final String? coverImage;
  final List<String>? images;
  final String? location;
  final String? timeAgo;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onBookmark;
  final bool showInteractions;
  final bool isCompact;
  final String? heroTag; // Hero animation tag for image

  const BlogPostCard({
    super.key,
    this.blogPost,
    this.postId,
    this.authorName,
    this.authorAvatar,
    this.title,
    this.content,
    this.coverImage,
    this.images,
    this.location,
    this.timeAgo,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onBookmark,
    this.showInteractions = true,
    this.isCompact = false,
    this.heroTag,
  });

  // Factory constructor from BlogPostModel
  factory BlogPostCard.fromBlogPost({
    required BlogPostModel blog,
    VoidCallback? onTap,
    VoidCallback? onLike,
    VoidCallback? onComment,
    VoidCallback? onBookmark,
    bool showInteractions = true,
    bool isCompact = false,
    bool isLiked = false,
    bool isBookmarked = false,
    String? heroTag,
  }) {
    return BlogPostCard(
      blogPost: blog,
      postId: blog.id,
      authorName: blog.authorName,
      authorAvatar: blog.authorAvatar,
      title: blog.title,
      content: blog.excerpt.isNotEmpty ? blog.excerpt : blog.content,
      coverImage: blog.coverImage,
      images: blog.images,
      location: blog.destinations.isNotEmpty ? blog.destinations.first : '',
      timeAgo: _getTimeAgo(blog.createdAt),
      likeCount: blog.likes,
      commentCount: blog.commentsCount,
      isLiked: isLiked,
      isBookmarked: isBookmarked,
      onTap: onTap,
      onLike: onLike,
      onComment: onComment,
      onBookmark: onBookmark,
      showInteractions: showInteractions,
      isCompact: isCompact,
      heroTag: heroTag,
    );
  }

  static String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactCard();
    }
    return _buildFullCard();
  }

  Widget _buildFullCard() {
    return GestureDetector(
      onTap: onTap ?? () {
        if (postId != null) {
          Get.toNamed('/blog-detail', arguments: {'postId': postId});
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.s3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            if (coverImage != null && coverImage!.isNotEmpty)
              _buildCoverImage(),

            Padding(
              padding: EdgeInsets.all(AppSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Info
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neutral200,
                            width: 1,
                          ),
                        ),
                        child: ClipOval(
                          child: AppImage(
                            imageData: authorAvatar ?? '',
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
                      
                      // Author Name & Time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authorName ?? 'Anonymous',
                              style: AppTypography.bodyM.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (timeAgo != null || location != null)
                              Text(
                                [
                                  if (timeAgo != null) timeAgo,
                                  if (location != null && location!.isNotEmpty) location,
                                ].join(' • '),
                                style: AppTypography.bodyS.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.s3),

                  // Title
                  if (title != null && title!.isNotEmpty)
                    Text(
                      title!,
                      style: AppTypography.bodyL.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  if (title != null && title!.isNotEmpty && content != null && content!.isNotEmpty)
                    SizedBox(height: AppSpacing.s2),

                  // Content
                  if (content != null && content!.isNotEmpty)
                    Text(
                      content!,
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Interactions
                  if (showInteractions) ...[
                    SizedBox(height: AppSpacing.s3),
                    Row(
                      children: [
                        // Like
                        if (onLike != null)
                          GestureDetector(
                            onTap: onLike,
                            child: Row(
                              children: [
                                Icon(
                                  isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                  size: 20.sp,
                                  color: isLiked ? AppColors.primary : AppColors.textTertiary,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  _formatCount(likeCount),
                                  style: AppTypography.bodyS.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(width: AppSpacing.s5),

                        // Comment
                        if (onComment != null)
                          GestureDetector(
                            onTap: onComment,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.comment_outlined,
                                  size: 20.sp,
                                  color: AppColors.textTertiary,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  _formatCount(commentCount),
                                  style: AppTypography.bodyS.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const Spacer(),

                        // Bookmark
                        if (onBookmark != null)
                          GestureDetector(
                            onTap: onBookmark,
                            child: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                              size: 22.sp,
                              color: isBookmarked ? AppColors.primary : AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    final imageWidget = Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        color: AppColors.neutral100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        child: AppImage(
          imageData: coverImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorWidget: Container(
            color: AppColors.neutral200,
            child: Icon(
              Icons.image_not_supported,
              size: 40.sp,
              color: AppColors.neutral400,
            ),
          ),
        ),
      ),
    );

    // Wrap in Hero if heroTag is provided
    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildCompactCard() {
    return GestureDetector(
      onTap: onTap ?? () {
        if (postId != null) {
          Get.toNamed('/blog-detail', arguments: {'postId': postId});
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.s3),
        padding: EdgeInsets.all(AppSpacing.s3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (coverImage != null && coverImage!.isNotEmpty)
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.neutral100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: AppImage(
                    imageData: coverImage!,
                    fit: BoxFit.cover,
                    width: 80.w,
                    height: 80.w,
                    errorWidget: Container(
                      color: AppColors.neutral200,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 30.sp,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
                ),
              ),

            if (coverImage != null && coverImage!.isNotEmpty)
              SizedBox(width: AppSpacing.s3),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  if (title != null && title!.isNotEmpty)
                    Text(
                      title!,
                      style: AppTypography.bodyM.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  SizedBox(height: AppSpacing.s1),

                  // Author & Time
                  Row(
                    children: [
                      if (authorName != null)
                        Text(
                          authorName!,
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      if (timeAgo != null && authorName != null)
                        Text(
                          ' • ',
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      if (timeAgo != null)
                        Text(
                          timeAgo!,
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),

                  // Stats
                  if (showInteractions) ...[
                    SizedBox(height: AppSpacing.s2),
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_up_outlined,
                          size: 14.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _formatCount(likeCount),
                          style: AppTypography.bodyXS.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        SizedBox(width: AppSpacing.s3),
                        Icon(
                          Icons.comment_outlined,
                          size: 14.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _formatCount(commentCount),
                          style: AppTypography.bodyXS.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        if (onBookmark != null)
                          GestureDetector(
                            onTap: onBookmark,
                            child: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                              size: 18.sp,
                              color: isBookmarked ? AppColors.primary : AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}