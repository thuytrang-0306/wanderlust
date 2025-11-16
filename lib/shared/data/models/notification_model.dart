import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for different types of notifications in the app
enum NotificationType {
  // System & Onboarding
  welcome('welcome'),
  systemUpdate('system_update'),
  maintenance('maintenance'),
  
  // Authentication & Profile
  emailVerified('email_verified'),
  profileCompleted('profile_completed'),
  
  // Business Related
  businessPending('business_pending'),
  businessApproved('business_approved'),
  businessRejected('business_rejected'),
  businessSuspended('business_suspended'),
  
  // Content & Blog
  blogPublished('blog_published'),
  blogApproved('blog_approved'),
  blogRejected('blog_rejected'),
  blogLike('blog_like'),
  blogComment('blog_comment'),
  blogShared('blog_shared'),
  
  // Social Interactions
  userFollow('user_follow'),
  userMention('user_mention'),
  friendRequest('friend_request'),
  
  // Booking & Travel
  bookingConfirmed('booking_confirmed'),
  bookingCancelled('booking_cancelled'),
  bookingReminder('booking_reminder'),
  paymentDue('payment_due'),
  paymentConfirmed('payment_confirmed'),
  refundProcessed('refund_processed'),
  
  // Reviews & Ratings
  reviewReceived('review_received'),
  reviewRequest('review_request'),
  
  // Trip & Itinerary
  tripShared('trip_shared'),
  tripInvite('trip_invite'),
  tripReminder('trip_reminder'),
  
  // Admin & Announcements
  adminAnnouncement('admin_announcement'),
  policyUpdate('policy_update'),
  
  // Promotions & Marketing
  promotion('promotion'),
  newsletter('newsletter'),
  recommendation('recommendation');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.adminAnnouncement,
    );
  }

  /// Get user-friendly display name for notification type
  String get displayName {
    switch (this) {
      case NotificationType.welcome:
        return 'Chào mừng';
      case NotificationType.businessApproved:
        return 'Kinh doanh phê duyệt';
      case NotificationType.businessRejected:
        return 'Kinh doanh từ chối';
      case NotificationType.businessPending:
        return 'Kinh doanh chờ duyệt';
      case NotificationType.blogLike:
        return 'Blog được thích';
      case NotificationType.blogComment:
        return 'Bình luận blog';
      case NotificationType.userFollow:
        return 'Người theo dõi';
      case NotificationType.bookingConfirmed:
        return 'Đặt chỗ xác nhận';
      case NotificationType.bookingCancelled:
        return 'Đặt chỗ hủy';
      case NotificationType.adminAnnouncement:
        return 'Thông báo';
      default:
        return 'Thông báo';
    }
  }

  /// Get icon for notification type
  String get icon {
    switch (this) {
      case NotificationType.welcome:
        return '🎉';
      case NotificationType.businessApproved:
        return '✅';
      case NotificationType.businessRejected:
        return '❌';
      case NotificationType.businessPending:
        return '⏳';
      case NotificationType.blogLike:
        return '👍';
      case NotificationType.blogComment:
        return '💬';
      case NotificationType.userFollow:
        return '👥';
      case NotificationType.bookingConfirmed:
        return '🎫';
      case NotificationType.bookingCancelled:
        return '❌';
      case NotificationType.adminAnnouncement:
        return '📢';
      case NotificationType.paymentConfirmed:
        return '💳';
      case NotificationType.reviewReceived:
        return '⭐';
      case NotificationType.tripShared:
        return '🗺️';
      case NotificationType.promotion:
        return '🎁';
      default:
        return '🔔';
    }
  }
}

/// Enum for notification priority levels
enum NotificationPriority {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');

  final String value;
  const NotificationPriority(this.value);

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.normal,
    );
  }
}

/// Comprehensive notification model for the Wanderlust app
class NotificationModel {
  final String id;
  final String recipientId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  
  // Sender information (optional, for user-to-user notifications)
  final String? senderId;
  final String? senderName;
  final String? senderAvatar;
  
  // Action & Navigation
  final String? actionUrl; // Deep link or route to navigate when tapped
  final Map<String, dynamic> metadata; // Additional data for the notification
  
  // Status & Timestamps
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? expiresAt; // For temporary notifications
  
