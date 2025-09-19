import 'package:get/get.dart';
import 'package:wanderlust/core/services/ai_storage_service.dart';
import 'package:wanderlust/core/services/gemini_service.dart';
import 'package:wanderlust/core/services/location_service.dart';
import 'package:wanderlust/core/services/unified_image_service.dart';
import 'package:wanderlust/data/services/user_profile_service.dart';
import 'package:wanderlust/data/services/business_service.dart';
import 'package:wanderlust/data/services/room_service.dart';
import 'package:wanderlust/presentation/controllers/auth_controller.dart';
import 'package:wanderlust/presentation/controllers/app_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(LocationService(), permanent: true);
    
    // Services
    Get.put(UnifiedImageService(), permanent: true);
    Get.put(UserProfileService(), permanent: true);
    Get.put(BusinessService(), permanent: true);
    Get.put(RoomService(), permanent: true);
    
    // AI Services
    Get.put(GeminiService(), permanent: true);
    Get.put(AIStorageService(), permanent: true);
  }
}
