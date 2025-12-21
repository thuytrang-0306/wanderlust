import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/data/models/trip_model.dart';
import 'package:wanderlust/data/models/destination_model.dart';
import 'package:wanderlust/data/services/trip_service.dart';
import 'package:wanderlust/data/services/destination_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripEditController extends BaseController {
  // Services
  final TripService _tripService = Get.find<TripService>();
  final DestinationService _destinationService = Get.find<DestinationService>();

  // Controllers
  final tripNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final destinationController = TextEditingController();
  final budgetController = TextEditingController();
  final notesController = TextEditingController();

  // Form validation is done manually since TripEditPage doesn't use Form widget

  // Data
  TripModel? editingTrip;
  final RxList<DestinationModel> availableDestinations = <DestinationModel>[].obs;
  DestinationModel? selectedDestination;

  // Date selection - Non-nullable to avoid null issues
  final Rx<DateTime> startDate = DateTime.now().add(const Duration(days: 7)).obs;
  final Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 10)).obs;

  // UI State
  final RxBool isSaving = false.obs;
  final RxBool isEditMode = false.obs;
  final RxString selectedVisibility = 'private'.obs;
  final RxList<String> selectedTags = <String>[].obs;
  final RxInt numberOfPeople = 1.obs;
  final RxMap<String, String?> errors = <String, String?>{}.obs;
  final RxString coverImage = ''.obs; // Base64 cover image

  // Available tags
  final List<String> availableTags = [
    'Phiêu lưu',
    'Thư giãn',
    'Gia đình',
    'Bạn bè',
    'Cặp đôi',
    'Một mình',
    'Công tác',
    'Backpacker',
    'Luxury',
    'Budget',
  ];

  @override
  void onInit() {
    super.onInit();

    // Check if editing existing trip
    final args = Get.arguments;
    if (args != null && args['trip'] != null) {
      editingTrip = args['trip'] as TripModel;
      isEditMode.value = true;
      _loadTripData();
    }

    loadDestinations();
  }

  @override
  void onClose() {
    tripNameController.dispose();
    descriptionController.dispose();
    destinationController.dispose();
    budgetController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void _loadTripData() {
    if (editingTrip == null) return;

    tripNameController.text = editingTrip!.title;
    descriptionController.text = editingTrip!.description;
    destinationController.text = editingTrip!.destination;
    budgetController.text = editingTrip!.budget > 0 ? editingTrip!.budget.toStringAsFixed(0) : '';
    notesController.text = editingTrip!.notes;

    startDate.value = editingTrip!.startDate;
    endDate.value = editingTrip!.endDate;
    selectedVisibility.value = editingTrip!.visibility;
    selectedTags.value = editingTrip!.tags;
    numberOfPeople.value = editingTrip!.travelers.length;
    coverImage.value = editingTrip!.coverImage; // Load existing cover image
  }

  Future<void> loadDestinations() async {
    try {
      final destinations = await _destinationService.getAllDestinations();
      availableDestinations.value = destinations;
    } catch (e) {
      LoggerService.e('Error loading destinations', error: e);
    }
  }

  void selectDestination(DestinationModel destination) {
    selectedDestination = destination;
    destinationController.text = destination.name;
  }

  Future<void> selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      startDate.value = picked;

      // Adjust end date if needed
      if (endDate.value.isBefore(picked)) {
        endDate.value = picked.add(const Duration(days: 3));
      }
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value,
      firstDate: startDate.value,
      lastDate: startDate.value.add(const Duration(days: 365)),
    );

    if (picked != null) {
      endDate.value = picked;
    }
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  void setVisibility(String visibility) {
    selectedVisibility.value = visibility;
  }

  int get tripDuration => endDate.value.difference(startDate.value).inDays + 1;

  String get durationText {
    final days = tripDuration;
    if (days == 1) return '1 ngày';
    if (days < 7) return '$days ngày';
    final weeks = (days / 7).floor();
    final remainingDays = days % 7;
    if (remainingDays == 0) return '$weeks tuần';
    return '$weeks tuần $remainingDays ngày';
  }

  // Missing methods for TripEditPage
  void updateField(String field, String value) {
    // Clear error when user types
    errors[field] = null;

    // Validate field
    switch (field) {
      case 'tripName':
        if (value.trim().isEmpty) {
          errors[field] = 'Vui lòng nhập tên lịch trình';
        } else if (value.trim().length < 3) {
          errors[field] = 'Tên phải có ít nhất 3 ký tự';
        }
        break;
      case 'destination':
        if (value.trim().isEmpty) {
          errors[field] = 'Vui lòng nhập điểm đến';
        }
        break;
    }
  }

  void updateStartDate(DateTime? date) {
    if (date != null) {
      startDate.value = date;
      // Adjust end date if needed
      if (endDate.value.isBefore(date)) {
        endDate.value = date.add(const Duration(days: 3));
      }
    }
  }

  void updateEndDate(DateTime? date) {
    if (date != null && !date.isBefore(startDate.value)) {
      endDate.value = date;
    }
  }

  void increasePeople() {
    if (numberOfPeople.value < 50) {
      numberOfPeople.value++;
    }
  }

  void decreasePeople() {
    if (numberOfPeople.value > 1) {
      numberOfPeople.value--;
    }
  }

  // Set cover image
  void setCoverImage(String base64Image) {
    coverImage.value = base64Image;
  }

  // Save trip plan (alias for saveTrip)
  void saveTripPlan() {
    saveTrip();
  }

  // Update saveTrip to use correct controller name
  Future<void> saveTrip() async {
    LoggerService.i('Starting saveTrip process');

    // Clear all errors
    errors.clear();

    // Validate all fields
    if (tripNameController.text.trim().isEmpty) {
      errors['tripName'] = 'Vui lòng nhập tên lịch trình';
      LoggerService.w('Validation failed: empty trip name');
      AppSnackbar.showError(title: 'Lỗi', message: 'Vui lòng nhập tên lịch trình');
      return;
    }

    if (tripNameController.text.trim().length < 3) {
      errors['tripName'] = 'Tên phải có ít nhất 3 ký tự';
      LoggerService.w('Validation failed: trip name too short');
      AppSnackbar.showError(title: 'Lỗi', message: 'Tên phải có ít nhất 3 ký tự');
      return;
    }

    if (destinationController.text.trim().isEmpty) {
      errors['destination'] = 'Vui lòng nhập điểm đến';
      LoggerService.w('Validation failed: empty destination');
      AppSnackbar.showError(title: 'Lỗi', message: 'Vui lòng nhập điểm đến');
      return;
    }

    // Validate budget if provided
    if (budgetController.text.isNotEmpty) {
      final budget = double.tryParse(budgetController.text);
      if (budget == null || budget < 0) {
        errors['budget'] = 'Ngân sách không hợp lệ';
        LoggerService.w('Validation failed: invalid budget');
        AppSnackbar.showError(title: 'Lỗi', message: 'Ngân sách không hợp lệ');
        return;
      }
    }

    LoggerService.i('Validation passed, proceeding with save');

    try {
      isSaving.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppSnackbar.showError(title: 'Lỗi', message: 'Vui lòng đăng nhập để tiếp tục');
        return;
      }

      // Use user-selected cover image if available, otherwise try destination image
      String coverImageToSave = coverImage.value;
      if (coverImageToSave.isEmpty &&
          selectedDestination != null &&
          selectedDestination!.images.isNotEmpty) {
        coverImageToSave = selectedDestination!.images.first;
      }

      if (editingTrip != null) {
        // Update existing trip
        final updates = {
          'title': tripNameController.text.trim(),
          'description': descriptionController.text.trim(),
          'destination': destinationController.text.trim(),
          'destinationId': selectedDestination?.id,
          'startDate': startDate.value,
          'endDate': endDate.value,
          'budget': double.tryParse(budgetController.text) ?? 0,
          'notes': notesController.text.trim(),
          'visibility': selectedVisibility.value,
          'tags': selectedTags,
          'coverImage': coverImageToSave,
        };

        final success = await _tripService.updateTrip(editingTrip!.id, updates);

        if (success) {
          // Navigate back immediately
          Get.back(result: {'success': true, 'tripId': editingTrip!.id});

          // Show success message after navigation
          AppSnackbar.showSuccess(title: 'Thành công', message: 'Đã cập nhật chuyến đi');
        } else {
          AppSnackbar.showError(title: 'Lỗi', message: 'Không thể cập nhật chuyến đi');
        }
      } else {
        // Create new trip
        LoggerService.i('Creating new trip');

        final newTrip = TripModel(
          id: '',
          userId: user.uid,
          title: tripNameController.text.trim(),
          description: descriptionController.text.trim(),
          destination: destinationController.text.trim(),
          destinationId: selectedDestination?.id,
          startDate: startDate.value,
          endDate: endDate.value,
          budget: double.tryParse(budgetController.text) ?? 0,
          spentAmount: 0,
          travelers: [
            TripTraveler(
              id: user.uid,
              name: user.displayName ?? 'Bạn',
              email: user.email,
              role: 'owner',
            ),
          ],
          status: 'planning',
          visibility: selectedVisibility.value,
          coverImage: coverImageToSave,
          notes: notesController.text.trim(),
          tags: selectedTags,
          stats: TripStats.empty(),
        );

        LoggerService.i('Calling _tripService.createTrip');
        final tripId = await _tripService.createTrip(newTrip);

        if (tripId != null) {
          LoggerService.i('Trip created successfully with ID: $tripId');

          // Navigate back immediately (controller will auto-dispose and clear form)
          Get.back(result: {'success': true, 'tripId': tripId});

          // Show success message after navigation
          AppSnackbar.showSuccess(title: 'Thành công', message: 'Đã tạo chuyến đi mới');
        } else {
          LoggerService.e('Failed to create trip - returned null');
          AppSnackbar.showError(title: 'Lỗi', message: 'Không thể tạo chuyến đi');
        }
      }
    } catch (e) {
      LoggerService.e('Error saving trip', error: e);
      AppSnackbar.showError(title: 'Lỗi', message: 'Có lỗi xảy ra');
    } finally {
      isSaving.value = false;
    }
  }
}
