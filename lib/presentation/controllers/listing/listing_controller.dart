import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/core/services/unified_image_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:wanderlust/data/services/listing_service.dart';

/// One Controller for ALL listing operations
/// Simple but powerful
class ListingController extends GetxController {
  final ListingService _listingService = Get.find<ListingService>();
  final UnifiedImageService _imageService = Get.find<UnifiedImageService>();
  
  // Mode: create or edit
  final bool isEditMode;
  final String? listingId;
  ListingModel? currentListing;
  
  // Listing type
  final Rx<ListingType> selectedType;
  
  // Form
  final formKey = GlobalKey<FormState>();
  
  // Common fields
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final discountPriceController = TextEditingController();
  
  // Images
  final RxList<String> images = <String>[].obs;
  final RxBool isUploadingImage = false.obs;
  
  // Dynamic details based on type
  final RxMap<String, dynamic> details = <String, dynamic>{}.obs;
  
  // Detail controllers (created dynamically)
  final Map<String, TextEditingController> detailControllers = {};
  
  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  
  ListingController({
    this.isEditMode = false,
    this.listingId,
    ListingType? type,
  }) : selectedType = (type ?? ListingType.room).obs;
  
  @override
  void onInit() {
    super.onInit();
    if (isEditMode && listingId != null) {
      loadListing();
    } else {
      initializeDetailControllers();
    }
  }
  
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    discountPriceController.dispose();
    
    // Dispose detail controllers
    detailControllers.forEach((_, controller) => controller.dispose());
    
