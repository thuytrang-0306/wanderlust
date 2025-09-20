import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

/// Typography system based on Wanderlust design specifications
/// Using Gilroy font family with 4px grid system
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Gilroy';

  // ============= HEADINGS =============
  /// H1: 32px/40px
  static TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.sp,
    height: 40 / 32, // line-height / font-size
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// H2: 24px/28px
  static TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.sp,
    height: 28 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  /// H3: 20px/24px
  static TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.sp,
    height: 24 / 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  /// H4: 18px/22px
  static TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.sp,
    height: 22 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
  );

  // ============= BODY TEXT =============
  /// Body XLarge: 18px/22px
  static TextStyle bodyXL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.sp,
    height: 22 / 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Body Large: 16px/20px
  static TextStyle bodyL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    height: 20 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Body Medium: 14px/17px
  static TextStyle bodyM = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    height: 17 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Body Small: 12px/14px
  static TextStyle bodyS = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    height: 14 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Body XSmall: 10px/12px
  static TextStyle bodyXS = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.sp,
    height: 12 / 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ============= LABELS =============
  /// Label 1: 18px/22px
  static TextStyle label1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.sp,
    height: 22 / 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Label 2: 16px/20px
  static TextStyle label2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    height: 20 / 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Label 3: 14px/17px
  static TextStyle label3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    height: 17 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Label 4: 12px/14px
  static TextStyle label4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    height: 14 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // ============= CAPTIONS =============
  /// Caption 1: 16px/20px
  static TextStyle caption1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    height: 20 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Caption 2: 14px/17px
  static TextStyle caption2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    height: 17 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Caption 3: 12px/14px
  static TextStyle caption3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    height: 14 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  // ============= SPECIAL STYLES =============
  /// Button text
  static TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Input text
  static TextStyle input = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    height: 20 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Input hint
  static TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    height: 20 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  /// Link text
  static TextStyle link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    height: 17 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  // ============= WEIGHT VARIATIONS =============
  /// Get text style with custom weight
  static TextStyle withWeight(TextStyle base, FontWeight weight) {
    return base.copyWith(fontWeight: weight);
  }

  // Font weight constants for Gilroy
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ============= LEGACY MAPPING (for backward compatibility) =============
  static TextStyle get heading1 => h1;
  static TextStyle get heading2 => h2;
  static TextStyle get heading3 => h3;
  static TextStyle get heading4 => h4;
  static TextStyle get heading5 => h4; // Map to H4
  static TextStyle get heading6 => label1; // Map to Label1

  static TextStyle get bodyLarge => bodyL;
  static TextStyle get bodyMedium => bodyM;
  static TextStyle get bodySmall => bodyS;

  static TextStyle get labelLarge => label2;
  static TextStyle get labelMedium => label3;
  static TextStyle get labelSmall => label4;

  static TextStyle get caption => caption3;
}
