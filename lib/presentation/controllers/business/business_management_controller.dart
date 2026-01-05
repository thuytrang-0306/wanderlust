import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/core/services/unified_image_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/models/business_profile_model.dart';
import 'package:wanderlust/data/services/business_service.dart';

class BusinessManagementController extends GetxController {
  final BusinessService _businessService = Get.find<BusinessService>();
  final UnifiedImageService _imageService = Get.find<UnifiedImageService>();

  // Form controllers
  final businessNameController = TextEditingController();
  final taxNumberController = TextEditingController();
  final businessPhoneController = TextEditingController();
  final businessEmailController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Services list
  final RxList<String> services = <String>[].obs;
  final serviceController = TextEditingController();

  // Verification document
  final RxString verificationDoc = ''.obs;
  final RxBool hasVerificationDoc = false.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingDoc = false.obs;

  // Current business profile
  BusinessProfileModel? currentBusiness;

  @override
  void onInit() {
    super.onInit();
    _loadBusinessData();
  }

  /// Load current business data
  Future<void> _loadBusinessData() async {
    try {
      isLoading.value = true;

      final business = _businessService.currentBusinessProfile.value;
      if (business == null) {
        Get.back();
        AppSnackbar.showError(message: 'Không tìm thấy thông tin doanh nghiệp');
        return;
      }

      currentBusiness = business;

      // Populate form fields
      businessNameController.text = business.businessName;
      taxNumberController.text = business.taxNumber ?? '';
      businessPhoneController.text = business.businessPhone;
      businessEmailController.text = business.businessEmail;
      addressController.text = business.address;
      descriptionController.text = business.description;

      // Load services
      if (business.services != null) {
        services.value = List.from(business.services!);
      }

      // Load verification doc
      if (business.verificationDoc != null) {
        verificationDoc.value = business.verificationDoc!;
        hasVerificationDoc.value = true;
      }
    } catch (e) {
      LoggerService.e('Error loading business data', error: e);
      AppSnackbar.showError(message: 'Không thể tải dữ liệu');
    } finally {
      isLoading.value = false;
    }
  }

  /// Add service to list
  void addService() {
    final service = serviceController.text.trim();
    if (service.isNotEmpty && !services.contains(service)) {
      services.add(service);
      serviceController.clear();
    }
  }

  /// Remove service from list
  void removeService(String service) {
    services.remove(service);
  }

  /// Pick verification document
  Future<void> pickVerificationDocument() async {
    try {
      isUploadingDoc.value = true;

      final imagePath = await _imageService.pickImage(source: ImageSource.gallery);
      if (imagePath == null) {
        isUploadingDoc.value = false;
        return;
      }

      // Convert to base64
      final base64 = await _imageService.imageToBase64(imagePath);
      if (base64 != null) {
        verificationDoc.value = base64;
        hasVerificationDoc.value = true;
        AppSnackbar.showSuccess(message: 'Đã tải lên giấy tờ xác thực');
      }
    } catch (e) {
      LoggerService.e('Error picking verification document', error: e);
      AppSnackbar.showError(message: 'Không thể tải lên giấy tờ');
    } finally {
      isUploadingDoc.value = false;
    }
  }

  /// Submit business update
  Future<void> submitUpdate() async {
    try {
      if (!formKey.currentState!.validate()) {
        AppSnackbar.showError(message: 'Vui lòng kiểm tra lại thông tin');
        return;
      }

      if (currentBusiness == null) {
        AppSnackbar.showError(message: 'Không tìm thấy thông tin doanh nghiệp');
        return;
      }

      AppDialogs.showLoading(message: 'Đang cập nhật...');
      isSaving.value = true;

      final success = await _businessService.updateBusinessProfile(
        profileId: currentBusiness!.id,
        businessName: businessNameController.text.trim(),
        businessPhone: businessPhoneController.text.trim(),
        businessEmail: businessEmailController.text.trim(),
        address: addressController.text.trim(),
        description: descriptionController.text.trim(),
        taxNumber: taxNumberController.text.trim().isEmpty
            ? null
            : taxNumberController.text.trim(),
        services: services.isEmpty ? null : services,
      );

      AppDialogs.hideLoading();

      if (success) {
        AppSnackbar.showSuccess(message: 'Cập nhật thành công!');
        Get.back(result: true);
      } else {
        AppSnackbar.showError(message: 'Không thể cập nhật thông tin');
      }
    } catch (e) {
      LoggerService.e('Error updating business', error: e);
      AppDialogs.hideLoading();
      AppSnackbar.showError(message: 'Có lỗi xảy ra: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete business with confirmation
  Future<void> deleteBusiness() async {
    try {
      if (currentBusiness == null) return;

      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Xóa doanh nghiệp'),
          content: Text(
            'Bạn có chắc chắn muốn xóa doanh nghiệp "${currentBusiness!.businessName}"?\n\n'
            'Hành động này không thể hoàn tác và sẽ xóa toàn bộ dữ liệu liên quan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      AppDialogs.showLoading(message: 'Đang xóa doanh nghiệp...');

      final success = await _businessService.deleteBusinessProfile(currentBusiness!.id);

      AppDialogs.hideLoading();

      if (success) {
        AppSnackbar.showSuccess(message: 'Đã xóa doanh nghiệp thành công');
        // Navigate to home and clear all business routes
        Get.offAllNamed('/main');
      } else {
        AppSnackbar.showError(message: 'Không thể xóa doanh nghiệp');
      }
    } catch (e) {
      LoggerService.e('Error deleting business', error: e);
      AppDialogs.hideLoading();
      AppSnackbar.showError(message: 'Có lỗi xảy ra');
    }
  }

  // Form validators
  String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên doanh nghiệp';
    }
    if (value.trim().length < 3) {
      return 'Tên doanh nghiệp phải có ít nhất 3 ký tự';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ';
    }
    if (value.trim().length < 10) {
      return 'Địa chỉ phải có ít nhất 10 ký tự';
    }
    return null;
  }

  @override
  void onClose() {
    businessNameController.dispose();
    taxNumberController.dispose();
    businessPhoneController.dispose();
    businessEmailController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    serviceController.dispose();
    super.onClose();
  }
}
