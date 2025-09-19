import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/services/saved_blogs_service.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/presentation/controllers/community/blog_detail_controller.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';

class BlogDetailPage extends StatelessWidget {
  const BlogDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure SavedBlogsService is initialized first
    if (!Get.isRegistered<SavedBlogsService>()) {
      Get.put(SavedBlogsService());
    }
    final controller = Get.put(BlogDetailController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 32.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Chi tiết bài viết',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isBookmarked.value ? Icons.bookmark : Icons.bookmark_border,
                color:
                    controller.isBookmarked.value
                        ? const Color(0xFFFBBF24)
                        : AppColors.textSecondary,
                size: 24.sp,
              ),
              onPressed: controller.toggleBookmark,
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Show loading state
        if (controller.isLoadingData.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error state
        if (controller.blogPost.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: AppColors.neutral400),
                SizedBox(height: AppSpacing.s4),
                Text(
                  'Không thể tải bài viết',
                  style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
                ),
                SizedBox(height: AppSpacing.s4),
                TextButton(onPressed: controller.loadBlogData, child: const Text('Thử lại')),
              ],
            ),
          );
        }

        final post = controller.blogPost.value!;

        return Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image gallery
                    _buildImageGallery(post),

                    // Author info
                    _buildAuthorSection(post),

                    // Article content
                    _buildArticleContent(post),

                    // Suggestions section
                    _buildSuggestionsSection(controller),

                    // Comments section
                    _buildCommentsSection(controller),

                    SizedBox(height: 80.h), // Space for bottom bar
                  ],
                ),
              ),
            ),

            // Bottom engagement bar
            _buildBottomBar(controller),
          ],
        );
      }),
    );
  }

  Widget _buildImageGallery(BlogPostModel post) {
    final images =
        [
          if (post.coverImage.isNotEmpty) post.coverImage,
          ...post.images.take(3),
        ].where((img) => img.isNotEmpty).toList();

    if (images.isEmpty) {
      return Container(
        height: 200.h,
        margin: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Icon(Icons.image_not_supported, size: 48.sp, color: AppColors.neutral400),
        ),
      );
    }

    if (images.length == 1) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: AppImage(
            imageData: images[0],
            height: 200.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AppImage(imageData: images[0], height: 140.h, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AppImage(
                imageData: images.length > 1 ? images[1] : images[0],
                height: 140.h,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorSection(BlogPostModel post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Use AppImage widget for avatar - handles both base64 and URLs
          AppImage.avatar(imageData: post.authorAvatar, size: 40),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              post.authorName,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            post.formattedDate,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
          ),
          if (post.destinations.isNotEmpty) ...[
            Text(' • ', style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary)),
            Text(
              post.destinations.first,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArticleContent(BlogPostModel post) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            post.title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8.h),

          // Category and Tags
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (post.category.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    post.category,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ...post.tags.map(
                (tag) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Excerpt
          if (post.excerpt.isNotEmpty) ...[
            Text(
              post.excerpt,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Content
          Text(
            post.content,
            style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary, height: 1.6),
          ),

          SizedBox(height: 24.h),

          // Stats row
          Row(
            children: [
              Icon(Icons.remove_red_eye_outlined, size: 16.sp, color: AppColors.textTertiary),
              SizedBox(width: 4.w),
              Text(
                '${post.formattedViews} lượt xem',
                style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.share_outlined, size: 16.sp, color: AppColors.textTertiary),
              SizedBox(width: 4.w),
              Text(
                '${post.shares} lượt chia sẻ',
                style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(BlogDetailController controller) {
    return Obx(() {
      if (controller.suggestions.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Gợi ý cho bạn',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = controller.suggestions[index];
                return _buildSuggestionCard(
                  title: suggestion['title'] ?? '',
                  location: suggestion['location'] ?? '',
                  price: suggestion['price'] ?? '',
                  rating: suggestion['rating'] ?? 0.0,
                  duration: suggestion['duration'] ?? '',
                  imageUrl: suggestion['image'] ?? '',
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
        ],
      );
    });
  }

  Widget _buildSuggestionCard({
    required String title,
    required String location,
    required String price,
    required double rating,
    required String duration,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap:
          () => Get.toNamed(
            '/accommodation-detail',
            arguments: {'accommodationName': title, 'location': location},
          ),
      child: Container(
        width: 180.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: AppImage(
                    imageData: imageUrl,
                    height: 120.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (duration.isNotEmpty)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF812C),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        duration,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.star, size: 12.sp, color: const Color(0xFFFBBF24)),
                        SizedBox(width: 2.w),
                        Text(
                          rating.toString(),
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$price VND',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(BlogDetailController controller) {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bình luận (${controller.commentCount.value})',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => _showAddCommentDialog(controller),
                  child: Text(
                    'Thêm bình luận',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Comments list
            if (controller.comments.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Text(
                    'Chưa có bình luận nào',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
                  ),
                ),
              )
            else
              ...controller.comments.take(5).map((comment) => _buildCommentItem(comment)),
          ],
        ),
      );
    });
  }

  Widget _buildCommentItem(BlogComment comment) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage.avatar(imageData: comment.userAvatar, size: 32),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      ' • ${_getTimeAgo(comment.createdAt)}',
                      style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  comment.content,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary, height: 1.4),
                ),
                if (comment.likes > 0) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.thumb_up_outlined, size: 16.sp, color: AppColors.textTertiary),
                      SizedBox(width: 4.w),
                      Text(
                        comment.likes.toString(),
                        style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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

  void _showAddCommentDialog(BlogDetailController controller) {
    final textController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Thêm bình luận'),
        content: TextField(
          controller: textController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Nhập bình luận của bạn...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.addComment(textController.text);
                Get.back();
              }
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BlogDetailController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
      child: Row(
        children: [
          // Like button
          GestureDetector(
            onTap: controller.toggleLike,
            child: Row(
              children: [
                Obx(
                  () => Icon(
                    controller.isLiked.value ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 20.sp,
                    color: controller.isLiked.value ? AppColors.primary : AppColors.textTertiary,
                  ),
                ),
                SizedBox(width: 6.w),
                Obx(
                  () => Text(
                    controller.likeCount.value.toString(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 24.w),

          // Comment count
          Row(
            children: [
              Icon(Icons.comment_outlined, size: 20.sp, color: AppColors.textTertiary),
              SizedBox(width: 6.w),
              Obx(
                () => Text(
                  controller.commentCount.value.toString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: 24.w),

          // Share button
          GestureDetector(
            onTap: controller.shareArticle,
            child: Icon(Icons.share_outlined, size: 20.sp, color: AppColors.textTertiary),
          ),

          const Spacer(),

          // View likes button
          TextButton(
            onPressed: () {},
            child: Text(
              'Xem lượt thích',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
