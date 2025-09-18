import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_text_field.dart';
import 'package:wanderlust/core/widgets/app_date_time_picker.dart';
import 'package:wanderlust/presentation/controllers/planning/trip_edit_controller.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/data/services/image_upload_service.dart';

class TripEditPage extends GetView<TripEditController> {
  const TripEditPage({super.key});

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
                padding: EdgeInsets.all(AppSpacing.s6),
                child: Column(
                  children: [
                    // Illustration
                    _buildIllustration(),
                    SizedBox(height: AppSpacing.s8),

                    // Form fields
                    _buildForm(),
                  ],
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
        border: Border(bottom: BorderSide(color: AppColors.neutral100, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.s2),
              child: Icon(Icons.arrow_back_ios, size: 24.sp, color: AppColors.primary),
            ),
          ),

          // Title
          Obx(
            () => Text(
              controller.isEditMode.value ? 'Chỉnh sửa lịch trình' : 'Tạo lịch trình',
              style: AppTypography.h4.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Save button
          GestureDetector(
            onTap: controller.saveTripPlan,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.s2),
              child: Text(
                'Lưu',
                style: AppTypography.bodyL.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Obx(() {
      final coverImage = controller.coverImage.value;

      return GestureDetector(
        onTap: _selectCoverImage,
        child: Container(
          height: 300.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.neutral200, width: 1),
          ),
          child: Stack(
            children: [
              // Display selected image or placeholder
              if (coverImage.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: AppImage(
                    imageData: coverImage,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 60.sp,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      SizedBox(height: AppSpacing.s3),
                      Text(
                        'Nhấn để thêm ảnh bìa',
                        style: AppTypography.bodyM.copyWith(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: AppSpacing.s1),
                      Text(
                        'Ảnh sẽ được hiển thị trên lịch trình',
                        style: AppTypography.bodyS.copyWith(color: AppColors.neutral500),
                      ),
                    ],
                  ),
                ),

              // Edit button overlay if image exists
              if (coverImage.isNotEmpty)
                Positioned(
                  top: AppSpacing.s3,
                  right: AppSpacing.s3,
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.s2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: 20.sp),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _selectCoverImage() async {
    final imageUploadService = Get.find<ImageUploadService>();
    final base64Image = await imageUploadService.showImagePickerDialog();

    if (base64Image != null) {
      controller.setCoverImage(base64Image);
    }
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trip name
        Obx(
          () => AppTextField(
            label: 'Tên lịch trình',
            hintText: 'Nhập tên lịch trình',
            controller: controller.tripNameController,
            onChanged: (value) => controller.updateField('tripName', value),
            errorText: controller.errors['tripName'],
          ),
        ),
        SizedBox(height: AppSpacing.s5),

        // Description
        AppTextField.multiline(
          label: 'Mô tả',
          hintText: 'Thêm mô tả cho lịch trình của bạn',
          controller: controller.descriptionController,
          maxLines: 3,
        ),
        SizedBox(height: AppSpacing.s5),

        // Destination
        Obx(
          () => AppTextField(
            label: 'Điểm đến',
            hintText: 'Bạn hãy điền điểm đến nhé',
            controller: controller.destinationController,
            onChanged: (value) => controller.updateField('destination', value),
            errorText: controller.errors['destination'],
          ),
        ),
        SizedBox(height: AppSpacing.s5),

        // Date row
        Row(
          children: [
            // Start date
            Expanded(
              child: Obx(
                () => AppDatePickerField(
                  label: 'Ngày bắt đầu',
                  value: controller.startDate.value,
                  onChanged: controller.updateStartDate,
                  hintText: '8/1/2025',
                  dateFormat: 'd/M/yyyy',
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.s4),

            // End date
            Expanded(
              child: Obx(
                () => AppDatePickerField(
                  label: 'Ngày kết thúc',
                  value: controller.endDate.value,
                  onChanged: controller.updateEndDate,
                  hintText: '12/1/2025',
                  dateFormat: 'd/M/yyyy',
                  firstDate: controller.startDate.value ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.s5),

        // Number of people
        _buildPeopleSelector(),
        SizedBox(height: AppSpacing.s5),

        // Budget
        AppTextField(
          label: 'Ngân sách (VND)',
          hintText: 'Ví dụ: 10000000',
          controller: controller.budgetController,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: AppSpacing.s5),

        // Tags
        _buildTagsSection(),
        SizedBox(height: AppSpacing.s5),

        // Visibility
        _buildVisibilitySection(),
        SizedBox(height: AppSpacing.s5),

        // Notes
        AppTextField.multiline(
          label: 'Ghi chú',
          hintText: 'Thêm ghi chú cho lịch trình',
          controller: controller.notesController,
          maxLines: 4,
        ),
        SizedBox(height: AppSpacing.s6),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thẻ tag',
          style: AppTypography.bodyM.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children:
                controller.availableTags.map((tag) {
                  final isSelected = controller.selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () => controller.toggleTag(tag),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s3,
                        vertical: AppSpacing.s2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.neutral300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: AppTypography.bodyS.copyWith(
                          color: isSelected ? Colors.white : AppColors.neutral700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quyền riêng tư',
          style: AppTypography.bodyM.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Row(
            children: [
              _buildVisibilityOption('private', Icons.lock_outline, 'Riêng tư'),
              SizedBox(width: AppSpacing.s3),
              _buildVisibilityOption('friends', Icons.people_outline, 'Bạn bè'),
              SizedBox(width: AppSpacing.s3),
              _buildVisibilityOption('public', Icons.public, 'Công khai'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityOption(String value, IconData icon, String label) {
    final isSelected = controller.selectedVisibility.value == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setVisibility(value),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s3),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.neutral300,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24.sp, color: isSelected ? AppColors.primary : AppColors.neutral600),
              SizedBox(height: 4.h),
              Text(
                label,
                style: AppTypography.bodyXS.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.neutral600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeopleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Số người',
          style: AppTypography.bodyM.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.neutral200, width: 1),
          ),
          child: Row(
            children: [
              // Decrease button
              GestureDetector(
                onTap: controller.decreasePeople,
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Icon(Icons.remove, color: Colors.white, size: 20.sp),
                ),
              ),

              // Number display
              Expanded(
                child: Center(
                  child: Obx(
                    () => Text(
                      controller.numberOfPeople.value.toString(),
                      style: AppTypography.h3.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Increase button
              GestureDetector(
                onTap: controller.increasePeople,
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Icon(Icons.add, color: Colors.white, size: 20.sp),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
