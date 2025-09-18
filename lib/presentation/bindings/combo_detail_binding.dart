import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/combo/combo_detail_controller.dart';

class ComboDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComboDetailController>(() => ComboDetailController());
  }
}
