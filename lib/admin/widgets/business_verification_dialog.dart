import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_business_controller.dart';
import 'package:wanderlust/shared/data/models/business_profile_model.dart';
import 'package:wanderlust/core/widgets/app_image.dart';

class BusinessVerificationDialog extends GetView<AdminBusinessController> {
  final BusinessProfileModel business;
  final bool isApproval;

  const BusinessVerificationDialog({
    super.key,
    required this.business,
    required this.isApproval,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 600.w,
        constraints: BoxConstraints(maxHeight: 0.8.sh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business overview
                    _buildBusinessOverview(),
                    SizedBox(height: 24.h),
                    
                    // Verification documents
                    if (business.verificationDoc != null)
                      _buildVerificationDocument(),
                    
                    SizedBox(height: 24.h),
                    
                    // Action form
                    _buildActionForm(),
                  ],
                ),
              ),
            ),
            
            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isApproval ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isApproval ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              isApproval ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isApproval ? 'Approve Business' : 'Reject Business',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isApproval 
                      ? 'Verify and approve this business registration'
                      : 'Reject this business registration with reason',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessOverview() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Business image
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: const Color(0xFFF3F4F6),
                ),
                child: business.businessImages?.isNotEmpty == true
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: AppImage(
                          imageData: business.businessImages!.first,
                          width: 60.w,
                          height: 60.h,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.business,
                        color: const Color(0xFF9CA3AF),
                        size: 32.sp,
                      ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.businessName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${business.businessType.icon} ${business.businessType.displayName}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: controller.getStatusColor(business.verificationStatus).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        business.verificationStatus.displayName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: controller.getStatusColor(business.verificationStatus),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Business details
          _buildDetailRow('Email', business.businessEmail, Icons.email),
          _buildDetailRow('Phone', business.businessPhone, Icons.phone),
          _buildDetailRow('Address', business.address, Icons.location_on),
          if (business.taxNumber?.isNotEmpty == true)
            _buildDetailRow('Tax Number', business.taxNumber!, Icons.receipt),
          _buildDetailRow('Registered', _formatDate(business.createdAt), Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: const Color(0xFF6B7280)),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationDocument() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Document',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: AppImage(
              imageData: business.verificationDoc!,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Business license or registration document',
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildActionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isApproval ? 'Approval Notes (Optional)' : 'Rejection Reason *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: isApproval 
              ? controller.verificationNotesController
              : controller.rejectionReasonController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: isApproval
                ? 'Add any notes about the verification process...'
                : 'Please provide a reason for rejection...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
        if (!isApproval) ...[
          SizedBox(height: 8.h),
          Text(
            'This action will reject the business registration and notify the owner.',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFFEF4444),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : _handleAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: isApproval 
                    ? const Color(0xFF10B981) 
                    : const Color(0xFFEF4444),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isApproval ? 'Approve Business' : 'Reject Business',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            )),
          ),
        ],
      ),
    );
  }

  void _handleAction() async {
    if (isApproval) {
      await controller.approveBusiness(business.id);
    } else {
      if (controller.rejectionReasonController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please provide a reason for rejection',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
        return;
      }
      await controller.rejectBusiness(business.id);
    }
    
    Get.back();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}