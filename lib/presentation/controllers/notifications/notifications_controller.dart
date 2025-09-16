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
    _loadFakeNotifications();
  }
  
  void _loadFakeNotifications() {
    // Fake data matching the design
    final now = DateTime.now();
    
    notifications.value = [
      // Today notifications
      NotificationModel(
        id: '1',
        userName: 'Thế Hùng',
        avatar: 'https://i.pravatar.cc/150?img=1',
        time: 'Đã thích bài viết của bạn . 1 giờ trước',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin mattis...',
        isUnread: true,
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '2',
        userName: 'Justin Barbie',
        avatar: 'https://i.pravatar.cc/150?img=2',
        time: 'Vừa đăng 1 bài viết mới . 30 phút trước',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin mattis...',
        isUnread: false,
        timestamp: now.subtract(const Duration(minutes: 30)),
      ),
      
      // 7 days ago notifications
      NotificationModel(
        id: '3',
        userName: 'Homestray Holan',
        avatar: 'https://i.pravatar.cc/150?img=3',
        time: 'Xác nhận bạn đã thanh toán thành công . 120/12',
        content: '',
        isUnread: false,
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      NotificationModel(
        id: '4',
        userName: 'Thế Hùng',
        avatar: 'https://i.pravatar.cc/150?img=1',
        time: 'Đã thích bài viết của bạn . 1 giờ trước',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin mattis...',
        isUnread: true,
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      NotificationModel(
        id: '5',
        userName: 'Justin Barbie',
        avatar: 'https://i.pravatar.cc/150?img=2',
        time: 'Vừa đăng 1 bài viết mới . 30 phút trước',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin mattis...',
        isUnread: false,
        timestamp: now.subtract(const Duration(days: 4)),
      ),
      NotificationModel(
        id: '6',
        userName: 'Homestray Holan',
        avatar: 'https://i.pravatar.cc/150?img=3',
        time: 'Xác nhận bạn đã thanh toán thành công . 120/12',
        content: '',
        isUnread: false,
        timestamp: now.subtract(const Duration(days: 5)),
      ),
      NotificationModel(
        id: '7',
        userName: 'Justin Barbie',
        avatar: 'https://i.pravatar.cc/150?img=2',
        time: 'Vừa đăng 1 bài viết mới . 30 phút trước',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin mattis...',
        isUnread: false,
        timestamp: now.subtract(const Duration(days: 6)),
      ),
    ];
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