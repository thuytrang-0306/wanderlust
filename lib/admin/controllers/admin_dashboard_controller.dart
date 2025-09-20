import 'dart:async';
import 'package:get/get.dart';
import '../services/admin_analytics_service.dart';
import '../services/admin_export_service.dart';
import '../services/admin_auth_service.dart';
import '../../shared/core/services/user_service.dart';
import '../../shared/data/services/blog_service.dart';
import '../../shared/data/services/business_service.dart';
import '../../shared/core/utils/logger_service.dart';
import '../../shared/core/widgets/app_snackbar.dart';

class AdminDashboardController extends GetxController {
  final AdminAnalyticsService _analyticsService = Get.find<AdminAnalyticsService>();
  final AdminExportService _exportService = Get.find<AdminExportService>();
  final AdminAuthService _authService = Get.find<AdminAuthService>();
  final UserService _userService = Get.find<UserService>();
  final BlogService _blogService = Get.find<BlogService>();
  final BusinessService _businessService = Get.find<BusinessService>();
  
  // State
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString selectedTimeRange = '30days'.obs; // 7days, 30days, 90days, 1year
  
  // Dashboard Stats
  final RxMap<String, dynamic> dashboardStats = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> recentActivities = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> chartData = <Map<String, dynamic>>[].obs;
  
