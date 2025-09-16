import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';

enum LogoSize {
  small,   // 60w
  medium,  // 80w
  large,   // 100w
  xlarge,  // 120w
}

enum LogoStyle {
  vertical,   // Logo on top, name below
  horizontal, // Logo and name side by side
  logoOnly,   // Just the logo
  nameOnly,   // Just the app name
}

class AppLogo extends StatelessWidget {
  final LogoSize size;
  final LogoStyle style;
  final Color? nameColor;
  final bool showTagline;
  final String? tagline;

  const AppLogo({
    super.key,
    this.size = LogoSize.medium,
    this.style = LogoStyle.vertical,
    this.nameColor,
    this.showTagline = false,
    this.tagline,
  });

  // Factory constructors for common use cases
  factory AppLogo.splash() {
    return const AppLogo(
      size: LogoSize.xlarge,
      style: LogoStyle.vertical,
      showTagline: true,
    );
  }

  factory AppLogo.auth() {
    return const AppLogo(
      size: LogoSize.medium,
      style: LogoStyle.vertical,
    );
  }

  factory AppLogo.compact() {
    return const AppLogo(
      size: LogoSize.small,
      style: LogoStyle.horizontal,
    );
  }

  factory AppLogo.header() {
    return const AppLogo(
      size: LogoSize.small,
      style: LogoStyle.horizontal,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine logo size
    double logoSize;
    double fontSize;
    switch (size) {
      case LogoSize.small:
        logoSize = 60.w;
        fontSize = 24.sp;
        break;
      case LogoSize.medium:
        logoSize = 80.w;
        fontSize = 28.sp;
        break;
      case LogoSize.large:
        logoSize = 100.w;
        fontSize = 32.sp;
        break;
      case LogoSize.xlarge:
        logoSize = 120.w;
        fontSize = 36.sp;
        break;
    }

    // Build logo image
    Widget logoWidget = Image.asset(
      'assets/images/logo.png',
      width: logoSize,
      height: logoSize,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if logo image not found
        return Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(logoSize * 0.25),
          ),
          child: Icon(
            Icons.location_on_rounded,
            color: AppColors.white,
            size: logoSize * 0.6,
          ),
        );
      },
    );

    // Build app name
    Widget nameWidget = Text(
      'Wanderlust',
      style: AppTypography.h2.copyWith(
        color: nameColor ?? AppColors.primary,
        fontWeight: AppTypography.bold,
        fontSize: fontSize,
      ),
    );

    // Build tagline if needed
    Widget? taglineWidget;
    if (showTagline && (tagline != null || style == LogoStyle.vertical)) {
      taglineWidget = Text(
        tagline ?? 'Khám phá thế giới theo cách của bạn',
        style: AppTypography.bodyS.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
        ),
        textAlign: TextAlign.center,
      );
    }

    // Build based on style
    switch (style) {
      case LogoStyle.vertical:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            logoWidget,
            SizedBox(height: size == LogoSize.small ? AppSpacing.s2 : AppSpacing.s3),
            nameWidget,
            if (taglineWidget != null) ...[
              SizedBox(height: AppSpacing.s2),
              taglineWidget,
            ],
          ],
        );
      
      case LogoStyle.horizontal:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            logoWidget,
            SizedBox(width: AppSpacing.s3),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                nameWidget,
                if (taglineWidget != null) taglineWidget,
              ],
            ),
          ],
        );
      
      case LogoStyle.logoOnly:
        return logoWidget;
      
      case LogoStyle.nameOnly:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            nameWidget,
            if (taglineWidget != null) ...[
              SizedBox(height: AppSpacing.s1),
              taglineWidget,
            ],
          ],
        );
    }
  }
}