import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:wanderlust/shared/core/utils/logger_service.dart';
import 'package:wanderlust/shared/data/models/notification_model.dart';

/// Local push notification service using flutter_local_notifications
/// Integrates with NotificationService to show OS-level push notifications
class LocalNotificationService extends GetxService {
  static LocalNotificationService get to => Get.find();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initialize();
  }

  /// Initialize local notifications
  Future<void> initialize() async {
    try {
      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _isInitialized = true;
      LoggerService.i('LocalNotificationService initialized');

      // Request permissions
      await _requestPermissions();
    } catch (e) {
      LoggerService.e('Failed to initialize LocalNotificationService', error: e);
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      // iOS permissions
      final bool? iosGranted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      if (iosGranted == true) {
        LoggerService.i('✅ iOS notification permissions GRANTED');
      } else if (iosGranted == false) {
        LoggerService.w('⚠️ iOS notification permissions DENIED');
      }

      // Android 13+ permissions - MUST request at runtime
      final bool? androidGranted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      if (androidGranted == true) {
        LoggerService.i('✅ Android notification permissions GRANTED');
      } else if (androidGranted == false) {
        LoggerService.w('⚠️ Android notification permissions DENIED');
      }
    } catch (e) {
      LoggerService.e('Failed to request notification permissions', error: e);
    }
  }

  /// Show notification
  Future<void> showNotification(NotificationModel notification) async {
    if (!_isInitialized) {
      LoggerService.w('LocalNotificationService not initialized');
      return;
    }

    try {
      // Build notification details
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'wanderlust_channel', // channel id
        'Wanderlust Notifications', // channel name
        channelDescription: 'Notifications from Wanderlust app',
        importance: _getImportance(notification.priority),
        priority: _getPriority(notification.priority),
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Create payload with notification data for tap handling
      final payload = jsonEncode({
        'id': notification.id,
        'type': notification.type.value,
        'actionUrl': notification.actionUrl,
        'metadata': notification.metadata,
      });

      // Show notification
      await _flutterLocalNotificationsPlugin.show(
        notification.id.hashCode, // Use notification id hash as notification id
        notification.title,
        notification.body,
        notificationDetails,
        payload: payload,
      );

      LoggerService.d('Local notification shown: ${notification.title}');
    } catch (e) {
      LoggerService.e('Failed to show local notification', error: e);
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    try {
      if (response.payload == null) return;

      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      final type = data['type'] as String?;
      final actionUrl = data['actionUrl'] as String?;
      final metadata = data['metadata'] as Map<String, dynamic>?;

      LoggerService.d('Notification tapped - type: $type, actionUrl: $actionUrl');

      // Navigate based on notification type
      _handleNavigation(type, actionUrl, metadata);
    } catch (e) {
      LoggerService.e('Failed to handle notification tap', error: e);
    }
  }

  /// Handle navigation based on notification type
  void _handleNavigation(
    String? type,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  ) {
    if (type == null) return;

    try {
      switch (type) {
        case 'blog_like':
        case 'blog_comment':
          final blogId = metadata?['blogId'] as String?;
          if (blogId != null) {
            Get.toNamed('/blog-detail', arguments: {'postId': blogId});
          }
          break;

        case 'user_follow':
          final userId = metadata?['followerId'] as String?;
          if (userId != null) {
            Get.toNamed('/user-profile', arguments: {'userId': userId});
          }
          break;

        case 'booking_confirmed':
        case 'booking_cancelled':
        case 'booking_reminder':
        case 'payment_confirmed':
        case 'payment_due':
          Get.toNamed('/booking-history');
          break;

        case 'business_approved':
        case 'business_rejected':
        case 'business_pending':
          Get.toNamed('/business-dashboard');
          break;

        default:
          if (actionUrl != null && actionUrl.isNotEmpty) {
            Get.toNamed(actionUrl);
          }
      }
    } catch (e) {
      LoggerService.e('Navigation failed', error: e);
    }
  }

  /// Get Android importance from priority
  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return Importance.max;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
      default:
        return Importance.defaultImportance;
    }
  }

  /// Get Android priority from priority
  Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return Priority.max;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
      default:
        return Priority.defaultPriority;
    }
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      LoggerService.d('Cancelled notification: $id');
    } catch (e) {
      LoggerService.e('Failed to cancel notification', error: e);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      LoggerService.i('Cancelled all notifications');
    } catch (e) {
      LoggerService.e('Failed to cancel all notifications', error: e);
    }
  }
}
