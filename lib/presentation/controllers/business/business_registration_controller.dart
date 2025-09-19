import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/core/services/unified_image_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_dialogs.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/models/business_profile_model.dart';
import 'package:wanderlust/data/services/business_service.dart';
import 'package:wanderlust/data/services/user_profile_service.dart';

class BusinessRegistrationController extends GetxController {
  final BusinessService _businessService = Get.find<BusinessService>();
  final UserProfileService _userProfileService = Get.find<UserProfileService>();
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
  
  // Selected business type
  final Rx<BusinessType?> selectedBusinessType = Rx<BusinessType?>(null);
  
  // Set business type
  void setBusinessType(BusinessType type) {
    selectedBusinessType.value = type;
    LoggerService.i('Business type set via method to: ${type.displayName}');
  }
  
  // Services list for business
  final RxList<String> services = <String>[].obs;
  final serviceController = TextEditingController();
  
  // Verification document
  final RxString verificationDoc = ''.obs;
  final RxBool hasVerificationDoc = false.obs;
  
  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isUploadingDoc = false.obs;
  
  // Current step for multi-step form
  final RxInt currentStep = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Get business type from arguments if passed
    final args = Get.arguments;
    LoggerService.i('BusinessRegistrationController onInit - arguments: $args');
    if (args != null && args['businessType'] != null) {
      selectedBusinessType.value = args['businessType'] as BusinessType;
      LoggerService.i('Business type set from arguments: ${selectedBusinessType.value?.displayName}');
    } else {
      LoggerService.w('No business type in arguments!');
    }
    
    // Pre-fill email and phone from user profile if available
    _prefillUserData();
  }
  
  void _prefillUserData() async {
    try {
      final profile = await _userProfileService.getCurrentUserProfile();
      if (profile != null) {
        businessEmailController.text = profile.email;
        businessPhoneController.text = profile.phoneNumber ?? '';
      }
    } catch (e) {
      LoggerService.e('Error prefilling user data', error: e);
    }
  }
  
  // Add service to list
  void addService() {
    final service = serviceController.text.trim();
    if (service.isNotEmpty && !services.contains(service)) {
      services.add(service);
      serviceController.clear();
    }
  }
  
  // Remove service from list
  void removeService(String service) {
    services.remove(service);
  }
  
  // Pick verification document
  Future<void> pickVerificationDocument() async {
    try {
      // Show source selection
      final source = await _showImageSourceDialog();
      if (source == null) return;
      
      isUploadingDoc.value = true;
      
      // Pick image
      final image = await _imageService.pickImage(source: source);
      if (image == null) {
        isUploadingDoc.value = false;
        return;
      }
      
      // Convert to base64
      final base64 = await _imageService.imageToBase64(image);
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
  
  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.bottomSheet<ImageSource>(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chọn nguồn ảnh',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Chụp ảnh'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Chọn từ thư viện'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
  
  // Validate and go to next step
  void nextStep() {
    if (currentStep.value == 0) {
      // Validate basic info
      if (formKey.currentState?.validate() ?? false) {
        currentStep.value++;
      }
    } else if (currentStep.value == 1) {
      // Validate additional info
      if (descriptionController.text.trim().isEmpty) {
        AppSnackbar.showError(message: 'Vui lòng nhập mô tả doanh nghiệp');
        return;
      }
      currentStep.value++;
    }
  }
  
  // Go to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }
  
  // Submit business registration
  Future<void> submitRegistration() async {
    try {
      LoggerService.i('Submit registration - Business type at start: ${selectedBusinessType.value?.displayName}');
      
      // Validate all required fields manually
      if (businessNameController.text.trim().isEmpty ||
          businessEmailController.text.trim().isEmpty ||
          businessPhoneController.text.trim().isEmpty ||
          addressController.text.trim().isEmpty) {
        currentStep.value = 0; // Go back to first step
        AppSnackbar.showError(message: 'Vui lòng điền đầy đủ thông tin bắt buộc');
        return;
      }
      
      if (descriptionController.text.trim().isEmpty) {
        currentStep.value = 1; // Go to description step
        AppSnackbar.showError(message: 'Vui lòng nhập mô tả doanh nghiệp');
        return;
      }
      
      if (selectedBusinessType.value == null) {
        LoggerService.e('Business type is null at submission!');
        AppSnackbar.showError(message: 'Vui lòng chọn loại hình kinh doanh. Vui lòng quay lại và chọn lại.');
        Get.back(); // Go back to business type selection
        return;
      }
      
      AppDialogs.showLoading(message: 'Đang tạo hồ sơ doanh nghiệp...');
      isLoading.value = true;
      
      // Create business profile
      final businessProfile = await _businessService.createBusinessProfile(
        businessName: businessNameController.text.trim(),
        businessType: selectedBusinessType.value!,
        businessPhone: businessPhoneController.text.trim(),
        businessEmail: businessEmailController.text.trim(),
        address: addressController.text.trim(),
        description: descriptionController.text.trim(),
        taxNumber: taxNumberController.text.trim().isEmpty 
            ? null 
            : taxNumberController.text.trim(),
        verificationDoc: verificationDoc.value.isEmpty 
            ? null 
            : verificationDoc.value,
        services: services.isEmpty ? null : services,
      );
      
      AppDialogs.hideLoading();
      
      if (businessProfile != null) {
        // Update user to business type
        await _userProfileService.upgradeToBusinessUser(businessProfile.id);
        
        // Show success and navigate to dashboard
        AppDialogs.showAlert(
          title: 'Đăng ký thành công!',
          message: 'Hồ sơ doanh nghiệp của bạn đã được tạo. Bạn có thể bắt đầu thêm các dịch vụ và sản phẩm ngay bây giờ.',
          onPressed: () => Get.offAllNamed('/business-dashboard'),
        );
      } else {
        AppSnackbar.showError(message: 'Không thể tạo hồ sơ doanh nghiệp');
      }
    } catch (e) {
      LoggerService.e('Error submitting registration', error: e);
      AppDialogs.hideLoading();
      AppSnackbar.showError(
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
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