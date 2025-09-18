import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/services/location_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/models/location_point.dart';

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
  
  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
    // Set default coordinates (Ho Chi Minh City)
    longitudeController.text = '106.6297';
    latitudeController.text = '10.8231';
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
  
  void updateLongitude(String value) {
    longitude.value = value;
    _validateForm();
  }
  
  void updateLatitude(String value) {
    latitude.value = value;
    _validateForm();
  }
  
  void _validateForm() {
    isValid.value = nameController.text.isNotEmpty &&
                   addressController.text.isNotEmpty &&
                   longitudeController.text.isNotEmpty &&
                   latitudeController.text.isNotEmpty;
  }
  
  void onMapTap(LatLng latLng) {
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
  }
  
  void saveLocation() {
    if (!isValid.value) {
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Vui lòng điền đầy đủ thông tin',
      );
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
    
    // Save to Firestore if needed in the future
    // For now, just return the data to the previous screen
    // which will handle the persistence
    
    AppSnackbar.showSuccess(
      title: 'Thành công',
      message: 'Đã thêm địa điểm riêng tư',
    );
    
    // Return data to previous page for processing
    Get.back(result: locationData);
  }
  
  void navigateToCurrentLocation() async {
    final locationService = LocationService.to;
    
    AppSnackbar.showInfo(
      title: 'Thông báo',
      message: 'Đang lấy vị trí hiện tại...',
    );
    
    final position = await locationService.getCurrentLocation();
    
    if (position != null) {
      // Update map center to current location
      mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0,
      );
      
      // Update location fields
      latitudeController.text = position.latitude.toStringAsFixed(6);
      longitudeController.text = position.longitude.toStringAsFixed(6);
      
      // Update selected location
      selectedLat.value = position.latitude;
      selectedLng.value = position.longitude;
      selectedLocation.value = LocationPoint(
        id: 'current',
        name: 'Vị trí hiện tại',
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      _validateForm();
      
      AppSnackbar.showSuccess(
        title: 'Thành công',
        message: 'Đã cập nhật vị trí hiện tại',
      );
    }
  }
}