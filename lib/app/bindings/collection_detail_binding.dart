import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/community/collection_detail_controller.dart';

class CollectionDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Use fenix: true to FORCE recreate controller each time
    // This prevents state pollution between different collections
    Get.lazyPut<CollectionDetailController>(
      () => CollectionDetailController(),
      fenix: true, // ← CRITICAL: Recreate on each navigation
    );
  }
}