import 'package:flutter/material.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final Color? lineColor;
  final Color? textColor;
  final double? lineThickness;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const DividerWithText({
    super.key,
    required this.text,
    this.lineColor,
    this.textColor,
    this.lineThickness,
    this.padding,
    this.textStyle,
  });

  // Factory constructor for common "Or" divider
  factory DividerWithText.or({String? text, Color? lineColor, Color? textColor}) {
    return DividerWithText(text: text ?? 'Hoặc', lineColor: lineColor, textColor: textColor);
  }

  // Factory constructor for "Or login with" divider
  factory DividerWithText.orLoginWith({Color? lineColor, Color? textColor}) {
    return DividerWithText(text: 'Hoặc đăng nhập với', lineColor: lineColor, textColor: textColor);
  }

  // Factory constructor for "Or register with" divider
  factory DividerWithText.orRegisterWith({Color? lineColor, Color? textColor}) {
    return DividerWithText(text: 'Hoặc đăng ký với', lineColor: lineColor, textColor: textColor);
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = lineColor ?? AppColors.neutral200;
    final dividerThickness = lineThickness ?? 1.0;
    final textPadding = padding ?? EdgeInsets.symmetric(horizontal: AppSpacing.s4);

    return Row(
      children: [
        Expanded(child: Container(height: dividerThickness, color: dividerColor)),
        Padding(
          padding: textPadding,
          child: Text(
            text,
            style:
                textStyle ??
                AppTypography.bodyM.copyWith(color: textColor ?? AppColors.textSecondary),
          ),
        ),
        Expanded(child: Container(height: dividerThickness, color: dividerColor)),
      ],
    );
  }
}

// Alternative implementation with more customization
class CustomDivider extends StatelessWidget {
  final Widget? child;
  final Color? lineColor;
  final double? lineThickness;
  final double? indent;
  final double? endIndent;
  final EdgeInsetsGeometry? padding;
  final Gradient? lineGradient;
  final bool dashed;
  final double dashWidth;
  final double dashSpace;

  const CustomDivider({
    super.key,
    this.child,
    this.lineColor,
    this.lineThickness,
    this.indent,
    this.endIndent,
    this.padding,
    this.lineGradient,
    this.dashed = false,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      // Simple divider without text
      return Container(
        margin: EdgeInsets.only(left: indent ?? 0, right: endIndent ?? 0),
        padding: padding,
        child:
            dashed
                ? _buildDashedLine()
                : Container(
                  height: lineThickness ?? 1,
                  decoration: BoxDecoration(
                    color: lineGradient == null ? (lineColor ?? AppColors.neutral200) : null,
                    gradient: lineGradient,
                  ),
                ),
      );
    }

    // Divider with centered widget
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          if (indent != null) SizedBox(width: indent),
          Expanded(
            child:
                dashed
                    ? _buildDashedLine()
                    : Container(
                      height: lineThickness ?? 1,
                      decoration: BoxDecoration(
                        color: lineGradient == null ? (lineColor ?? AppColors.neutral200) : null,
                        gradient: lineGradient,
                      ),
                    ),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.s3), child: child!),
          Expanded(
            child:
                dashed
                    ? _buildDashedLine()
                    : Container(
                      height: lineThickness ?? 1,
                      decoration: BoxDecoration(
                        color: lineGradient == null ? (lineColor ?? AppColors.neutral200) : null,
                        gradient: lineGradient,
                      ),
                    ),
          ),
          if (endIndent != null) SizedBox(width: endIndent),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: lineThickness ?? 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: lineColor ?? AppColors.neutral200),
              ),
            );
          }),
        );
      },
    );
  }
}
