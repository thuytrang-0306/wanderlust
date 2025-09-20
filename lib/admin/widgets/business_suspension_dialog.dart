import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_business_controller.dart';
import 'package:wanderlust/shared/data/models/business_profile_model.dart';

class BusinessSuspensionDialog extends StatefulWidget {
  final BusinessProfileModel business;

  const BusinessSuspensionDialog({
    super.key,
    required this.business,
  });

  @override
  State<BusinessSuspensionDialog> createState() => _BusinessSuspensionDialogState();
}

class _BusinessSuspensionDialogState extends State<BusinessSuspensionDialog> {
  final AdminBusinessController _controller = Get.find<AdminBusinessController>();
  final TextEditingController _reasonController = TextEditingController();
  String _selectedReason = 'violation_terms';
  bool _isLoading = false;

  final Map<String, String> _suspensionReasons = {
    'violation_terms': 'Violation of Terms of Service',
    'false_information': 'False or Misleading Information',
    'poor_service': 'Consistently Poor Service',
    'safety_concerns': 'Safety Concerns Reported',
    'legal_issues': 'Legal or Regulatory Issues',
    'inactive_business': 'Business No Longer Active',
    'user_complaints': 'Multiple User Complaints',
    'other': 'Other (Please specify)',
  };

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 500.w,
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
            _buildBusinessInfo(),
            SizedBox(height: 24.h),
            _buildReasonSelection(),
            SizedBox(height: 16.h),
            _buildAdditionalDetails(),
            SizedBox(height: 24.h),
            _buildWarning(),
            SizedBox(height: 24.h),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.warning,
            color: const Color(0xFFD97706),
            size: 24.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suspend Business',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                'This action will temporarily disable the business',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
          iconSize: 24.sp,
        ),
      ],
    );
  }

  Widget _buildBusinessInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: const Color(0xFFF3F4F6),
            ),
            child: Icon(
              Icons.business,
              color: const Color(0xFF6B7280),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.business.businessName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  widget.business.businessType.displayName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  '${widget.business.totalListings} listings',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suspension Reason',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedReason,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            items: _suspensionReasons.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: TextStyle(fontSize: 14.sp),
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedReason = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Details',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _reasonController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: _selectedReason == 'other' 
                ? 'Please specify the reason for suspension...'
                : 'Provide additional context or details (optional)...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFFDC2626),
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warning: This action will:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '• Hide all business listings from public view\n'
                  '• Prevent new bookings and inquiries\n'
                  '• Notify the business owner via email\n'
                  '• Add this action to the business history',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : () => Get.back(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: const Text('Cancel'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _suspendBusiness,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Suspend Business'),
          ),
        ),
      ],
    );
  }

  void _suspendBusiness() async {
    if (_selectedReason == 'other' && _reasonController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please specify the reason for suspension',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reason = _selectedReason == 'other' 
          ? _reasonController.text.trim()
          : _suspensionReasons[_selectedReason]!;
      
      final additionalDetails = _selectedReason != 'other' && _reasonController.text.trim().isNotEmpty
          ? _reasonController.text.trim()
          : null;

      final finalReason = _selectedReason == 'other' 
          ? _reasonController.text.trim()
          : '${_suspensionReasons[_selectedReason]!}${additionalDetails != null ? '\n\nDetails: $additionalDetails' : ''}';

      await _controller.suspendBusiness(
        widget.business.id,
        reason: finalReason,
      );

      Get.back(); // Close dialog
      Get.snackbar(
        'Success',
        'Business suspended successfully',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to suspend business: $e',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}