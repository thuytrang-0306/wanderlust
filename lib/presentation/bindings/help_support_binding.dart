import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/settings/help_support_controller.dart';

class HelpSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpSupportController>(
      () => HelpSupportController(),
    );
  }
}