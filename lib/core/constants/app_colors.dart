import 'package:flutter/material.dart';

/// Color system based on Wanderlust design specifications
class AppColors {
  AppColors._();
  
  // ============= PRIMARY COLORS =============
  // Primary color palette for interactive elements (CTAs, links, inputs, active states)
  static const Color primary50 = Color(0xFFF7FEE7);
  static const Color primary100 = Color(0xFFECFCCA);
  static const Color primary200 = Color(0xFFDEFA9B);
  static const Color primary300 = Color(0xFFABEB68);
  static const Color primary400 = Color(0xFF84CC16);
  static const Color primary500 = Color(0xFF65A30D);
  static const Color primary600 = Color(0xFF528729);
  static const Color primary700 = Color(0xFF446E26);
  static const Color primary800 = Color(0xFF355321);
  static const Color primary900 = Color(0xFF21330F);
  static const Color primary950 = Color(0xFF111907);
  
  // Main primary color
  static const Color primary = primary500;
  static const Color primaryLight = primary300;
  static const Color primaryDark = primary700;
  
  // ============= SECONDARY COLORS =============
  // Secondary color palette for secondary focus elements
  static const Color secondary50 = Color(0xFFFFF5F0);
  static const Color secondary100 = Color(0xFFFFE6D5);
  static const Color secondary200 = Color(0xFFFFCDAB);
  static const Color secondary300 = Color(0xFFFFB380);
  static const Color secondary400 = Color(0xFFFF9A56);
  static const Color secondary500 = Color(0xFFFF812C);
  static const Color secondary600 = Color(0xFFE56A00);
  static const Color secondary700 = Color(0xFFB35300);
  static const Color secondary800 = Color(0xFF803C00);
  static const Color secondary900 = Color(0xFF662F00);
  static const Color secondary950 = Color(0xFF421708);
  
  // Main secondary color
  static const Color secondary = secondary500;
  static const Color secondaryLight = secondary300;
  static const Color secondaryDark = secondary700;
  
  // ============= NEUTRAL COLORS =============
  // Supporting colors for backgrounds, text, separators, modals
  static const Color neutral50 = Color(0xFFF6F6F6);
  static const Color neutral100 = Color(0xFFE3E4E1);
  static const Color neutral200 = Color(0xFFD5D6D2);
  static const Color neutral300 = Color(0xFFBABCB5);
  static const Color neutral400 = Color(0xFF9FA196);
  static const Color neutral500 = Color(0xFF86877C);
  static const Color neutral600 = Color(0xFF73746B);
  static const Color neutral700 = Color(0xFF585951);
  static const Color neutral800 = Color(0xFF42423D);
  static const Color neutral900 = Color(0xFF32332E);
  static const Color neutral950 = Color(0xFF1F1F1B);
  
  // ============= SEMANTIC COLORS =============
  // Success - Positive emotions, complete states
  static const Color success50 = Color(0xFFF0FDF4);
  static const Color success100 = Color(0xFFDCFCE7);
  static const Color success200 = Color(0xFFBBF7D0);
  static const Color success300 = Color(0xFF86EFAC);
  static const Color success400 = Color(0xFF37D334);  // Main success
  static const Color success500 = Color(0xFF22C55E);
  static const Color success600 = Color(0xFF16A34A);
  static const Color success700 = Color(0xFF15803D);
  static const Color success800 = Color(0xFF166534);
  static const Color success900 = Color(0xFF14532D);
  
  // Warning - Hold states, caution
  static const Color warning50 = Color(0xFFFFFBEB);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color warning200 = Color(0xFFFDE68A);
  static const Color warning300 = Color(0xFFF6DA45);  // Main warning
  static const Color warning400 = Color(0xFFFACC15);
  static const Color warning500 = Color(0xFFEAB308);
  static const Color warning600 = Color(0xFFCA8A04);
  static const Color warning700 = Color(0xFFA16207);
  static const Color warning800 = Color(0xFF854D0E);
  static const Color warning900 = Color(0xFF713F12);
  
  // Error - Negative emotions, error states
  static const Color error50 = Color(0xFFFEF2F2);
  static const Color error100 = Color(0xFFFEE2E2);
  static const Color error200 = Color(0xFFFECACA);
  static const Color error300 = Color(0xFFFCA5A5);
  static const Color error400 = Color(0xFFF87171);
  static const Color error500 = Color(0xFFF04040);  // Main error
  static const Color error600 = Color(0xFFDC2626);
  static const Color error700 = Color(0xFFB91C1C);
  static const Color error800 = Color(0xFF991B1B);
  static const Color error900 = Color(0xFF7F1D1D);
  
  // Info
  static const Color info = Color(0xFF2196F3);
  
  // ============= BASE COLORS =============
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  
  // ============= BACKGROUND COLORS =============
  static const Color background = neutral50;
  static const Color backgroundDark = neutral950;
  static const Color surface = white;
  static const Color surfaceDark = neutral900;
  static const Color surfaceVariant = neutral100;
  static const Color surfaceVariantDark = neutral800;
  
  // ============= TEXT COLORS =============
  static const Color textPrimary = neutral950;
  static const Color textPrimaryDark = neutral50;
  static const Color textSecondary = neutral700;
  static const Color textSecondaryDark = neutral300;
  static const Color textTertiary = neutral500;
  static const Color textTertiaryDark = neutral400;
  static const Color textDisabled = neutral400;
  static const Color textDisabledDark = neutral600;
  static const Color textHint = neutral300;
  static const Color textHintDark = neutral700;
  
  // ============= BORDER COLORS =============
  static const Color border = neutral200;
  static const Color borderDark = neutral800;
  static const Color divider = neutral100;
  static const Color dividerDark = neutral900;
  
  // ============= GRADIENTS =============
  static const LinearGradient gradient101 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF84CC16),
      Color(0xFF65A30D),
    ],
  );
  
  static const LinearGradient gradient202 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF812C),
      Color(0xFFE56A00),
    ],
  );
  
  static const LinearGradient gradient303 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF37D334),
      Color(0xFF22C55E),
    ],
  );
  
  static const LinearGradient gradient505 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1F1F1B),
      Color(0xFF42423D),
    ],
  );
  
  // ============= SPECIAL GRADIENT =============
  static const LinearGradient primaryGradient = gradient101;
  static const LinearGradient secondaryGradient = gradient202;
  static const LinearGradient successGradient = gradient303;
  static const LinearGradient darkGradient = gradient505;
  
  // ============= LEGACY MAPPING (for backward compatibility) =============
  static const Color grey = neutral500;
  static const Color greyLight = neutral200;
  static const Color greyDark = neutral700;
  static const Color success = success400;
  static const Color warning = warning300;
  static const Color error = error500;
}