import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/core/widgets/app_text_field.dart';
import 'package:wanderlust/data/models/room_model.dart';
import 'package:wanderlust/presentation/controllers/room/edit_room_controller.dart';

class EditRoomPage extends GetView<EditRoomController> {
  const EditRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => EditRoomController());
    
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.neutral800),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Chỉnh sửa phòng',
          style: AppTypography.h4.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Room status toggle
          Obx(() {
            if (controller.isLoading.value) return SizedBox.shrink();
            return PopupMenuButton<RoomStatus>(
              icon: Icon(Icons.more_vert, color: AppColors.neutral700),
              onSelected: (status) {
                controller.selectedStatus.value = status;
              },
              itemBuilder: (context) => RoomStatus.values.map((status) {
                return PopupMenuItem<RoomStatus>(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: AppSpacing.s2),
                      Text(status.displayName),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        
        return SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current status indicator
                _buildStatusIndicator(),
                
                // Room images section
                _buildImagesSection(),
                
                // Basic info section
                _buildBasicInfoSection(),
                
                // Pricing section
                _buildPricingSection(),
                
                // Room details section
                _buildRoomDetailsSection(),
                
                // Facilities section
                _buildFacilitiesSection(),
                
                // Amenities section
                _buildAmenitiesSection(),
                
                // Description section
                _buildDescriptionSection(),
                
                // Submit button
                _buildSubmitButton(),
                
                SizedBox(height: AppSpacing.s8),
              ],
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildStatusIndicator() {
    return Obx(() => Container(
      padding: EdgeInsets.all(AppSpacing.s5),
      color: _getStatusColor(controller.selectedStatus.value).withOpacity(0.1),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: _getStatusColor(controller.selectedStatus.value),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.s2),
          Text(
            'Trạng thái: ${controller.selectedStatus.value.displayName}',
            style: AppTypography.bodyM.copyWith(
              color: _getStatusColor(controller.selectedStatus.value),
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          Text(
            'Tap vào menu để thay đổi',
            style: AppTypography.bodyS.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    ));
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s3),
      child: Text(
        title,
        style: AppTypography.bodyL.copyWith(
          color: AppColors.neutral900,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ảnh phòng'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Obx(() => Column(
            children: [
              // Image grid
              if (controller.roomImages.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.s3,
                    mainAxisSpacing: AppSpacing.s3,
                  ),
                  itemCount: controller.roomImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            image: DecorationImage(
                              image: MemoryImage(
                                controller.roomImages[index].toImageBytes(),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // First image badge
                        if (index == 0)
                          Positioned(
                            left: 4.w,
                            bottom: 4.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.s2,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                'Ảnh chính',
                                style: AppTypography.bodyXS.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 4.h,
                          right: 4.w,
                          child: InkWell(
                            onTap: () => controller.removeImage(index),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              
              if (controller.roomImages.isNotEmpty)
                SizedBox(height: AppSpacing.s4),
              
              // Add image button
              if (controller.roomImages.length < 6)
                InkWell(
                  onTap: controller.isUploadingImage.value 
                      ? null 
                      : controller.pickRoomImage,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.neutral300,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: controller.isUploadingImage.value
                          ? CircularProgressIndicator(color: AppColors.primary)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: AppColors.neutral500,
                                  size: 32.sp,
                                ),
                                SizedBox(height: AppSpacing.s2),
                                Text(
                                  'Thêm ảnh (${controller.roomImages.length}/6)',
                                  style: AppTypography.bodyS.copyWith(
                                    color: AppColors.neutral600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
            ],
          )),
        ),
      ],
    );
  }
  
  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin cơ bản'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            children: [
              // Room name
              AppTextField(
                controller: controller.roomNameController,
                label: 'Tên phòng *',
                hintText: 'VD: Phòng Deluxe Ocean View',
                validator: controller.validateRoomName,
              ),
              
              SizedBox(height: AppSpacing.s4),
              
              // Room type
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loại phòng *',
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.neutral700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s2),
                  Obx(() => Wrap(
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s2,
                    children: RoomType.values.map((type) {
                      final isSelected = controller.selectedRoomType.value == type;
                      return InkWell(
                        onTap: () => controller.selectedRoomType.value = type,
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.s3,
                            vertical: AppSpacing.s2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primary 
                                : AppColors.neutral100,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.primary 
                                  : AppColors.neutral300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                type.icon,
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                type.displayName,
                                style: AppTypography.bodyS.copyWith(
                                  color: isSelected 
                                      ? Colors.white 
                                      : AppColors.neutral700,
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Giá phòng'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: controller.priceController,
                      label: 'Giá/đêm (VNĐ) *',
                      hintText: 'VD: 1500000',
                      keyboardType: TextInputType.number,
                      validator: controller.validatePrice,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: AppTextField(
                      controller: controller.discountPriceController,
                      label: 'Giá khuyến mãi',
                      hintText: 'VD: 1200000',
                      keyboardType: TextInputType.number,
                      validator: controller.validateDiscountPrice,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRoomDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Chi tiết phòng'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: controller.maxGuestsController,
                      label: 'Số khách tối đa *',
                      hintText: 'VD: 2',
                      keyboardType: TextInputType.number,
                      validator: (value) => controller.validateNumber(value, 'Số khách'),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: AppTextField(
                      controller: controller.numberOfBedsController,
                      label: 'Số giường *',
                      hintText: 'VD: 1',
                      keyboardType: TextInputType.number,
                      validator: (value) => controller.validateNumber(value, 'Số giường'),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpacing.s4),
              
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: controller.roomSizeController,
                      label: 'Diện tích (m²) *',
                      hintText: 'VD: 35',
                      keyboardType: TextInputType.number,
                      validator: controller.validateRoomSize,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: AppTextField(
                      controller: controller.floorController,
                      label: 'Tầng',
                      hintText: 'VD: 5',
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpacing.s4),
              
              AppTextField(
                controller: controller.viewTypeController,
                label: 'Loại view',
                hintText: 'VD: View biển, View thành phố, View vườn',
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFacilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tiện nghi trong phòng'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Obx(() => Column(
            children: [
              _buildFacilityToggle(
                'Wifi miễn phí',
                Icons.wifi,
                controller.hasWifi,
              ),
              _buildFacilityToggle(
                'Máy lạnh',
                Icons.ac_unit,
                controller.hasAirConditioner,
              ),
              _buildFacilityToggle(
                'TV',
                Icons.tv,
                controller.hasTV,
              ),
              _buildFacilityToggle(
                'Tủ lạnh',
                Icons.kitchen,
                controller.hasRefrigerator,
              ),
              _buildFacilityToggle(
                'Phòng tắm riêng',
                Icons.bathroom,
                controller.hasBathroom,
              ),
              _buildFacilityToggle(
                'Nước nóng',
                Icons.hot_tub,
                controller.hasHotWater,
              ),
              _buildFacilityToggle(
                'Ban công',
                Icons.balcony,
                controller.hasBalcony,
              ),
              _buildFacilityToggle(
                'Bếp',
                Icons.countertops,
                controller.hasKitchen,
              ),
            ],
          )),
        ),
      ],
    );
  }
  
  Widget _buildFacilityToggle(String title, IconData icon, RxBool value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s2),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neutral600, size: 20.sp),
          SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyM.copyWith(
                color: AppColors.neutral800,
              ),
            ),
          ),
          Switch(
            value: value.value,
            onChanged: (newValue) => value.value = newValue,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tiện ích khác'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Obx(() => Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: controller.commonAmenities.map((amenity) {
              final isSelected = controller.selectedAmenities.contains(amenity);
              return InkWell(
                onTap: () => controller.toggleAmenity(amenity),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s3,
                    vertical: AppSpacing.s2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withOpacity(0.1) 
                        : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary 
                          : AppColors.neutral300,
                    ),
                  ),
                  child: Text(
                    amenity,
                    style: AppTypography.bodyS.copyWith(
                      color: isSelected 
                          ? AppColors.primary 
                          : AppColors.neutral700,
                      fontWeight: isSelected 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
        ),
      ],
    );
  }
  
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mô tả chi tiết'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: AppTextField.multiline(
            controller: controller.descriptionController,
            label: 'Mô tả phòng *',
            hintText: 'Mô tả chi tiết về phòng, vị trí, đặc điểm nổi bật...',
            maxLines: 6,
            validator: controller.validateDescription,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubmitButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(AppSpacing.s5),
      child: Column(
        children: [
          Obx(() => AppButton.primary(
            onPressed: controller.isLoading.value 
                ? null 
                : controller.submitUpdateRoom,
            text: 'Lưu thay đổi',
            isLoading: controller.isLoading.value,
          )),
          SizedBox(height: AppSpacing.s3),
          AppButton.text(
            onPressed: () => Get.back(),
            text: 'Hủy bỏ',
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return AppColors.success;
      case RoomStatus.booked:
        return AppColors.warning;
      case RoomStatus.maintenance:
        return AppColors.neutral500;
      case RoomStatus.inactive:
        return AppColors.error;
    }
  }
}

// Extension to convert base64 to bytes
extension Base64Image on String {
  Uint8List toImageBytes() {
    if (startsWith('data:image')) {
      final base64String = split(',').last;
      return Uri.parse('data:image/png;base64,$base64String')
          .data!
          .contentAsBytes();
    }
    return Uri.parse('data:image/png;base64,$this')
        .data!
        .contentAsBytes();
  }
}