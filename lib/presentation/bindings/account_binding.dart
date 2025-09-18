import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/account/account_controller.dart';

class AccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountController>(() => AccountController());
  }
}
