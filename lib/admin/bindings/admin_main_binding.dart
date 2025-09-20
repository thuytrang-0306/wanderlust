import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_main_controller.dart';
import 'package:wanderlust/admin/controllers/admin_dashboard_controller.dart';
import 'package:wanderlust/admin/controllers/admin_analytics_controller.dart';
import 'package:wanderlust/admin/controllers/admin_user_management_controller.dart';
import 'package:wanderlust/admin/controllers/admin_business_controller.dart';
import 'package:wanderlust/admin/services/admin_business_service.dart';
import 'package:wanderlust/admin/routes/admin_routes.dart';

class AdminMainBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put(AdminBusinessService());
    
    // Main controller
    Get.put(AdminMainController());
    
    // Always put dashboard controller
    Get.put(AdminDashboardController());
    
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