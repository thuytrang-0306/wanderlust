import 'package:get/get.dart';
import 'package:wanderlust/core/services/ai_storage_service.dart';
import 'package:wanderlust/core/services/gemini_service.dart';
import 'package:wanderlust/presentation/controllers/ai/ai_chat_controller.dart';

class AIChatBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize services if not already initialized
    if (!Get.isRegistered<GeminiService>()) {
      Get.put(GeminiService());
    }
    
    if (!Get.isRegistered<AIStorageService>()) {
      Get.put(AIStorageService());
    }
    
    // Put controller
    Get.put(AIChatController());
  }
}