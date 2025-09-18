import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/community/create_post_controller.dart';

class CreatePostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatePostController>(() => CreatePostController());
  }
}
