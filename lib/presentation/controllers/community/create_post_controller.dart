import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/services/blog_service.dart';
import 'package:wanderlust/data/services/image_upload_service.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';

class CreatePostController extends GetxController {
  // Services
  final BlogService _blogService = Get.find<BlogService>();
  final ImageUploadService _imageUploadService = Get.put(ImageUploadService());
  
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
  final RxBool isUploading = false.obs;
  
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
    
    // Listen to all text field changes
    titleController.addListener(_updateShareButton);
    descriptionController.addListener(_updateShareButton);
  }
  
  @override
  void onClose() {
    titleController.dispose();
    tagController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
  
  void _updateShareButton() {
    // Enable share if title is not empty (description is optional)
    canShare.value = titleController.text.trim().isNotEmpty && !isUploading.value;
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
  
  Future<void> sharePost() async {
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
    
    try {
      isUploading.value = true;
      canShare.value = false;
      
      // Show loading dialog
      AppDialogs.showLoading(message: 'Đang đăng bài...');
      
      // Convert images to base64
      List<String> uploadedImages = [];
      for (var imageFile in selectedImages) {
        // Convert to base64 data URL
        final imageData = await _imageUploadService.convertToBase64(
          File(imageFile.path),
        );
        if (imageData != null) {
          uploadedImages.add(imageData);
        }
      }
      
      // Use first image as cover, or placeholder if upload failed
      String coverImage = uploadedImages.isNotEmpty 
          ? uploadedImages.first
          : 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800';
      
      // Create excerpt from description (first 150 chars)
      String excerpt = descriptionController.text.trim();
      if (excerpt.isEmpty) {
        excerpt = titleController.text.trim();
      }
      if (excerpt.length > 150) {
        excerpt = '${excerpt.substring(0, 147)}...';
      }
      
      // Create post in Firestore
      final post = await _blogService.createPost(
        title: titleController.text.trim(),
        content: descriptionController.text.trim(),
        excerpt: excerpt,
        coverImage: coverImage,
        category: 'Du lịch',
        tags: selectedTags.toList(),
        destinations: selectedTags.where((tag) => 
          ['TaXua', 'Haiphong', 'DaNang'].contains(tag)
        ).toList(),
        images: uploadedImages.skip(1).toList(), // Rest as additional images
        publish: true,
      );
      
      // Close loading dialog first
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Close loading
      }
      
      if (post != null) {
        AppSnackbar.showSuccess(
          title: 'Thành công',
          message: 'Bài viết đã được chia sẻ',
        );
        
        // Wait a bit for snackbar to show
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Return to previous page with result
        Get.back(result: {
          'postId': post.id,
          'title': post.title,
        });
      } else {
        AppSnackbar.showError(
          title: 'Lỗi',
          message: 'Không thể tạo bài viết',
        );
      }
      
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Close loading if still showing
      }
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Đã xảy ra lỗi: ${e.toString()}',
      );
    } finally {
      isUploading.value = false;
      _updateShareButton();
    }
  }
}