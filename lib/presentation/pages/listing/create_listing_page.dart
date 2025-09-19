import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/core/widgets/app_text_field.dart';
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:wanderlust/presentation/controllers/listing/listing_controller.dart';

/// Simple unified page for creating/editing ANY type of listing
class CreateListingPage extends StatelessWidget {
  const CreateListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final isEdit = args?['isEdit'] ?? false;
    final listingId = args?['listingId'];
    final initialType = args?['type'] ?? ListingType.room;
    
    // Initialize controller
    final controller = Get.put(ListingController(
      isEditMode: isEdit,
      listingId: listingId,
      type: initialType,
    ));
    
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
          isEdit ? 'Chỉnh sửa' : 'Tạo mới',
          style: AppTypography.h4.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 100.h),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type selector (only for create mode)
                if (!isEdit) _buildTypeSelector(controller),
                
                // Images section
                _buildImageSection(controller),
                
                // Basic info
                _buildBasicInfoSection(controller),
                
                // Price section
                _buildPriceSection(controller),
                
                // Dynamic details based on type
                _buildDynamicDetails(controller),
                
                // Description
                _buildDescriptionSection(controller),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildBottomBar(controller),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.s5, AppSpacing.s4, AppSpacing.s5, AppSpacing.s2),
      child: Text(
        title,
        style: AppTypography.bodyL.copyWith(
          color: AppColors.neutral900,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildTypeSelector(ListingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Loại hình kinh doanh'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Obx(() => Wrap(
            spacing: AppSpacing.s3,
            runSpacing: AppSpacing.s3,
            children: ListingType.values.map((type) {
              final isSelected = controller.selectedType.value == type;
              return InkWell(
                onTap: () => controller.changeType(type),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s4,
                    vertical: AppSpacing.s3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.neutral300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type.icon,
                        style: TextStyle(fontSize: 20.sp),
                      ),
                      SizedBox(width: AppSpacing.s2),
                      Text(
                        type.displayName,
                        style: AppTypography.bodyM.copyWith(
                          color: isSelected ? Colors.white : AppColors.neutral700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
        ),
      ],
    );
  }
  
  Widget _buildImageSection(ListingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Hình ảnh'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Obx(() => Column(
            children: [
              if (controller.images.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.s3,
                    mainAxisSpacing: AppSpacing.s3,
                  ),
                  itemCount: controller.images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            image: DecorationImage(
                              image: MemoryImage(_convertBase64ToBytes(controller.images[index])),
                              fit: BoxFit.cover,
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
              
              if (controller.images.isNotEmpty)
                SizedBox(height: AppSpacing.s4),
              
              if (controller.images.length < 6)
                InkWell(
                  onTap: controller.isUploadingImage.value ? null : controller.pickImage,
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
                                  'Thêm ảnh (${controller.images.length}/6)',
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
  
  Widget _buildBasicInfoSection(ListingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin cơ bản'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: AppTextField(
            controller: controller.titleController,
            label: 'Tên ${controller.selectedType.value.displayName.toLowerCase()} *',
            hintText: _getTitleHint(controller.selectedType.value),
            validator: controller.validateTitle,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPriceSection(ListingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Giá'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller.priceController,
                  label: 'Giá gốc (VNĐ) *',
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDynamicDetails(ListingController controller) {
    return Obx(() {
      final type = controller.selectedType.value;
      
      switch (type) {
        case ListingType.room:
          return _buildRoomDetails(controller);
        case ListingType.tour:
          return _buildTourDetails(controller);
        case ListingType.food:
          return _buildFoodDetails(controller);
        case ListingType.service:
          return _buildServiceDetails(controller);
      }
    });
  }
  
  Widget _buildRoomDetails(ListingController controller) {
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
                      controller: controller.detailControllers['maxGuests']!,
                      label: 'Số khách tối đa',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: AppTextField(
                      controller: controller.detailControllers['numberOfBeds']!,
                      label: 'Số giường',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s4),
              AppTextField(
                controller: controller.detailControllers['roomSize']!,
                label: 'Diện tích (m²)',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: AppSpacing.s4),
              // Facilities toggles
              Obx(() => Column(
                children: [
                  _buildToggle('Wifi miễn phí', 'hasWifi', controller),
                  _buildToggle('Máy lạnh', 'hasAirConditioner', controller),
                  _buildToggle('TV', 'hasTV', controller),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTourDetails(ListingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Chi tiết tour'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            children: [
              AppTextField(
                controller: controller.detailControllers['duration']!,
                label: 'Thời gian tour',
                hintText: 'VD: 3 ngày 2 đêm',
              ),
              SizedBox(height: AppSpacing.s4),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: controller.detailControllers['groupSize']!,
                      label: 'Số người/nhóm',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: AppTextField(
                      controller: controller.detailControllers['departure']!,
                      label: 'Điểm khởi hành',
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s4),
              Obx(() => Column(
                children: [
                  _buildToggle('Bao gồm xe đưa đón', 'includeTransport', controller),
                  _buildToggle('Có hướng dẫn viên', 'includeGuide', controller),
                  _buildToggle('Bao gồm bữa ăn', 'includeMeals', controller),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFoodDetails(ListingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Chi tiết món ăn'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            children: [
              AppTextField(
                controller: controller.detailControllers['category']!,
                label: 'Loại món',
                hintText: 'VD: Món chính, Khai vị, Tráng miệng',
              ),
              SizedBox(height: AppSpacing.s4),
              AppTextField(
                controller: controller.detailControllers['serving']!,
                label: 'Khẩu phần',
                hintText: 'VD: 1 người, 2-3 người',
              ),
              SizedBox(height: AppSpacing.s4),
              Obx(() => Column(
                children: [
                  _buildToggle('Món chay', 'isVegetarian', controller),
                  _buildToggle('Món cay', 'isSpicy', controller),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildServiceDetails(ListingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Chi tiết dịch vụ'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            children: [
              AppTextField(
                controller: controller.detailControllers['duration']!,
                label: 'Thời gian',
                hintText: 'VD: 1 giờ, 2 ngày',
              ),
              SizedBox(height: AppSpacing.s4),
              AppTextField(
                controller: controller.detailControllers['location']!,
                label: 'Địa điểm cung cấp',
                hintText: 'VD: Tại khách sạn, Tận nơi',
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildToggle(String label, String key, ListingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyM.copyWith(
                color: AppColors.neutral800,
              ),
            ),
          ),
          Switch(
            value: controller.details[key] ?? false,
            onChanged: (value) => controller.toggleDetail(key, value),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDescriptionSection(ListingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mô tả'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: AppTextField.multiline(
            controller: controller.descriptionController,
            label: 'Mô tả chi tiết *',
            hintText: 'Mô tả chi tiết về ${controller.selectedType.value.displayName.toLowerCase()}...',
            maxLines: 5,
            validator: controller.validateDescription,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomBar(ListingController controller) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => AppButton.primary(
          onPressed: controller.isSaving.value ? null : controller.submit,
          text: controller.isEditMode ? 'Cập nhật' : 'Tạo mới',
          isLoading: controller.isSaving.value,
        )),
      ),
    );
  }
  
  String _getTitleHint(ListingType type) {
    switch (type) {
      case ListingType.room:
        return 'VD: Phòng Deluxe Ocean View';
      case ListingType.tour:
        return 'VD: Tour Đà Nẵng 3N2Đ';
      case ListingType.food:
        return 'VD: Phở bò đặc biệt';
      case ListingType.service:
        return 'VD: Thuê xe máy 24h';
    }
  }
  
  Uint8List _convertBase64ToBytes(String base64String) {
    if (base64String.startsWith('data:image')) {
      base64String = base64String.split(',').last;
    }
    return Uri.parse('data:image/png;base64,$base64String')
        .data!
        .contentAsBytes();
  }
}