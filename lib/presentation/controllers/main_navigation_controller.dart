import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/presentation/controllers/account/account_controller.dart';
import 'package:wanderlust/presentation/controllers/account/user_profile_controller.dart';
import 'package:wanderlust/presentation/controllers/discover/discover_controller.dart';

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
  
  @override
  void onInit() {
    super.onInit();
    // Initialize controllers for tabs when main navigation loads
    Get.lazyPut(() => DiscoverController());
    Get.lazyPut(() => AccountController());
    
    // Put UserProfileController immediately and permanently
    // This ensures it's available for all pages that need user data
    if (!Get.isRegistered<UserProfileController>()) {
      Get.put(UserProfileController(), permanent: true);
    }
  }
  
  // Change tab
  void changeTab(int index) {
    currentIndex.value = index;
  }
  
  // Get current tab label
  String get currentTabLabel => tabLabels[currentIndex.value];
}