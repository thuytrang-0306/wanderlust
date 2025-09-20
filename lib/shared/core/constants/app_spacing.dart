import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing system based on Wanderlust design specifications
/// Using 4px base unit for consistent spacing
class AppSpacing {
  AppSpacing._();

  // ============= SPACING VALUES (4px grid) =============
  /// 0px
  static double get s0 => 0;

  /// 1px
  static double get px => 1.w;

  /// 2px (0.5 * 4)
  static double get s0_5 => 2.w;

  /// 4px (1 * 4)
  static double get s1 => 4.w;

  /// 6px (1.5 * 4)
  static double get s1_5 => 6.w;

  /// 8px (2 * 4)
  static double get s2 => 8.w;

  /// 10px (2.5 * 4)
  static double get s2_5 => 10.w;

  /// 12px (3 * 4)
  static double get s3 => 12.w;

  /// 14px (3.5 * 4)
  static double get s3_5 => 14.w;

  /// 16px (4 * 4)
  static double get s4 => 16.w;

  /// 20px (5 * 4)
  static double get s5 => 20.w;

  /// 24px (6 * 4)
  static double get s6 => 24.w;

  /// 28px (7 * 4)
  static double get s7 => 28.w;

  /// 32px (8 * 4)
  static double get s8 => 32.w;

  /// 36px (9 * 4)
  static double get s9 => 36.w;

  /// 40px (10 * 4)
  static double get s10 => 40.w;

  /// 44px (11 * 4)
  static double get s11 => 44.w;

  /// 48px (12 * 4)
  static double get s12 => 48.w;

  /// 56px (14 * 4)
  static double get s14 => 56.w;

  // ============= SEMANTIC SPACING =============
  // Padding & Margin
  static double get paddingXS => s2; // 8px
  static double get paddingSM => s3; // 12px
  static double get paddingMD => s4; // 16px
  static double get paddingLG => s5; // 20px
  static double get paddingXL => s6; // 24px
  static double get paddingXXL => s8; // 32px

  // Screen padding
  static double get screenPaddingH => s4; // 16px horizontal
  static double get screenPaddingV => s5; // 20px vertical

  // Component spacing
  static double get componentSpacingXS => s2; // 8px
  static double get componentSpacingSM => s3; // 12px
  static double get componentSpacingMD => s4; // 16px
  static double get componentSpacingLG => s6; // 24px

  // List spacing
  static double get listItemSpacing => s3; // 12px
  static double get listSectionSpacing => s6; // 24px

  // Grid spacing
  static double get gridSpacing => s4; // 16px
  static double get gridSpacingSM => s3; // 12px
  static double get gridSpacingLG => s5; // 20px

  // ============= BORDER RADIUS =============
  static double get radiusXS => s1; // 4px
  static double get radiusSM => s2; // 8px
  static double get radiusMD => s3; // 12px
  static double get radiusLG => s4; // 16px
  static double get radiusXL => s5; // 20px
  static double get radiusXXL => s6; // 24px
  static double get radiusFull => 999.r; // Fully rounded

  // Component specific radius
  static double get buttonRadius => s3; // 12px
  static double get cardRadius => s4; // 16px
  static double get modalRadius => s5; // 20px
  static double get inputRadius => s3; // 12px

  // ============= ICON SIZES =============
  static double get iconXS => s4; // 16px
  static double get iconSM => s5; // 20px
  static double get iconMD => s6; // 24px
  static double get iconLG => s8; // 32px
  static double get iconXL => s10; // 40px
  static double get iconXXL => s12; // 48px

  // ============= HEIGHTS =============
  // Button heights
  static double get buttonHeightSM => s8; // 32px
  static double get buttonHeightMD => s10; // 40px
  static double get buttonHeightLG => s12; // 48px
  static double get buttonHeightXL => s14; // 56px

  // Input heights
  static double get inputHeightSM => s8; // 32px
  static double get inputHeightMD => s10; // 40px
  static double get inputHeightLG => s12; // 48px

  // Navigation heights
  static double get appBarHeight => s14; // 56px
  static double get bottomNavHeight => 60.h; // 60px
  static double get tabBarHeight => s12; // 48px

  // ============= LEGACY MAPPING (for backward compatibility) =============
  static double get xs => s2; // 8px
  static double get sm => s3; // 12px
  static double get md => s4; // 16px
  static double get lg => s6; // 24px
  static double get xl => s8; // 32px
  static double get xxl => s12; // 48px

  static double get radiusXs => radiusXS;
  static double get radiusSm => radiusSM;
  static double get radiusMd => radiusMD;
  static double get radiusLg => radiusLG;
  static double get radiusXl => radiusXL;
  static double get radiusRound => radiusFull;

  static double get iconXs => iconXS;
  static double get iconSm => iconSM;
  static double get iconMd => iconMD;
  static double get iconLg => iconLG;
  static double get iconXl => iconXL;

  static double get inputHeight => inputHeightLG;
}
