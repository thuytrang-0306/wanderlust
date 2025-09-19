import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/community/collection_detail_controller.dart';

class CollectionDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CollectionDetailController>(
      () => CollectionDetailController(),
    );
  }
}