import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/core/widgets/app_text_field.dart';
import 'package:wanderlust/data/models/business_profile_model.dart';
import 'package:wanderlust/presentation/controllers/business/business_registration_controller.dart';

class BusinessInfoFormPage extends GetView<BusinessRegistrationController> {
  const BusinessInfoFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller will get arguments in onInit
    Get.lazyPut(() => BusinessRegistrationController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.neutral800),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Đăng ký doanh nghiệp',
          style: AppTypography.h4.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Obx(() => _buildProgressIndicator()),
            
            // Form content
            Expanded(
              child: Obx(() => _buildStepContent()),
            ),
            
            // Bottom navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s3),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = controller.currentStep.value >= index;
          final isCompleted = controller.currentStep.value > index;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.neutral200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 18.sp)
                        : Text(
                            '${index + 1}',
                            style: AppTypography.bodyM.copyWith(
                              color: isActive ? Colors.white : AppColors.neutral600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color: isCompleted ? AppColors.primary : AppColors.neutral200,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildStepContent() {
    switch (controller.currentStep.value) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildAdditionalInfoStep();
      case 2:
        return _buildVerificationStep();
      default:
        return _buildBasicInfoStep();
    }
  }
  
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s5),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin cơ bản',
              style: AppTypography.h3.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.s2),
            Text(
              'Vui lòng điền đầy đủ thông tin doanh nghiệp',
              style: AppTypography.bodyM.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            
            SizedBox(height: AppSpacing.s6),
            
            // Business type display
            if (controller.selectedBusinessType.value != null)
              Container(
                padding: EdgeInsets.all(AppSpacing.s4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Text(
                      controller.selectedBusinessType.value!.icon,
                      style: TextStyle(fontSize: 24.sp),
                    ),
                    SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loại hình:',
                            style: AppTypography.bodyS.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                          Text(
                            controller.selectedBusinessType.value!.displayName,
                            style: AppTypography.bodyM.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            SizedBox(height: AppSpacing.s5),
            
            // Business name
            AppTextField.name(
              controller: controller.businessNameController,
              label: 'Tên doanh nghiệp *',
              hintText: 'VD: Khách sạn Mường Thanh',
              validator: controller.validateBusinessName,
            ),
            
            SizedBox(height: AppSpacing.s4),
            
            // Tax number
            AppTextField(
              controller: controller.taxNumberController,
              label: 'Mã số thuế (không bắt buộc)',
              hintText: 'VD: 0123456789',
              keyboardType: TextInputType.number,
            ),
            
            SizedBox(height: AppSpacing.s4),
            
            // Business phone
            AppTextField(
              controller: controller.businessPhoneController,
              label: 'Số điện thoại doanh nghiệp *',
              hintText: 'VD: 0901234567',
              validator: controller.validatePhone,
              keyboardType: TextInputType.phone,
            ),
            
            SizedBox(height: AppSpacing.s4),
            
            // Business email
            AppTextField.email(
              controller: controller.businessEmailController,
              validator: controller.validateEmail,
            ),
            
            SizedBox(height: AppSpacing.s4),
            
            // Address
            AppTextField(
              controller: controller.addressController,
              label: 'Địa chỉ *',
              hintText: 'VD: 123 Nguyễn Văn Linh, Q.7, TP.HCM',
              validator: controller.validateAddress,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdditionalInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin bổ sung',
            style: AppTypography.h3.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Mô tả chi tiết về doanh nghiệp của bạn',
            style: AppTypography.bodyM.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          
          SizedBox(height: AppSpacing.s6),
          
          // Description
          AppTextField(
            controller: controller.descriptionController,
            label: 'Mô tả doanh nghiệp *',
            hintText: 'Giới thiệu về doanh nghiệp, dịch vụ, ưu điểm...',
            maxLines: 10,
          ),
          
          SizedBox(height: AppSpacing.s5),
          
          // Services
          Text(
            'Danh sách dịch vụ',
            style: AppTypography.bodyL.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s3),
          
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller.serviceController,
                  label: 'Thêm dịch vụ',
                  hintText: 'VD: WiFi miễn phí',
                ),
              ),
              SizedBox(width: AppSpacing.s3),
              SizedBox(
                width: 80.w,
                child: AppButton(
                  onPressed: controller.addService,
                  text: 'Thêm',
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.s3),
          
          // Services list
          Obx(() => Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: controller.services.map((service) => Chip(
              label: Text(service),
              deleteIcon: Icon(Icons.close, size: 18.sp),
              onDeleted: () => controller.removeService(service),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: AppTypography.bodyS.copyWith(
                color: AppColors.primary,
              ),
            )).toList(),
          )),
        ],
      ),
    );
  }
  
  Widget _buildVerificationStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xác thực doanh nghiệp',
            style: AppTypography.h3.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Tải lên giấy phép kinh doanh hoặc CMND/CCCD để xác thực',
            style: AppTypography.bodyM.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          
          SizedBox(height: AppSpacing.s6),
          
          // Upload area
          Obx(() => InkWell(
            onTap: controller.isUploadingDoc.value 
                ? null 
                : controller.pickVerificationDocument,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: controller.hasVerificationDoc.value 
                      ? AppColors.success 
                      : AppColors.neutral300,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: controller.isUploadingDoc.value
                    ? CircularProgressIndicator(color: AppColors.primary)
                    : controller.hasVerificationDoc.value
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 48.sp,
                              ),
                              SizedBox(height: AppSpacing.s3),
                              Text(
                                'Đã tải lên giấy tờ',
                                style: AppTypography.bodyL.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: AppSpacing.s2),
                              Text(
                                'Nhấn để thay đổi',
                                style: AppTypography.bodyS.copyWith(
                                  color: AppColors.neutral600,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                color: AppColors.neutral400,
                                size: 48.sp,
                              ),
                              SizedBox(height: AppSpacing.s3),
                              Text(
                                'Nhấn để tải lên',
                                style: AppTypography.bodyL.copyWith(
                                  color: AppColors.neutral700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: AppSpacing.s2),
                              Text(
                                'PNG, JPG (Max 5MB)',
                                style: AppTypography.bodyS.copyWith(
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          )),
          
          SizedBox(height: AppSpacing.s5),
          
          // Info box
          Container(
            padding: EdgeInsets.all(AppSpacing.s4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20.sp),
                SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lưu ý:',
                        style: AppTypography.bodyM.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.s1),
                      Text(
                        '• Giấy tờ phải còn hiệu lực\n• Ảnh phải rõ ràng, không bị mờ\n• Bạn có thể bỏ qua bước này và xác thực sau',
                        style: AppTypography.bodyS.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomNavigation() {
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
      child: Obx(() => Row(
        children: [
          if (controller.currentStep.value > 0)
            Expanded(
              child: AppButton.outline(
                onPressed: controller.previousStep,
                text: 'Quay lại',
              ),
            ),
          if (controller.currentStep.value > 0)
            SizedBox(width: AppSpacing.s3),
          Expanded(
            child: AppButton.primary(
              onPressed: controller.currentStep.value < 2
                  ? controller.nextStep
                  : controller.submitRegistration,
              text: controller.currentStep.value < 2 
                  ? 'Tiếp theo' 
                  : 'Hoàn tất đăng ký',
              isLoading: controller.isLoading.value,
            ),
          ),
        ],
      )),
    );
  }
}