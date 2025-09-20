import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final String? errorText;
  final Color? fillColor;
  final bool filled;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.errorText,
    this.fillColor,
    this.filled = true,
  });

  // Factory constructors for common field types
  factory AppTextField.email({
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    Function(String)? onFieldSubmitted,
    Function(String)? onChanged,
    bool autofocus = false,
  }) {
    return AppTextField(
      controller: controller,
      label: 'Email',
      hintText: 'Nhập email của bạn',
      validator: validator,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction ?? TextInputAction.next,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      autofocus: autofocus,
    );
  }

  factory AppTextField.password({
    required TextEditingController controller,
    required bool isPasswordVisible,
    required VoidCallback togglePasswordVisibility,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    Function(String)? onFieldSubmitted,
    Function(String)? onChanged,
    String? label,
    String? hintText,
  }) {
    return AppTextField(
      controller: controller,
      label: label ?? 'Mật khẩu',
      hintText: hintText ?? 'Nhập mật khẩu của bạn',
      validator: validator,
      obscureText: !isPasswordVisible,
      textInputAction: textInputAction ?? TextInputAction.done,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textTertiary,
          size: 20.sp,
        ),
        onPressed: togglePasswordVisibility,
      ),
    );
  }

  factory AppTextField.name({
    required TextEditingController controller,
    required String label,
    String? hintText,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    Function(String)? onFieldSubmitted,
    Function(String)? onChanged,
    bool autofocus = false,
  }) {
    return AppTextField(
      controller: controller,
      label: label,
      hintText: hintText ?? 'Nhập ${label.toLowerCase()}',
      validator: validator,
      keyboardType: TextInputType.name,
      textInputAction: textInputAction ?? TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      autofocus: autofocus,
    );
  }

  factory AppTextField.phone({
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    Function(String)? onFieldSubmitted,
    Function(String)? onChanged,
  }) {
    return AppTextField(
      controller: controller,
      label: 'Số điện thoại',
      hintText: 'Nhập số điện thoại',
      validator: validator,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction ?? TextInputAction.next,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
    );
  }

  factory AppTextField.search({
    required TextEditingController controller,
    Function(String)? onChanged,
    Function(String)? onFieldSubmitted,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return AppTextField(
      controller: controller,
      label: '',
      hintText: hintText ?? 'Tìm kiếm...',
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: TextInputAction.search,
      prefixIcon: Icon(Icons.search, color: AppColors.textTertiary, size: 20.sp),
      suffixIcon: suffixIcon,
    );
  }

  factory AppTextField.multiline({
    required TextEditingController controller,
    required String label,
    String? hintText,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    int maxLines = 4,
    int? maxLength,
  }) {
    return AppTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      validator: validator,
      onChanged: onChanged,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: maxLines,
      maxLength: maxLength,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      style: AppTypography.bodyM.copyWith(
        color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
        fontSize: 16.sp,
      ),
      decoration: InputDecoration(
        labelText: label.isNotEmpty ? label : null,
        labelStyle: AppTypography.bodyM.copyWith(color: AppColors.textSecondary, fontSize: 14.sp),
        hintText: hintText,
        hintStyle: AppTypography.bodyM.copyWith(
          color: AppColors.textHint.withValues(alpha: 0.5),
          fontSize: 16.sp,
        ),
        errorText: errorText,
        errorStyle: AppTypography.bodyS.copyWith(color: AppColors.error, fontSize: 12.sp),
        floatingLabelBehavior:
            label.isNotEmpty ? FloatingLabelBehavior.always : FloatingLabelBehavior.never,
        floatingLabelStyle: AppTypography.bodyS.copyWith(
          color: AppColors.textSecondary,
          fontSize: 12.sp,
          fontWeight: AppTypography.medium,
        ),
        filled: filled,
        fillColor: fillColor ?? AppColors.neutral50.withValues(alpha: 0.5),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: 18.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.s3),
          borderSide: BorderSide(color: AppColors.neutral200.withValues(alpha: 0.5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.s3),
          borderSide: BorderSide(color: AppColors.neutral200.withValues(alpha: 0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.s3),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.s3),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.s3),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.s3),
          borderSide: BorderSide(color: AppColors.neutral200.withValues(alpha: 0.3), width: 1),
        ),
      ),
    );
  }
}
