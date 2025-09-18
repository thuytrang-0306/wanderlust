import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/community/collection_detail_controller.dart';

class CollectionDetailPage extends GetView<CollectionDetailController> {
  const CollectionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => CollectionDetailController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 32.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Obx(
          () => Text(
            controller.collectionName.value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.posts.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: 8.h),
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final post = controller.posts[index];
            return _buildPostCard(post);
          },
        );
      }),
    );
  }

  Widget _buildPostCard(SavedPostModel post) {
    return GestureDetector(
      onTap: () => controller.openBlogDetail(post),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: CachedNetworkImageProvider(post.authorAvatar),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Text(
                            post.timeAgo,
                            style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
                          ),
                          if (post.location != null) ...[
                            Text(
                              ' • ',
                              style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
                            ),
                            Text(
                              post.location!,
                              style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.toggleBookmark(post.id),
                  child: Icon(Icons.bookmark, color: const Color(0xFFFBBF24), size: 24.sp),
                ),
              ],
            ),

            // Post Title
            SizedBox(height: 12.h),
            Text(
              post.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Post Content
            SizedBox(height: 8.h),
            Text(
              post.content,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // Post Images
            if (post.images.isNotEmpty) ...[SizedBox(height: 12.h), _buildPostImages(post.images)],

            // Interactions
            SizedBox(height: 12.h),
            Row(
              children: [
                // Like
                Row(
                  children: [
                    Icon(Icons.thumb_up_outlined, size: 18.sp, color: AppColors.textTertiary),
                    SizedBox(width: 6.w),
                    Text(
                      _formatCount(post.likeCount),
                      style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                SizedBox(width: 20.w),

                // Comment
                Row(
                  children: [
                    Icon(Icons.comment_outlined, size: 18.sp, color: AppColors.textTertiary),
                    SizedBox(width: 6.w),
                    Text(
                      post.commentCount.toString(),
                      style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
                    ),
                  ],
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
        borderRadius: BorderRadius.circular(8.r),
        child: CachedNetworkImage(
          imageUrl: images[0],
          height: 180.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    if (images.length == 2) {
      return Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                bottomLeft: Radius.circular(8.r),
              ),
              child: CachedNetworkImage(imageUrl: images[0], height: 140.h, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8.r),
                bottomRight: Radius.circular(8.r),
              ),
              child: CachedNetworkImage(imageUrl: images[1], height: 140.h, fit: BoxFit.cover),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
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
            Icon(Icons.bookmark_border_rounded, size: 80.sp, color: AppColors.neutral300),
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
              'Hãy lưu các bài viết yêu thích vào bộ sưu tập này',
              style: TextStyle(fontSize: 14.sp, color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Model
class SavedPostModel {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String timeAgo;
  final String? location;
  final String title;
  final String content;
  final List<String> images;
  final int likeCount;
  final int commentCount;

  SavedPostModel({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.timeAgo,
    this.location,
    required this.title,
    required this.content,
    required this.images,
    required this.likeCount,
    required this.commentCount,
  });
}
