import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/trip/add_private_location_controller.dart';

class AddPrivateLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddPrivateLocationController>(
      () => AddPrivateLocationController(),
    );
  }
}