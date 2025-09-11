import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  AppSpacing._();
  
  // Padding & Margin
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;
  
  // Border Radius
  static double get radiusXs => 4.r;
  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r;
  static double get radiusXl => 24.r;
  static double get radiusRound => 999.r;
  
  // Icon Sizes
  static double get iconXs => 16.sp;
  static double get iconSm => 20.sp;
  static double get iconMd => 24.sp;
  static double get iconLg => 32.sp;
  static double get iconXl => 48.sp;
  
  // Heights
  static double get buttonHeightSm => 36.h;
  static double get buttonHeightMd => 44.h;
  static double get buttonHeightLg => 52.h;
  
  static double get inputHeight => 48.h;
  static double get appBarHeight => 56.h;
  static double get bottomNavHeight => 60.h;
}