import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/presentation/controllers/community/blog_detail_controller.dart';

class BlogDetailPage extends StatelessWidget {
  const BlogDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BlogDetailController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: AppColors.textPrimary,
            size: 32.sp,
          ),
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
          Obx(() => IconButton(
            icon: Icon(
              controller.isBookmarked.value 
                ? Icons.bookmark 
                : Icons.bookmark_border,
              color: controller.isBookmarked.value 
                ? const Color(0xFFFBBF24) 
                : AppColors.textSecondary,
              size: 24.sp,
            ),
            onPressed: controller.toggleBookmark,
          )),
        ],
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image gallery
                  _buildImageGallery(controller),
                  
                  // Author info
                  _buildAuthorSection(controller),
                  
                  // Article content
                  _buildArticleContent(controller),
                  
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
      ),
    );
  }
  
  Widget _buildImageGallery(BlogDetailController controller) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 140.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              height: 140.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=400',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAuthorSection(BlogDetailController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundImage: CachedNetworkImageProvider(
              'https://i.pravatar.cc/150?img=3',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Hiếu Thứ Hai',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '2 giờ trước',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textTertiary,
            ),
          ),
          Text(
            ' • ',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textTertiary,
            ),
          ),
          Text(
            'Hà Giang',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildArticleContent(BlogDetailController controller) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Lorem ipsum dolor sit amet, consectetur.',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Body paragraphs
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas id sit eu tellus sed cursus eleifend id porta. Lorem adipiscing mus vestibulum consequat porta eu ultrices feugiat. Et, faucibus ut amet turpis. Facilisis faucibus semper cras purus.',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas id sit eu tellus sed cursus eleifend id porta.',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Fermentum et eget libero lectus. Amet, tellus aliquam, dignissim enim placerat purus nunc, ac ipsum. Ac pretium.',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestionsSection(BlogDetailController controller) {
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
            itemCount: 2,
            itemBuilder: (context, index) {
              return _buildSuggestionCard(
                title: index == 0 ? 'Homestay Sơn Thủy' : 'Khách sạn GG',
                location: 'Hà Giang',
                price: index == 0 ? '400.000' : '600.000',
                rating: 4.4,
                duration: '4N/5D',
                imageUrl: index == 0
                  ? 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400'
                  : 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
              );
            },
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
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
      onTap: () => Get.toNamed('/accommodation-detail', arguments: {
        'accommodationName': title,
        'location': location,
      }),
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
              Container(
                height: 120.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
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
          
          // Content with flexible layout
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
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.star,
                        size: 12.sp,
                        color: const Color(0xFFFBBF24),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bình luận',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Comment item
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundImage: CachedNetworkImageProvider(
                  'https://i.pravatar.cc/150?img=5',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Jake',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          ' • 5 phút',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_up_outlined,
                          size: 16.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '5,000',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.comment_outlined,
                          size: 16.sp,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomBar(BlogDetailController controller) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
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
                Obx(() => Icon(
                  controller.isLiked.value 
                    ? Icons.thumb_up 
                    : Icons.thumb_up_outlined,
                  size: 20.sp,
                  color: controller.isLiked.value 
                    ? AppColors.primary 
                    : AppColors.textTertiary,
                )),
                SizedBox(width: 6.w),
                Obx(() => Text(
                  controller.likeCount.value.toString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ],
            ),
          ),
          
          SizedBox(width: 24.w),
          
          // Comment count
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                size: 20.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 6.w),
              Text(
                '700',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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