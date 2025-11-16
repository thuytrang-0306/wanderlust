import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/core/widgets/app_text_field.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/presentation/controllers/account/edit_profile_controller.dart';

class EditProfilePage extends GetView<EditProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Chỉnh sửa hồ sơ', style: AppTypography.heading5),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: AppSpacing.s6),

              // Avatar
              _buildAvatarSection(),

              SizedBox(height: AppSpacing.s6),

              // Form fields
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(AppSpacing.s5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin cá nhân',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4),

                    AppTextField(
                      controller: controller.nameController,
                      label: 'Họ và tên',
                      hintText: 'Nhập họ và tên',
                      keyboardType: TextInputType.name,
                    ),

                    SizedBox(height: AppSpacing.s4),

                    AppTextField(
                      controller: controller.emailController,
                      label: 'Email',
                      hintText: 'Nhập email',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    SizedBox(height: AppSpacing.s4),

                    AppTextField(
                      controller: controller.phoneController,
                      label: 'Số điện thoại',
                      hintText: 'Nhập số điện thoại',
                      keyboardType: TextInputType.phone,
                    ),

                    SizedBox(height: AppSpacing.s4),

                    // Date of Birth
                    _buildDateOfBirthField(),

                    SizedBox(height: AppSpacing.s4),

                    AppTextField(
                      controller: controller.bioController,
                      label: 'Giới thiệu',
                      hintText: 'Viết vài dòng về bạn...',
                      maxLines: 4,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.s6),

              // Save button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
                child: Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: AppButton.primary(
                      onPressed: controller.isSaving.value ? null : controller.saveProfile,
                      text: controller.isSaving.value ? 'Đang lưu...' : 'Lưu thay đổi',
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.s8),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Obx(() {
            final avatar = controller.avatarImage.value;
            return Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neutral300, width: 2),
              ),
              child: ClipOval(
                child: avatar != null
                    ? AppImage(
                        imageData: avatar,
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.person,
                        size: 60.sp,
                        color: AppColors.neutral400,
                      ),
              ),
            );
          }),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngày sinh',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.s2),
        Obx(
          () => InkWell(
            onTap: controller.selectDateOfBirth,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s4,
                vertical: AppSpacing.s3 + 4.h,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neutral300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20.sp),
                  SizedBox(width: AppSpacing.s3),
                  Text(
                    controller.selectedDate.value != null
                        ? DateFormat('dd/MM/yyyy').format(controller.selectedDate.value!)
                        : 'Chọn ngày sinh',
                    style: AppTypography.bodyMedium.copyWith(
                      color: controller.selectedDate.value != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
