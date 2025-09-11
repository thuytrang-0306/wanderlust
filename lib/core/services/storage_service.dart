import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();
  
  late GetStorage _box;
  
  // Storage Keys
  static const String keyFirstTime = 'first_time';
  static const String keyToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyNotificationEnabled = 'notification_enabled';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keySearchHistory = 'search_history';
  static const String keyFavorites = 'favorites';
  
  Future<StorageService> init() async {
    await GetStorage.init('wanderlust_storage');
    _box = GetStorage('wanderlust_storage');
    LoggerService.i('StorageService initialized');
    return this;
  }
  
  // Generic methods
  T? read<T>(String key) {
    final value = _box.read<T>(key);
    LoggerService.d('Read from storage: $key = $value');
    return value;
  }
  
  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
    LoggerService.d('Write to storage: $key = $value');
  }
  
  Future<void> remove(String key) async {
    await _box.remove(key);
    LoggerService.d('Removed from storage: $key');
  }
  
  Future<void> clearAll() async {
    await _box.erase();
    LoggerService.w('All storage data cleared');
  }
  
  // User & Auth
  bool get isFirstTime => read<bool>(keyFirstTime) ?? true;
  Future<void> setFirstTime(bool value) => write(keyFirstTime, value);
  
  String? get token => read<String>(keyToken);
  Future<void> saveToken(String token) => write(keyToken, token);
  Future<void> clearToken() => remove(keyToken);
  
  String? get userId => read<String>(keyUserId);
  Future<void> saveUserId(String id) => write(keyUserId, id);
  
  Map<String, dynamic>? get userData => read<Map<String, dynamic>>(keyUserData);
  Future<void> saveUserData(Map<String, dynamic> data) => write(keyUserData, data);
  Future<void> clearUserData() => remove(keyUserData);
  
  bool get hasUser => token != null && userId != null;
  
  // Settings
  String get language => read<String>(keyLanguage) ?? 'en';
  Future<void> saveLanguage(String lang) => write(keyLanguage, lang);
  
  String get theme => read<String>(keyTheme) ?? 'light';
  Future<void> saveTheme(String theme) => write(keyTheme, theme);
  
  bool get onboardingComplete => read<bool>(keyOnboardingComplete) ?? false;
  Future<void> setOnboardingComplete(bool value) => write(keyOnboardingComplete, value);
  
  bool get notificationEnabled => read<bool>(keyNotificationEnabled) ?? true;
  Future<void> setNotificationEnabled(bool value) => write(keyNotificationEnabled, value);
  
  bool get biometricEnabled => read<bool>(keyBiometricEnabled) ?? false;
  Future<void> setBiometricEnabled(bool value) => write(keyBiometricEnabled, value);
  
  // App Data
  List<String> get searchHistory => read<List<dynamic>>(keySearchHistory)?.cast<String>() ?? [];
  
  Future<void> addSearchHistory(String query) async {
    final history = searchHistory;
    history.remove(query); // Remove if exists
    history.insert(0, query); // Add to beginning
    if (history.length > 10) history.removeLast(); // Keep max 10 items
    await write(keySearchHistory, history);
  }
  
  Future<void> clearSearchHistory() => remove(keySearchHistory);
  
  List<String> get favorites => read<List<dynamic>>(keyFavorites)?.cast<String>() ?? [];
  
  Future<void> addFavorite(String id) async {
    final favs = favorites;
    if (!favs.contains(id)) {
      favs.add(id);
      await write(keyFavorites, favs);
    }
  }
  
  Future<void> removeFavorite(String id) async {
    final favs = favorites;
    favs.remove(id);
    await write(keyFavorites, favs);
  }
  
  bool isFavorite(String id) => favorites.contains(id);
  
  // Clear user session
  Future<void> clearSession() async {
    await clearToken();
    await clearUserData();
    await remove(keyUserId);
    await remove(keyFavorites);
    LoggerService.i('User session cleared');
  }
}