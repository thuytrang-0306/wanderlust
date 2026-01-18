import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class PaymentMethodController extends BaseController {
  // Selected payment method: 'payos' or 'zalopay'
  final selectedPaymentMethod = 'payos'.obs;

  @override
  void onInit() {
    super.onInit();

    // Get current payment method from arguments if available
    final args = Get.arguments;
    if (args != null && args is Map && args['currentMethod'] != null) {
      selectedPaymentMethod.value = args['currentMethod'];
    }
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    LoggerService.d('Payment method selected: $method');
  }

  void savePaymentMethod() {
    final method = selectedPaymentMethod.value;

    // Prepare payment method data to return
    Map<String, dynamic> paymentData = {
      'method': method,
    };

    if (method == 'payos') {
      paymentData['displayName'] = 'PayOS - QR Ngân hàng';
      paymentData['icon'] = 'qr_code';
      paymentData['description'] = 'Quét mã QR để thanh toán';
    } else if (method == 'zalopay') {
      paymentData['displayName'] = 'ZaloPay';
      paymentData['icon'] = 'wallet';
      paymentData['description'] = 'Thanh toán qua ví ZaloPay';
    }

    LoggerService.i('Payment method saved: $paymentData');

    // Return payment method data to previous screen
    Get.back(result: paymentData);

    AppSnackbar.showSuccess(
      message: 'Đã chọn ${paymentData['displayName']}',
    );
  }
}
