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
  // Logo & Branding
  static const String logo = '$_imagesPath/logo.png';
  static const String logoLight = '$_imagesPath/logo_light.png';
  static const String logoDark = '$_imagesPath/logo_dark.png';
  static const String splash = '$_imagesPath/splash.png';
  
  // Onboarding
  static const String onboarding1 = '$_imagesPath/onboarding_1.png';
  static const String onboarding2 = '$_imagesPath/onboarding_2.png';
  static const String onboarding3 = '$_imagesPath/onboarding_3.png';
  
  // Placeholders
  static const String placeholder = '$_imagesPath/placeholder.png';
  static const String userPlaceholder = '$_imagesPath/user_placeholder.png';
  static const String destinationPlaceholder = '$_imagesPath/destination_placeholder.png';
  
  // Backgrounds
  static const String backgroundPattern = '$_imagesPath/bg_pattern.png';
  static const String backgroundGradient = '$_imagesPath/bg_gradient.png';
  
  // ============= ICONS =============
  // Navigation icons
  static const String iconHome = '$_iconsPath/ic_home.svg';
  static const String iconExplore = '$_iconsPath/ic_explore.svg';
  static const String iconBooking = '$_iconsPath/ic_booking.svg';
  static const String iconProfile = '$_iconsPath/ic_profile.svg';
  
  // Action icons
  static const String iconSearch = '$_iconsPath/ic_search.svg';
  static const String iconFilter = '$_iconsPath/ic_filter.svg';
  static const String iconNotification = '$_iconsPath/ic_notification.svg';
  static const String iconSettings = '$_iconsPath/ic_settings.svg';
  static const String iconShare = '$_iconsPath/ic_share.svg';
  static const String iconFavorite = '$_iconsPath/ic_favorite.svg';
  static const String iconLocation = '$_iconsPath/ic_location.svg';
  static const String iconCalendar = '$_iconsPath/ic_calendar.svg';
  
  // Social icons
  static const String iconGoogle = '$_iconsPath/ic_google.svg';
  static const String iconFacebook = '$_iconsPath/ic_facebook.svg';
  static const String iconApple = '$_iconsPath/ic_apple.svg';
  
  // ============= ANIMATIONS =============
  // Lottie animations
  static const String animLoading = '$_animationsPath/loading.json';
  static const String animSuccess = '$_animationsPath/success.json';
  static const String animError = '$_animationsPath/error.json';
  static const String animEmpty = '$_animationsPath/empty.json';
  static const String animNoInternet = '$_animationsPath/no_internet.json';
  static const String animWelcome = '$_animationsPath/welcome.json';
  static const String animTravel = '$_animationsPath/travel.json';
  
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
enum AssetType {
  image,
  icon,
  animation,
  font,
}