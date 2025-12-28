import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/notifications/notifications_controller.dart';
import 'package:wanderlust/shared/data/models/notification_model.dart';
import 'package:wanderlust/shared/core/widgets/app_image.dart';
import 'package:wanderlust/core/widgets/custom_app_bar.dart';

class NotificationsPage extends GetView<NotificationsController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => NotificationsController());

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Thông báo',
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return GestureDetector(
                onTap: () => controller.markAllAsRead(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'Đọc tất cả',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF54189A),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox();
          }),
          SizedBox(width: 8.w),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => controller.navigateToSettings(),
          ),
        ],
      ),
      body: Container(
              color: Colors.white,
              child: Obx(() {
                if (controller.notifications.isEmpty) {
                  return _buildEmptyState();
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.todayNotifications.isNotEmpty) ...[
                        _buildSectionHeader('Hôm nay'),
                        ...controller.todayNotifications.map(
                          (notification) => _buildNotificationItem(notification),
                        ),
                      ],
                      if (controller.weekNotifications.isNotEmpty) ...[
                        _buildSectionHeader('7 ngày qua'),
                        ...controller.weekNotifications.map(
                          (notification) => _buildNotificationItem(notification),
                        ),
                      ],
                      if (controller.olderNotifications.isNotEmpty) ...[
                        _buildSectionHeader('Cũ hơn'),
                        ...controller.olderNotifications.map(
                          (notification) => _buildNotificationItem(notification),
                        ),
                      ],
                    ],
                  ),
                );
              }),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      color: const Color(0xFFF5F7F8),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s3),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => controller.handleNotificationTap(notification),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s4),
          decoration: BoxDecoration(
            color: notification.isUnread ? const Color(0xFFF8FAFC) : Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar or Icon
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
                  color: notification.senderAvatar == null ? AppColors.primary.withValues(alpha: 0.1) : null,
                ),
                child: ClipOval(
                  child: notification.senderAvatar != null
                      ? AppImage(
                          imageData: notification.senderAvatar!,
                          width: 44.w,
                          height: 44.h,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            notification.type.icon,
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ),
                ),
              ),
              SizedBox(width: AppSpacing.s3),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with type indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _getTypeColor(notification.type).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            notification.type.displayName,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: _getTypeColor(notification.type),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    
                    // Body content
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF4B5563),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    
                    // Time and sender info
                    Row(
                      children: [
                        Text(
                          notification.timeAgo,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        if (notification.senderName != null) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                          Text(
                            notification.senderName!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Unread indicator and priority
              Column(
                children: [
                  if (notification.isUnread)
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (notification.priority == NotificationPriority.high ||
                      notification.priority == NotificationPriority.urgent) ...[
                    SizedBox(height: 4.h),
                    Icon(
                      Icons.priority_high,
                      size: 16.sp,
                      color: notification.priority == NotificationPriority.urgent
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFEAB308),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.businessApproved:
      case NotificationType.bookingConfirmed:
      case NotificationType.paymentConfirmed:
        return const Color(0xFF10B981);
      case NotificationType.businessRejected:
      case NotificationType.bookingCancelled:
        return const Color(0xFFEF4444);
      case NotificationType.businessPending:
      case NotificationType.bookingReminder:
        return const Color(0xFFEAB308);
      case NotificationType.blogLike:
      case NotificationType.userFollow:
        return AppColors.primary;
      case NotificationType.welcome:
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.neutral500;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 80.sp, color: AppColors.neutral300),
          SizedBox(height: AppSpacing.s4),
          Text(
            'Không có thông báo',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral600,
            ),
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Bạn sẽ nhận được thông báo khi có hoạt động mới',
            style: TextStyle(fontSize: 14.sp, color: AppColors.neutral500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// NotificationModel is now imported from shared/data/models/notification_model.dart
