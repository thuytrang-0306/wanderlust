import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/widgets/blog_post_card.dart';
import 'package:wanderlust/presentation/controllers/community/collection_detail_controller.dart';

class CollectionDetailPage extends GetView<CollectionDetailController> {
  const CollectionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        if (controller.isLoadingData.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.blogPosts.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPosts,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: AppSpacing.s3,
            ),
            itemCount: controller.blogPosts.length,
            itemBuilder: (context, index) {
              final blog = controller.blogPosts[index];
              return BlogPostCard.fromBlogPost(
                blog: blog,
                isBookmarked: true,
                onBookmark: () => controller.toggleBookmark(blog.id),
                onLike: () => controller.toggleLike(blog.id),
                onComment: () => controller.openBlogDetail(blog.id),
                showInteractions: true,
                isCompact: false,
              );
            },
          ),
        );
      }),
    );
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