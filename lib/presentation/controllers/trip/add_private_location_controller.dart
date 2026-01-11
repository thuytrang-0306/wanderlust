import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/services/location_service.dart';
import 'package:wanderlust/core/services/geocoding_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/models/location_point.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class AddPrivateLocationController extends BaseController {
  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();

  // Observable values
  final RxString locationName = ''.obs;
  final RxString address = ''.obs;
  final RxString longitude = ''.obs;
  final RxString latitude = ''.obs;
  final RxBool isValid = false.obs;

  // Map values
  final RxDouble selectedLat = 10.8231.obs;
  final RxDouble selectedLng = 106.6297.obs;
  final Rx<LocationPoint?> selectedLocation = Rx<LocationPoint?>(null);
  late MapController mapController;

  // Edit mode
  final RxBool isEditMode = false.obs;
  Map<String, dynamic>? existingLocation;

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();

    // Check if in edit mode
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['mode'] == 'edit' && args['location'] != null) {
        isEditMode.value = true;
        existingLocation = args['location'] as Map<String, dynamic>;
        _loadExistingLocation();
      } else {
        // New location - try to get current location first
        _initializeWithCurrentLocation();
      }
    } else {
      // New location - try to get current location first
      _initializeWithCurrentLocation();
    }
  }

  void _loadExistingLocation() {
    if (existingLocation == null) return;

    // Load existing data
    nameController.text = existingLocation!['title'] ?? '';
    addressController.text = existingLocation!['address'] ?? '';

    final lat = existingLocation!['latitude'];
    final lng = existingLocation!['longitude'];

    if (lat != null && lng != null) {
      final latValue = lat is double ? lat : double.tryParse(lat.toString()) ?? 10.8231;
      final lngValue = lng is double ? lng : double.tryParse(lng.toString()) ?? 106.6297;

      selectedLat.value = latValue;
      selectedLng.value = lngValue;
      latitudeController.text = latValue.toStringAsFixed(6);
      longitudeController.text = lngValue.toStringAsFixed(6);

      // Update selected location (AppMap will auto-center)
      selectedLocation.value = LocationPoint(
        id: 'existing',
        name: nameController.text,
        latitude: latValue,
        longitude: lngValue,
      );
    }

    _validateForm();
  }

  Future<void> _initializeWithCurrentLocation() async {
    final locationService = LocationService.to;

    // Try to get current location
    final position = await locationService.getCurrentLocation();

    if (position != null) {
      // Use current location
      selectedLat.value = position.latitude;
      selectedLng.value = position.longitude;
      latitudeController.text = position.latitude.toStringAsFixed(6);
      longitudeController.text = position.longitude.toStringAsFixed(6);

      // Update selected location (AppMap will auto-center)
      selectedLocation.value = LocationPoint(
        id: 'current',
        name: 'Vị trí hiện tại',
        latitude: position.latitude,
        longitude: position.longitude,
      );

      LoggerService.i('Initialized with current location: ${position.latitude}, ${position.longitude}');
    } else {
      // Fallback to default (Ho Chi Minh City)
      selectedLat.value = 10.8231;
      selectedLng.value = 106.6297;
      longitudeController.text = '106.6297';
      latitudeController.text = '10.8231';

      LoggerService.w('Could not get current location, using default');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    longitudeController.dispose();
    latitudeController.dispose();
    mapController.dispose();
    super.onClose();
  }

  void updateName(String value) {
    locationName.value = value;
    _validateForm();
  }

  void updateAddress(String value) {
    address.value = value;
    _validateForm();
  }

  // Geocode address to coordinates
  Future<void> geocodeAddress() async {
    if (addressController.text.trim().isEmpty) {
      AppSnackbar.showWarning(title: 'Chú ý', message: 'Vui lòng nhập địa chỉ');
      return;
    }

    try {
      AppSnackbar.showInfo(title: 'Đang xử lý', message: 'Đang tìm vị trí...');

      final geocodingService = GeocodingService.to;
      final result = await geocodingService.geocode(addressController.text.trim());

      if (result != null) {
        final lat = result['lat'] as double;
        final lng = result['lng'] as double;

        // Update coordinates
        selectedLat.value = lat;
        selectedLng.value = lng;
        latitudeController.text = lat.toStringAsFixed(6);
        longitudeController.text = lng.toStringAsFixed(6);

        // Update selected location (this triggers map rebuild with new center)
        selectedLocation.value = LocationPoint(
          id: 'geocoded',
          name: result['displayName'] ?? addressController.text,
          latitude: lat,
          longitude: lng,
        );

        _validateForm();

        Get.back(); // Close snackbar
        AppSnackbar.showSuccess(title: 'Thành công', message: 'Đã tìm thấy vị trí');
        LoggerService.i('Geocoded address: ${result['displayName']}');
      } else {
        Get.back();
        AppSnackbar.showWarning(
          title: 'Không tìm thấy',
          message: 'Không thể tìm thấy vị trí cho địa chỉ này',
        );
      }
    } catch (e) {
      Get.back();
      LoggerService.e('Geocoding failed', error: e);
      AppSnackbar.showError(title: 'Lỗi', message: 'Có lỗi xảy ra khi tìm vị trí');
    }
  }

  void updateLongitude(String value) {
    longitude.value = value;
    _validateForm();
    _updateMapFromCoordinates();
  }

  void updateLatitude(String value) {
    latitude.value = value;
    _validateForm();
    _updateMapFromCoordinates();
  }

  // Update map when coordinates are manually entered
  void _updateMapFromCoordinates() {
    final lat = double.tryParse(latitudeController.text);
    final lng = double.tryParse(longitudeController.text);

    if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      selectedLat.value = lat;
      selectedLng.value = lng;

      // Update selected location (AppMap will auto-center)
      selectedLocation.value = LocationPoint(
        id: 'manual',
        name: 'Selected Location',
        latitude: lat,
        longitude: lng,
      );
    }
  }

  void _validateForm() {
    isValid.value =
        nameController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        longitudeController.text.isNotEmpty &&
        latitudeController.text.isNotEmpty;
  }

  void onMapTap(LatLng latLng) async {
    // Update selected coordinates
    selectedLat.value = latLng.latitude;
    selectedLng.value = latLng.longitude;

    // Update text fields
    latitudeController.text = latLng.latitude.toStringAsFixed(6);
    longitudeController.text = latLng.longitude.toStringAsFixed(6);

    // Update observable values
    latitude.value = latLng.latitude.toString();
    longitude.value = latLng.longitude.toString();

    // Update selected location
    selectedLocation.value = LocationPoint(
      id: 'selected',
      name: 'Selected Location',
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );

    _validateForm();

    // Reverse geocode to get address
    _reverseGeocodeLocation(latLng.latitude, latLng.longitude);
  }

  // Reverse geocode coordinates to address
  Future<void> _reverseGeocodeLocation(double lat, double lng) async {
    try {
      final geocodingService = GeocodingService.to;
      final result = await geocodingService.reverseGeocode(lat, lng);

      if (result != null) {
        // Update address field with formatted address
        final formattedAddress = geocodingService.formatAddress(result);
        if (formattedAddress.isNotEmpty) {
          addressController.text = formattedAddress;
          address.value = formattedAddress;
          _validateForm();

          LoggerService.i('Reverse geocoded: $formattedAddress');
        }
      }
    } catch (e) {
      LoggerService.w('Reverse geocoding failed', error: e);
      // Don't show error to user, it's not critical
    }
  }

  void saveLocation() {
    LoggerService.i('saveLocation called');
    LoggerService.i('Validation state: isValid=${isValid.value}');
    LoggerService.i('Name: "${nameController.text}", Address: "${addressController.text}"');
    LoggerService.i('Lat: "${latitudeController.text}", Lng: "${longitudeController.text}"');

    if (!isValid.value) {
      LoggerService.w('Validation failed - showing error');
      AppSnackbar.showError(title: 'Lỗi', message: 'Vui lòng điền đầy đủ thông tin');
      return;
    }

    // Create location data
    final locationData = {
      'name': nameController.text.trim(),
      'address': addressController.text.trim(),
      'latitude': double.tryParse(latitudeController.text) ?? 0.0,
      'longitude': double.tryParse(longitudeController.text) ?? 0.0,
      'type': 'private',
      'addedAt': DateTime.now(),
    };
    LoggerService.i('Location data created: $locationData');

    // Navigate back with result (parent controller will show snackbar)
    Get.back(result: locationData);
    LoggerService.i('Location saved and navigated back');
  }

  void navigateToCurrentLocation() async {
    final locationService = LocationService.to;

    AppSnackbar.showInfo(title: 'Thông báo', message: 'Đang lấy vị trí hiện tại...');

    final position = await locationService.getCurrentLocation();

    if (position != null) {
      // Update location fields
      latitudeController.text = position.latitude.toStringAsFixed(6);
      longitudeController.text = position.longitude.toStringAsFixed(6);

      // Update selected location (AppMap will auto-center)
      selectedLat.value = position.latitude;
      selectedLng.value = position.longitude;
      selectedLocation.value = LocationPoint(
        id: 'current',
        name: 'Vị trí hiện tại',
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _validateForm();

      AppSnackbar.showSuccess(title: 'Thành công', message: 'Đã cập nhật vị trí hiện tại');
    }
  }
}
