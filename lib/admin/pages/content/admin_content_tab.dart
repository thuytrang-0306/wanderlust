import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_content_controller.dart';
import 'package:wanderlust/admin/services/admin_content_service.dart';
import 'package:wanderlust/admin/widgets/content_details_dialog.dart';
import 'package:wanderlust/core/widgets/app_image.dart';

class AdminContentTab extends GetView<AdminContentController> {
  const AdminContentTab({super.key});

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
            
            // Content list
            _buildContentList(),
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
              'Content Moderation',
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
                  controller.exportContent,
                  isPrimary: false,
                ),
                SizedBox(width: 12.w),
                _buildActionButton(
                  'Refresh',
                  Icons.refresh,
                  controller.refreshContent,
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
                    'Total Content',
                    controller.contentStats.value.totalContent.toString(),
                    Icons.article,
                    const Color(0xFF3B82F6),
                  ),
                ),
                SizedBox(width: 16.w),
                SizedBox(
                  width: 200.w,
                  child: _buildStatCard(
                    'Pending Review',
                    controller.contentStats.value.pendingReview.toString(),
                    Icons.pending_actions,
                    const Color(0xFFF59E0B),
                  ),
                ),
                SizedBox(width: 16.w),
                SizedBox(
                  width: 200.w,
                  child: _buildStatCard(
                    'Approved',
                    controller.contentStats.value.approvedContent.toString(),
                    Icons.check_circle,
                    const Color(0xFF10B981),
                  ),
                ),
                SizedBox(width: 16.w),
                SizedBox(
                  width: 200.w,
                  child: _buildStatCard(
                    'Flagged',
                    controller.contentStats.value.flaggedContent.toString(),
                    Icons.flag,
                    const Color(0xFFDC2626),
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
              hintText: 'Search content by title, author, content...',
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
                        DropdownMenuItem(value: 'pending', child: Text('Pending Review')),
                        DropdownMenuItem(value: 'approved', child: Text('Approved')),
                        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                        DropdownMenuItem(value: 'flagged', child: Text('Flagged')),
                        DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
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
                        labelText: 'Content Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Types')),
                        DropdownMenuItem(value: 'blog', child: Text('Blog Posts')),
                        DropdownMenuItem(value: 'listing', child: Text('Listings')),
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

  Widget _buildContentList() {
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
          
          // Content items
          Obx(() {
            if (controller.content.isEmpty) {
              return _buildEmptyState();
            }
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.content.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final contentItem = controller.content[index];
                return _buildContentItem(contentItem);
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
              'Content',
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
              'Author',
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

  Widget _buildContentItem(ContentModerationItem contentItem) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => _showContentDetails(contentItem),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Obx(() => Checkbox(
                value: controller.selectedContent.contains(contentItem.id),
                onChanged: (_) => controller.toggleContentSelection(contentItem.id),
              )),
              SizedBox(width: 16.w),
              
              // Content info
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // Content image or icon
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: const Color(0xFFF3F4F6),
                      ),
                      child: contentItem.images.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: AppImage(
                                imageData: contentItem.images.first,
                                width: 48.w,
                                height: 48.h,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              contentItem.type == ContentType.blog ? Icons.article : Icons.hotel,
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
                            contentItem.title,
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
                            contentItem.content,
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
              
              // Content type
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: controller.getTypeColor(contentItem.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '${controller.getTypeIcon(contentItem.type)} ${contentItem.type.displayName}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: controller.getTypeColor(contentItem.type),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              
              // Author
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contentItem.authorName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (contentItem.reportCount > 0) ...[
                      SizedBox(height: 2.h),
                      Text(
                        '${contentItem.reportCount} reports',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Status
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(contentItem.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    contentItem.status.displayName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: controller.getStatusColor(contentItem.status),
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
                  _formatDate(contentItem.createdAt),
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
                    if (contentItem.status == ContentStatus.pending) ...[ 
                      _buildQuickActionButton(
                        'Approve',
                        Icons.check,
                        const Color(0xFF10B981),
                        () => _showModerationDialog(contentItem, true),
                      ),
                      SizedBox(width: 8.w),
                      _buildQuickActionButton(
                        'Reject',
                        Icons.close,
                        const Color(0xFFEF4444),
                        () => _showModerationDialog(contentItem, false),
                      ),
                    ] else ...[ 
                      _buildQuickActionButton(
                        'View',
                        Icons.visibility,
                        const Color(0xFF3B82F6),
                        () => _showContentDetails(contentItem),
                      ),
                      SizedBox(width: 8.w),
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert, size: 16.sp),
                        itemBuilder: (context) => [
                          if (contentItem.status != ContentStatus.flagged)
                            const PopupMenuItem(
                              value: 'flag',
                              child: Text('Flag Content'),
                            ),
                          const PopupMenuItem(
                            value: 'history',
                            child: Text('View History'),
                          ),
                        ],
                        onSelected: (value) => _handlePopupAction(value, contentItem),
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
            Icons.article_outlined,
            size: 64.sp,
            color: const Color(0xFF9CA3AF),
          ),
          SizedBox(height: 16.h),
          Text(
            'No content found',
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

  void _showContentDetails(ContentModerationItem contentItem) {
    Get.dialog(
      ContentDetailsDialog(
        contentItem: contentItem,
      ),
      barrierDismissible: false,
    );
  }

  void _showModerationDialog(ContentModerationItem contentItem, bool isApproval) {
    // Show moderation dialog - will implement later
    if (isApproval) {
      controller.approveContent(contentItem.id, contentItem.type);
    } else {
      // For now, just prompt for reason
      showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: const Text('Reject Content'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to reject "${contentItem.title}"?'),
              SizedBox(height: 16.h),
              TextField(
                controller: controller.rejectionReasonController,
                decoration: const InputDecoration(
                  labelText: 'Rejection Reason *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.rejectContent(contentItem.id, contentItem.type);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Reject'),
            ),
          ],
        ),
      );
    }
  }

  void _handlePopupAction(String action, ContentModerationItem contentItem) {
    switch (action) {
      case 'flag':
        _showFlagDialog(contentItem);
        break;
      case 'history':
        _showContentDetails(contentItem);
        break;
    }
  }

  void _showFlagDialog(ContentModerationItem contentItem) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Flag Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to flag "${contentItem.title}"?'),
            SizedBox(height: 16.h),
            TextField(
              controller: controller.flagReasonController,
              decoration: const InputDecoration(
                labelText: 'Flag Reason *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.flagContent(contentItem.id, contentItem.type);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Flag'),
          ),
        ],
      ),
    );
  }
}