    super.onClose();
  }
  
  /// Initialize detail controllers based on type
  void initializeDetailControllers() {
    // Clear existing
    detailControllers.forEach((_, controller) => controller.dispose());
    detailControllers.clear();
    details.clear();
    
    // Create based on type
    switch (selectedType.value) {
      case ListingType.room:
        detailControllers['maxGuests'] = TextEditingController(text: '2');
        detailControllers['numberOfBeds'] = TextEditingController(text: '1');
        detailControllers['roomSize'] = TextEditingController();
        details['hasWifi'] = true;
        details['hasAirConditioner'] = false;
        details['hasTV'] = false;
        break;
        
      case ListingType.tour:
        detailControllers['duration'] = TextEditingController();
        detailControllers['groupSize'] = TextEditingController(text: '20');
        detailControllers['departure'] = TextEditingController();
        details['includeTransport'] = true;
        details['includeGuide'] = true;
        details['includeMeals'] = false;
        break;
        
      case ListingType.food:
        detailControllers['category'] = TextEditingController();
        detailControllers['serving'] = TextEditingController(text: '1 người');
        details['isVegetarian'] = false;
        details['isSpicy'] = false;
        break;
        
      case ListingType.service:
        detailControllers['duration'] = TextEditingController();
        detailControllers['location'] = TextEditingController();
        break;
    }
  }
  
  /// Load listing for editing
  Future<void> loadListing() async {
    try {
      isLoading.value = true;
      final listing = await _listingService.getListingById(listingId!);
      
      if (listing == null) {
        Get.back();
        AppSnackbar.showError(message: 'Không tìm thấy dữ liệu');
        return;
      }
      
      currentListing = listing;
      selectedType.value = listing.type;
      
      // Populate common fields
      titleController.text = listing.title;
      descriptionController.text = listing.description;
      priceController.text = listing.price.toStringAsFixed(0);
      discountPriceController.text = listing.discountPrice?.toStringAsFixed(0) ?? '';
      images.value = List.from(listing.images);
      
      // Populate details
      details.value = Map.from(listing.details);
      initializeDetailControllers();
      
      // Fill detail controllers from saved data
      listing.details.forEach((key, value) {
        if (detailControllers.containsKey(key) && value != null) {
          detailControllers[key]!.text = value.toString();
        }
      });
      
    } catch (e) {
      LoggerService.e('Error loading listing', error: e);
      Get.back();
      AppSnackbar.showError(message: 'Lỗi khi tải dữ liệu');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Pick image
  Future<void> pickImage() async {
    try {
      if (images.length >= 6) {
        AppSnackbar.showWarning(message: 'Tối đa 6 ảnh');
        return;
      }
      
      isUploadingImage.value = true;
      
      final imagePath = await _imageService.pickImage(source: ImageSource.gallery);
      if (imagePath != null) {
        final base64Image = await _imageService.imageToBase64(imagePath);
        if (base64Image != null) {
          images.add(base64Image);
        }
      }
    } catch (e) {
      LoggerService.e('Error picking image', error: e);
      AppSnackbar.showError(message: 'Không thể tải ảnh');
    } finally {
      isUploadingImage.value = false;
    }
  }
  
  /// Remove image
  void removeImage(int index) {
    if (index < images.length) {
      images.removeAt(index);
    }
  }
  
  /// Change listing type (only in create mode)
  void changeType(ListingType type) {
    if (!isEditMode) {
      selectedType.value = type;
      initializeDetailControllers();
    }
  }
  
  /// Toggle detail boolean
  void toggleDetail(String key, bool value) {
    details[key] = value;
  }
  
  /// Validation
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tiêu đề';
    }
    if (value.trim().length < 3) {
      return 'Tiêu đề phải có ít nhất 3 ký tự';
    }
    return null;
  }
  
  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập giá';
    }
    final price = double.tryParse(value.trim());
    if (price == null || price <= 0) {
      return 'Giá phải là số dương';
    }
    return null;
  }
  
  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập mô tả';
    }
    if (value.trim().length < 20) {
      return 'Mô tả phải có ít nhất 20 ký tự';
    }
    return null;
  }
  
  /// Submit
  Future<void> submit() async {
    try {
      if (!formKey.currentState!.validate()) {
        AppSnackbar.showError(message: 'Vui lòng kiểm tra lại thông tin');
        return;
      }
      
      if (images.isEmpty) {
        AppSnackbar.showError(message: 'Vui lòng thêm ít nhất 1 ảnh');
        return;
      }
      
      AppDialogs.showLoading(
        message: isEditMode ? 'Đang cập nhật...' : 'Đang tạo...'
      );
      isSaving.value = true;
      
      // Collect detail values from controllers
      final finalDetails = Map<String, dynamic>.from(details);
      detailControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          // Try to parse as number first
          final numValue = int.tryParse(controller.text) ?? 
                          double.tryParse(controller.text);
          finalDetails[key] = numValue ?? controller.text;
        }
      });
      
      bool success = false;
      
      if (isEditMode) {
        // Update
        final updates = {
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'price': double.parse(priceController.text.trim()),
          'discountPrice': discountPriceController.text.trim().isNotEmpty
              ? double.parse(discountPriceController.text.trim())
              : null,
          'images': images,
          'details': finalDetails,
        };
        success = await _listingService.updateListing(listingId!, updates);
      } else {
        // Create
        final created = await _listingService.createListing(
          type: selectedType.value,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          price: double.parse(priceController.text.trim()),
          discountPrice: discountPriceController.text.trim().isNotEmpty
              ? double.parse(discountPriceController.text.trim())
              : null,
          images: images,
          details: finalDetails,
        );
        success = created != null;
      }
      
      AppDialogs.hideLoading();
      
      if (success) {
        AppSnackbar.showSuccess(
          message: isEditMode ? 'Cập nhật thành công!' : 'Tạo thành công!'
        );
        Get.back(result: true);
      } else {
        AppSnackbar.showError(message: 'Có lỗi xảy ra');
      }
      
    } catch (e) {
      LoggerService.e('Error submitting', error: e);
      AppDialogs.hideLoading();
      AppSnackbar.showError(message: 'Có lỗi xảy ra');
    } finally {
      isSaving.value = false;
    }
  }
}