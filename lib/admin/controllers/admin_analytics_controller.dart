import 'package:get/get.dart';
import 'package:wanderlust/shared/core/services/user_service.dart';
import 'package:wanderlust/shared/core/utils/logger_service.dart';

class AdminAnalyticsController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  
  // UI state
  final RxBool isLoading = false.obs;
  final RxString selectedTimeRange = '30days'.obs;
  final RxString selectedMetric = 'users'.obs;
  
  // Analytics data
  final RxList<Map<String, dynamic>> userAnalytics = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> engagementData = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> retentionData = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> platformStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
    LoggerService.i('AdminAnalyticsController initialized');
  }

  Future<void> loadAnalytics() async {
    try {
      isLoading.value = true;
      LoggerService.i('Loading analytics data for timeRange: ${selectedTimeRange.value}');
      
      await Future.wait([
        _loadUserAnalytics(),
        _loadEngagementData(),
        _loadRetentionData(),
        _loadPlatformStats(),
      ]);
      
      LoggerService.i('Analytics data loaded successfully');
    } catch (e) {
      LoggerService.e('Error loading analytics', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserAnalytics() async {
    // Generate user analytics data based on real user data
    final now = DateTime.now();
    final days = _getDaysFromTimeRange();
    final analytics = <Map<String, dynamic>>[];
    
    final totalUsers = _userService.totalUsers.value;
    final baseUsers = (totalUsers * 0.7).round(); // Assume 70% of users joined in the period
    
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final growth = (baseUsers / days) + (i % 3 == 0 ? 2 : 0); // Some variance
      
      analytics.add({
        'date': date.toIso8601String().split('T')[0],
        'newUsers': growth.round(),
        'totalUsers': baseUsers + (days - i) * (growth / days).round(),
        'activeUsers': ((baseUsers + (days - i) * (growth / days).round()) * 0.65).round(),
      });
    }
    
    userAnalytics.value = analytics;
  }

  Future<void> _loadEngagementData() async {
    // Generate engagement data
    final now = DateTime.now();
    final days = _getDaysFromTimeRange();
    final engagement = <Map<String, dynamic>>[];
    
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final baseEngagement = 65 + (i % 7) * 5; // Weekly pattern
      
      engagement.add({
        'date': date.toIso8601String().split('T')[0],
        'engagement': baseEngagement,
        'sessions': (200 + i * 5).round(),
        'avgSessionTime': (180 + (i % 5) * 30).round(), // in seconds
      });
    }
    
    engagementData.value = engagement;
  }

  Future<void> _loadRetentionData() async {
    // Generate retention data
    retentionData.value = [
      {'period': 'Day 1', 'retention': 85},
      {'period': 'Day 7', 'retention': 65},
      {'period': 'Day 30', 'retention': 45},
      {'period': 'Day 90', 'retention': 25},
    ];
  }

  Future<void> _loadPlatformStats() async {
    // Platform usage statistics
    platformStats.value = {
      'mobile': {
        'users': (_userService.totalUsers.value * 0.85).round(),
        'percentage': 85,
        'growth': '+12%',
      },
      'web': {
        'users': (_userService.totalUsers.value * 0.15).round(),
        'percentage': 15,
        'growth': '+8%',
      },
      'platforms': [
        {'name': 'Android', 'users': (_userService.totalUsers.value * 0.60).round(), 'color': 0xFF4CAF50},
        {'name': 'iOS', 'users': (_userService.totalUsers.value * 0.25).round(), 'color': 0xFF2196F3},
        {'name': 'Web', 'users': (_userService.totalUsers.value * 0.15).round(), 'color': 0xFFFF9800},
      ],
    };
  }

  int _getDaysFromTimeRange() {
    switch (selectedTimeRange.value) {
      case '7days':
        return 7;
      case '30days':
        return 30;
      case '90days':
        return 90;
      default:
        return 30;
    }
  }

  void onTimeRangeChanged(String timeRange) {
    if (selectedTimeRange.value != timeRange) {
      selectedTimeRange.value = timeRange;
      loadAnalytics();
    }
  }

  void onMetricChanged(String metric) {
    if (selectedMetric.value != metric) {
      selectedMetric.value = metric;
      LoggerService.i('Analytics metric changed to: $metric');
    }
  }

  Future<void> refreshAnalytics() async {
    LoggerService.i('Refreshing analytics data');
    await loadAnalytics();
  }

  Future<void> exportAnalyticsData() async {
    try {
      LoggerService.i('Exporting analytics data');
      
      // Create comprehensive analytics export
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'timeRange': selectedTimeRange.value,
        'userAnalytics': userAnalytics,
        'engagementData': engagementData,
        'retentionData': retentionData,
        'platformStats': platformStats,
        'summary': {
          'totalUsers': _userService.totalUsers.value,
          'activeUsers': _userService.activeUsers.value,
          'newUsersToday': _userService.newUsersToday.value,
          'bannedUsers': _userService.bannedUsers.value,
        },
      };
      
      // Note: Actual export implementation would be added here
      LoggerService.i('Analytics export prepared: ${exportData.length} data points');
      
    } catch (e) {
      LoggerService.e('Error exporting analytics data', error: e);
    }
  }

  // Computed properties for UI
  double get userGrowthRate {
    if (userAnalytics.length < 2) return 0.0;
    final first = userAnalytics.first['newUsers'] as int;
    final last = userAnalytics.last['newUsers'] as int;
    return last > 0 ? ((first - last) / last * 100) : 0.0;
  }

  double get engagementRate {
    if (engagementData.isEmpty) return 0.0;
    final total = engagementData.fold<int>(0, (sum, item) => sum + (item['engagement'] as int));
    return total / engagementData.length;
  }

  String get averageSessionTime {
    if (engagementData.isEmpty) return '0m';
    final total = engagementData.fold<int>(0, (sum, item) => sum + (item['avgSessionTime'] as int));
    final avgSeconds = total / engagementData.length;
    final minutes = (avgSeconds / 60).round();
    return '${minutes}m';
  }
}