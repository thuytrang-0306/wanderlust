import 'package:get/get.dart';
import 'package:wanderlust/core/services/location_service.dart';
import 'package:wanderlust/presentation/controllers/auth_controller.dart';
import 'package:wanderlust/presentation/controllers/app_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(LocationService(), permanent: true);
  }
}
