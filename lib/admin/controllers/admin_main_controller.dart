import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_dashboard_controller.dart';
import 'package:wanderlust/admin/controllers/admin_analytics_controller.dart';
import 'package:wanderlust/admin/controllers/admin_user_management_controller.dart';
import 'package:wanderlust/admin/controllers/admin_business_controller.dart';
import 'package:wanderlust/admin/controllers/admin_content_controller.dart';
import 'package:wanderlust/shared/core/utils/logger_service.dart';

enum AdminTab {
  dashboard,
  analytics,
  users,
  business,
  content,
  settings,
}

class AdminMainController extends GetxController {
  final Rx<AdminTab> currentTab = AdminTab.dashboard.obs;
  
  // Tab titles
  final Map<AdminTab, String> _tabTitles = {
    AdminTab.dashboard: 'Dashboard',
    AdminTab.analytics: 'Analytics',
    AdminTab.users: 'User Management',
    AdminTab.business: 'Business Management',
    AdminTab.content: 'Content Moderation',
    AdminTab.settings: 'Settings',
  };

  String get currentTabTitle => _tabTitles[currentTab.value] ?? 'Dashboard';

  @override
  void onInit() {
    super.onInit();
    LoggerService.i('AdminMainController initialized');
  }

  void changeTab(AdminTab tab) {
    if (currentTab.value != tab) {
      currentTab.value = tab;
      LoggerService.i('Admin tab changed to: ${tab.name}');
      
      // Initialize controllers for tabs that need them
      _ensureControllerExists(tab);
    }
  }

  void _ensureControllerExists(AdminTab tab) {
    try {
      switch (tab) {
        case AdminTab.dashboard:
          Get.find<AdminDashboardController>();
          break;
        case AdminTab.analytics:
          if (!Get.isRegistered<AdminAnalyticsController>()) {
            Get.put(AdminAnalyticsController());
          }
          break;
        case AdminTab.users:
          if (!Get.isRegistered<AdminUserManagementController>()) {
            Get.put(AdminUserManagementController());
          }
          break;
        case AdminTab.business:
          if (!Get.isRegistered<AdminBusinessController>()) {
            Get.put(AdminBusinessController());
          }
          break;
        case AdminTab.content:
          if (!Get.isRegistered<AdminContentController>()) {
            Get.put(AdminContentController());
          }
          break;
        default:
          break;
      }
    } catch (e) {
      LoggerService.e('Error ensuring controller exists for tab: ${tab.name}', error: e);
    }
  }

  void refreshCurrentTab() {
    try {
      switch (currentTab.value) {
        case AdminTab.dashboard:
          final dashboardController = Get.find<AdminDashboardController>();
          dashboardController.refreshDashboard();
          break;
        case AdminTab.analytics:
          if (Get.isRegistered<AdminAnalyticsController>()) {
            final analyticsController = Get.find<AdminAnalyticsController>();
            analyticsController.refreshAnalytics();
          }
          break;
        case AdminTab.users:
          if (Get.isRegistered<AdminUserManagementController>()) {
            final userController = Get.find<AdminUserManagementController>();
            userController.refreshUsers();
          }
          break;
        case AdminTab.business:
          if (Get.isRegistered<AdminBusinessController>()) {
            final businessController = Get.find<AdminBusinessController>();
            businessController.refreshBusinesses();
          }
          break;
        case AdminTab.content:
          if (Get.isRegistered<AdminContentController>()) {
            final contentController = Get.find<AdminContentController>();
            contentController.refreshContent();
          }
          break;
        default:
          LoggerService.i('Refresh not implemented for tab: ${currentTab.value.name}');
      }
    } catch (e) {
      LoggerService.e('Error refreshing tab: ${currentTab.value.name}', error: e);
    }
  }

  void exportCurrentTabData() {
    try {
      switch (currentTab.value) {
        case AdminTab.dashboard:
          final dashboardController = Get.find<AdminDashboardController>();
          dashboardController.exportDashboardData();
          break;
        case AdminTab.analytics:
          if (Get.isRegistered<AdminAnalyticsController>()) {
            final analyticsController = Get.find<AdminAnalyticsController>();
            analyticsController.exportAnalyticsData();
          }
          break;
        case AdminTab.users:
          if (Get.isRegistered<AdminUserManagementController>()) {
            final userController = Get.find<AdminUserManagementController>();
            userController.exportUsers();
          }
          break;
        case AdminTab.content:
          if (Get.isRegistered<AdminContentController>()) {
            final contentController = Get.find<AdminContentController>();
            contentController.exportContent();
          }
          break;
        default:
          LoggerService.i('Export not implemented for tab: ${currentTab.value.name}');
      }
    } catch (e) {
      LoggerService.e('Error exporting tab data: ${currentTab.value.name}', error: e);
    }
  }

  // Navigation methods for sidebar
  void goToDashboard() => changeTab(AdminTab.dashboard);
  void goToAnalytics() => changeTab(AdminTab.analytics);
  void goToUsers() => changeTab(AdminTab.users);
  void goToBusiness() => changeTab(AdminTab.business);
  void goToContent() => changeTab(AdminTab.content);
  void goToSettings() => changeTab(AdminTab.settings);
}