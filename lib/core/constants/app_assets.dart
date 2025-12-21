/// Asset paths management for Wanderlust app
class AppAssets {
  AppAssets._();

  // ============= BASE PATHS =============
  static const String _basePath = 'assets';
  static const String _imagesPath = '$_basePath/images';
  static const String _iconsPath = '$_basePath/icons';
  static const String _animationsPath = '$_basePath/animations';
  static const String _fontsPath = '$_basePath/fonts';

  // ============= IMAGES =============
  // Logo & Branding (ACTUAL FILES)
  static const String logo = '$_imagesPath/logo.png';
  static const String splashLogoIosStyle = '$_imagesPath/splash_logo_ios_style.png';
  static const String appIcon = '$_imagesPath/app_icon.png';
  static const String appIconAdaptive = '$_imagesPath/app_icon_adaptive.png';

  // Onboarding (ACTUAL FILES)
  static const String onboarding1 = '$_imagesPath/on_boarding_1.png';
  static const String onboarding2 = '$_imagesPath/on_boarding_2.png';
  static const String onboarding3 = '$_imagesPath/on_boarding_3.png';

  // NOTE: Placeholder images not created yet - use network images for now
  // TODO: Create actual placeholder images when needed

  // 3D Illustrations (TODO: Add actual files when available)
  static const String travel3d = '$_imagesPath/travel_3d.png';

  // AI Assistant FAB icon
  static const String aiFabIcon = '$_imagesPath/ai_fab_icon.png';

  // ============= ICONS =============
  // Bottom Navigation icons (PNG with multi-resolution)
  static const String iconTabHome = '$_iconsPath/tab_home.png';
  static const String iconTabCommunity = '$_iconsPath/tab_community.png';
  static const String iconTabPlanning = '$_iconsPath/tab_planning.png';
  static const String iconTabNotifications = '$_iconsPath/tab_notifications.png';
  static const String iconTabAccount = '$_iconsPath/tab_account.png';

  // NOTE: SVG icons and Lottie animations not created yet
  // TODO: Add SVG icons when designer provides them
  // TODO: Add Lottie animations when created

  // ============= ANIMATIONS =============
  // Currently no animation files exist in the animations folder

  // ============= FONTS =============
  static const String fontGilroy = 'Gilroy';

  // ============= HELPER METHODS =============

  /// Get asset path with extension check
  static String getAssetPath(String name, AssetType type) {
    switch (type) {
      case AssetType.image:
        return '$_imagesPath/$name';
      case AssetType.icon:
        return '$_iconsPath/$name';
      case AssetType.animation:
        return '$_animationsPath/$name';
      case AssetType.font:
        return '$_fontsPath/$name';
    }
  }

  /// Check if asset is SVG
  static bool isSvg(String path) {
    return path.toLowerCase().endsWith('.svg');
  }

  /// Check if asset is Lottie
  static bool isLottie(String path) {
    return path.toLowerCase().endsWith('.json');
  }

  /// Check if asset exists (for debug)
  static bool assetExists(String path) {
    // This is just for documentation
    // Actual check would need to be async with rootBundle
    return true;
  }
}

/// Asset types enum
enum AssetType { image, icon, animation, font }
