import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:share_plus/share_plus.dart';

class MyTripsController extends BaseController with GetTickerProviderStateMixin {
  late TabController tabController;

  final RxBool isLoadingTrips = false.obs;
  final upcomingTrips = <Map<String, dynamic>>[].obs;
  final ongoingTrips = <Map<String, dynamic>>[].obs;
  final completedTrips = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    loadTrips();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void loadTrips() async {
    isLoadingTrips.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    upcomingTrips.value = [
      {
        'id': '1',
        'name': 'Khám phá Đà Lạt mùa xuân',
        'destination': 'Đà Lạt, Lâm Đồng',
        'startDate': '15/03/2024',
        'endDate': '20/03/2024',
        'status': 'upcoming',
        'members': 4,
        'activities': 12,
        'image': '',
      },
      {
        'id': '2',
        'name': 'Phú Quốc - Thiên đường biển đảo',
        'destination': 'Phú Quốc, Kiên Giang',
        'startDate': '01/04/2024',
        'endDate': '05/04/2024',
        'status': 'upcoming',
        'members': 2,
        'activities': 8,
        'image': '',
      },
    ];

    ongoingTrips.value = [
      {
        'id': '3',
        'name': 'Sapa mùa lúa chín',
        'destination': 'Sapa, Lào Cai',
        'startDate': '10/09/2024',
        'endDate': '13/09/2024',
        'status': 'ongoing',
        'members': 3,
        'activities': 10,
        'image': '',
      },
    ];

    completedTrips.value = [
      {
        'id': '4',
        'name': 'Hội An - Phố cổ',
        'destination': 'Hội An, Quảng Nam',
        'startDate': '20/08/2024',
        'endDate': '23/08/2024',
        'status': 'completed',
        'members': 5,
        'activities': 15,
        'image': '',
      },
      {
        'id': '5',
        'name': 'Nha Trang biển xanh',
        'destination': 'Nha Trang, Khánh Hòa',
        'startDate': '15/07/2024',
        'endDate': '18/07/2024',
        'status': 'completed',
        'members': 4,
        'activities': 9,
        'image': '',
      },
    ];

    isLoadingTrips.value = false;
  }

  void createNewTrip() {
    Get.toNamed('/trip-edit');
  }

  void navigateToTripDetail(Map<String, dynamic> trip) {
    Get.toNamed('/trip-detail', arguments: trip);
  }

  void editTrip(Map<String, dynamic> trip) {
    Get.toNamed('/trip-edit', arguments: trip);
  }

  void shareTrip(Map<String, dynamic> trip) async {
    final shareText = '''
Chuyến đi: ${trip['name']}
Điểm đến: ${trip['destination']}
Thời gian: ${trip['startDate']} - ${trip['endDate']}
Số người: ${trip['members']}
Số hoạt động: ${trip['activities']}

Chia sẻ từ ứng dụng Wanderlust
''';

    await Share.share(shareText);
  }

  void duplicateTrip(Map<String, dynamic> trip) async {
    final confirm = await AppDialogs.showConfirm(
      title: 'Sao chép chuyến đi',
      message: 'Bạn muốn tạo một bản sao của chuyến đi "${trip['name']}"?',
      confirmText: 'Sao chép',
      cancelText: 'Hủy',
    );

    if (confirm) {
      // TODO: Implement duplicate logic
      AppSnackbar.showSuccess(message: 'Đã sao chép chuyến đi thành công');
    }
  }

  void archiveTrip(Map<String, dynamic> trip) async {
    final confirm = await AppDialogs.showConfirm(
      title: 'Lưu trữ chuyến đi',
      message: 'Bạn muốn lưu trữ chuyến đi "${trip['name']}"?',
      confirmText: 'Lưu trữ',
      cancelText: 'Hủy',
    );

    if (confirm) {
      // Remove from current list
      if (trip['status'] == 'upcoming') {
        upcomingTrips.removeWhere((t) => t['id'] == trip['id']);
      } else if (trip['status'] == 'ongoing') {
        ongoingTrips.removeWhere((t) => t['id'] == trip['id']);
      }

      AppSnackbar.showSuccess(message: 'Đã lưu trữ chuyến đi');
    }
  }

  void deleteTrip(Map<String, dynamic> trip) async {
    final confirm = await AppDialogs.showConfirm(
      title: 'Xóa chuyến đi',
      message:
          'Bạn có chắc chắn muốn xóa chuyến đi "${trip['name']}"? Hành động này không thể hoàn tác.',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
      confirmColor: const Color(0xFFF87B7B),
    );

    if (confirm) {
      // Remove from appropriate list
      if (trip['status'] == 'upcoming') {
        upcomingTrips.removeWhere((t) => t['id'] == trip['id']);
      } else if (trip['status'] == 'ongoing') {
        ongoingTrips.removeWhere((t) => t['id'] == trip['id']);
      } else if (trip['status'] == 'completed') {
        completedTrips.removeWhere((t) => t['id'] == trip['id']);
      }

      AppSnackbar.showSuccess(message: 'Đã xóa chuyến đi');
    }
  }
}
