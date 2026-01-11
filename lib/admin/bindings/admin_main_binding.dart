import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_main_controller.dart';
import 'package:wanderlust/admin/controllers/admin_dashboard_controller.dart';
import 'package:wanderlust/admin/controllers/admin_analytics_controller.dart';
import 'package:wanderlust/admin/controllers/admin_user_management_controller.dart';
import 'package:wanderlust/admin/controllers/admin_business_controller.dart';
import 'package:wanderlust/admin/controllers/admin_settings_controller.dart';
import 'package:wanderlust/admin/services/admin_business_service.dart';
import 'package:wanderlust/admin/routes/admin_routes.dart';

class AdminMainBinding extends Bindings {
  @override
  void dependencies() {
    // Services - Use lazy loading to improve login performance
    Get.lazyPut<AdminBusinessService>(() => AdminBusinessService(), fenix: true);

    // Main controller - Required immediately
    Get.put(AdminMainController());

    // Dashboard controller - Required immediately for initial view
    Get.put(AdminDashboardController());

    // Settings controller - Use lazy loading (only needed when settings tab opened)
    Get.lazyPut<AdminSettingsController>(() => AdminSettingsController(), fenix: true);

    // Check current route and set appropriate tab
    final currentRoute = Get.currentRoute;
    switch (currentRoute) {
      case AdminRoutes.ANALYTICS:
        Get.find<AdminMainController>().changeTab(AdminTab.analytics);
        break;
      case AdminRoutes.USERS:
        Get.find<AdminMainController>().changeTab(AdminTab.users);
        break;
      case AdminRoutes.BUSINESS:
        Get.find<AdminMainController>().changeTab(AdminTab.business);
        break;
      case AdminRoutes.CONTENT:
        Get.find<AdminMainController>().changeTab(AdminTab.content);
        break;
      case AdminRoutes.SETTINGS:
        Get.find<AdminMainController>().changeTab(AdminTab.settings);
        break;
      default:
        Get.find<AdminMainController>().changeTab(AdminTab.dashboard);
    }
  }
}