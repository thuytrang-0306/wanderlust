import 'package:get/get.dart';
import 'package:wanderlust/presentation/controllers/booking/booking_history_controller.dart';

class BookingHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingHistoryController>(() => BookingHistoryController());
  }
}
