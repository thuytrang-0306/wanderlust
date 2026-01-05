import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/core/widgets/app_text_field.dart';
import 'package:wanderlust/data/models/business_profile_model.dart';
import 'package:wanderlust/presentation/controllers/business/business_management_controller.dart';

/// Production-ready Edit Business Page
/// Full UI/UX with proper validation and error handling
class EditBusinessPage extends StatelessWidget {
  const EditBusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BusinessManagementController());

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
          'Chỉnh sửa thông tin',
          style: AppTypography.h4.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Delete button
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => controller.deleteBusiness(),
            tooltip: 'Xóa doanh nghiệp',
          ),
        ],
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
                // Business Type Info (Read-only)
                _buildBusinessTypeSection(controller),

                // Basic Information
                _buildBasicInfoSection(controller),

                // Contact Information
                _buildContactSection(controller),

                // Description
                _buildDescriptionSection(controller),

                // Services
                _buildServicesSection(controller),

                // Verification (Optional)
                _buildVerificationSection(controller),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildBottomBar(controller),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s5,
        AppSpacing.s4,
        AppSpacing.s5,
        AppSpacing.s2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodyL.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: AppTypography.bodyS.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBusinessTypeSection(BusinessManagementController controller) {
    if (controller.currentBusiness == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Loại hình kinh doanh',
          subtitle: 'Loại hình kinh doanh không thể thay đổi',
        ),
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    controller.currentBusiness!.typeIcon,
                    style: TextStyle(fontSize: 24.sp),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currentBusiness!.typeDisplayName,
                      style: AppTypography.bodyL.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Loại hình kinh doanh chính',
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.lock_outline, color: AppColors.neutral400, size: 20.sp),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(BusinessManagementController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin cơ bản'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            children: [
              AppTextField(
                controller: controller.businessNameController,
                label: 'Tên doanh nghiệp *',
                hintText: 'VD: Khách sạn ABC',
                validator: controller.validateBusinessName,
              ),
              SizedBox(height: AppSpacing.s4),
              AppTextField(
                controller: controller.taxNumberController,
                label: 'Mã số thuế',
                hintText: 'VD: 0123456789',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BusinessManagementController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin liên hệ'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            children: [
              AppTextField(
                controller: controller.businessPhoneController,
                label: 'Số điện thoại *',
                hintText: 'Nhập số điện thoại',
                keyboardType: TextInputType.phone,
                validator: controller.validatePhone,
              ),
              SizedBox(height: AppSpacing.s4),
              AppTextField(
                controller: controller.businessEmailController,
                label: 'Email *',
                hintText: 'Nhập email',
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              SizedBox(height: AppSpacing.s4),
              AppTextField(
                controller: controller.addressController,
                label: 'Địa chỉ *',
                hintText: 'VD: 123 Đường ABC, Quận XYZ, TP. HCM',
                validator: controller.validateAddress,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BusinessManagementController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Mô tả doanh nghiệp',
          subtitle: 'Giới thiệu về doanh nghiệp của bạn',
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: AppTextField.multiline(
            controller: controller.descriptionController,
            label: 'Mô tả chi tiết *',
            hintText: 'Giới thiệu về doanh nghiệp, dịch vụ, điểm nổi bật...',
            maxLines: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(BusinessManagementController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Dịch vụ cung cấp',
          subtitle: 'Các dịch vụ mà doanh nghiệp của bạn cung cấp',
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            children: [
              // Service input
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: controller.serviceController,
                      label: 'Thêm dịch vụ',
                      hintText: 'VD: Spa, Massage, Bể bơi',
                      onFieldSubmitted: (_) => controller.addService(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  SizedBox(
                    width: 100.w,
                    child: AppButton.primary(
                      onPressed: controller.addService,
                      text: 'Thêm',
                      icon: Icons.add,
                    ),
                  ),
                ],
              ),

              // Services list
              Obx(() {
                if (controller.services.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: AppSpacing.s4),
                    child: Text(
                      'Chưa có dịch vụ nào',
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.neutral500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.only(top: AppSpacing.s4),
                  child: Wrap(
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s2,
                    children: controller.services.map((service) {
                      return Chip(
                        label: Text(service),
                        labelStyle: AppTypography.bodyS.copyWith(
                          color: AppColors.neutral800,
                        ),
                        deleteIcon: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: AppColors.neutral600,
                        ),
                        onDeleted: () => controller.removeService(service),
                        backgroundColor: AppColors.neutral100,
                        side: BorderSide(color: AppColors.neutral300),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationSection(BusinessManagementController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Xác thực doanh nghiệp',
          subtitle: 'Tải lên giấy phép kinh doanh hoặc giấy tờ liên quan',
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (controller.hasVerificationDoc.value) {
                  return Container(
                    padding: EdgeInsets.all(AppSpacing.s3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 24.sp,
                        ),
                        SizedBox(width: AppSpacing.s3),
                        Expanded(
                          child: Text(
                            'Đã tải lên giấy tờ xác thực',
                            style: AppTypography.bodyM.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: controller.pickVerificationDocument,
                          child: Text('Thay đổi'),
                        ),
                      ],
                    ),
                  );
                }

                return AppButton.outline(
                  onPressed: controller.isUploadingDoc.value
                      ? null
                      : controller.pickVerificationDocument,
                  text: controller.isUploadingDoc.value
                      ? 'Đang tải lên...'
                      : 'Tải lên giấy tờ',
                  icon: Icons.upload_file,
                  isLoading: controller.isUploadingDoc.value,
                );
              }),

              SizedBox(height: AppSpacing.s3),

              // Verification status
              if (controller.currentBusiness != null)
                _buildVerificationStatus(controller.currentBusiness!.verificationStatus),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStatus(VerificationStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case VerificationStatus.verified:
        color = AppColors.success;
        text = 'Đã xác thực';
        icon = Icons.verified;
        break;
      case VerificationStatus.pending:
        color = Colors.orange;
        text = 'Đang chờ xác thực';
        icon = Icons.pending;
        break;
      case VerificationStatus.rejected:
        color = AppColors.error;
        text = 'Bị từ chối';
        icon = Icons.cancel;
        break;
      case VerificationStatus.expired:
        color = AppColors.neutral500;
        text = 'Hết hạn';
        icon = Icons.access_time;
        break;
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: AppSpacing.s2),
          Text(
            'Trạng thái: $text',
            style: AppTypography.bodyS.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BusinessManagementController controller) {
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
          onPressed: controller.isSaving.value ? null : controller.submitUpdate,
          text: 'Cập nhật thông tin',
          isLoading: controller.isSaving.value,
        )),
      ),
    );
  }
}
