import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/widgets/app_map.dart';
import 'package:wanderlust/core/widgets/app_text_field.dart';
import 'package:wanderlust/presentation/controllers/trip/add_private_location_controller.dart';

class AddPrivateLocationPage extends StatelessWidget {
  const AddPrivateLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddPrivateLocationController());

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
          'Địa điểm riêng tư',
          style: TextStyle(color: AppColors.primary, fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: controller.saveLocation,
            child: Text(
              'Lưu',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form fields section
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location name field
                AppTextField(
                  label: 'Tên địa điểm',
                  controller: controller.nameController,
                  hintText: 'Điền tên của địa điểm riêng tư',
                  onChanged: (value) => controller.updateName(value),
                ),

                SizedBox(height: 20.h),

                // Address field
                AppTextField(
                  label: 'Địa chỉ',
                  controller: controller.addressController,
                  hintText: 'Điền địa chỉ mà bạn có sẵn',
                  onChanged: (value) => controller.updateAddress(value),
                ),
              ],
            ),
          ),

          // Map section - Expanded to fill available space
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Stack(
                  children: [
                    // Interactive Map
                    Obx(
                      () => AppMap.locationPicker(
                        onLocationSelected: controller.onMapTap,
                        initialLocation: controller.selectedLocation.value,
                      ),
                    ),

                    // Navigation button
                    Positioned(
                      bottom: 20.h,
                      right: 20.w,
                      child: GestureDetector(
                        onTap: controller.navigateToCurrentLocation,
                        child: Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.navigation_rounded, color: Colors.white, size: 28.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom section with info text and coordinates
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map instruction text
                Text(
                  'Bạn có thể nhấn giữ vào bản đồ để chọn mới địa điểm của mình',
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280), height: 1.4),
                ),

                SizedBox(height: 20.h),

                // Coordinates in row
                Row(
                  children: [
                    // Longitude field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            label: 'Kinh độ',
                            controller: controller.longitudeController,
                            hintText: 'Ví dụ: 106.6297',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => controller.updateLongitude(value),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Latitude field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            label: 'Vĩ độ',
                            controller: controller.latitudeController,
                            hintText: 'Ví dụ: 10.8231',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => controller.updateLatitude(value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
