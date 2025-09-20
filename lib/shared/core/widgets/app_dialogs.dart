import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';

class AppDialogs {
  static void showLoading({String? message, bool barrierDismissible = false}) {
    Get.dialog(
      PopScope(
        canPop: barrierDismissible,
        onPopInvokedWithResult: (didPop, result) {},
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                if (message != null) ...[
                  SizedBox(height: 16.h),
                  Text(message, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.black.withOpacity(0.5),
    );
  }

  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  static Future<bool> showConfirm({
    String? title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    IconData? icon,
    bool barrierDismissible = true,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title:
            title != null
                ? Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.primary, size: 24.sp),
                      SizedBox(width: 8.w),
                    ],
                    Expanded(child: Text(title, style: AppTypography.heading5)),
                  ],
                )
                : null,
        content: Text(message, style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText ?? 'Cancel',
              style: AppTypography.button.copyWith(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              confirmText ?? 'Confirm',
              style: AppTypography.button.copyWith(color: confirmColor ?? AppColors.primary),
            ),
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );

    return result ?? false;
  }

  static void showAlert({
    String? title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    IconData? icon,
    AlertType type = AlertType.info,
    bool barrierDismissible = true,
  }) {
    final color = _getColorForType(type);
    final iconData = icon ?? _getIconForType(type);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: color, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Text(title ?? _getTitleForType(type), style: AppTypography.heading6)),
          ],
        ),
        content: Text(message, style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              onPressed?.call();
            },
            child: Text(buttonText ?? 'OK', style: AppTypography.button.copyWith(color: color)),
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static void showSuccess({
    String? title,
    required String message,
    VoidCallback? onDismiss,
    Duration? autoHideDuration,
  }) {
    showAlert(title: title, message: message, type: AlertType.success, onPressed: onDismiss);

    if (autoHideDuration != null) {
      Future.delayed(autoHideDuration, () {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      });
    }
  }

  static void showError({String? title, required String message, VoidCallback? onRetry}) {
    showAlert(
      title: title,
      message: message,
      type: AlertType.error,
      buttonText: onRetry != null ? 'Retry' : 'OK',
      onPressed: onRetry,
    );
  }

  static void showInfo({String? title, required String message}) {
    showAlert(title: title, message: message, type: AlertType.info);
  }

  static void showWarning({String? title, required String message, VoidCallback? onContinue}) {
    showAlert(
      title: title,
      message: message,
      type: AlertType.warning,
      buttonText: onContinue != null ? 'Continue' : 'OK',
      onPressed: onContinue,
    );
  }

  static Future<T?> showCustom<T>({
    required Widget child,
    bool barrierDismissible = true,
    EdgeInsets? padding,
  }) {
    return Get.dialog<T>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(padding: padding ?? EdgeInsets.all(16.w), child: child),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<String?> showInput({
    String? title,
    String? hint,
    String? initialValue,
    String? confirmText,
    String? cancelText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    final result = await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: title != null ? Text(title, style: AppTypography.heading6) : null,
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
            ),
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines ?? 1,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              cancelText ?? 'Cancel',
              style: AppTypography.button.copyWith(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Get.back(result: controller.text);
              }
            },
            child: Text(
              confirmText ?? 'OK',
              style: AppTypography.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  static Color _getColorForType(AlertType type) {
    switch (type) {
      case AlertType.success:
        return AppColors.success;
      case AlertType.error:
        return AppColors.error;
      case AlertType.warning:
        return AppColors.warning;
      case AlertType.info:
        return AppColors.info;
    }
  }

  static IconData _getIconForType(AlertType type) {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle_outline;
      case AlertType.error:
        return Icons.error_outline;
      case AlertType.warning:
        return Icons.warning_amber_outlined;
      case AlertType.info:
        return Icons.info_outline;
    }
  }

  static String _getTitleForType(AlertType type) {
    switch (type) {
      case AlertType.success:
        return 'Success';
      case AlertType.error:
        return 'Error';
      case AlertType.warning:
        return 'Warning';
      case AlertType.info:
        return 'Information';
    }
  }
}

enum AlertType { success, error, warning, info }
