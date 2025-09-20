import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_business_controller.dart';
import 'package:wanderlust/shared/data/models/business_profile_model.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/admin/widgets/business_verification_dialog.dart';

class BusinessDetailsDialog extends GetView<AdminBusinessController> {
  final BusinessProfileModel business;

  const BusinessDetailsDialog({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 800.w,
        constraints: BoxConstraints(maxHeight: 0.9.sh),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: Row(
                children: [
                  // Main content
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBusinessInfo(),
                          SizedBox(height: 24.h),
                          _buildContactInfo(),
                          SizedBox(height: 24.h),
                          _buildVerificationInfo(),
                          SizedBox(height: 24.h),
                          _buildBusinessImages(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Activity sidebar
                  Container(
                    width: 300.w,
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildActivityHeader(),
                        Expanded(
                          child: _buildActivityList(),
                        ),
                      ],
                    ),
                  ),
                ],
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        children: [
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
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: controller.getTypeColor(business.businessType).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '${business.businessType.icon} ${business.businessType.displayName}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: controller.getTypeColor(business.businessType),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
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

  Widget _buildBusinessInfo() {
    return _buildSection(
      'Business Information',
      [
        _buildInfoRow('Business Name', business.businessName),
        _buildInfoRow('Business Type', business.businessType.displayName),
        _buildInfoRow('Description', business.description),
        if (business.taxNumber?.isNotEmpty == true)
          _buildInfoRow('Tax Number', business.taxNumber!),
        _buildInfoRow('Rating', '${business.formattedRating} (${business.totalReviews} reviews)'),
        _buildInfoRow('Total Listings', business.totalListings.toString()),
        _buildInfoRow('Status', business.isActive ? 'Active' : 'Suspended'),
      ],
    );
  }

  Widget _buildContactInfo() {
    return _buildSection(
      'Contact Information',
      [
        _buildInfoRow('Email', business.businessEmail, icon: Icons.email),
        _buildInfoRow('Phone', business.businessPhone, icon: Icons.phone),
        _buildInfoRow('Address', business.address, icon: Icons.location_on),
      ],
    );
  }

  Widget _buildVerificationInfo() {
    return _buildSection(
      'Verification Details',
      [
        _buildInfoRow('Status', business.verificationStatus.displayName),
        _buildInfoRow('Submitted', _formatDate(business.createdAt)),
        if (business.verifiedAt != null)
          _buildInfoRow('Verified At', _formatDate(business.verifiedAt!)),
        if (business.verificationDoc != null)
          _buildVerificationDoc(),
      ],
    );
  }

  Widget _buildVerificationDoc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Text(
          'Verification Document',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: AppImage(
              imageData: business.verificationDoc!,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessImages() {
    if (business.businessImages?.isEmpty != false) {
      return const SizedBox();
    }
    
    return _buildSection(
      'Business Images',
      [
        SizedBox(
          height: 120.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: business.businessImages!.length,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              return Container(
                width: 160.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: AppImage(
                    imageData: business.businessImages![index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            size: 20.sp,
            color: const Color(0xFF6B7280),
          ),
          SizedBox(width: 8.w),
          Text(
            'Activity History',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return Obx(() {
      if (controller.businessHistory.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              Icon(
                Icons.history,
                size: 48.sp,
                color: const Color(0xFF9CA3AF),
              ),
              SizedBox(height: 16.h),
              Text(
                'No activity history',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      }
      
      return ListView.separated(
        padding: EdgeInsets.all(20.w),
        itemCount: controller.businessHistory.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final activity = controller.businessHistory[index];
          return _buildActivityItem(activity);
        },
      );
    });
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final action = activity['action'] as String? ?? '';
    final timestamp = activity['timestamp'] as DateTime? ?? DateTime.now();
    final adminEmail = activity['adminEmail'] as String? ?? 'System';
    final details = activity['details'] as Map<String, dynamic>? ?? {};
    
    IconData icon;
    Color color;
    String title;
    
    switch (action) {
      case 'business_approved':
        icon = Icons.check_circle;
        color = const Color(0xFF10B981);
        title = 'Business Approved';
        break;
      case 'business_rejected':
        icon = Icons.cancel;
        color = const Color(0xFFEF4444);
        title = 'Business Rejected';
        break;
      case 'business_suspended':
        icon = Icons.pause_circle;
        color = const Color(0xFFF59E0B);
        title = 'Business Suspended';
        break;
      case 'business_reactivated':
        icon = Icons.play_circle;
        color = const Color(0xFF3B82F6);
        title = 'Business Reactivated';
        break;
      case 'business_info_updated':
        icon = Icons.edit;
        color = const Color(0xFF8B5CF6);
        title = 'Information Updated';
        break;
      default:
        icon = Icons.info;
        color = const Color(0xFF6B7280);
        title = 'Unknown Action';
    }
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'By: $adminEmail',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            _formatDateTime(timestamp),
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          if (details.isNotEmpty) ...[
            SizedBox(height: 8.h),
            ...details.entries.map((entry) => Text(
              '${entry.key}: ${entry.value}',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF6B7280),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 16.h),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16.sp, color: const Color(0xFF6B7280)),
            SizedBox(width: 8.w),
          ],
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
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
          if (business.verificationStatus == VerificationStatus.pending) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  Get.dialog(
                    BusinessVerificationDialog(
                      business: business,
                      isApproval: false,
                    ),
                  );
                },
                icon: const Icon(Icons.close),
                label: const Text('Reject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  Get.dialog(
                    BusinessVerificationDialog(
                      business: business,
                      isApproval: true,
                    ),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text('Close'),
              ),
            ),
            SizedBox(width: 16.w),
            if (business.isActive)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Show suspension dialog
                  },
                  icon: const Icon(Icons.pause),
                  label: const Text('Suspend'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              )
            else
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.reactivateBusiness(business.id),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Reactivate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}