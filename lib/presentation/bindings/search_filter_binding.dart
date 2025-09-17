import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/search/search_filter_controller.dart';

class SearchFilterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchFilterController>(
      () => SearchFilterController(),
    );
  }
}