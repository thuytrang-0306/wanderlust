import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class UnifiedImageService extends GetxService {
  static UnifiedImageService get to => Get.find();

  final ImagePicker _picker = ImagePicker();

  // Image quality settings
  static const int maxWidth = 1024;
  static const int maxHeight = 1024;
  static const int quality = 85;
  static const int thumbnailWidth = 200;
  static const int thumbnailHeight = 200;
  static const int thumbnailQuality = 70;

  // Cache for decoded images
  final Map<String, Uint8List> _imageCache = {};
  static const int maxCacheSize = 50;

  /// Pick image from gallery or camera
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidthOverride,
    double? maxHeightOverride,
    int? qualityOverride,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidthOverride ?? maxWidth.toDouble(),
        maxHeight: maxHeightOverride ?? maxHeight.toDouble(),
        imageQuality: qualityOverride ?? quality,
      );

      if (image != null) {
        LoggerService.i('Image picked: ${image.path}');
      }

      return image;
    } catch (e) {
      LoggerService.e('Error picking image', error: e);
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<XFile>?> pickMultipleImages({
    double? maxWidthOverride,
    double? maxHeightOverride,
    int? qualityOverride,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidthOverride ?? maxWidth.toDouble(),
        maxHeight: maxHeightOverride ?? maxHeight.toDouble(),
        imageQuality: qualityOverride ?? quality,
      );

      if (images.isNotEmpty) {
        LoggerService.i('${images.length} images picked');
      }

      return images;
    } catch (e) {
      LoggerService.e('Error picking multiple images', error: e);
      return null;
    }
  }

  /// Compress image and convert to base64
  Future<String?> imageToBase64(XFile imageFile, {bool createThumbnail = false}) async {
    try {
      final bytes = await imageFile.readAsBytes();

      // Compress image
      final compressed = await compressImage(bytes, isThumb: createThumbnail);

      if (compressed == null) return null;

      // Convert to base64
      final base64String = base64Encode(compressed);

      LoggerService.i('Image converted to base64, size: ${base64String.length} chars');

      return base64String;
    } catch (e) {
      LoggerService.e('Error converting image to base64', error: e);
      return null;
    }
  }

  /// Compress image bytes
  Future<Uint8List?> compressImage(Uint8List bytes, {bool isThumb = false}) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: isThumb ? thumbnailWidth : maxWidth,
        minHeight: isThumb ? thumbnailHeight : maxHeight,
        quality: isThumb ? thumbnailQuality : quality,
        format: CompressFormat.jpeg,
      );

      LoggerService.i('Image compressed from ${bytes.length} to ${result.length} bytes');

      return result;
    } catch (e) {
      LoggerService.e('Error compressing image', error: e);
      return null;
    }
  }

  /// Convert base64 string to Uint8List with caching
  Uint8List? base64ToImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;

    try {
      // Check cache first
      if (_imageCache.containsKey(base64String)) {
        return _imageCache[base64String];
      }

      // Decode base64
      final bytes = base64Decode(base64String);

      // Add to cache
      _addToCache(base64String, bytes);

      return bytes;
    } catch (e) {
      LoggerService.e('Error decoding base64 image', error: e);
      return null;
    }
  }

  /// Process picked image for upload
  Future<Map<String, String?>?> processImageForUpload(XFile imageFile) async {
    try {
      // Create both full size and thumbnail
      final fullSize = await imageToBase64(imageFile);
      final thumbnail = await imageToBase64(imageFile, createThumbnail: true);

      if (fullSize == null) return null;

      return {'full': fullSize, 'thumbnail': thumbnail};
    } catch (e) {
      LoggerService.e('Error processing image for upload', error: e);
      return null;
    }
  }

  /// Process multiple images for upload
  Future<List<Map<String, String?>>> processMultipleImagesForUpload(List<XFile> imageFiles) async {
    final results = <Map<String, String?>>[];

    for (final file in imageFiles) {
      final processed = await processImageForUpload(file);
      if (processed != null) {
        results.add(processed);
      }
    }

    return results;
  }

  /// Save image from URL to base64
  Future<String?> urlToBase64(String imageUrl) async {
    try {
      // Download image using http package
      final response = await GetConnect().request(imageUrl, 'GET');

      if (response.bodyBytes == null) return null;

      // bodyBytes is already Uint8List
      final bytes = response.bodyBytes as Uint8List;

      // Compress and convert
      final compressed = await compressImage(bytes);
      if (compressed == null) return null;

      return base64Encode(compressed);
    } catch (e) {
      LoggerService.e('Error converting URL to base64', error: e);
      return null;
    }
  }

  /// Add image to cache with size limit
  void _addToCache(String key, Uint8List bytes) {
    // Remove oldest items if cache is full
    if (_imageCache.length >= maxCacheSize) {
      _imageCache.remove(_imageCache.keys.first);
    }

    _imageCache[key] = bytes;
  }

  /// Clear image cache
  void clearCache() {
    _imageCache.clear();
    LoggerService.i('Image cache cleared');
  }

  /// Get cache size
  int get cacheSize => _imageCache.length;

  /// Get total cache memory usage in bytes
  int get cacheMemoryUsage {
    int total = 0;
    for (final bytes in _imageCache.values) {
      total += bytes.length;
    }
    return total;
  }

  /// Clean up old cache entries
  void cleanupCache({int keepLast = 20}) {
    if (_imageCache.length <= keepLast) return;

    final keysToRemove = _imageCache.keys.take(_imageCache.length - keepLast).toList();
    for (final key in keysToRemove) {
      _imageCache.remove(key);
    }

    LoggerService.i('Cache cleaned up, kept last $keepLast items');
  }

  // ============ METHODS FROM ImageUploadService (for backward compatibility) ============

  /// Show image picker dialog UI
  Future<String?> showImagePickerDialog({bool withPrefix = true, bool isAvatar = false}) async {
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

    final imageFile = await pickImage(source: source);
    if (imageFile == null) return null;

    if (withPrefix) {
      return await imageToBase64WithPrefix(imageFile, isAvatar: isAvatar);
    } else {
      return await imageToBase64(imageFile, createThumbnail: isAvatar);
    }
  }

  /// Convert image to base64 with data URL prefix (for backward compatibility)
  Future<String?> imageToBase64WithPrefix(XFile imageFile, {bool isAvatar = false}) async {
    try {
      final bytes = await imageFile.readAsBytes();

      // Compress image
      final compressed = await compressImage(
        bytes,
        isThumb: isAvatar,
      );

      if (compressed == null) return null;

      // Convert to base64 with prefix
      final base64String = base64Encode(compressed);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      LoggerService.e('Error converting image to base64 with prefix', error: e);
      return null;
    }
  }

  /// Pick image and return as File (for backward compatibility)
  Future<File?> pickImageFromGallery() async {
    final xFile = await pickImage(source: ImageSource.gallery);
    return xFile != null ? File(xFile.path) : null;
  }

  /// Pick image from camera and return as File (for backward compatibility)
  Future<File?> pickImageFromCamera() async {
    final xFile = await pickImage(source: ImageSource.camera);
    return xFile != null ? File(xFile.path) : null;
  }

  /// Convert File to base64 with prefix (for backward compatibility)
  Future<String?> convertToBase64(File imageFile, {bool isAvatar = false}) async {
    final xFile = XFile(imageFile.path);
    return imageToBase64WithPrefix(xFile, isAvatar: isAvatar);
  }

  /// Convert avatar to base64 (for backward compatibility)
  Future<String?> convertAvatarToBase64(File imageFile) async {
    return convertToBase64(imageFile, isAvatar: true);
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
