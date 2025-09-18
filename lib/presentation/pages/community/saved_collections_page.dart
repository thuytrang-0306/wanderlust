import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/community/saved_collections_controller.dart';

class SavedCollectionsPage extends GetView<SavedCollectionsController> {
  const SavedCollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => SavedCollectionsController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: AppColors.primary, size: 32.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Đã lưu',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Icon(Icons.add, color: AppColors.primary, size: 16.sp),
            ),
            onPressed: controller.createNewCollection,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.collections.isEmpty) {
          return _buildEmptyState();
        }

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
            ),
            itemCount: controller.collections.length,
            itemBuilder: (context, index) {
              final collection = controller.collections[index];
              return _buildCollectionCard(collection);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCollectionCard(CollectionModel collection) {
    return GestureDetector(
      onTap: () => controller.openCollection(collection),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Collection Images Collage
              _buildCollageImages(collection.images),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                ),
              ),

              // Collection Name
              Positioned(
                bottom: 12.h,
                left: 12.w,
                right: 12.w,
                child: Text(
                  collection.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollageImages(List<String> images) {
    if (images.isEmpty) {
      return Container(
        color: AppColors.neutral200,
        child: Center(
          child: Icon(Icons.bookmark_outline, color: AppColors.neutral400, size: 40.sp),
        ),
      );
    }

    if (images.length == 1) {
      return CachedNetworkImage(
        imageUrl: images[0],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (images.length == 2) {
      return Row(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: images[0],
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
          Expanded(
            child: CachedNetworkImage(
              imageUrl: images[1],
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
        ],
      );
    }

    if (images.length == 3) {
      return Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: images[0],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: images[1],
                    fit: BoxFit.cover,
                    height: double.infinity,
                  ),
                ),
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: images[2],
                    fit: BoxFit.cover,
                    height: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // 4 or more images
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: images[0],
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
              ),
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: images[1],
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: images[2],
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
              ),
              Expanded(
                child:
                    images.length > 3
                        ? CachedNetworkImage(
                          imageUrl: images[3],
                          fit: BoxFit.cover,
                          height: double.infinity,
                        )
                        : Container(color: AppColors.neutral200),
              ),
            ],
          ),
        ),
      ],
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
              'Chưa có bộ sưu tập nào',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: AppSpacing.s2),
            Text(
              'Tạo bộ sưu tập để lưu các bài viết yêu thích',
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
class CollectionModel {
  final String id;
  final String name;
  final List<String> images;
  final int postCount;
  final bool isDefault;

  CollectionModel({
    required this.id,
    required this.name,
    required this.images,
    required this.postCount,
    this.isDefault = false,
  });
}
