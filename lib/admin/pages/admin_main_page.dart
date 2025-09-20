import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/admin_main_controller.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_header.dart';
import 'dashboard/admin_dashboard_tab.dart';
import 'analytics/admin_analytics_tab.dart';
import 'user_management/admin_user_management_tab.dart';
import 'business/admin_business_tab.dart';
import 'content/admin_content_tab.dart';
import 'settings/admin_settings_tab.dart';

class AdminMainPage extends GetView<AdminMainController> {
  const AdminMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar - only show on desktop
          if (context.width > 768) 
            AdminSidebar(
              onTabChanged: controller.changeTab,
              currentTab: controller.currentTab,
            ),
          
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Header
                Obx(() => AdminHeader(
                  title: controller.currentTabTitle,
                  actions: _buildTabActions(),
                  showMenuButton: context.width <= 768,
                )),
                
                // Tab Content
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    child: Obx(() => _buildTabContent()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (controller.currentTab.value) {
      case AdminTab.dashboard:
        return const AdminDashboardTab();
      case AdminTab.analytics:
        return const AdminAnalyticsTab();
      case AdminTab.users:
        return const AdminUserManagementTab();
      case AdminTab.business:
        return const AdminBusinessTab();
      case AdminTab.content:
        return const AdminContentTab();
      case AdminTab.settings:
        return const AdminSettingsTab();
      default:
        return const AdminDashboardTab();
    }
  }

  List<Widget>? _buildTabActions() {
    switch (controller.currentTab.value) {
      case AdminTab.dashboard:
        return [
          IconButton(
            onPressed: controller.refreshCurrentTab,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          SizedBox(width: 8.w),
          ElevatedButton.icon(
            onPressed: controller.exportCurrentTabData,
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Export'),
          ),
        ];
      case AdminTab.analytics:
        return [
          IconButton(
            onPressed: controller.refreshCurrentTab,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          SizedBox(width: 8.w),
          ElevatedButton.icon(
            onPressed: controller.exportCurrentTabData,
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Export Analytics'),
          ),
        ];
      case AdminTab.users:
        return [
          IconButton(
            onPressed: controller.refreshCurrentTab,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          SizedBox(width: 8.w),
          ElevatedButton.icon(
            onPressed: controller.exportCurrentTabData,
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Export Users'),
          ),
        ];
      default:
        return [
          IconButton(
            onPressed: controller.refreshCurrentTab,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ];
    }
  }
}