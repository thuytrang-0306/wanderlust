import 'package:flutter/material.dart';

/// Color system based on Wanderlust design specifications
class AppColors {
  AppColors._();
  
  // ============= PRIMARY COLORS =============
  // Primary color palette for interactive elements (CTAs, links, inputs, active states)
  static const Color primary50 = Color(0xFFF6F2FF);
  static const Color primary100 = Color(0xFFEEE8FF);
  static const Color primary200 = Color(0xFFDFD4FF);
  static const Color primary300 = Color(0xFFC8B2FF);
  static const Color primary400 = Color(0xFF9D6EFF);
  static const Color primary500 = Color(0xFF9455FD);
  static const Color primary600 = Color(0xFF8832F5);
  static const Color primary700 = Color(0xFF7920E1);
  static const Color primary800 = Color(0xFF661ABD);
  static const Color primary900 = Color(0xFF54189A);
  static const Color primary950 = Color(0xFF340C69);
  
  // Main primary color
  static const Color primary = primary500;
  static const Color primaryLight = primary300;
  static const Color primaryDark = primary700;
  
  // ============= SECONDARY COLORS =============
  // Secondary color palette for secondary focus elements
  static const Color secondary950_1 = Color(0xFF3D1A73);
  static const Color secondary950_2 = Color(0xFF351A5F);
  static const Color secondary950_3 = Color(0xFF321958);
  static const Color secondary950_4 = Color(0xFF2F105F);
  static const Color secondary950_5 = Color(0xFF2B1848);
  static const Color secondary950_6 = Color(0xFF1B0937);
  
  // Main secondary colors
  static const Color secondary = secondary950_1;
  static const Color secondaryLight = secondary950_3;
  static const Color secondaryDark = secondary950_6;
  
  // ============= NEUTRAL COLORS =============
  // Supporting colors for backgrounds, text, separators, modals
  static const Color neutral50 = Color(0xFFF5F7F8);
  static const Color neutral100 = Color(0xFFF5F7F8); // Same as 50 in design
  static const Color neutral200 = Color(0xFFDDE2E8);
  static const Color neutral300 = Color(0xFFC8D0D9);
  static const Color neutral400 = Color(0xFFB2BAC7);
  static const Color neutral500 = Color(0xFF9DA4B7);
  static const Color neutral600 = Color(0xFF8C92A8);
  static const Color neutral700 = Color(0xFF74798E);
  static const Color neutral800 = Color(0xFF5F6474);
  static const Color neutral900 = Color(0xFF50545F);
  static const Color neutral950 = Color(0xFF2F3137);
  
  // Common neutral colors
  static const Color grey = neutral500;
  static const Color greyLight = neutral300;
  static const Color greyDark = neutral700;
  
  // ============= SEMANTIC COLORS =============
  // Colors for specific states and feedback
  static const Color success = Color(0xFF86FB84);
  static const Color successLight = Color(0xFFA4FCA2);
  static const Color successDark = Color(0xFF6ADB68);
  
  static const Color warning = Color(0xFFFDF28D);
  static const Color warningLight = Color(0xFFFDF5A8);
  static const Color warningDark = Color(0xFFE4D97F);
  
  static const Color error = Color(0xFFF87B7B);
  static const Color errorLight = Color(0xFFFA9595);
  static const Color errorDark = Color(0xFFE66969);
  
  static const Color info = Color(0xFF4094F0);
  static const Color infoLight = Color(0xFF6AAEF4);
  static const Color infoDark = Color(0xFF3678C4);
  
  // ============= BASE COLORS =============
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  
  // ============= BACKGROUND COLORS =============
  static const Color background = white;
  static const Color backgroundSecondary = neutral50;
  static const Color backgroundTertiary = neutral100;
  static const Color backgroundDark = neutral950;
  static const Color surface = backgroundSecondary;
  static const Color surfaceVariant = backgroundTertiary;
  
  // ============= TEXT COLORS =============
  static const Color textPrimary = neutral950;
  static const Color textSecondary = neutral700;
  static const Color textTertiary = neutral500;
  static const Color textDisabled = neutral400;
  static const Color textHint = neutral400;
  static const Color textOnPrimary = white;
  static const Color textOnDark = white;
  
  // ============= BORDER COLORS =============
  static const Color border = neutral200;
  static const Color borderLight = neutral100;
  static const Color borderDark = neutral300;
  
  // ============= DIVIDER COLORS =============
  static const Color divider = neutral200;
  static const Color dividerLight = neutral100;
  
  // ============= SHADOW COLORS =============
  static const Color shadow = Color(0x1A000000); // 10% black
  static const Color shadowLight = Color(0x0D000000); // 5% black
  static const Color shadowDark = Color(0x33000000); // 20% black
  
  // ============= OVERLAY COLORS =============
  static const Color overlay = Color(0x66000000); // 40% black
  static const Color overlayLight = Color(0x33000000); // 20% black
  static const Color overlayDark = Color(0x99000000); // 60% black
  
  // ============= GRADIENTS =============
  // Design system gradients
  static const LinearGradient gradient101 = LinearGradient(
    colors: [Color(0xFFC4CDF4), Color(0xFFEDE0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradient202 = LinearGradient(
    colors: [Color(0xFFC8D4FF), Color(0xFFDFF4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradient303 = LinearGradient(
    colors: [Color(0xFFBEEBFE), Color(0xFFDDFFF7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradient505 = LinearGradient(
    colors: [Color(0xFFD0FCEF), Color(0xFFE6F5C5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Utility gradients based on primary colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary400, primary600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient primaryGradientLight = LinearGradient(
    colors: [primary300, primary500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Secondary gradients
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary950_2, secondary950_5],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Neutral gradients
  static const LinearGradient neutralGradient = LinearGradient(
    colors: [neutral100, neutral300],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ============= MATERIAL COLOR SWATCHES =============
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF9455FD,
    <int, Color>{
      50: primary50,
      100: primary100,
      200: primary200,
      300: primary300,
      400: primary400,
      500: primary500,
      600: primary600,
      700: primary700,
      800: primary800,
      900: primary900,
    },
  );
  
  // ============= HELPER METHODS =============
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Get appropriate text color for a background
  static Color getTextColorFor(Color background) {
    // Calculate luminance
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? textPrimary : textOnDark;
  }
  
  /// Check if color is dark
  static bool isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }
  
  /// Check if color is light
  static bool isLight(Color color) {
    return color.computeLuminance() >= 0.5;
  }
}