import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';

class MainNavigationController extends BaseController {
  // Current tab index
  final RxInt currentIndex = 0.obs;
  
  // Tab labels
  final List<String> tabLabels = [
    'Khám phá',
    'Cộng đồng',
    'Lập kế hoạch',
    'Thông báo',
    'Tài khoản',
  ];
  
  // Change tab
  void changeTab(int index) {
    currentIndex.value = index;
  }
  
  // Get current tab label
  String get currentTabLabel => tabLabels[currentIndex.value];
}