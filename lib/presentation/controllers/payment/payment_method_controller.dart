import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

class PaymentMethodController extends GetxController {
  // Selected payment type
  final selectedPaymentType = 'card'.obs;
  
  // Card details controllers
  final cardNumberController = TextEditingController();
  final cardHolderController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  
  // Loading state
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    cardNumberController.dispose();
    cardHolderController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.onClose();
  }
  
  void selectPaymentType(String type) {
    selectedPaymentType.value = type;
    
    // Clear card fields if switching away from card
    if (type != 'card') {
      cardNumberController.clear();
      cardHolderController.clear();
      expiryController.clear();
      cvvController.clear();
    }
  }
  
  bool _validateCardDetails() {
    if (selectedPaymentType.value == 'card') {
      if (cardNumberController.text.trim().isEmpty) {
        AppSnackbar.showError(message: 'Vui lòng nhập số thẻ');
        return false;
      }
      
      // Validate card number (16 digits)
      final cardNumber = cardNumberController.text.trim().replaceAll(' ', '');
      if (cardNumber.length != 16 || !RegExp(r'^[0-9]+$').hasMatch(cardNumber)) {
        AppSnackbar.showError(message: 'Số thẻ không hợp lệ');
        return false;
      }
      
      if (cardHolderController.text.trim().isEmpty) {
        AppSnackbar.showError(message: 'Vui lòng nhập tên trên thẻ');
        return false;
      }
      
      if (expiryController.text.trim().isEmpty) {
        AppSnackbar.showError(message: 'Vui lòng nhập ngày hết hạn');
        return false;
      }
      
      // Validate expiry date format (MM/YY)
      final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$');
      if (!expiryRegex.hasMatch(expiryController.text.trim())) {
        AppSnackbar.showError(message: 'Ngày hết hạn không hợp lệ (MM/YY)');
        return false;
      }
      
      if (cvvController.text.trim().isEmpty) {
        AppSnackbar.showError(message: 'Vui lòng nhập mã CVV');
        return false;
      }
      
      // Validate CVV (3 or 4 digits)
      final cvv = cvvController.text.trim();
      if ((cvv.length != 3 && cvv.length != 4) || !RegExp(r'^[0-9]+$').hasMatch(cvv)) {
        AppSnackbar.showError(message: 'Mã CVV không hợp lệ');
        return false;
      }
    }
    
    return true;
  }
  
  String _getCardType(String cardNumber) {
    // Simple card type detection based on first digits
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('35')) return 'JCB';
    if (cardNumber.startsWith('62')) return 'UnionPay';
    return 'Unknown';
  }

  void savePaymentMethod() {
    if (!_validateCardDetails()) return;
    
    isLoading.value = true;
    
    // Simulate saving
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      
      Map<String, dynamic> paymentData;
      
      if (selectedPaymentType.value == 'card') {
        final cardNumber = cardNumberController.text.trim().replaceAll(' ', '');
        paymentData = {
          'type': 'card',
          'cardType': _getCardType(cardNumber),
          'lastFourDigits': cardNumber.substring(cardNumber.length - 4),
          'cardHolder': cardHolderController.text.trim(),
          'expiry': expiryController.text.trim(),
        };
      } else {
        paymentData = {
          'type': 'digital',
          'method': 'PayPal', // or Apple Pay based on selection
        };
      }
      
      // Pass payment info back to booking page
      Get.back(result: paymentData);
      
      AppSnackbar.showSuccess(message: 'Đã lưu phương thức thanh toán');
    });
  }
}