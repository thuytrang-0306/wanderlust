import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/core/services/unified_image_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/models/room_model.dart';
import 'package:wanderlust/data/services/room_service.dart';

class CreateRoomController extends GetxController {
  final RoomService _roomService = Get.find<RoomService>();
  final UnifiedImageService _imageService = Get.find<UnifiedImageService>();
  
  // Form controllers
  final roomNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final discountPriceController = TextEditingController();
  final maxGuestsController = TextEditingController(text: '2');
  final numberOfBedsController = TextEditingController(text: '1');
  final roomSizeController = TextEditingController();
  final floorController = TextEditingController();
  final viewTypeController = TextEditingController();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Selected room type
  final Rx<RoomType> selectedRoomType = RoomType.single.obs;
  
  // Room images
  final RxList<String> roomImages = <String>[].obs;
  final RxBool isUploadingImage = false.obs;
  
  // Amenities
  final RxList<String> selectedAmenities = <String>[].obs;
  
  // Facilities toggles
  final RxBool hasBalcony = false.obs;
  final RxBool hasKitchen = false.obs;
  final RxBool hasAirConditioner = false.obs;
  final RxBool hasWifi = true.obs;
  final RxBool hasTV = false.obs;
  final RxBool hasRefrigerator = false.obs;
  final RxBool hasBathroom = true.obs;
  final RxBool hasHotWater = false.obs;
  
  // Loading state
  final RxBool isLoading = false.obs;
  
  // Common amenities list
  final List<String> commonAmenities = [
    'Máy sấy tóc',
    'Két an toàn',
    'Minibar',
    'Bàn làm việc',
    'Ghế sofa',
    'Máy pha cà phê',
    'Dép trong phòng',
    'Khăn tắm',
    'Đồ vệ sinh cá nhân',
    'Gương trang điểm',
    'Tủ quần áo',
    'Móc treo đồ',
    'Ban công riêng',
    'View biển',
    'View núi',
    'View thành phố',
    'Phòng không hút thuốc',
    'Cách âm',
  ];
  
  @override
  void onInit() {
    super.onInit();
    // Set default amenities
    selectedAmenities.addAll(['Khăn tắm', 'Dép trong phòng', 'Đồ vệ sinh cá nhân']);
  }
  
  @override
  void onClose() {
    roomNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    discountPriceController.dispose();
    maxGuestsController.dispose();
    numberOfBedsController.dispose();
    roomSizeController.dispose();
    floorController.dispose();
    viewTypeController.dispose();
    super.onClose();
  }
  
  // Toggle amenity selection
  void toggleAmenity(String amenity) {
    if (selectedAmenities.contains(amenity)) {
      selectedAmenities.remove(amenity);
    } else {
      selectedAmenities.add(amenity);
    }
  }
  
  // Pick and add room image
  Future<void> pickRoomImage() async {
    try {
      isUploadingImage.value = true;
      
      final imagePath = await _imageService.pickImage(source: ImageSource.gallery);
      if (imagePath != null) {
        // Convert to base64
        final base64Image = await _imageService.imageToBase64(imagePath);
        if (base64Image != null) {
          roomImages.add(base64Image);
          LoggerService.i('Room image added, total: ${roomImages.length}');
        }
      }
    } catch (e) {
      LoggerService.e('Error picking room image', error: e);
      AppSnackbar.showError(message: 'Không thể tải ảnh lên');
    } finally {
      isUploadingImage.value = false;
    }
  }
  
  // Remove room image
  void removeImage(int index) {
    if (index < roomImages.length) {
      roomImages.removeAt(index);
    }
  }
  
  // Validate form
  String? validateRoomName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên phòng';
    }
    if (value.trim().length < 3) {
      return 'Tên phòng phải có ít nhất 3 ký tự';
    }
    return null;
  }
  
  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập giá phòng';
    }
    final price = double.tryParse(value.trim());
    if (price == null || price <= 0) {
      return 'Giá phòng phải là số dương';
    }
    return null;
  }
  
  String? validateDiscountPrice(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    
    final discountPrice = double.tryParse(value.trim());
    if (discountPrice == null || discountPrice <= 0) {
      return 'Giá khuyến mãi phải là số dương';
    }
    
    final originalPrice = double.tryParse(priceController.text.trim()) ?? 0;
    if (discountPrice >= originalPrice) {
      return 'Giá khuyến mãi phải nhỏ hơn giá gốc';
    }
    
    return null;
  }
  
  String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    final number = int.tryParse(value.trim());
    if (number == null || number <= 0) {
      return '$fieldName phải là số dương';
    }
    return null;
  }
  
  String? validateRoomSize(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập diện tích phòng';
    }
    final size = double.tryParse(value.trim());
    if (size == null || size <= 0) {
      return 'Diện tích phải là số dương';
    }
    return null;
  }
  
  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập mô tả phòng';
    }
    if (value.trim().length < 20) {
      return 'Mô tả phải có ít nhất 20 ký tự';
    }
    return null;
  }
  
  // Submit create room
  Future<void> submitCreateRoom() async {
    try {
      // Validate form
      if (!formKey.currentState!.validate()) {
        AppSnackbar.showError(message: 'Vui lòng kiểm tra lại thông tin');
        return;
      }
      
      // Validate images
      if (roomImages.isEmpty) {
        AppSnackbar.showError(message: 'Vui lòng thêm ít nhất 1 ảnh phòng');
        return;
      }
      
      // Validate description
      if (descriptionController.text.trim().isEmpty) {
        AppSnackbar.showError(message: 'Vui lòng nhập mô tả phòng');
        return;
      }
      
      AppDialogs.showLoading(message: 'Đang tạo phòng...');
      isLoading.value = true;
      
      // Parse values
      final pricePerNight = double.parse(priceController.text.trim());
      final discountPrice = discountPriceController.text.trim().isNotEmpty 
          ? double.parse(discountPriceController.text.trim())
          : null;
      final maxGuests = int.parse(maxGuestsController.text.trim());
      final numberOfBeds = int.parse(numberOfBedsController.text.trim());
      final roomSize = double.parse(roomSizeController.text.trim());
      
      // Create room
      final room = await _roomService.createRoom(
        roomName: roomNameController.text.trim(),
        roomType: selectedRoomType.value,
        description: descriptionController.text.trim(),
        pricePerNight: pricePerNight,
        discountPrice: discountPrice,
        maxGuests: maxGuests,
        numberOfBeds: numberOfBeds,
        roomSize: roomSize,
        amenities: selectedAmenities,
        images: roomImages,
        floor: floorController.text.trim().isNotEmpty 
            ? floorController.text.trim() 
            : null,
        viewType: viewTypeController.text.trim().isNotEmpty
            ? viewTypeController.text.trim()
            : null,
        hasBalcony: hasBalcony.value,
        hasKitchen: hasKitchen.value,
        hasAirConditioner: hasAirConditioner.value,
        hasWifi: hasWifi.value,
        hasTV: hasTV.value,
        hasRefrigerator: hasRefrigerator.value,
        hasBathroom: hasBathroom.value,
        hasHotWater: hasHotWater.value,
      );
      
      AppDialogs.hideLoading();
      
      if (room != null) {
        AppSnackbar.showSuccess(message: 'Tạo phòng thành công!');
        Get.back(result: true); // Return true to indicate success
      } else {
        AppSnackbar.showError(message: 'Không thể tạo phòng');
      }
    } catch (e) {
      LoggerService.e('Error creating room', error: e);
      AppDialogs.hideLoading();
      AppSnackbar.showError(message: 'Có lỗi xảy ra: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}