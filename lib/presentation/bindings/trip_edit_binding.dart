import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/planning/trip_edit_controller.dart';

class TripEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripEditController>(() => TripEditController());
  }
}