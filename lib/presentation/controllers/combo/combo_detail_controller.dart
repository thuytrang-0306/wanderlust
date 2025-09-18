import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

class ComboDetailController extends BaseController {
  // Observable values
  final RxBool isBookmarked = false.obs;
  final RxBool showFullDescription = false.obs;
  final RxInt selectedDay = 1.obs;

  // Combo data from arguments
  Map<String, dynamic> comboData = {};

  @override
  void onInit() {
    super.onInit();
    loadComboData();
  }

  void loadComboData() {
    // Get data from arguments
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      comboData = args;
    } else {
      // Default data for testing
      comboData = {
        'title': 'Tour Nha Trang - Chuyên đi chữa lành cảm xúc',
        'location': 'Nha Trang, Khánh Hòa',
        'duration': '2 ngày 1 đêm',
        'price': '3.500.000',
        'rating': '4.8',
        'creator': 'Hiếu Thủ Hại',
        'image': 'https://images.unsplash.com/photo-1559628233-100c798642d4?w=800',
      };
    }
  }

  void toggleBookmark() {
    isBookmarked.value = !isBookmarked.value;

    if (isBookmarked.value) {
      AppSnackbar.showSuccess(message: 'Đã lưu combo tour', position: SnackPosition.BOTTOM);
    } else {
      AppSnackbar.showInfo(message: 'Đã bỏ lưu combo tour', position: SnackPosition.BOTTOM);
    }
  }

  void toggleDescription() {
    showFullDescription.value = !showFullDescription.value;
  }

  void selectDay(int day) {
    selectedDay.value = day;
  }

  void initializeCombo() {
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: Text('Khai tạo combo tour'),
        content: Text(
          'Bạn muốn tạo lịch trình du lịch mới từ combo tour này?\n\n'
          'Lịch trình sẽ được sao chép vào kế hoạch của bạn và bạn có thể tùy chỉnh theo ý muốn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Hủy',
              style: TextStyle(color: Get.theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
          TextButton(onPressed: _createTripFromCombo, child: Text('Xác nhận')),
        ],
      ),
    );
  }

  void _createTripFromCombo() {
    Get.back(); // Close dialog

    // Navigate to TripEditPage with combo data
    Get.toNamed(
      '/trip-edit',
      arguments: {
        'isNewTrip': true,
        'fromCombo': true,
        'comboData': {
          'title': comboData['title'],
          'location': comboData['location'],
          'duration': comboData['duration'],
          'itinerary': _generateItineraryFromCombo(),
        },
      },
    );

    AppSnackbar.showSuccess(
      message: 'Đã tạo lịch trình từ combo tour',
      position: SnackPosition.BOTTOM,
    );
  }

  Map<String, dynamic> _generateItineraryFromCombo() {
    // Generate itinerary data from combo
    return {
      'days': [
        {
          'day': 1,
          'title': 'TP.HCM → Nha Trang',
          'activities': [
            {
              'time': '05:00 - 06:00',
              'title': 'Di chuyển từ TP.HCM đến Nha Trang',
              'type': 'transport',
              'details': 'Vietnam Airlines',
            },
            {'time': '07:30 - 10:00', 'title': 'Nhận phòng khách sạn', 'type': 'accommodation'},
          ],
        },
        {
          'day': 2,
          'title': 'Khám phá Nha Trang',
          'activities': [
            {'time': '08:00 - 10:00', 'title': 'Viếng chùa Long Sơn', 'type': 'attraction'},
            {'time': '10:30 - 12:00', 'title': 'Tham quan Tháp Bà Ponagar', 'type': 'attraction'},
            {'time': '14:00 - 17:00', 'title': 'Vịnh Nha Trang', 'type': 'beach'},
          ],
        },
      ],
    };
  }
}
