import 'package:get/get.dart';
import 'admin_routes.dart';
import '../pages/auth/admin_login_page.dart';
import '../pages/dashboard/admin_dashboard_page.dart';
import '../pages/dashboard/analytics_page.dart';
import '../pages/users/user_management_page.dart';
import '../pages/users/user_detail_page.dart';
import '../pages/business/business_management_page.dart';
import '../pages/business/business_detail_page.dart';
import '../pages/business/business_approval_page.dart';
import '../pages/content/content_moderation_page.dart';
import '../pages/content/blog_moderation_page.dart';
import '../pages/content/listing_moderation_page.dart';
import '../pages/settings/admin_settings_page.dart';
import '../pages/settings/system_settings_page.dart';
import '../bindings/admin_dashboard_binding.dart';
import '../bindings/user_management_binding.dart';
import '../bindings/business_management_binding.dart';
import '../bindings/content_moderation_binding.dart';

class AdminPages {
  static final routes = [
    // Auth
    GetPage(
      name: AdminRoutes.LOGIN,
      page: () => const AdminLoginPage(),
      transition: Transition.fadeIn,
    ),
    
    // Dashboard
    GetPage(
      name: AdminRoutes.DASHBOARD,
      page: () => const AdminDashboardPage(),
      binding: AdminDashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.ANALYTICS,
      page: () => const AnalyticsPage(),
      binding: AdminDashboardBinding(),
      transition: Transition.fadeIn,
    ),
    
    // User Management
    GetPage(
      name: AdminRoutes.USERS,
      page: () => const UserManagementPage(),
      binding: UserManagementBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.USER_DETAIL,
      page: () => const UserDetailPage(),
      binding: UserManagementBinding(),
      transition: Transition.fadeIn,
    ),
    
    // Business Management
    GetPage(
      name: AdminRoutes.BUSINESS,
      page: () => const BusinessManagementPage(),
      binding: BusinessManagementBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.BUSINESS_DETAIL,
      page: () => const BusinessDetailPage(),
      binding: BusinessManagementBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.BUSINESS_APPROVAL,
      page: () => const BusinessApprovalPage(),
      binding: BusinessManagementBinding(),
      transition: Transition.fadeIn,
    ),
    
    // Content Moderation
    GetPage(
      name: AdminRoutes.CONTENT,
      page: () => const ContentModerationPage(),
      binding: ContentModerationBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.BLOG_MODERATION,
      page: () => const BlogModerationPage(),
      binding: ContentModerationBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.LISTING_MODERATION,
      page: () => const ListingModerationPage(),
      binding: ContentModerationBinding(),
      transition: Transition.fadeIn,
    ),
    
    // Settings
    GetPage(
      name: AdminRoutes.SETTINGS,
      page: () => const AdminSettingsPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AdminRoutes.SYSTEM_SETTINGS,
      page: () => const SystemSettingsPage(),
      transition: Transition.fadeIn,
    ),
  ];
}