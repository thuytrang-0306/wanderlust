import 'package:get/get.dart';
import 'package:wanderlust/core/services/ai_storage_service.dart';
import 'package:wanderlust/core/services/gemini_service.dart';
import 'package:wanderlust/core/services/location_service.dart';
import 'package:wanderlust/core/services/saved_blogs_service.dart';
import 'package:wanderlust/core/services/unified_image_service.dart';
import 'package:wanderlust/data/services/user_profile_service.dart';
import 'package:wanderlust/data/services/business_service.dart';
import 'package:wanderlust/data/services/listing_service.dart';
import 'package:wanderlust/data/services/booking_service.dart';
import 'package:wanderlust/presentation/controllers/auth_controller.dart';
import 'package:wanderlust/presentation/controllers/app_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core controllers only - required for app startup
    Get.put(AppController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    
    // Lazy load services - only init when needed
    Get.lazyPut(() => LocationService(), fenix: true);
    Get.lazyPut(() => UnifiedImageService(), fenix: true);
    Get.lazyPut(() => UserProfileService(), fenix: true);
    Get.lazyPut(() => BusinessService(), fenix: true);
    Get.lazyPut(() => ListingService(), fenix: true);
    Get.lazyPut(() => BookingService(), fenix: true);
    Get.lazyPut(() => SavedBlogsService(), fenix: true);
    
    // AI Services - lazy load
    Get.lazyPut(() => GeminiService(), fenix: true);
    Get.lazyPut(() => AIStorageService(), fenix: true);
  }
}
