import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

class TripEditController extends GetxController {
  // Controllers for text fields
  final tripNameController = TextEditingController();
  final destinationController = TextEditingController();
  
  // Observable values
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxInt numberOfPeople = 1.obs;
  final RxBool isEditMode = false.obs;
  
  // Error handling
  final RxMap<String, String?> errors = <String, String?>{}.obs;
  
  // Trip ID for edit mode
  String? tripId;
  
  @override
  void onInit() {
    super.onInit();
    
    // Check arguments
    final arguments = Get.arguments;
    if (arguments != null) {
      // Check if creating from combo
      if (arguments['fromCombo'] == true && arguments['comboData'] != null) {
        _loadFromCombo(arguments['comboData']);
      }
      // Check if we're in edit mode
      else if (arguments['tripId'] != null) {
        isEditMode.value = true;
        tripId = arguments['tripId'];
        _loadTripData(tripId!);
      }
    }
  }
  
  @override
  void onClose() {
    tripNameController.dispose();
    destinationController.dispose();
    super.onClose();
  }
  
  void _loadTripData(String id) {
    // TODO: Load trip data from repository
    // For now, using fake data
    tripNameController.text = 'Nguyên Đán Hà Giang';
    destinationController.text = 'Hà Giang';
    startDate.value = DateTime(2025, 1, 8);
    endDate.value = DateTime(2025, 1, 12);
    numberOfPeople.value = 2;
  }
  
  void _loadFromCombo(Map<String, dynamic> comboData) {
    // Extract title without "Tour" prefix
    String title = comboData['title'] ?? '';
    if (title.startsWith('Tour ')) {
      title = title.substring(5);
    }
    
    tripNameController.text = title;
    destinationController.text = comboData['location'] ?? '';
    
    // Parse duration to calculate dates
    String duration = comboData['duration'] ?? '2 ngày 1 đêm';
    int days = _parseDaysFromDuration(duration);
    
    // Set dates starting from tomorrow
    startDate.value = DateTime.now().add(const Duration(days: 1));
    endDate.value = startDate.value?.add(Duration(days: days - 1));
    
    numberOfPeople.value = 1;
    
    // Show success message
    AppSnackbar.showInfo(
      message: 'Đã tải thông tin từ combo tour',
    );
  }
  
  int _parseDaysFromDuration(String duration) {
    // Parse "X ngày Y đêm" format
    final regex = RegExp(r'(\d+)\s*ngày');
    final match = regex.firstMatch(duration);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '2') ?? 2;
    }
    return 2; // Default 2 days
  }
  
  void updateField(String field, String value) {
    // Clear error when user starts typing
    errors[field] = null;
  }
  
  void updateStartDate(DateTime? date) {
    startDate.value = date;
    errors['startDate'] = null;
    
    // If end date is before start date, clear it
    if (endDate.value != null && date != null && endDate.value!.isBefore(date)) {
      endDate.value = null;
    }
  }
  
  void updateEndDate(DateTime? date) {
    endDate.value = date;
    errors['endDate'] = null;
  }
  
  void increasePeople() {
    if (numberOfPeople.value < 99) {
      numberOfPeople.value++;
    }
  }
  
  void decreasePeople() {
    if (numberOfPeople.value > 1) {
      numberOfPeople.value--;
    }
  }
  
  bool _validateForm() {
    bool isValid = true;
    errors.clear();
    
    // Validate trip name
    if (tripNameController.text.trim().isEmpty) {
      errors['tripName'] = 'Vui lòng nhập tên lịch trình';
      isValid = false;
    }
    
    // Validate destination
    if (destinationController.text.trim().isEmpty) {
      errors['destination'] = 'Vui lòng nhập điểm đến';
      isValid = false;
    }
    
    // Validate start date
    if (startDate.value == null) {
      errors['startDate'] = 'Vui lòng chọn ngày bắt đầu';
      isValid = false;
    }
    
    // Validate end date
    if (endDate.value == null) {
      errors['endDate'] = 'Vui lòng chọn ngày kết thúc';
      isValid = false;
    }
    
    // Validate date range
    if (startDate.value != null && endDate.value != null) {
      if (endDate.value!.isBefore(startDate.value!)) {
        errors['endDate'] = 'Ngày kết thúc phải sau ngày bắt đầu';
        isValid = false;
      }
    }
    
    return isValid;
  }
  
  void saveTripPlan() {
    if (!_validateForm()) {
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Vui lòng kiểm tra lại thông tin',
      );
      return;
    }
    
    // Format date range
    String dateRange = '';
    if (startDate.value != null && endDate.value != null) {
      final startStr = 'T${startDate.value!.weekday == 7 ? "CN" : (startDate.value!.weekday + 1).toString()}, ${startDate.value!.day}/${startDate.value!.month}';
      final endStr = 'CN, ${endDate.value!.day}/${endDate.value!.month}';
      dateRange = '$startStr - $endStr';
    }
    
    // TODO: Save to repository
    final tripData = {
      'tripName': tripNameController.text.trim(),
      'destination': destinationController.text.trim(),
      'startDate': startDate.value,
      'endDate': endDate.value,
      'numberOfPeople': numberOfPeople.value,
      'dateRange': dateRange,
    };
    
    if (isEditMode.value) {
      // Update existing trip
      AppSnackbar.showSuccess(
        title: 'Thành công',
        message: 'Đã cập nhật lịch trình',
      );
    } else {
      // Create new trip
      AppSnackbar.showSuccess(
        title: 'Thành công',
        message: 'Đã tạo lịch trình mới',
      );
    }
    
    // Navigate to Trip Detail page
    Get.offNamed('/trip-detail', arguments: {
      'tripName': tripNameController.text.trim(),
      'dateRange': dateRange,
      'peopleCount': numberOfPeople.value,
      'tripImage': '', // Will be added later when image picker is implemented
    });
  }
}