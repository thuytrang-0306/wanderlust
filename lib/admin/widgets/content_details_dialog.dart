import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/services/admin_content_service.dart';
import 'package:wanderlust/admin/controllers/admin_content_controller.dart';
import 'package:wanderlust/core/widgets/app_image.dart';

class ContentDetailsDialog extends StatefulWidget {
  final ContentModerationItem contentItem;

  const ContentDetailsDialog({
    super.key,
    required this.contentItem,
  });

  @override
  State<ContentDetailsDialog> createState() => _ContentDetailsDialogState();
}

class _ContentDetailsDialogState extends State<ContentDetailsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminContentController _controller = Get.find<AdminContentController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadContentHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadContentHistory() {
    _controller.viewContentDetails(widget.contentItem.id, widget.contentItem.type);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 900.w,
        height: 700.h,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildContentTab(),
                  _buildModerationTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _controller.getTypeColor(widget.contentItem.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '${_controller.getTypeIcon(widget.contentItem.type)} ${widget.contentItem.type.displayName}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: _controller.getTypeColor(widget.contentItem.type),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contentItem.title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'By ${widget.contentItem.authorName}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _buildStatusChip(),
          SizedBox(width: 12.w),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            iconSize: 24.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _controller.getStatusColor(widget.contentItem.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        widget.contentItem.status.displayName,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: _controller.getStatusColor(widget.contentItem.status),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF3B82F6),
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorColor: const Color(0xFF3B82F6),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.article, size: 16.sp),
                SizedBox(width: 8.w),
                Text('Content'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gavel, size: 16.sp),
                SizedBox(width: 8.w),
                Text('Moderation'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 16.sp),
                SizedBox(width: 8.w),
                Text('History'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content Images
          if (widget.contentItem.images.isNotEmpty) ...[
            Text(
              'Images',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 200.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.contentItem.images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: AppImage(
                        imageData: widget.contentItem.images[index],
                        width: 150.w,
                        height: 200.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Content Text
          Text(
            'Content',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              widget.contentItem.content,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Metadata
          _buildMetadataSection(),
        ],
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metadata',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildMetadataRow('Created', _formatDate(widget.contentItem.createdAt)),
              _buildMetadataRow('Updated', _formatDate(widget.contentItem.updatedAt)),
              _buildMetadataRow('Author', widget.contentItem.authorName),
              _buildMetadataRow('Reports', widget.contentItem.reportCount.toString()),
              if (widget.contentItem.flags.isNotEmpty)
                _buildMetadataRow('Flags', widget.contentItem.flags.join(', ')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModerationTab() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              if (widget.contentItem.status == ContentStatus.pending) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveContent(),
                    icon: Icon(Icons.check, size: 16.sp),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRejectDialog(),
                    icon: Icon(Icons.close, size: 16.sp),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ],
              if (widget.contentItem.status != ContentStatus.flagged) ...[
                if (widget.contentItem.status != ContentStatus.pending) SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showFlagDialog(),
                    icon: Icon(Icons.flag, size: 16.sp),
                    label: const Text('Flag'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 32.h),

          // Moderation Notes
          Text(
            'Moderation Notes',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _controller.moderationNotesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add notes about this content...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Obx(() {
      final history = _controller.contentHistory;
      if (history.isEmpty) {
        return const Center(
          child: Text('No moderation history available'),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.all(24.w),
        itemCount: history.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final item = history[index];
          return _buildHistoryItem(item);
        },
      );
    });
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final action = item['action'] as String;
    final timestamp = item['timestamp'] as String;
    final adminName = item['adminName'] as String;
    final reason = item['reason'] as String?;

    IconData icon;
    Color color;
    switch (action) {
      case 'approved':
        icon = Icons.check_circle;
        color = const Color(0xFF10B981);
        break;
      case 'rejected':
        icon = Icons.cancel;
        color = const Color(0xFFEF4444);
        break;
      case 'flagged':
        icon = Icons.flag;
        color = const Color(0xFFDC2626);
        break;
      default:
        icon = Icons.info;
        color = const Color(0xFF3B82F6);
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content ${action.toLowerCase()} by $adminName',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                if (reason != null && reason.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'Reason: $reason',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF374151),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: () {
              // Save moderation notes if any
              if (_controller.moderationNotesController.text.isNotEmpty) {
                // Save notes logic here
                _controller.moderationNotesController.clear();
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Notes'),
          ),
        ],
      ),
    );
  }

  void _approveContent() {
    _controller.approveContent(widget.contentItem.id, widget.contentItem.type);
    Get.back();
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${widget.contentItem.title}"?'),
            SizedBox(height: 16.h),
            TextField(
              controller: _controller.rejectionReasonController,
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
              _controller.rejectContent(widget.contentItem.id, widget.contentItem.type);
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

  void _showFlagDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Flag Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to flag "${widget.contentItem.title}"?'),
            SizedBox(height: 16.h),
            TextField(
              controller: _controller.flagReasonController,
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
              _controller.flagContent(widget.contentItem.id, widget.contentItem.type);
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}