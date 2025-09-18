import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/notifications/notifications_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NotificationsPage extends GetView<NotificationsController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => NotificationsController());

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
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
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8E0FF), // Light purple gradient
            Color(0xFFF5F0FF), // Very light purple
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Settings action
                },
                child: Icon(Icons.settings_outlined, color: AppColors.primary, size: 24.sp),
              ),
            ],
          ),
        ),
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
        onTap: () {
          controller.markAsRead(notification.id);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: notification.avatar,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color: AppColors.neutral200,
                          child: Icon(Icons.person, color: AppColors.neutral400, size: 20.sp),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: AppColors.neutral200,
                          child: Icon(Icons.person, color: AppColors.neutral400, size: 20.sp),
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
                    // Name
                    Text(
                      notification.userName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Time
                    Text(
                      notification.time,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF9CA3AF),
                        height: 1.2,
                      ),
                    ),
                    if (notification.content.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        notification.content,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF4B5563),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Unread indicator
              if (notification.isUnread) ...[
                SizedBox(width: AppSpacing.s2),
                Container(
                  width: 8.w,
                  height: 8.w,
                  margin: EdgeInsets.only(top: 6.h),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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

// Notification Model
class NotificationModel {
  final String id;
  final String userName;
  final String avatar;
  final String time;
  final String content;
  final bool isUnread;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.userName,
    required this.avatar,
    required this.time,
    required this.content,
    required this.isUnread,
    required this.timestamp,
  });
}
