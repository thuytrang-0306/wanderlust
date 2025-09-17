import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

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
  
  @override
  void onInit() {
    super.onInit();
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
  
  void onMapLongPress(double lat, double lng) {
    // Update selected coordinates
    selectedLat.value = lat;
    selectedLng.value = lng;
    
    // Update text fields
    latitudeController.text = lat.toStringAsFixed(6);
    longitudeController.text = lng.toStringAsFixed(6);
    
    // Update observable values
    latitude.value = lat.toString();
    longitude.value = lng.toString();
    
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
    
    // TODO: Save to database/repository
    
    AppSnackbar.showSuccess(
      title: 'Thành công',
      message: 'Đã thêm địa điểm riêng tư',
    );
    
    // Return data to previous page
    Get.back(result: locationData);
  }
  
  void navigateToCurrentLocation() {
    // TODO: Get current location and center map
    // For now, just show a message
    AppSnackbar.showInfo(
      title: 'Thông báo',
      message: 'Đang lấy vị trí hiện tại...',
    );
  }
}