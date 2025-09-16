import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class AccountController extends GetxController {
  // User data
  final Rx<String?> userPhotoUrl = Rx<String?>(null);
  final RxString userName = 'User'.obs;
  final RxString userEmail = ''.obs;
  
  // Settings
  final RxBool notificationsEnabled = true.obs;
  final RxBool darkModeEnabled = false.obs;
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }
  
  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userPhotoUrl.value = user.photoURL;
      userName.value = user.displayName ?? 'Wanderlust User';
      userEmail.value = user.email ?? '';
    }
  }
  
  void changeAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        // TODO: Upload image to Firebase Storage
        // For now, just show success message
        AppSnackbar.showSuccess(
          message: 'Avatar sẽ được cập nhật',
        );
      }
    } catch (e) {
      LoggerService.e('Failed to pick image', error: e);
      AppSnackbar.showError(
        message: 'Không thể chọn ảnh',
      );
    }
  }
  
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    // TODO: Update notification settings
    AppSnackbar.showInfo(
      message: value 
          ? 'Đã bật thông báo' 
          : 'Đã tắt thông báo',
    );
  }
  
  void toggleDarkMode(bool value) {
    darkModeEnabled.value = value;
    // TODO: Implement dark mode
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    AppSnackbar.showInfo(
      message: value 
          ? 'Đã bật chế độ tối' 
          : 'Đã tắt chế độ tối',
    );
  }
  
  void navigateToProfile() {
    AppSnackbar.showInfo(message: 'Tính năng đang phát triển');
  }
  
  void navigateToChangePassword() {
    AppSnackbar.showInfo(message: 'Tính năng đang phát triển');
  }
  
  void navigateToSavedPosts() {
    AppSnackbar.showInfo(message: 'Tính năng đang phát triển');
  }
  
  void navigateToTripHistory() {
    AppSnackbar.showInfo(message: 'Tính năng đang phát triển');
  }
  
  void navigateToFavorites() {
    AppSnackbar.showInfo(message: 'Tính năng đang phát triển');
  }
  
  void navigateToLanguage() {
    AppSnackbar.showInfo(message: 'Tính năng đang phát triển');
  }
  
  void navigateToHelp() {
    AppSnackbar.showInfo(message: 'Tính năng đang phát triển');
  }
  
  void navigateToPrivacy() {
    AppSnackbar.showInfo(message: 'Tính năng đang phát triển');
  }
  
  void navigateToTerms() {
    AppSnackbar.showInfo(message: 'Tính năng đang phát triển');
  }
  
  void navigateToAbout() {
    AppDialogs.showAlert(
      title: 'Về Wanderlust',
      message: '''Wanderlust - Ứng dụng du lịch hàng đầu Việt Nam
      
Phiên bản: 1.0.0
Build: 2024.1

Được phát triển bởi đội ngũ Wanderlust Team với mục tiêu mang đến trải nghiệm du lịch tốt nhất cho người dùng Việt Nam.

© 2024 Wanderlust. All rights reserved.''',
    );
  }
  
  void logout() async {
    // Show confirmation dialog
    final result = await AppDialogs.showConfirm(
      title: 'Đăng xuất',
      message: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
    );
    
    if (result == true) {
      try {
        AppDialogs.showLoading(message: 'Đang đăng xuất...');
        await FirebaseAuth.instance.signOut();
        AppDialogs.hideLoading();
        
        Get.offAllNamed(Routes.LOGIN);
        AppSnackbar.showSuccess(
          message: 'Đăng xuất thành công',
        );
      } catch (e) {
        AppDialogs.hideLoading();
        LoggerService.e('Failed to logout', error: e);
        AppSnackbar.showError(
          message: 'Không thể đăng xuất',
        );
      }
    }
  }
}