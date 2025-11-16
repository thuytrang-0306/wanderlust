import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/account/edit_profile_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}
