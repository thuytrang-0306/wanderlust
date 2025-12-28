import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/shared/core/utils/logger_service.dart';
import 'package:wanderlust/shared/data/models/notification_model.dart';
import 'package:wanderlust/shared/core/services/local_notification_service.dart';

/// Centralized NotificationService for managing all app notifications
/// This service provides:
/// - Real-time notification streaming from Firestore
/// - CRUD operations for notifications
/// - Auto-notification triggers from app events
/// - User preference filtering
/// - Admin broadcasting capabilities
class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String _notificationsCollection = 'notifications';
  static const String _usersCollection = 'users';

  // Reactive state
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  // Current user
  String? get _currentUserId => _auth.currentUser?.uid;

  // Local notification service
  LocalNotificationService? get _localNotificationService {
    try {
      return Get.isRegistered<LocalNotificationService>()
          ? LocalNotificationService.to
          : null;
    } catch (e) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    LoggerService.i('NotificationService initialized');
    
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _startListeningToNotifications();
        LoggerService.i('Started listening to notifications for user: ${user.uid}');
      } else {
        _stopListeningToNotifications();
        _clearNotifications();
        LoggerService.i('Stopped listening to notifications - user logged out');
      }
    });

    // Start immediately if user is already logged in
    if (_currentUserId != null) {
      _startListeningToNotifications();
    }
  }

  // ============ REAL-TIME NOTIFICATION STREAMING ============

  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  void _startListeningToNotifications() {
    if (_currentUserId == null) return;

    try {
      _notificationSubscription?.cancel();
      
      _notificationSubscription = _firestore
          .collection(_notificationsCollection)
          .where('recipientId', isEqualTo: _currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(100) // Limit to recent 100 notifications
          .snapshots()
          .listen(
        (snapshot) {
          _processNotificationSnapshot(snapshot);
        },
        onError: (error) {
          LoggerService.e('Error listening to notifications', error: error);
        },
      );
    } catch (e) {
      LoggerService.e('Failed to start notification listener', error: e);
    }
  }

  void _stopListeningToNotifications() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }

  void _processNotificationSnapshot(QuerySnapshot snapshot) {
    try {
      final previousIds = notifications.map((n) => n.id).toSet();

      final newNotifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .where((notification) => notification != null)
          .cast<NotificationModel>()
          .toList();

      // Detect NEW unread notifications to show push notification
      for (final notification in newNotifications) {
        if (!previousIds.contains(notification.id) && notification.isUnread) {
          // This is a new unread notification - show local push
          _showLocalPushNotification(notification);
        }
      }

      notifications.value = newNotifications;
      _updateUnreadCount();

      LoggerService.d('Updated notifications: ${notifications.length} total, ${unreadCount.value} unread');
    } catch (e) {
      LoggerService.e('Error processing notification snapshot', error: e);
    }
  }

  /// Show local push notification for new notification
  void _showLocalPushNotification(NotificationModel notification) {
    try {
      final localService = _localNotificationService;
      if (localService != null) {
        localService.showNotification(notification);
        LoggerService.d('Triggered local push for: ${notification.title}');
      }
    } catch (e) {
      LoggerService.e('Failed to show local push notification', error: e);
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => n.isUnread).length;
  }

  void _clearNotifications() {
    notifications.clear();
    unreadCount.value = 0;
  }

  // ============ NOTIFICATION CRUD OPERATIONS ============

  /// Create a new notification
  Future<String?> createNotification({
    required String recipientId,
    required String title,
    required String body,
    required NotificationType type,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      // Check if recipient wants to receive this type of notification
      final shouldSend = await _checkUserNotificationPreferences(recipientId, type);
      if (!shouldSend) {
        LoggerService.d('Notification not sent - user preferences disabled for type: ${type.value}');
        return null;
      }

      final notification = NotificationModel(
        id: '', // Will be set by Firestore
        recipientId: recipientId,
        title: title,
        body: body,
        type: type,
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        actionUrl: actionUrl,
        metadata: metadata ?? {},
        priority: priority,
        isRead: false,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_notificationsCollection)
          .add(notification.toFirestore());

      LoggerService.i('Notification created: ${docRef.id} for user: $recipientId');
      return docRef.id;
    } catch (e) {
      LoggerService.e('Failed to create notification', error: e);
      return null;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true, 'readAt': FieldValue.serverTimestamp()});

      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
      }

      LoggerService.d('Marked notification as read: $notificationId');
      return true;
    } catch (e) {
      LoggerService.e('Failed to mark notification as read', error: e);
      return false;
    }
  }

  /// Mark all notifications as read for current user
  Future<bool> markAllAsRead() async {
    try {
      if (_currentUserId == null) return false;

      final batch = _firestore.batch();
      final unreadNotifications = notifications.where((n) => n.isUnread);

      for (final notification in unreadNotifications) {
        batch.update(
          _firestore.collection(_notificationsCollection).doc(notification.id),
          {'isRead': true, 'readAt': FieldValue.serverTimestamp()},
        );
      }

      await batch.commit();

      // Update local state
      for (int i = 0; i < notifications.length; i++) {
        if (notifications[i].isUnread) {
          notifications[i] = notifications[i].copyWith(isRead: true);
        }
      }
      _updateUnreadCount();

      LoggerService.i('Marked all notifications as read for user: $_currentUserId');
      return true;
    } catch (e) {
      LoggerService.e('Failed to mark all notifications as read', error: e);
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .delete();

      // Update local state
      notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();

      LoggerService.d('Deleted notification: $notificationId');
      return true;
    } catch (e) {
      LoggerService.e('Failed to delete notification', error: e);
      return false;
    }
  }

  /// Clear all notifications for current user
  Future<bool> clearAllNotifications() async {
    try {
      if (_currentUserId == null) return false;

      final batch = _firestore.batch();
      final userNotifications = await _firestore
          .collection(_notificationsCollection)
          .where('recipientId', isEqualTo: _currentUserId)
          .get();

      for (final doc in userNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      
      // Update local state
      _clearNotifications();

      LoggerService.i('Cleared all notifications for user: $_currentUserId');
      return true;
    } catch (e) {
      LoggerService.e('Failed to clear all notifications', error: e);
      return false;
    }
  }

  // ============ AUTO-NOTIFICATION TRIGGERS ============

  /// Send welcome notification to new user
  Future<void> sendWelcomeNotification(String userId) async {
    await createNotification(
      recipientId: userId,
      title: 'Chào mừng đến với Wanderlust! 🎉',
      body: 'Khám phá những chuyến đi tuyệt vời và chia sẻ trải nghiệm của bạn cùng cộng đồng.',
      type: NotificationType.welcome,
      priority: NotificationPriority.high,
      metadata: {
        'welcomeBonus': true,
        'onboardingSteps': ['complete_profile', 'explore_destinations', 'create_first_trip']
      },
    );
  }

  /// Send business registration notification
  Future<void> sendBusinessRegistrationNotification(String userId) async {
    await createNotification(
      recipientId: userId,
      title: 'Đăng ký kinh doanh đang được xem xét 📋',
      body: 'Chúng tôi đang xem xét hồ sơ kinh doanh của bạn. Quá trình này có thể mất 2-3 ngày làm việc.',
      type: NotificationType.businessPending,
      priority: NotificationPriority.normal,
      metadata: {'estimatedDays': 3},
    );
  }

  /// Send business approval notification
  Future<void> sendBusinessApprovalNotification(String userId, String businessName) async {
    await createNotification(
      recipientId: userId,
      title: 'Tài khoản kinh doanh đã được phê duyệt! ✅',
      body: 'Chúc mừng! $businessName đã được xác minh. Bạn có thể bắt đầu đăng dịch vụ và nhận booking.',
      type: NotificationType.businessApproved,
      priority: NotificationPriority.high,
      actionUrl: '/business/dashboard',
      metadata: {'businessName': businessName},
    );
  }

  /// Send business rejection notification
  Future<void> sendBusinessRejectionNotification(String userId, String reason) async {
    await createNotification(
      recipientId: userId,
      title: 'Cần bổ sung thông tin kinh doanh 📝',
      body: 'Hồ sơ cần được cập nhật: $reason. Vui lòng chỉnh sửa và gửi lại.',
      type: NotificationType.businessRejected,
      priority: NotificationPriority.high,
      actionUrl: '/business/profile/edit',
      metadata: {'rejectionReason': reason},
    );
  }

  /// Send blog interaction notification
  Future<void> sendBlogLikeNotification({
    required String blogAuthorId,
    required String blogTitle,
    required String likerName,
    String? likerAvatar,
    required String blogId,
  }) async {
    if (blogAuthorId == _currentUserId) return; // Don't notify self

    await createNotification(
      recipientId: blogAuthorId,
      title: 'Có người thích blog của bạn! 👍',
      body: '$likerName đã thích blog "$blogTitle"',
      type: NotificationType.blogLike,
      senderName: likerName,
      senderAvatar: likerAvatar,
      actionUrl: '/blogs/$blogId',
      metadata: {'blogId': blogId, 'blogTitle': blogTitle},
    );
  }

  /// Send booking confirmation notification
  Future<void> sendBookingConfirmationNotification({
    required String userId,
    required String bookingId,
    required String serviceName,
    required DateTime checkInDate,
  }) async {
    await createNotification(
      recipientId: userId,
      title: 'Đặt chỗ thành công! 🎫',
      body: 'Booking cho "$serviceName" đã được xác nhận. Check-in: ${_formatDate(checkInDate)}',
      type: NotificationType.bookingConfirmed,
      priority: NotificationPriority.high,
      actionUrl: '/bookings/$bookingId',
      metadata: {
        'bookingId': bookingId,
        'serviceName': serviceName,
        'checkInDate': checkInDate.toIso8601String(),
      },
    );
  }

  /// Send user follow notification
  Future<void> sendUserFollowNotification({
    required String followedUserId,
    required String followerName,
    String? followerAvatar,
    required String followerId,
  }) async {
    if (followedUserId == _currentUserId) return; // Don't notify self

    await createNotification(
      recipientId: followedUserId,
      title: 'Bạn có người theo dõi mới! 👥',
      body: '$followerName đã bắt đầu theo dõi bạn',
      type: NotificationType.userFollow,
      senderId: followerId,
      senderName: followerName,
      senderAvatar: followerAvatar,
      actionUrl: '/profile/$followerId',
      metadata: {'followerId': followerId},
    );
  }

  // ============ ADMIN BROADCASTING ============

  /// Send notification to all users (Admin only)
  Future<bool> broadcastToAllUsers({
    required String title,
    required String body,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      // Get all users
      final usersSnapshot = await _firestore
          .collection(_usersCollection)
          .where('userType', whereIn: ['regular', 'business'])
          .get();

      final batch = _firestore.batch();
      
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        
        // Check user notification preferences
        final shouldSend = await _checkUserNotificationPreferences(userId, NotificationType.adminAnnouncement);
        if (!shouldSend) continue;

        final notification = NotificationModel(
          id: '', // Will be set by Firestore
          recipientId: userId,
          title: title,
          body: body,
          type: NotificationType.adminAnnouncement,
          senderName: 'Wanderlust Team',
          actionUrl: actionUrl,
          metadata: metadata ?? {},
          priority: priority,
          isRead: false,
          createdAt: DateTime.now(),
        );

        final docRef = _firestore.collection(_notificationsCollection).doc();
        batch.set(docRef, notification.toFirestore());
      }

      await batch.commit();
      LoggerService.i('Broadcast notification sent to ${usersSnapshot.docs.length} users');
      return true;
    } catch (e) {
      LoggerService.e('Failed to broadcast notification', error: e);
      return false;
    }
  }

  /// Send notification to specific user group
  Future<bool> sendToUserGroup({
    required List<String> userIds,
    required String title,
    required String body,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      final batch = _firestore.batch();
      int sentCount = 0;

      for (final userId in userIds) {
        // Check user notification preferences
        final shouldSend = await _checkUserNotificationPreferences(userId, NotificationType.adminAnnouncement);
        if (!shouldSend) continue;

        final notification = NotificationModel(
          id: '', // Will be set by Firestore
          recipientId: userId,
          title: title,
          body: body,
          type: NotificationType.adminAnnouncement,
          senderName: 'Wanderlust Team',
          actionUrl: actionUrl,
          metadata: metadata ?? {},
          priority: priority,
          isRead: false,
          createdAt: DateTime.now(),
        );

        final docRef = _firestore.collection(_notificationsCollection).doc();
        batch.set(docRef, notification.toFirestore());
        sentCount++;
      }

      await batch.commit();
      LoggerService.i('Group notification sent to $sentCount users');
      return true;
    } catch (e) {
      LoggerService.e('Failed to send group notification', error: e);
      return false;
    }
  }

  // ============ USER PREFERENCE HANDLING ============

  Future<bool> _checkUserNotificationPreferences(String userId, NotificationType type) async {
    try {
      final userDoc = await _firestore.collection(_usersCollection).doc(userId).get();
      
      if (!userDoc.exists) return false;

      final userData = userDoc.data();
      final notificationSettings = userData?['notificationSettings'] as Map<String, dynamic>?;

      if (notificationSettings == null) return true; // Default: allow all

      // Map notification types to user preference settings
      switch (type) {
        case NotificationType.welcome:
        case NotificationType.businessApproved:
        case NotificationType.businessRejected:
        case NotificationType.businessPending:
        case NotificationType.bookingConfirmed:
        case NotificationType.bookingCancelled:
          return notificationSettings['push'] ?? true;
        
        case NotificationType.blogLike:
        case NotificationType.blogComment:
        case NotificationType.userFollow:
          return notificationSettings['push'] ?? true;
        
        case NotificationType.adminAnnouncement:
          return notificationSettings['marketing'] ?? false;
        
        default:
          return notificationSettings['push'] ?? true;
      }
    } catch (e) {
      LoggerService.w('Failed to check user notification preferences, allowing by default', error: e);
      return true; // Default: allow notification if check fails
    }
  }

  // ============ UTILITY METHODS ============

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get filtered notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return notifications.where((n) => n.type == type).toList();
  }

  /// Get today's notifications
  List<NotificationModel> get todayNotifications {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return notifications.where((n) {
      return n.createdAt.isAfter(todayStart);
    }).toList();
  }

  /// Get this week's notifications
  List<NotificationModel> get weekNotifications {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekAgo = now.subtract(const Duration(days: 7));

    return notifications.where((n) {
      return n.createdAt.isBefore(todayStart) && n.createdAt.isAfter(weekAgo);
    }).toList();
  }

  /// Get older notifications
  List<NotificationModel> get olderNotifications {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    return notifications.where((n) {
      return n.createdAt.isBefore(weekAgo);
    }).toList();
  }

  @override
  void onClose() {
    _stopListeningToNotifications();
    LoggerService.i('NotificationService disposed');
    super.onClose();
  }
}