  // Delivery tracking
  final bool isDelivered;
  final DateTime? deliveredAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.senderId,
    this.senderName,
    this.senderAvatar,
    this.actionUrl,
    this.metadata = const {},
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.expiresAt,
    this.isDelivered = false,
    this.deliveredAt,
  });

  /// Create NotificationModel from Firestore document
  static NotificationModel? fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      return NotificationModel(
        id: doc.id,
        recipientId: data['recipientId'] ?? '',
        title: data['title'] ?? '',
        body: data['body'] ?? '',
        type: NotificationType.fromString(data['type'] ?? 'admin_announcement'),
        priority: NotificationPriority.fromString(data['priority'] ?? 'normal'),
        senderId: data['senderId'],
        senderName: data['senderName'],
        senderAvatar: data['senderAvatar'],
        actionUrl: data['actionUrl'],
        metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
        isRead: data['isRead'] ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        readAt: (data['readAt'] as Timestamp?)?.toDate(),
        expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
        isDelivered: data['isDelivered'] ?? false,
        deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      // Log error but don't crash the app
      // Note: Using print here since this is a model class without access to LoggerService
      print('Error parsing notification from Firestore: $e');
      return null;
    }
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'title': title,
      'body': body,
      'type': type.value,
      'priority': priority.value,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'actionUrl': actionUrl,
      'metadata': metadata,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
      'readAt': readAt,
      'expiresAt': expiresAt,
      'isDelivered': isDelivered,
      'deliveredAt': deliveredAt,
    };
  }

  /// Create from JSON (for local storage or API)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      recipientId: json['recipientId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: NotificationType.fromString(json['type'] ?? 'admin_announcement'),
      priority: NotificationPriority.fromString(json['priority'] ?? 'normal'),
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderAvatar: json['senderAvatar'],
      actionUrl: json['actionUrl'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      isDelivered: json['isDelivered'] ?? false,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientId': recipientId,
      'title': title,
      'body': body,
      'type': type.value,
      'priority': priority.value,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'actionUrl': actionUrl,
      'metadata': metadata,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isDelivered': isDelivered,
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  /// Copy with modifications
  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? expiresAt,
    bool? isDelivered,
    DateTime? deliveredAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isDelivered: isDelivered ?? this.isDelivered,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  /// Check if notification is unread
  bool get isUnread => !isRead;

  /// Check if notification has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get time ago string (e.g., "2 hours ago", "1 day ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    }
  }

  /// Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (notificationDate == today) {
      return 'Hôm nay ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (notificationDate == yesterday) {
      return 'Hôm qua ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Check if this is a system notification (no specific sender)
  bool get isSystemNotification => senderId == null;

  /// Check if this is a user-to-user notification
  bool get isUserNotification => senderId != null;

  /// Get notification category for grouping
  String get category {
    switch (type) {
      case NotificationType.welcome:
      case NotificationType.systemUpdate:
      case NotificationType.maintenance:
        return 'Hệ thống';
      
      case NotificationType.businessPending:
      case NotificationType.businessApproved:
      case NotificationType.businessRejected:
      case NotificationType.businessSuspended:
        return 'Kinh doanh';
      
      case NotificationType.blogLike:
      case NotificationType.blogComment:
      case NotificationType.blogPublished:
      case NotificationType.blogApproved:
      case NotificationType.blogRejected:
        return 'Blog & Nội dung';
      
      case NotificationType.userFollow:
      case NotificationType.userMention:
      case NotificationType.friendRequest:
        return 'Mạng xã hội';
      
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingCancelled:
      case NotificationType.bookingReminder:
      case NotificationType.paymentDue:
      case NotificationType.paymentConfirmed:
      case NotificationType.refundProcessed:
        return 'Đặt chỗ & Thanh toán';
      
      case NotificationType.reviewReceived:
      case NotificationType.reviewRequest:
        return 'Đánh giá';
      
      case NotificationType.tripShared:
      case NotificationType.tripInvite:
      case NotificationType.tripReminder:
        return 'Chuyến đi';
      
      case NotificationType.adminAnnouncement:
      case NotificationType.policyUpdate:
        return 'Thông báo chung';
      
      case NotificationType.promotion:
      case NotificationType.newsletter:
      case NotificationType.recommendation:
        return 'Khuyến mãi';
      
      default:
        return 'Khác';
    }
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: ${type.value}, title: $title, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}