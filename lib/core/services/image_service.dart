import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';

class ImageService extends GetxService {
  static ImageService get to => Get.find();
  
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Image quality settings
  static const int imageQuality = 85;
  static const int maxWidth = 1080;
  static const int maxHeight = 1920;
  static const int thumbnailSize = 300;
  
  Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    bool compress = true,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: compress ? imageQuality : 100,
        maxWidth: compress ? maxWidth.toDouble() : null,
        maxHeight: compress ? maxHeight.toDouble() : null,
      );
      
      if (pickedFile != null) {
        LoggerService.i('Image picked: ${pickedFile.path}');
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error picking image', error: e);
      AppDialogs.showError(
        title: 'Image Picker Error',
        message: 'Failed to pick image. Please try again.',
      );
      return null;
    }
  }
  
  Future<List<File>?> pickMultipleImages({
    bool compress = true,
    int? limit,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: compress ? imageQuality : 100,
        maxWidth: compress ? maxWidth.toDouble() : null,
        maxHeight: compress ? maxHeight.toDouble() : null,
        limit: limit,
      );
      
      if (pickedFiles.isNotEmpty) {
        LoggerService.i('${pickedFiles.length} images picked');
        return pickedFiles.map((file) => File(file.path)).toList();
      }
      return null;
    } catch (e) {
      LoggerService.e('Error picking multiple images', error: e);
      AppDialogs.showError(
        title: 'Image Picker Error',
        message: 'Failed to pick images. Please try again.',
      );
      return null;
    }
  }
  
  Future<File?> showImageSourceDialog() async {
    final source = await Get.bottomSheet<ImageSource>(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
    
    if (source != null) {
      return pickImage(source: source);
    }
    return null;
  }
  
  Future<File?> compressImage(
    File file, {
    int quality = imageQuality,
    int? minWidth,
    int? minHeight,
  }) async {
    try {
      final String targetPath = file.path.replaceFirst(
        path.extension(file.path),
        '_compressed${path.extension(file.path)}',
      );
      
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth ?? maxWidth,
        minHeight: minHeight ?? maxHeight,
      );
      
      if (result != null) {
        final compressedFile = File(result.path);
        final originalSize = await file.length();
        final compressedSize = await compressedFile.length();
        
        LoggerService.i(
          'Image compressed: ${originalSize ~/ 1024}KB -> ${compressedSize ~/ 1024}KB',
        );
        
        return compressedFile;
      }
      return file;
    } catch (e) {
      LoggerService.e('Error compressing image', error: e);
      return file;
    }
  }
  
  Future<String?> uploadImage(
    File file, {
    required String path,
    bool showProgress = true,
    Function(double)? onProgress,
  }) async {
    try {
      if (showProgress) {
        AppDialogs.showLoading(message: 'Uploading image...');
      }
      
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
      final Reference ref = _storage.ref().child(path).child(fileName);
      
      final UploadTask uploadTask = ref.putFile(file);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
        LoggerService.d('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (showProgress) {
        AppDialogs.hideLoading();
      }
      
      LoggerService.i('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      if (showProgress) {
        AppDialogs.hideLoading();
      }
      LoggerService.e('Error uploading image', error: e);
      AppDialogs.showError(
        title: 'Upload Failed',
        message: 'Failed to upload image. Please try again.',
      );
      return null;
    }
  }
  
  Future<List<String>> uploadMultipleImages(
    List<File> files, {
    required String path,
    bool showProgress = true,
  }) async {
    try {
      if (showProgress) {
        AppDialogs.showLoading(message: 'Uploading ${files.length} images...');
      }
      
      final List<String> urls = [];
      
      for (int i = 0; i < files.length; i++) {
        final url = await uploadImage(
          files[i],
          path: path,
          showProgress: false,
        );
        
        if (url != null) {
          urls.add(url);
        }
      }
      
      if (showProgress) {
        AppDialogs.hideLoading();
      }
      
      LoggerService.i('Uploaded ${urls.length}/${files.length} images successfully');
      return urls;
    } catch (e) {
      if (showProgress) {
        AppDialogs.hideLoading();
      }
      LoggerService.e('Error uploading multiple images', error: e);
      return [];
    }
  }
  
  Future<bool> deleteImage(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
      LoggerService.i('Image deleted: $url');
      return true;
    } catch (e) {
      LoggerService.e('Error deleting image', error: e);
      return false;
    }
  }
  
  Future<File?> cropImage(File file) async {
    // Implement image cropping if needed
    // You can use packages like image_cropper
    return file;
  }
}