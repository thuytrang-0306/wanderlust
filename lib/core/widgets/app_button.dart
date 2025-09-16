import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

enum ButtonSize {
  small,   // 40h
  medium,  // 48h  
  large,   // 56h
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final Widget? child;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.large,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.fullWidth = true,
    this.padding,
    this.textStyle,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.child,
  });

  // Factory constructors for common button types
  factory AppButton.primary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
    ButtonSize size = ButtonSize.large,
    IconData? icon,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.primary,
      size: size,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
    );
  }

  factory AppButton.secondary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
    ButtonSize size = ButtonSize.large,
    IconData? icon,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.secondary,
      size: size,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
    );
  }

  factory AppButton.outline({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
    ButtonSize size = ButtonSize.large,
    IconData? icon,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.outline,
      size: size,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
    );
  }

  factory AppButton.text({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.text,
      size: size,
      isLoading: isLoading,
      fullWidth: false,
      icon: icon,
    );
  }

  factory AppButton.danger({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
    ButtonSize size = ButtonSize.large,
    IconData? icon,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.danger,
      size: size,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine button height based on size
    double buttonHeight;
    switch (size) {
      case ButtonSize.small:
        buttonHeight = 40.h;
        break;
      case ButtonSize.medium:
        buttonHeight = 48.h;
        break;
      case ButtonSize.large:
        buttonHeight = 56.h;
        break;
    }

    // Determine colors based on type
    Color bgColor;
    Color fgColor;
    Color? borderColor;

    switch (type) {
      case ButtonType.primary:
        // Using the exact color from design: #9455FDCC
        bgColor = backgroundColor ?? const Color(0xCC9455FD);
        fgColor = textColor ?? AppColors.white;
        borderColor = null;
        break;
      case ButtonType.secondary:
        bgColor = backgroundColor ?? AppColors.secondary;
        fgColor = textColor ?? AppColors.white;
        borderColor = null;
        break;
      case ButtonType.outline:
        bgColor = backgroundColor ?? Colors.transparent;
        fgColor = textColor ?? AppColors.primary;
        borderColor = AppColors.primary;
        break;
      case ButtonType.text:
        bgColor = backgroundColor ?? Colors.transparent;
        fgColor = textColor ?? AppColors.primary;
        borderColor = null;
        break;
      case ButtonType.danger:
        bgColor = backgroundColor ?? AppColors.error;
        fgColor = textColor ?? AppColors.white;
        borderColor = null;
        break;
    }

    // Apply disabled state
    final bool isButtonDisabled = isDisabled || isLoading || onPressed == null;
    if (isButtonDisabled) {
      bgColor = bgColor.withValues(alpha: 0.5);
      fgColor = fgColor.withValues(alpha: 0.7);
    }

    // Build button content
    Widget buttonContent = isLoading
        ? SizedBox(
            width: 24.w,
            height: 24.w,
            child: CircularProgressIndicator(
              color: fgColor,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20.sp,
                  color: fgColor,
                ),
                SizedBox(width: AppSpacing.s2),
              ],
              Flexible(
                child: Text(
                  text,
                  style: textStyle ??
                      AppTypography.button.copyWith(
                        color: fgColor,
                        fontSize: size == ButtonSize.small ? 14.sp : 16.sp,
                        fontWeight: AppTypography.semiBold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    // Use child if provided (for custom content)
    if (child != null && !isLoading) {
      buttonContent = child!;
    }

    // Build the button
    Widget button = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius ?? 28.r),
      child: InkWell(
        onTap: isButtonDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius ?? 28.r),
        child: Container(
          height: buttonHeight,
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: AppSpacing.s5,
                vertical: 12.h, // As per your requirement
              ),
          decoration: BoxDecoration(
            border: borderColor != null
                ? Border.all(
                    color: isButtonDisabled
                        ? borderColor.withValues(alpha: 0.5)
                        : borderColor,
                    width: 1.5,
                  )
                : null,
            borderRadius: BorderRadius.circular(borderRadius ?? 28.r),
          ),
          alignment: Alignment.center,
          child: buttonContent,
        ),
      ),
    );

    // Apply full width if needed
    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

// Convenience widget for icon-only buttons
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final bool isLoading;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.isLoading = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonSize = size ?? 48.w;
    
    Widget button = Material(
      color: backgroundColor ?? AppColors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    color: iconColor ?? AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  icon,
                  size: buttonSize * 0.5,
                  color: iconColor ?? AppColors.primary,
                ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}