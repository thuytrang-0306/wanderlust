import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/data/services/image_upload_service.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:wanderlust/core/services/storage_service.dart';

class UserProfileController extends BaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageUploadService _imageUpload = Get.put(ImageUploadService());
  
  // User data
  final userName = 'Nguyen Thuy Trang'.obs;
  final userEmail = 'thuytrang@gmail.com'.obs;
  final userAvatar = ''.obs;
  
  // Stats
  final totalTrips = 12.obs;
  final totalBookings = 28.obs;
  final totalReviews = 45.obs;
  final totalPoints = 2850.obs;
  final activeTripsCount = 2.obs;
  
  // Settings
  final notificationsEnabled = true.obs;
  final currentLanguage = 'Tiếng Việt'.obs;
  final appVersion = '1.0.0'.obs;
  
  final ImagePicker _imagePicker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadStats();
  }
  
  void loadUserData() {
    // Load from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userName.value = user.displayName ?? 'User';
      userEmail.value = user.email ?? '';
      userAvatar.value = user.photoURL ?? '';
    }
    
    // Load from local storage
    final savedNotifications = StorageService.to.read('notifications_enabled');
    if (savedNotifications != null) {
      notificationsEnabled.value = savedNotifications;
    }
    
    final savedLanguage = StorageService.to.read('app_language');
    if (savedLanguage != null) {
      currentLanguage.value = savedLanguage == 'vi' ? 'Tiếng Việt' : 'English';
    }
  }
  
  void loadStats() {
    // TODO: Load actual stats from API
    // For now using mock data
    totalTrips.value = 12;
    totalBookings.value = 28;
    totalReviews.value = 45;
    totalPoints.value = 2850;
    activeTripsCount.value = 2;
  }
  
  void changeAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        AppSnackbar.showInfo(
          message: 'Đang tải ảnh lên...',
        );
        
        // Upload image using ImageUploadService (Cloudinary/ImgBB)
        final imageUrl = await _imageUpload.uploadAvatar(File(image.path));
        
        if (imageUrl != null) {
          // Update Firestore
          final user = _auth.currentUser;
          if (user != null) {
            await _firestore.collection('users').doc(user.uid).update({
              'photoURL': imageUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            
            // Update Firebase Auth profile
            await user.updatePhotoURL(imageUrl);
          }
          
          // Update local state
          userAvatar.value = imageUrl;
          
          AppSnackbar.showSuccess(
            message: 'Cập nhật ảnh đại diện thành công',
          );
        } else {
          AppSnackbar.showError(
            message: 'Không thể tải ảnh lên',
          );
        }
      }
    } catch (e) {
      AppSnackbar.showError(
        message: 'Không thể cập nhật ảnh: $e',
      );
    }
  }
  
  void navigateToMyTrips() {
    Get.toNamed('/my-trips');
  }
  
  void navigateToSaved() {
    Get.toNamed('/saved-collections');
  }
  
  void navigateToBookingHistory() {
    Get.toNamed('/booking-history');
  }
  
  void navigateToMyReviews() {
    Get.toNamed('/my-reviews');
  }
  
  void navigateToEditProfile() {
    Get.toNamed('/edit-profile');
  }
  
  void navigateToSecurity() {
    Get.toNamed('/security-settings');
  }
  
  void navigateToNotificationSettings() {
    Get.toNamed('/notification-settings');
  }
  
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    StorageService.to.write('notifications_enabled', value);
    
    AppSnackbar.showInfo(
      message: value 
        ? 'Đã bật thông báo' 
        : 'Đã tắt thông báo',
    );
  }
  
  void changeLanguage() {
    Get.dialog(
      AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: currentLanguage.value == 'Tiếng Việt' ? 'vi' : 'en',
              onChanged: (value) {
                currentLanguage.value = 'Tiếng Việt';
                StorageService.to.write('app_language', 'vi');
                Get.back();
                AppSnackbar.showSuccess(
                  message: 'Đã chuyển sang Tiếng Việt',
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLanguage.value == 'Tiếng Việt' ? 'vi' : 'en',
              onChanged: (value) {
                currentLanguage.value = 'English';
                StorageService.to.write('app_language', 'en');
                Get.back();
                AppSnackbar.showSuccess(
                  message: 'Changed to English',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void navigateToHelp() {
    Get.toNamed('/help-center');
  }
  
  void navigateToContact() {
    Get.toNamed('/contact-support');
  }
  
  void navigateToAbout() {
    Get.toNamed('/about');
  }
  
  void navigateToSettings() {
    Get.toNamed('/settings');
  }
  
  void logout() async {
    final confirm = await AppDialogs.showConfirm(
      title: 'Đăng xuất',
      message: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
    );
    
    if (confirm) {
      try {
        AppDialogs.showLoading(message: 'Đang đăng xuất...');
        
        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();
        
        // Clear local storage
        await StorageService.to.clearAll();
        
        AppDialogs.hideLoading();
        
        // Navigate to login
        Get.offAllNamed('/login');
        
        AppSnackbar.showInfo(
          message: 'Đã đăng xuất thành công',
        );
      } catch (e) {
        AppDialogs.hideLoading();
        AppSnackbar.showError(
          message: 'Không thể đăng xuất: $e',
        );
      }
    }
  }
}