import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_business_controller.dart';
import 'package:wanderlust/shared/data/models/business_profile_model.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/admin/widgets/business_verification_dialog.dart';
import 'package:wanderlust/admin/widgets/business_details_dialog.dart';
import 'package:wanderlust/admin/widgets/business_suspension_dialog.dart';

class AdminBusinessTab extends GetView<AdminBusinessController> {
  const AdminBusinessTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with stats
            _buildHeader(),
            SizedBox(height: 24.h),
            
            // Filters and search
            _buildFilters(),
            SizedBox(height: 24.h),
            
            // Business list
            _buildBusinessList(),
          ],
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Business Management',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            Row(
              children: [
                _buildActionButton(
                  'Export All',
                  Icons.download,
                  controller.exportBusinesses,
                  isPrimary: false,
                ),
                SizedBox(width: 12.w),
                _buildActionButton(
                  'Refresh',
                  Icons.refresh,
                  controller.refreshBusinesses,
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        // Statistics cards
        Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: Row(
              children: [
                SizedBox(
                  width: 200.w,
                  child: _buildStatCard(
                    'Total Businesses',
                    controller.businessStats.value.totalBusinesses.toString(),
                    Icons.business,
                    const Color(0xFF3B82F6),
                  ),
                ),
                SizedBox(width: 16.w),
                SizedBox(
                  width: 200.w,
                  child: _buildStatCard(
                    'Pending Verification',
                    controller.businessStats.value.pendingVerification.toString(),
                    Icons.pending_actions,
                    const Color(0xFFF59E0B),
                  ),
                ),
                SizedBox(width: 16.w),
                SizedBox(
                  width: 200.w,
                  child: _buildStatCard(
                    'Verified',
                    controller.businessStats.value.verifiedBusinesses.toString(),
                    Icons.verified,
                    const Color(0xFF10B981),
                  ),
                ),
                SizedBox(width: 16.w),
                SizedBox(
                  width: 200.w,
                  child: _buildStatCard(
                    'New Today',
                    controller.businessStats.value.newToday.toString(),
                    Icons.today,
                    const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24.sp),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search businesses by name, email, phone...',
              prefixIcon: const Icon(Icons.search),
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
          SizedBox(height: 16.h),
          
          // Filter dropdowns
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicWidth(
              child: Row(
                children: [
                  SizedBox(
                    width: 200.w,
                    child: Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedStatus.value,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Status')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'verified', child: Text('Verified')),
                        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                        DropdownMenuItem(value: 'expired', child: Text('Expired')),
                      ],
                      onChanged: (value) => controller.onStatusFilterChanged(value!),
                    )),
                  ),
                  SizedBox(width: 16.w),
                  SizedBox(
                    width: 200.w,
                    child: Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedType.value,
                      decoration: InputDecoration(
                        labelText: 'Business Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Types')),
                        DropdownMenuItem(value: 'hotel', child: Text('Hotel/Homestay')),
                        DropdownMenuItem(value: 'tour', child: Text('Tour Operator')),
                        DropdownMenuItem(value: 'restaurant', child: Text('Restaurant')),
                        DropdownMenuItem(value: 'service', child: Text('Service')),
                      ],
                      onChanged: (value) => controller.onTypeFilterChanged(value!),
                    )),
                  ),
                  SizedBox(width: 16.w),
                  SizedBox(
                    width: 200.w,
                    child: Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedDateRange.value,
                      decoration: InputDecoration(
                        labelText: 'Date Range',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Time')),
                        DropdownMenuItem(value: 'today', child: Text('Today')),
                        DropdownMenuItem(value: 'week', child: Text('This Week')),
                        DropdownMenuItem(value: 'month', child: Text('This Month')),
                        DropdownMenuItem(value: 'year', child: Text('This Year')),
                      ],
                      onChanged: (value) => controller.onDateRangeFilterChanged(value!),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // List header
          _buildListHeader(),
          
          // Business items
          Obx(() {
            if (controller.businesses.isEmpty) {
              return _buildEmptyState();
            }
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.businesses.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final business = controller.businesses[index];
                return _buildBusinessItem(business);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          Obx(() => Checkbox(
            value: controller.isAllSelected,
            onChanged: controller.toggleSelectAll,
            tristate: true,
          )),
          SizedBox(width: 16.w),
          Expanded(
            flex: 3,
            child: Text(
              'Business',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Type',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Created',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Actions',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessItem(BusinessProfileModel business) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => _showBusinessDetails(business),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Obx(() => Checkbox(
                value: controller.selectedBusinesses.contains(business.id),
                onChanged: (_) => controller.toggleBusinessSelection(business.id),
              )),
              SizedBox(width: 16.w),
              
              // Business info
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // Business image or avatar
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: const Color(0xFFF3F4F6),
                      ),
                      child: business.businessImages?.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: AppImage(
                                imageData: business.businessImages!.first,
                                width: 48.w,
                                height: 48.h,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.business,
                              color: const Color(0xFF9CA3AF),
                              size: 24.sp,
                            ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            business.businessName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: const Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            business.businessEmail,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Business type
              Expanded(
                flex: 2,
                child: Container(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              
              // Verification status
              Expanded(
                flex: 2,
                child: Container(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              
              // Created date
              Expanded(
                flex: 2,
                child: Text(
                  _formatDate(business.createdAt),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              
              // Actions
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    if (business.verificationStatus == VerificationStatus.pending) ...[
                      _buildQuickActionButton(
                        'Approve',
                        Icons.check,
                        const Color(0xFF10B981),
                        () => _showVerificationDialog(business, true),
                      ),
                      SizedBox(width: 8.w),
                      _buildQuickActionButton(
                        'Reject',
                        Icons.close,
                        const Color(0xFFEF4444),
                        () => _showVerificationDialog(business, false),
                      ),
                    ] else ...[
                      _buildQuickActionButton(
                        'View',
                        Icons.visibility,
                        const Color(0xFF3B82F6),
                        () => _showBusinessDetails(business),
                      ),
                      SizedBox(width: 8.w),
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert, size: 16.sp),
                        itemBuilder: (context) => [
                          if (business.isActive)
                            const PopupMenuItem(
                              value: 'suspend',
                              child: Text('Suspend'),
                            )
                          else
                            const PopupMenuItem(
                              value: 'reactivate',
                              child: Text('Reactivate'),
                            ),
                          const PopupMenuItem(
                            value: 'history',
                            child: Text('View History'),
                          ),
                        ],
                        onSelected: (value) => _handlePopupAction(value, business),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Icon(
            Icons.business_outlined,
            size: 64.sp,
            color: const Color(0xFF9CA3AF),
          ),
          SizedBox(height: 16.h),
          Text(
            'No businesses found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed, {
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16.sp),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF3B82F6) : Colors.white,
        foregroundColor: isPrimary ? Colors.white : const Color(0xFF374151),
        side: isPrimary ? null : const BorderSide(color: Color(0xFFE5E7EB)),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    
    if (diff == 0) {
      return 'Today';
    } else if (diff == 1) {
      return 'Yesterday';
    } else if (diff < 7) {
      return '${diff}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showBusinessDetails(BusinessProfileModel business) {
    controller.viewBusinessDetails(business.id);
    Get.dialog(
      BusinessDetailsDialog(business: business),
      barrierDismissible: true,
    );
  }

  void _showVerificationDialog(BusinessProfileModel business, bool isApproval) {
    Get.dialog(
      BusinessVerificationDialog(
        business: business,
        isApproval: isApproval,
      ),
      barrierDismissible: false,
    );
  }

  void _handlePopupAction(String action, BusinessProfileModel business) {
    switch (action) {
      case 'suspend':
        _showSuspensionDialog(business);
        break;
      case 'reactivate':
        controller.reactivateBusiness(business.id);
        break;
      case 'history':
        _showBusinessDetails(business);
        break;
    }
  }

  void _showSuspensionDialog(BusinessProfileModel business) {
    Get.dialog(
      BusinessSuspensionDialog(business: business),
      barrierDismissible: false,
    );
  }
}