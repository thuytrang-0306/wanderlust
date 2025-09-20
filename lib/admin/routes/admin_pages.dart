import 'package:get/get.dart';
import 'admin_routes.dart';
import '../pages/auth/admin_login_page.dart';
import '../pages/auth/admin_setup_page.dart';
import '../pages/admin_main_page.dart';
import '../bindings/admin_main_binding.dart';

class AdminPages {
  static final routes = [
    // Auth
    GetPage(
      name: AdminRoutes.LOGIN,
      page: () => const AdminLoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.SETUP,
      page: () => const AdminSetupPage(),
      transition: Transition.fadeIn,
    ),
    
    // Main Admin Page with Tab Navigation
    GetPage(
      name: AdminRoutes.DASHBOARD,
      page: () => const AdminMainPage(),
      binding: AdminMainBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.ANALYTICS,
      page: () => const AdminMainPage(),
      binding: AdminMainBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.USERS,
      page: () => const AdminMainPage(),
      binding: AdminMainBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.BUSINESS,
      page: () => const AdminMainPage(),
      binding: AdminMainBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.CONTENT,
      page: () => const AdminMainPage(),
      binding: AdminMainBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.SETTINGS,
      page: () => const AdminMainPage(),
      binding: AdminMainBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}