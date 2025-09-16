import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/presentation/controllers/community/create_post_controller.dart';
import 'dart:io';

class CreatePostPage extends GetView<CreatePostController> {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.s5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Images section
                      _buildImagesSection(),
                      
                      SizedBox(height: AppSpacing.s6),
                      
                      // Title field
                      _buildTitleField(),
                      
                      SizedBox(height: AppSpacing.s5),
                      
                      // Tags field
                      _buildTagsField(),
                      
                      SizedBox(height: AppSpacing.s4),
                      
                      // Tag chips
                      _buildTagChips(),
                      
                      SizedBox(height: AppSpacing.s5),
                      
                      // Description field
                      _buildDescriptionField(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.neutral100,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios,
              size: 24.sp,
              color: AppColors.primary,
            ),
          ),
          
          // Title
          Text(
            'Tạo bài viết',
            style: AppTypography.h4.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          // Share button
          GestureDetector(
            onTap: controller.sharePost,
            child: Obx(() => Text(
              'Chia sẻ',
              style: AppTypography.bodyL.copyWith(
                color: controller.canShare.value 
                    ? AppColors.primary 
                    : AppColors.neutral400,
                fontWeight: FontWeight.w600,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Obx(() => SizedBox(
      height: controller.selectedImages.isEmpty ? 180.h : 200.h,
      child: controller.selectedImages.isEmpty 
        ? Row(
            children: [
              // Add photo button
              GestureDetector(
                onTap: controller.pickImages,
                child: Container(
                  width: 160.w,
                  height: 160.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8FA),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFFE8E8EA),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48.sp,
                        color: const Color(0xFFB8B8C0),
                      ),
                      SizedBox(height: AppSpacing.s2),
                      Text(
                        'Thêm ảnh',
                        style: AppTypography.bodyM.copyWith(
                          color: const Color(0xFFB8B8C0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.selectedImages.length) {
                // Add more button
                return GestureDetector(
                  onTap: controller.pickImages,
                  child: Container(
                    width: controller.selectedImages.length == 1 ? 200.w : 160.w,
                    height: 200.h,
                    margin: EdgeInsets.only(
                      left: index > 0 ? AppSpacing.s3 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8FA),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFFE8E8EA),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 32.sp,
                          color: const Color(0xFFB8B8C0),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              // Image item
              final image = controller.selectedImages[index];
              return Container(
                width: controller.selectedImages.length == 1 ? 200.w : 320.w,
                height: 200.h,
                margin: EdgeInsets.only(
                  right: index < controller.selectedImages.length - 1 ? AppSpacing.s3 : 0,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Image.file(
                        File(image.path),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Remove button
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: () => controller.removeImage(index),
                        child: Container(
                          width: 28.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    ));
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiêu đề *',
          style: AppTypography.bodyM.copyWith(
            color: const Color(0xFF1C1C28),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8FA),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFE8E8EA),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller.titleController,
            style: AppTypography.bodyM.copyWith(
              color: const Color(0xFF1C1C28),
            ),
            decoration: InputDecoration(
              hintText: 'Bạn hãy nhập tiêu đề cho bài viết',
              hintStyle: AppTypography.bodyM.copyWith(
                color: const Color(0xFFB8B8C0),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
            ),
            onChanged: (value) => controller.updateField(),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tag địa điểm',
          style: AppTypography.bodyM.copyWith(
            color: const Color(0xFF1C1C28),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8FA),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFE8E8EA),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller.tagController,
            style: AppTypography.bodyM.copyWith(
              color: const Color(0xFF1C1C28),
            ),
            decoration: InputDecoration(
              hintText: 'Bạn hãy thêm tag cho bài viết',
              hintStyle: AppTypography.bodyM.copyWith(
                color: const Color(0xFFB8B8C0),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
            ),
            onSubmitted: (value) => controller.addCustomTag(value),
          ),
        ),
      ],
    );
  }

  Widget _buildTagChips() {
    return Obx(() => Wrap(
      spacing: AppSpacing.s3,
      runSpacing: AppSpacing.s3,
      children: [
        ...controller.availableTags.map((tag) => _buildTagChip(
          label: tag,
          isSelected: controller.selectedTags.contains(tag),
          onTap: () => controller.toggleTag(tag),
        )).toList(),
        ...controller.selectedTags
            .where((tag) => !controller.availableTags.contains(tag))
            .map((tag) => _buildTagChip(
              label: tag,
              isSelected: true,
              onTap: () => controller.toggleTag(tag),
            )).toList(),
      ],
    ));
  }

  Widget _buildTagChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : const Color(0xFFE8E8EA),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.bodyM.copyWith(
                color: isSelected 
                    ? AppColors.primary 
                    : const Color(0xFF6B6B78),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 6.w),
              Icon(
                Icons.close,
                size: 16.sp,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mô tả',
          style: AppTypography.bodyM.copyWith(
            color: const Color(0xFF1C1C28),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8FA),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFE8E8EA),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              TextField(
                controller: controller.descriptionController,
                maxLines: 8,
                maxLength: 2000,
                style: AppTypography.bodyM.copyWith(
                  color: const Color(0xFF1C1C28),
                ),
                decoration: InputDecoration(
                  hintText: 'Bạn hãy nhập mô tả địa điểm',
                  hintStyle: AppTypography.bodyM.copyWith(
                    color: const Color(0xFFB8B8C0),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.w),
                  counterText: '',
                ),
                onChanged: (value) => controller.updateDescription(value),
              ),
              // Character counter
              Positioned(
                bottom: 12.h,
                right: 12.w,
                child: Obx(() => Text(
                  '${controller.descriptionLength.value}/2000',
                  style: AppTypography.bodyXS.copyWith(
                    color: const Color(0xFFB8B8C0),
                  ),
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}