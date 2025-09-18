import 'package:get/get.dart';
import 'package:wanderlust/presentation/pages/notifications/notifications_page.dart';

class NotificationsController extends GetxController {
  // Observable list of notifications
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  
  // Filtered notifications
  List<NotificationModel> get todayNotifications {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    return notifications.where((n) {
      return n.timestamp.isAfter(todayStart);
    }).toList();
  }
  
  List<NotificationModel> get weekNotifications {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekAgo = now.subtract(const Duration(days: 7));
    
    return notifications.where((n) {
      return n.timestamp.isBefore(todayStart) && n.timestamp.isAfter(weekAgo);
    }).toList();
  }
  
  @override
  void onInit() {
    super.onInit();
    // Load real notifications from service when available
    // For now, keep empty state
    notifications.value = [];
  }
  
  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = notifications[index];
      if (notification.isUnread) {
        notifications[index] = NotificationModel(
          id: notification.id,
          userName: notification.userName,
          avatar: notification.avatar,
          time: notification.time,
          content: notification.content,
          isUnread: false,
          timestamp: notification.timestamp,
        );
      }
    }
  }
  
  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      final notification = notifications[i];
      if (notification.isUnread) {
        notifications[i] = NotificationModel(
          id: notification.id,
          userName: notification.userName,
          avatar: notification.avatar,
          time: notification.time,
          content: notification.content,
          isUnread: false,
          timestamp: notification.timestamp,
        );
      }
    }
  }
  
  int get unreadCount => notifications.where((n) => n.isUnread).length;
}