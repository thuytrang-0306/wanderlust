import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:wanderlust/core/services/storage_service.dart';
import 'package:wanderlust/core/services/unified_image_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends BaseController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();

  final avatarImage = Rxn<String>(); // base64 or URL
  final selectedDate = Rxn<DateTime>();
  final isSaving = false.obs;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.onClose();
  }

  Future<void> _loadUserProfile() async {
    try {
      setLoading();

      _userId = _auth.currentUser?.uid;
      if (_userId == null) {
        AppSnackbar.showError(message: 'Không tìm thấy thông tin người dùng');
        Get.back();
        return;
      }

      final doc = await _firestore.collection('users').doc(_userId).get();

      if (doc.exists) {
        final data = doc.data()!;
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        bioController.text = data['bio'] ?? '';
        avatarImage.value = data['avatar'];

        if (data['dateOfBirth'] != null) {
          selectedDate.value = (data['dateOfBirth'] as Timestamp).toDate();
        }
      }

      setIdle();
    } catch (e) {
      setError('Không thể tải thông tin: $e');
      AppSnackbar.showError(message: 'Không thể tải thông tin: $e');
    }
  }

  Future<void> pickImage() async {
    try {
      final imageFile = await UnifiedImageService.to.pickImage(
        source: ImageSource.gallery,
        maxWidthOverride: 300,
        maxHeightOverride: 300,
      );
      if (imageFile == null) return;

      AppDialogs.showLoading(message: 'Đang xử lý ảnh...');

      final base64String = await UnifiedImageService.to.imageToBase64(
        imageFile,
        createThumbnail: true,
      );

      AppDialogs.hideLoading();

      if (base64String != null) {
        avatarImage.value = base64String;
      } else {
        AppSnackbar.showError(message: 'Không thể xử lý ảnh');
      }
    } catch (e) {
      AppDialogs.hideLoading();
      AppSnackbar.showError(message: 'Không thể tải ảnh: $e');
    }
  }

  Future<void> selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> saveProfile() async {
    if (!_validateForm()) return;

    try {
      isSaving.value = true;
      AppDialogs.showLoading(message: 'Đang lưu...');

      final Map<String, dynamic> updates = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'bio': bioController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (avatarImage.value != null) {
        updates['avatar'] = avatarImage.value;
      }

      if (selectedDate.value != null) {
        updates['dateOfBirth'] = Timestamp.fromDate(selectedDate.value!);
      }

      await _firestore.collection('users').doc(_userId).update(updates);

      // Update local storage
      await StorageService.to.write('user_name', nameController.text.trim());
      await StorageService.to.write('user_email', emailController.text.trim());

      if (avatarImage.value != null) {
        await StorageService.to.write('user_avatar', avatarImage.value);
      }

      AppDialogs.hideLoading();
      isSaving.value = false;

      AppSnackbar.showSuccess(message: 'Cập nhật thông tin thành công');
      Get.back(result: true); // Return true to indicate success
    } catch (e) {
      AppDialogs.hideLoading();
      isSaving.value = false;
      AppSnackbar.showError(message: 'Không thể lưu: $e');
    }
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      AppSnackbar.showError(message: 'Vui lòng nhập tên');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      AppSnackbar.showError(message: 'Vui lòng nhập email');
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      AppSnackbar.showError(message: 'Email không hợp lệ');
      return false;
    }

    if (phoneController.text.trim().isNotEmpty) {
      if (!GetUtils.isPhoneNumber(phoneController.text.trim())) {
        AppSnackbar.showError(message: 'Số điện thoại không hợp lệ');
        return false;
      }
    }

    return true;
  }
}
