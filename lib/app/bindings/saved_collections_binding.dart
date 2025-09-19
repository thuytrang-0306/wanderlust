import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/community/saved_collections_controller.dart';

class SavedCollectionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SavedCollectionsController>(
      () => SavedCollectionsController(),
      fenix: true, // Keep alive between routes
    );
  }
}