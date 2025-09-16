import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';

enum SnackbarType {
  success,
  error,
  warning,
  info,
}

class AppSnackbar {
  // Private constructor to prevent instantiation
  AppSnackbar._();

  // Success snackbar
  static void showSuccess({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _showSnackbar(
      title: title ?? 'Thành công',
      message: message,
      type: SnackbarType.success,
      duration: duration,
      position: position,
    );
  }

  // Error snackbar
  static void showError({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _showSnackbar(
      title: title ?? 'Lỗi',
      message: message,
      type: SnackbarType.error,
      duration: duration,
      position: position,
    );
  }

  // Warning snackbar
  static void showWarning({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _showSnackbar(
      title: title ?? 'Cảnh báo',
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      position: position,
    );
  }

  // Info snackbar
  static void showInfo({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _showSnackbar(
      title: title ?? 'Thông báo',
      message: message,
      type: SnackbarType.info,
      duration: duration,
      position: position,
    );
  }

  // Custom snackbar with more control
  static void showCustom({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
    TextButton? mainButton,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor ?? AppColors.primary,
      colorText: textColor ?? AppColors.white,
      duration: duration,
      margin: EdgeInsets.all(AppSpacing.s4),
      borderRadius: AppSpacing.s3,
      icon: icon != null
          ? Icon(
              icon,
              color: textColor ?? AppColors.white,
              size: 24.sp,
            )
          : null,
      mainButton: mainButton,
      shouldIconPulse: false,
      animationDuration: const Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInOutBack,
    );
  }

  // Private method to show snackbar based on type
  static void _showSnackbar({
    required String title,
    required String message,
    required SnackbarType type,
    required Duration duration,
    required SnackPosition position,
  }) {
    Color backgroundColor;
    Color textColor = AppColors.white;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case SnackbarType.error:
        backgroundColor = AppColors.error;
        icon = Icons.error_outline;
        break;
      case SnackbarType.warning:
        backgroundColor = AppColors.warning;
        textColor = AppColors.black;
        icon = Icons.warning_amber_outlined;
        break;
      case SnackbarType.info:
        backgroundColor = AppColors.primary;
        icon = Icons.info_outline;
        break;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      margin: EdgeInsets.all(AppSpacing.s4),
      borderRadius: AppSpacing.s3,
      icon: Padding(
        padding: EdgeInsets.only(left: AppSpacing.s3),
        child: Icon(
          icon,
          color: textColor,
          size: 28.sp,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s3,
      ),
      titleText: Text(
        title,
        style: AppTypography.bodyL.copyWith(
          color: textColor,
          fontWeight: AppTypography.semiBold,
        ),
      ),
      messageText: Text(
        message,
        style: AppTypography.bodyM.copyWith(
          color: textColor.withValues(alpha: 0.9),
        ),
      ),
      shouldIconPulse: false,
      animationDuration: const Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInOutBack,
      boxShadows: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Show loading snackbar (useful for async operations)
  static SnackbarController showLoading({
    String? message,
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    return Get.snackbar(
      'Đang xử lý',
      message ?? 'Vui lòng đợi...',
      snackPosition: position,
      backgroundColor: AppColors.neutral800,
      colorText: AppColors.white,
      duration: null, // Indefinite duration
      margin: EdgeInsets.all(AppSpacing.s4),
      borderRadius: AppSpacing.s3,
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: AppColors.neutral600,
      progressIndicatorValueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      isDismissible: false,
      shouldIconPulse: false,
    );
  }

  // Close all snackbars
  static void closeAll() {
    Get.closeAllSnackbars();
  }

  // Close current snackbar
  static void closeCurrent() {
    Get.closeCurrentSnackbar();
  }

  // Check if snackbar is open
  static bool get isSnackbarOpen => Get.isSnackbarOpen;
}