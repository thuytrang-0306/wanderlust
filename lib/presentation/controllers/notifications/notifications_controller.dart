import 'package:get/get.dart';
import 'package:wanderlust/shared/core/services/notification_service.dart';
import 'package:wanderlust/shared/data/models/notification_model.dart';
import 'package:wanderlust/shared/core/utils/logger_service.dart';

class NotificationsController extends GetxController {
  // Get NotificationService instance
  NotificationService get _notificationService {
    if (Get.isRegistered<NotificationService>()) {
      return NotificationService.to;
    }
    // Fallback: put service if not registered
    Get.put(NotificationService());
    return NotificationService.to;
  }

  // Proxy to NotificationService observables
  RxList<NotificationModel> get notifications => _notificationService.notifications;
  RxInt get unreadCount => _notificationService.unreadCount;
  RxBool get isLoading => _notificationService.isLoading;

  // Filtered notifications using NotificationService methods
  List<NotificationModel> get todayNotifications => _notificationService.todayNotifications;
  List<NotificationModel> get weekNotifications => _notificationService.weekNotifications;
  List<NotificationModel> get olderNotifications => _notificationService.olderNotifications;

  @override
  void onInit() {
    super.onInit();
    LoggerService.i('NotificationsController initialized - using NotificationService');
    
    // Ensure NotificationService is initialized
    try {
      _notificationService;
      LoggerService.d('NotificationService successfully accessed');
    } catch (e) {
      LoggerService.e('Failed to initialize NotificationService', error: e);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      LoggerService.d('Marked notification as read: $notificationId');
    } catch (e) {
      LoggerService.e('Failed to mark notification as read', error: e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      LoggerService.i('Marked all notifications as read');
    } catch (e) {
      LoggerService.e('Failed to mark all notifications as read', error: e);
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      LoggerService.d('Deleted notification: $notificationId');
    } catch (e) {
      LoggerService.e('Failed to delete notification', error: e);
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();
      LoggerService.i('Cleared all notifications');
    } catch (e) {
      LoggerService.e('Failed to clear all notifications', error: e);
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    try {
      // NotificationService automatically syncs with Firestore
      // This method can be used for manual refresh if needed
      LoggerService.d('Notifications refreshed (real-time sync active)');
    } catch (e) {
      LoggerService.e('Failed to refresh notifications', error: e);
    }
  }

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notificationService.getNotificationsByType(type);
  }

  /// Get notifications by category
  List<NotificationModel> getNotificationsByCategory(String category) {
    return notifications.where((n) => n.category == category).toList();
  }

  @override
  void onClose() {
    LoggerService.i('NotificationsController disposed');
    super.onClose();
  }
}
