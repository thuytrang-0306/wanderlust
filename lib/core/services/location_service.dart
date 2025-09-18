import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

class LocationService extends GetxService {
  static LocationService get to => Get.find();

  // Observable states
  final RxBool hasLocationPermission = false.obs;
  final RxBool isLocationEnabled = false.obs;
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLoadingLocation = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialPermissionStatus();
  }

  // Check initial permission status
  Future<void> _checkInitialPermissionStatus() async {
    try {
      isLocationEnabled.value = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      hasLocationPermission.value =
          permission == LocationPermission.whileInUse || permission == LocationPermission.always;
    } catch (e) {
      LoggerService.e('Error checking initial permission status', error: e);
    }
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Request user to enable location services
        _showLocationServiceDialog();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppSnackbar.showWarning(
            title: 'Quyền truy cập bị từ chối',
            message: 'Vui lòng cấp quyền truy cập vị trí để sử dụng tính năng này',
          );
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission denied forever, show dialog to open settings
        _showPermissionDeniedDialog();
        return false;
      }

      hasLocationPermission.value = true;
      isLocationEnabled.value = true;
      return true;
    } catch (e) {
      LoggerService.e('Error requesting location permission', error: e);
      AppSnackbar.showError(title: 'Lỗi', message: 'Không thể yêu cầu quyền truy cập vị trí');
      return false;
    }
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      isLoadingLocation.value = true;

      // Check and request permission if needed
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        isLoadingLocation.value = false;
        return null;
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      currentPosition.value = position;
      isLoadingLocation.value = false;

      LoggerService.i('Got current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      LoggerService.e('Error getting current location', error: e);
      isLoadingLocation.value = false;

      if (e.toString().contains('timeout')) {
        AppSnackbar.showError(
          title: 'Lỗi',
          message: 'Không thể lấy vị trí hiện tại. Vui lòng thử lại',
        );
      }

      return null;
    }
  }

  // Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
  }

  // Show dialog when location service is disabled
  void _showLocationServiceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Dịch vụ vị trí bị tắt'),
        content: const Text('Vui lòng bật dịch vụ vị trí trong cài đặt để sử dụng tính năng này'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openLocationSettings();
            },
            child: const Text('Mở cài đặt'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Show dialog when permission is denied forever
  void _showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Quyền truy cập bị từ chối'),
        content: const Text(
          'Bạn đã từ chối quyền truy cập vị trí. '
          'Vui lòng vào cài đặt ứng dụng để cấp quyền.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Mở cài đặt'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Stream location updates
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: accuracy, distanceFilter: distanceFilter),
    );
  }

  // Check if location is within radius
  bool isWithinRadius({
    required double centerLat,
    required double centerLng,
    required double checkLat,
    required double checkLng,
    required double radiusInMeters,
  }) {
    double distance = calculateDistance(centerLat, centerLng, checkLat, checkLng);
    return distance <= radiusInMeters;
  }
}
