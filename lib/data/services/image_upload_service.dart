import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Service để xử lý images với base64 encoding
/// KHÔNG dùng external storage - chỉ dùng Firestore với base64
/// Đã test thành công với user avatar, blog posts
class ImageUploadService extends GetxService {
  static ImageUploadService get to => Get.find();

  final ImagePicker _picker = ImagePicker();

  // Image compression settings cho base64 storage
  static const int MAX_WIDTH = 1024; // Giảm size để base64 không quá lớn
  static const int MAX_HEIGHT = 1024;
  static const int QUALITY = 70; // Balance quality vs size
  static const int AVATAR_SIZE = 300; // Avatar nhỏ hơn
  static const int THUMBNAIL_SIZE = 200; // Cho thumbnails

  /// Pick image từ gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: QUALITY,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error picking image from gallery', error: e);
      return null;
    }
  }

  /// Pick image từ camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: QUALITY,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error picking image from camera', error: e);
      return null;
    }
  }

  /// Convert image to base64 với compression
  Future<String?> convertToBase64(File imageFile, {bool isAvatar = false}) async {
    try {
      // Compress image trước khi convert
      final compressedFile = await _compressImage(
        imageFile,
        maxWidth: isAvatar ? AVATAR_SIZE : MAX_WIDTH,
        maxHeight: isAvatar ? AVATAR_SIZE : MAX_HEIGHT,
        quality: QUALITY,
      );

      if (compressedFile == null) return null;

      // Convert to base64
      final bytes = await compressedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      // Return as data URL format để AppImage widget có thể handle
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      LoggerService.e('Error converting image to base64', error: e);
      return null;
    }
  }

  /// Convert avatar image to base64 (smaller size)
  Future<String?> convertAvatarToBase64(File imageFile) async {
    return convertToBase64(imageFile, isAvatar: true);
  }

  /// Compress image file
  Future<File?> _compressImage(
    File file, {
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    try {
      final filePath = file.absolute.path;

      // Get file extension
      final lastIndex = filePath.lastIndexOf(RegExp(r'\.'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_compressed.jpg";

      final compressedBytes = await FlutterImageCompress.compressWithFile(
        filePath,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) {
        LoggerService.w('Image compression returned null');
        return file; // Return original if compression fails
      }

      // Write compressed bytes to new file
      final compressedFile = File(outPath);
      await compressedFile.writeAsBytes(compressedBytes);

      // Log compression ratio
      final originalSize = await file.length();
      final compressedSize = await compressedFile.length();
      final ratio = ((1 - (compressedSize / originalSize)) * 100).toStringAsFixed(1);
      LoggerService.i(
        'Image compressed by $ratio% (${originalSize ~/ 1024}KB -> ${compressedSize ~/ 1024}KB)',
      );

      return compressedFile;
    } catch (e) {
      LoggerService.e('Error compressing image', error: e);
      return file; // Return original if compression fails
    }
  }

  /// Show image picker dialog
  Future<String?> showImagePickerDialog() async {
    final source = await Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text('Chọn ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Từ thư viện'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    File? imageFile;
    if (source == ImageSource.gallery) {
      imageFile = await pickImageFromGallery();
    } else {
      imageFile = await pickImageFromCamera();
    }

    if (imageFile != null) {
      return await convertToBase64(imageFile);
    }

    return null;
  }

  /// Calculate base64 size in KB
  int calculateBase64SizeKB(String base64String) {
    // Remove data URL prefix if exists
    String cleanBase64 = base64String;
    if (base64String.startsWith('data:')) {
      cleanBase64 = base64String.split(',').last;
    }

    // Calculate size
    final bytes = utf8.encode(cleanBase64);
    return bytes.length ~/ 1024;
  }
}
