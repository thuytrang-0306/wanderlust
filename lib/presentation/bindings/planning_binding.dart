import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/planning/planning_controller.dart';

class PlanningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlanningController>(
      () => PlanningController(),
      fenix: true, // Keep controller alive
    );
  }
}
