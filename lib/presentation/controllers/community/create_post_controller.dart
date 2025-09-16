import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

class CreatePostController extends GetxController {
  // Text controllers
  final titleController = TextEditingController();
  final tagController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  
  // Observable values
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxList<String> selectedTags = <String>[].obs;
  final RxInt descriptionLength = 0.obs;
  final RxBool canShare = false.obs;
  
  // Available tags (predefined)
  final List<String> availableTags = [
    'Homestay',
    'TaXua',
    'Haiphong',
    'DaNang',
    'Khachsan',
    'Quan com',
  ];
  
  @override
  void onInit() {
    super.onInit();
    
    // Listen to title changes
    titleController.addListener(_updateShareButton);
  }
  
  @override
  void onClose() {
    titleController.dispose();
    tagController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
  
  void _updateShareButton() {
    canShare.value = titleController.text.trim().isNotEmpty;
  }
  
  void updateField() {
    _updateShareButton();
  }
  
  void updateDescription(String value) {
    descriptionLength.value = value.length;
    _updateShareButton();
  }
  
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      
      if (images.isNotEmpty) {
        // Limit to 5 images total
        if (selectedImages.length + images.length > 5) {
          AppSnackbar.showWarning(
            title: 'Giới hạn ảnh',
            message: 'Bạn chỉ có thể chọn tối đa 5 ảnh',
          );
          
          // Add only the images that fit within the limit
          final remaining = 5 - selectedImages.length;
          selectedImages.addAll(images.take(remaining));
        } else {
          selectedImages.addAll(images);
        }
      }
    } catch (e) {
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Không thể chọn ảnh',
      );
    }
  }
  
  void removeImage(int index) {
    selectedImages.removeAt(index);
  }
  
  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }
  
  void addCustomTag(String tag) {
    if (tag.trim().isNotEmpty && !selectedTags.contains(tag.trim())) {
      selectedTags.add(tag.trim());
      tagController.clear();
    }
  }
  
  void sharePost() {
    if (!canShare.value) {
      AppSnackbar.showWarning(
        title: 'Thiếu thông tin',
        message: 'Vui lòng nhập tiêu đề cho bài viết',
      );
      return;
    }
    
    // Validate minimum requirements
    if (selectedImages.isEmpty) {
      AppSnackbar.showWarning(
        title: 'Thiếu ảnh',
        message: 'Vui lòng thêm ít nhất một ảnh',
      );
      return;
    }
    
    // TODO: Upload images and create post
    final postData = {
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'tags': selectedTags.toList(),
      'images': selectedImages.map((e) => e.path).toList(),
    };
    
    AppSnackbar.showSuccess(
      title: 'Thành công',
      message: 'Bài viết đã được chia sẻ',
    );
    
    // Navigate back with result
    Get.back(result: postData);
  }
}