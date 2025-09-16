import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_text_field.dart';
import 'package:wanderlust/core/widgets/app_date_time_picker.dart';
import 'package:wanderlust/presentation/controllers/planning/trip_edit_controller.dart';
import 'package:wanderlust/core/constants/app_assets.dart';

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
        border: Border(
          bottom: BorderSide(
            color: AppColors.neutral100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.s2),
              child: Icon(
                Icons.arrow_back_ios,
                size: 24.sp,
                color: AppColors.primary,
              ),
            ),
          ),
          
          // Title
          Obx(() => Text(
            controller.isEditMode.value 
                ? 'Chỉnh sửa lịch trình'
                : 'Tạo lịch trình',
            style: AppTypography.h4.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          )),
          
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
    return Container(
      height: 300.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Image.asset(
          AppAssets.travel3d,
          height: 250.h,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback illustration if asset not found
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.travel_explore,
                  size: 100.sp,
                  color: AppColors.primary.withOpacity(0.5),
                ),
                SizedBox(height: AppSpacing.s4),
                Text(
                  'Travel Planning',
                  style: AppTypography.bodyL.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trip name
        Obx(() => AppTextField(
          label: 'Tên lịch trình',
          hintText: 'Nhập tên lịch trình',
          controller: controller.tripNameController,
          onChanged: (value) => controller.updateField('tripName', value),
          errorText: controller.errors['tripName'],
        )),
        SizedBox(height: AppSpacing.s5),
        
        // Destination
        Obx(() => AppTextField(
          label: 'Điểm đến',
          hintText: 'Bạn hãy điền điểm đến nhé',
          controller: controller.destinationController,
          onChanged: (value) => controller.updateField('destination', value),
          errorText: controller.errors['destination'],
        )),
        SizedBox(height: AppSpacing.s5),
        
        // Date row
        Row(
          children: [
            // Start date
            Expanded(
              child: Obx(() => AppDatePickerField(
                label: 'Ngày bắt đầu',
                value: controller.startDate.value,
                onChanged: controller.updateStartDate,
                hintText: '8/1/2025',
                dateFormat: 'd/M/yyyy',
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              )),
            ),
            SizedBox(width: AppSpacing.s4),
            
            // End date
            Expanded(
              child: Obx(() => AppDatePickerField(
                label: 'Ngày kết thúc',
                value: controller.endDate.value,
                onChanged: controller.updateEndDate,
                hintText: '12/1/2025',
                dateFormat: 'd/M/yyyy',
                firstDate: controller.startDate.value ?? DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              )),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.s5),
        
        // Number of people
        _buildPeopleSelector(),
      ],
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
            border: Border.all(
              color: AppColors.neutral200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Decrease button
              GestureDetector(
                onTap: controller.decreasePeople,
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
              
              // Number display
              Expanded(
                child: Center(
                  child: Obx(() => Text(
                    controller.numberOfPeople.value.toString(),
                    style: AppTypography.h3.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                ),
              ),
              
              // Increase button
              GestureDetector(
                onTap: controller.increasePeople,
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}