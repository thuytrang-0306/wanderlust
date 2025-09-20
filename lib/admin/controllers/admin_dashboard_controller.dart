import 'package:get/get.dart';
import '../services/admin_analytics_service.dart';
import '../services/admin_export_service.dart';
import '../../shared/core/utils/logger_service.dart';
import '../../shared/core/widgets/app_snackbar.dart';

class AdminDashboardController extends GetxController {
  final AdminAnalyticsService _analyticsService = Get.find<AdminAnalyticsService>();
  final AdminExportService _exportService = Get.find<AdminExportService>();
  
  // State
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> dashboardStats = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> recentActivities = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }
  
  Future<void> loadDashboard() async {
    isLoading.value = true;
    
    try {
      // Load dashboard stats
      await _analyticsService.loadDashboardStats();
      dashboardStats.value = _analyticsService.dashboardStats;
      
      // Load recent activities
      await _analyticsService.loadRecentActivities();
      recentActivities.value = _analyticsService.recentActivities;
      
      LoggerService.i('Dashboard loaded successfully');
    } catch (e) {
      LoggerService.e('Error loading dashboard', error: e);
      AppSnackbar.showError(
        message: 'Failed to load dashboard data',
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> refreshDashboard() async {
    AppSnackbar.showInfo(message: 'Refreshing dashboard...');
    await loadDashboard();
    AppSnackbar.showSuccess(message: 'Dashboard refreshed');
  }
  
  Future<void> exportDashboardData() async {
    try {
      final analyticsData = await _analyticsService.exportAnalyticsData(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );
      
      await _exportService.exportAnalyticsToJSON(analyticsData);
      
      AppSnackbar.showSuccess(
        message: 'Dashboard data exported successfully',
      );
    } catch (e) {
      LoggerService.e('Error exporting dashboard data', error: e);
      AppSnackbar.showError(
        message: 'Failed to export dashboard data',
      );
    }
  }
}