import 'package:get/get.dart';
import '../../shared/core/services/firebase_service.dart';
import '../../shared/core/services/storage_service.dart';
import '../../shared/core/services/connectivity_service.dart';
import '../../shared/data/services/blog_service.dart';
import '../../shared/data/services/business_service.dart';
// import '../../shared/data/services/user_service.dart'; // TODO: Create UserService
import '../services/admin_analytics_service.dart';
import '../services/admin_export_service.dart';
import '../services/admin_auth_service.dart';
import '../controllers/admin_auth_controller.dart';

class AdminInitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services (if not already registered)
    if (!Get.isRegistered<FirebaseService>()) {
      Get.lazyPut<FirebaseService>(() => FirebaseService(), fenix: true);
    }
    if (!Get.isRegistered<StorageService>()) {
      Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    }
    if (!Get.isRegistered<ConnectivityService>()) {
      Get.lazyPut<ConnectivityService>(() => ConnectivityService(), fenix: true);
    }

    // Data Services
    Get.lazyPut<BlogService>(() => BlogService(), fenix: true);
    Get.lazyPut<BusinessService>(() => BusinessService(), fenix: true);
    // Get.lazyPut<UserService>(() => UserService(), fenix: true); // TODO: Create UserService

    // Admin-specific Services
    Get.lazyPut<AdminAnalyticsService>(() => AdminAnalyticsService(), fenix: true);
    Get.lazyPut<AdminExportService>(() => AdminExportService(), fenix: true);
    Get.lazyPut<AdminAuthService>(() => AdminAuthService(), fenix: true);

    // Admin Controllers
    Get.lazyPut<AdminAuthController>(() => AdminAuthController(), fenix: true);
  }
}