  // Quick Access Stats
  final RxInt totalUsers = 0.obs;
  final RxInt activeUsers = 0.obs;
  final RxInt newUsersToday = 0.obs;
  final RxInt totalBusinesses = 0.obs;
  final RxInt pendingBusinesses = 0.obs;
  final RxInt totalBlogs = 0.obs;
  final RxInt pendingBlogs = 0.obs;
  final RxInt totalRevenue = 0.obs;
  final RxDouble growthRate = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadDashboard();
    _setupRealtimeUpdates();
    LoggerService.i('AdminDashboardController initialized');
  }

  void _setupRealtimeUpdates() {
    // Update dashboard every 30 seconds
    ever(selectedTimeRange, (_) => loadDashboard());
    
    // Listen to UserService statistics updates
    ever(_userService.totalUsers, (int value) => totalUsers.value = value);
    ever(_userService.activeUsers, (int value) => activeUsers.value = value);
    ever(_userService.newUsersToday, (int value) => newUsersToday.value = value);
  }
  
  Future<void> loadDashboard() async {
    if (isLoading.value) return; // Prevent multiple concurrent loads
    
    isLoading.value = true;
    
    try {
      LoggerService.i('Loading dashboard data for timeRange: ${selectedTimeRange.value}');
      
      // Load all statistics in parallel for better performance
      await Future.wait([
        _loadUserStatistics(),
        _loadBusinessStatistics(),
        _loadContentStatistics(),
        _loadRevenueStatistics(),
        _loadRecentActivities(),
        _loadChartData(),
      ]);
      
      LoggerService.i('Dashboard loaded successfully');
    } catch (e, stackTrace) {
      LoggerService.e('Error loading dashboard', error: e, stackTrace: stackTrace);
      AppSnackbar.showError(
        message: 'Failed to load dashboard data: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserStatistics() async {
    try {
      // UserService already provides real-time stats
      totalUsers.value = _userService.totalUsers.value;
      activeUsers.value = _userService.activeUsers.value;
      newUsersToday.value = _userService.newUsersToday.value;
      
      LoggerService.d('User statistics loaded: ${totalUsers.value} total, ${activeUsers.value} active');
    } catch (e) {
      LoggerService.e('Error loading user statistics', error: e);
    }
  }

  Future<void> _loadBusinessStatistics() async {
    try {
      // Load business statistics from BusinessService
      totalBusinesses.value = 0; // TODO: Implement in BusinessService
      pendingBusinesses.value = 0; // TODO: Implement in BusinessService
      
      LoggerService.d('Business statistics loaded');
    } catch (e) {
      LoggerService.e('Error loading business statistics', error: e);
    }
  }

  Future<void> _loadContentStatistics() async {
    try {
      // Load content statistics from BlogService
      totalBlogs.value = 0; // TODO: Implement in BlogService
      pendingBlogs.value = 0; // TODO: Implement in BlogService
      
      LoggerService.d('Content statistics loaded');
    } catch (e) {
      LoggerService.e('Error loading content statistics', error: e);
    }
  }

  Future<void> _loadRevenueStatistics() async {
    try {
      // Load revenue statistics
      totalRevenue.value = 0; // TODO: Implement revenue calculation
      growthRate.value = 0.0; // TODO: Implement growth rate calculation
      
      LoggerService.d('Revenue statistics loaded');
    } catch (e) {
      LoggerService.e('Error loading revenue statistics', error: e);
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      // Load recent admin activities
      final activities = await _authService.getAdminActivityLogs(limit: 20);
      recentActivities.value = activities;
      
      LoggerService.d('Recent activities loaded: ${activities.length} items');
    } catch (e) {
      LoggerService.e('Error loading recent activities', error: e);
    }
  }

  Future<void> _loadChartData() async {
    try {
      // Generate chart data based on selected time range
      final now = DateTime.now();
      final days = _getDaysFromTimeRange();
      final startDate = now.subtract(Duration(days: days));
      
      // Mock chart data for now
      chartData.value = _generateMockChartData(startDate, now);
      
      LoggerService.d('Chart data loaded for ${days} days');
    } catch (e) {
      LoggerService.e('Error loading chart data', error: e);
    }
  }

  int _getDaysFromTimeRange() {
    switch (selectedTimeRange.value) {
      case '7days':
        return 7;
      case '30days':
        return 30;
      case '90days':
        return 90;
      case '1year':
        return 365;
      default:
        return 30;
    }
  }

  List<Map<String, dynamic>> _generateMockChartData(DateTime startDate, DateTime endDate) {
    final data = <Map<String, dynamic>>[];
    final difference = endDate.difference(startDate).inDays;
    
    for (int i = 0; i <= difference; i++) {
      final date = startDate.add(Duration(days: i));
      data.add({
        'date': date.toIso8601String().split('T')[0],
        'users': 10 + (i * 2) + (i % 7 * 5), // Mock user growth
        'revenue': 1000 + (i * 50) + (i % 5 * 200), // Mock revenue
        'businesses': 5 + (i ~/ 7), // Mock business growth
        'content': 8 + (i * 3) + (i % 3 * 2), // Mock content creation
      });
    }
    
    return data;
  }
  
  Future<void> refreshDashboard() async {
    if (isRefreshing.value) return; // Prevent multiple refreshes
    
    isRefreshing.value = true;
    AppSnackbar.showInfo(message: 'Refreshing dashboard...');
    
    try {
      // Force refresh UserService data
      await _userService.refreshData();
      
      // Reload dashboard
      await loadDashboard();
      
      AppSnackbar.showSuccess(message: 'Dashboard refreshed successfully');
      LoggerService.i('Dashboard refreshed successfully');
    } catch (e, stackTrace) {
      LoggerService.e('Error refreshing dashboard', error: e, stackTrace: stackTrace);
      AppSnackbar.showError(message: 'Failed to refresh dashboard');
    } finally {
      isRefreshing.value = false;
    }
  }

  void changeTimeRange(String newTimeRange) {
    if (selectedTimeRange.value != newTimeRange) {
      selectedTimeRange.value = newTimeRange;
      LoggerService.d('Time range changed to: $newTimeRange');
    }
  }

  // Get dashboard summary data
  Map<String, dynamic> getDashboardSummary() {
    return {
      'totalUsers': totalUsers.value,
      'activeUsers': activeUsers.value,
      'newUsersToday': newUsersToday.value,
      'totalBusinesses': totalBusinesses.value,
      'pendingBusinesses': pendingBusinesses.value,
      'totalBlogs': totalBlogs.value,
      'pendingBlogs': pendingBlogs.value,
      'totalRevenue': totalRevenue.value,
      'growthRate': growthRate.value,
      'timeRange': selectedTimeRange.value,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  // Export dashboard data in various formats
  Future<void> exportDashboardData({String format = 'json'}) async {
    if (!_authService.hasPermission('export_data')) {
      AppSnackbar.showError(message: 'Permission denied: export_data');
      return;
    }

    try {
      LoggerService.i('Exporting dashboard data in $format format');
      
      final dashboardData = {
        'summary': getDashboardSummary(),
        'chartData': chartData.value,
        'recentActivities': recentActivities.take(10).toList(),
        'userStatistics': {
          'total': totalUsers.value,
          'active': activeUsers.value,
          'newToday': newUsersToday.value,
          'newThisWeek': _userService.newUsersThisWeek.value,
          'newThisMonth': _userService.newUsersThisMonth.value,
        },
        'exportedAt': DateTime.now().toIso8601String(),
        'exportedBy': _authService.currentAdmin?.name,
      };

      switch (format.toLowerCase()) {
        case 'json':
          await _exportService.exportAnalyticsToJSON(dashboardData);
          break;
        case 'csv':
          await _exportService.exportAnalyticsToCSV(dashboardData);
          break;
        default:
          throw Exception('Unsupported export format: $format');
      }
      
      AppSnackbar.showSuccess(
        message: 'Dashboard data exported as $format successfully',
      );
      LoggerService.i('Dashboard data exported successfully');
    } catch (e, stackTrace) {
      LoggerService.e('Error exporting dashboard data', error: e, stackTrace: stackTrace);
      AppSnackbar.showError(
        message: 'Failed to export dashboard data: ${e.toString()}',
      );
    }
  }

  // Get quick stats for cards
  List<Map<String, dynamic>> getQuickStatsCards() {
    return [
      {
        'title': 'Total Users',
        'value': totalUsers.value.toString(),
        'subtitle': '${newUsersToday.value} new today',
        'icon': 'users',
        'color': '#2196F3',
        'trend': '+${(growthRate.value * 100).toStringAsFixed(1)}%',
      },
      {
        'title': 'Active Users',
        'value': activeUsers.value.toString(),
        'subtitle': '${((activeUsers.value / (totalUsers.value == 0 ? 1 : totalUsers.value)) * 100).toInt()}% of total',
        'icon': 'user_check',
        'color': '#4CAF50',
        'trend': 'Active',
      },
      {
        'title': 'Businesses',
        'value': totalBusinesses.value.toString(),
        'subtitle': '${pendingBusinesses.value} pending approval',
        'icon': 'business',
        'color': '#FF9800',
        'trend': pendingBusinesses.value > 0 ? 'Needs Review' : 'All Approved',
      },
      {
        'title': 'Content',
        'value': totalBlogs.value.toString(),
        'subtitle': '${pendingBlogs.value} pending review',
        'icon': 'article',
        'color': '#9C27B0',
        'trend': pendingBlogs.value > 0 ? 'Needs Moderation' : 'All Reviewed',
      },
      {
        'title': 'Revenue',
        'value': '\$${(totalRevenue.value / 1000).toStringAsFixed(1)}K',
        'subtitle': 'This ${selectedTimeRange.value.replaceAll('days', ' days')}',
        'icon': 'monetization_on',
        'color': '#00BCD4',
        'trend': '+${(growthRate.value * 100).toStringAsFixed(1)}%',
      },
    ];
  }

  // Start auto-refresh timer
  void startAutoRefresh() {
    // Refresh every 5 minutes
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (Get.isRegistered<AdminDashboardController>()) {
        refreshDashboard();
      } else {
        timer.cancel();
      }
    });
  }

  // Trend calculation methods
  String getTotalUsersTrend() {
    // Mock implementation - calculate trend based on growth
    final trend = growthRate.value * 100;
    return trend > 0 ? '+${trend.toStringAsFixed(1)}%' : '${trend.toStringAsFixed(1)}%';
  }
  
  String getActiveUsersTrend() {
    // Mock implementation - active users trend
    final activePercentage = totalUsers.value > 0 
        ? (activeUsers.value / totalUsers.value * 100) 
        : 0.0;
    return '+${activePercentage.toStringAsFixed(1)}%';
  }
  
  String getNewUsersTrend() {
    // Mock implementation - new users trend
    return newUsersToday.value > 10 ? '+15.2%' : '+8.5%';
  }
  
  String getBannedUsersTrend() {
    // Mock implementation - banned users trend (should be low)
    return '0%';
  }

  @override
  void onClose() {
    LoggerService.i('AdminDashboardController disposed');
    super.onClose();
  }
}