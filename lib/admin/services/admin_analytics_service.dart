import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/core/utils/logger_service.dart';

class AdminAnalyticsService extends GetxService {
  static AdminAnalyticsService get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Real-time analytics data
  final RxMap<String, dynamic> _dashboardStats = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> _recentActivities = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> _userAnalytics = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _businessAnalytics = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _contentAnalytics = <String, dynamic>{}.obs;
  
  // Getters
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  Map<String, dynamic> get userAnalytics => _userAnalytics;
  Map<String, dynamic> get businessAnalytics => _businessAnalytics;
  Map<String, dynamic> get contentAnalytics => _contentAnalytics;
  
  @override
  void onInit() {
    super.onInit();
    loadDashboardStats();
    loadRecentActivities();
    _setupRealTimeListeners();
  }
  
  Future<void> loadDashboardStats() async {
    try {
      final stats = await Future.wait([
        _getTotalUsers(),
        _getTotalBusinesses(),
        _getTotalBlogs(),
        _getTotalBookings(),
        _getMonthlyRevenue(),
        _getActiveUsers(),
      ]);
      
      _dashboardStats.value = {
        'totalUsers': stats[0],
        'totalBusinesses': stats[1],
        'totalBlogs': stats[2],
        'totalBookings': stats[3],
        'monthlyRevenue': stats[4],
        'activeUsers': stats[5],
        'lastUpdated': DateTime.now(),
      };
      
      LoggerService.i('Dashboard stats loaded');
    } catch (e) {
      LoggerService.e('Error loading dashboard stats', error: e);
    }
  }
  
  Future<int> _getTotalUsers() async {
    final snapshot = await _firestore.collection('users').count().get();
    return snapshot.count ?? 0;
  }
  
  Future<int> _getTotalBusinesses() async {
    final snapshot = await _firestore.collection('businesses').count().get();
    return snapshot.count ?? 0;
  }
  
  Future<int> _getTotalBlogs() async {
    final snapshot = await _firestore.collection('blogs').count().get();
    return snapshot.count ?? 0;
  }
  
  Future<int> _getTotalBookings() async {
    final snapshot = await _firestore.collection('bookings').count().get();
    return snapshot.count ?? 0;
  }
  
  Future<double> _getMonthlyRevenue() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final snapshot = await _firestore
        .collection('bookings')
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('status', isEqualTo: 'completed')
        .get();
    
    double revenue = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      revenue += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
    }
    
    return revenue;
  }
  
  Future<int> _getActiveUsers() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final snapshot = await _firestore
        .collection('users')
        .where('lastActiveAt', isGreaterThanOrEqualTo: sevenDaysAgo)
        .count()
        .get();
    
    return snapshot.count ?? 0;
  }
  
  Future<void> loadRecentActivities() async {
    try {
      final activities = <Map<String, dynamic>>[];
      
      // Get recent user registrations
      final recentUsers = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      
      for (final doc in recentUsers.docs) {
        activities.add({
          'type': 'user_registration',
          'title': 'New user registered',
          'description': 'User ${doc.data()['name']} joined the platform',
          'timestamp': doc.data()['createdAt'],
          'icon': 'person_add',
          'color': 'success',
        });
      }
      
      // Get recent business registrations
      final recentBusinesses = await _firestore
          .collection('businesses')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      
      for (final doc in recentBusinesses.docs) {
        activities.add({
          'type': 'business_registration',
          'title': 'New business registered',
          'description': 'Business ${doc.data()['name']} requested approval',
          'timestamp': doc.data()['createdAt'],
          'icon': 'business',
          'color': 'info',
        });
      }
      
      // Get recent blog posts
      final recentBlogs = await _firestore
          .collection('blogs')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      
      for (final doc in recentBlogs.docs) {
        activities.add({
          'type': 'blog_post',
          'title': 'New blog post',
          'description': 'Blog "${doc.data()['title']}" was published',
          'timestamp': doc.data()['createdAt'],
          'icon': 'article',
          'color': 'primary',
        });
      }
      
      // Sort by timestamp and take latest 10
      activities.sort((a, b) {
        final aTime = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });
      
      _recentActivities.value = activities.take(10).toList();
      LoggerService.i('Recent activities loaded: ${activities.length}');
    } catch (e) {
      LoggerService.e('Error loading recent activities', error: e);
    }
  }
  
  void _setupRealTimeListeners() {
    // Listen to user count changes
    _firestore.collection('users').snapshots().listen((snapshot) {
      if (_dashboardStats.isNotEmpty) {
        _dashboardStats['totalUsers'] = snapshot.docs.length;
      }
    });
    
    // Listen to business count changes
    _firestore.collection('businesses').snapshots().listen((snapshot) {
      if (_dashboardStats.isNotEmpty) {
        _dashboardStats['totalBusinesses'] = snapshot.docs.length;
      }
    });
    
    // Listen to blog count changes
    _firestore.collection('blogs').snapshots().listen((snapshot) {
      if (_dashboardStats.isNotEmpty) {
        _dashboardStats['totalBlogs'] = snapshot.docs.length;
      }
    });
  }
  
  // User Analytics
  Future<Map<String, dynamic>> getUserAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // User registrations over time
      final registrations = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .orderBy('createdAt')
          .get();
      
      // Group by day
      final registrationsByDay = <String, int>{};
      for (final doc in registrations.docs) {
        final date = (doc.data()['createdAt'] as Timestamp).toDate();
        final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        registrationsByDay[dayKey] = (registrationsByDay[dayKey] ?? 0) + 1;
      }
      
      return {
        'totalRegistrations': registrations.docs.length,
        'registrationsByDay': registrationsByDay,
        'averageDaily': registrations.docs.length / (endDate.difference(startDate).inDays + 1),
      };
    } catch (e) {
      LoggerService.e('Error getting user analytics', error: e);
      return {};
    }
  }
  
  // Business Analytics
  Future<Map<String, dynamic>> getBusinessAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final businesses = await _firestore
          .collection('businesses')
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .get();
      
      final approved = businesses.docs.where((doc) => 
          doc.data()['verificationStatus'] == 'approved').length;
      final pending = businesses.docs.where((doc) => 
          doc.data()['verificationStatus'] == 'pending').length;
      final rejected = businesses.docs.where((doc) => 
          doc.data()['verificationStatus'] == 'rejected').length;
      
      return {
        'totalBusinesses': businesses.docs.length,
        'approved': approved,
        'pending': pending,
        'rejected': rejected,
        'approvalRate': businesses.docs.isNotEmpty ? (approved / businesses.docs.length) * 100 : 0,
      };
    } catch (e) {
      LoggerService.e('Error getting business analytics', error: e);
      return {};
    }
  }
  
  // Export data for external analysis
  Future<Map<String, dynamic>> exportAnalyticsData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userAnalytics = await getUserAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      
      final businessAnalytics = await getBusinessAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      
      return {
        'exportDate': DateTime.now().toIso8601String(),
        'dateRange': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
        'userAnalytics': userAnalytics,
        'businessAnalytics': businessAnalytics,
        'dashboardStats': _dashboardStats,
      };
    } catch (e) {
      LoggerService.e('Error exporting analytics data', error: e);
      return {};
    }
  }
}