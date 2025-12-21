import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

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

    try {
      // TODO: Load real trip data from Firestore
      // For now, keep empty arrays until backend is ready
      upcomingTrips.value = [];
      ongoingTrips.value = [];
      completedTrips.value = [];
    } catch (e) {
      // Handle error
    } finally {
      isLoadingTrips.value = false;
    }
  }

  void createNewTrip() async {
    final result = await Get.toNamed('/trip-edit');

    // Refresh list if trip was created successfully
    if (result != null && result is Map<String, dynamic> && result['success'] == true) {
      loadTrips(); // Refresh to show new trip
      LoggerService.i('New trip created, list refreshed');
    }
  }

  void navigateToTripDetail(Map<String, dynamic> trip) {
    Get.toNamed('/trip-detail', arguments: trip);
  }

  void editTrip(Map<String, dynamic> trip) async {
    final result = await Get.toNamed('/trip-edit', arguments: trip);

    // Refresh list if trip was updated successfully
    if (result != null && result is Map<String, dynamic> && result['success'] == true) {
      loadTrips(); // Refresh to show updated trip
      LoggerService.i('Trip updated, list refreshed');
    }
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
