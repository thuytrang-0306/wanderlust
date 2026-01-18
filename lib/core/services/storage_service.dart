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

  // Trip Cache Keys
  static const String keyTripsCache = 'trips_cache';
  static const String keyTripsCacheTimestamp = 'trips_cache_timestamp';
  static const String keyTripDetailCache = 'trip_detail_cache';
  static const String keyTripDayDataCache = 'trip_day_data_cache';

  // Cache TTL (Time To Live) - 5 minutes for trips list
  static const int tripsCacheTTLMs = 5 * 60 * 1000;

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
    await clearTripsCache();
    LoggerService.i('User session cleared');
  }

  // ============ TRIP CACHE METHODS ============

  /// Save trips list to cache
  Future<void> cacheTrips(List<Map<String, dynamic>> trips) async {
    await write(keyTripsCache, trips);
    await write(keyTripsCacheTimestamp, DateTime.now().millisecondsSinceEpoch);
    LoggerService.d('Cached ${trips.length} trips');
  }

  /// Get cached trips list
  List<Map<String, dynamic>>? getCachedTrips() {
    final cached = read<List<dynamic>>(keyTripsCache);
    if (cached == null) return null;

    // Check if cache is still valid
    final timestamp = read<int>(keyTripsCacheTimestamp);
    if (timestamp != null) {
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > tripsCacheTTLMs) {
        LoggerService.d('Trips cache expired (age: ${age}ms)');
        return null; // Cache expired, but still return for offline-first
      }
    }

    return cached.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Check if trips cache is valid (not expired)
  bool isTripsCacheValid() {
    final timestamp = read<int>(keyTripsCacheTimestamp);
    if (timestamp == null) return false;

    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    return age <= tripsCacheTTLMs;
  }

  /// Get cached trips even if expired (for offline-first)
  List<Map<String, dynamic>>? getCachedTripsOffline() {
    final cached = read<List<dynamic>>(keyTripsCache);
    if (cached == null) return null;
    return cached.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Cache trip detail (dayNotes, privateLocations)
  Future<void> cacheTripDayData(String tripId, Map<String, dynamic> dayData) async {
    final allCache = read<Map<String, dynamic>>(keyTripDayDataCache) ?? {};
    allCache[tripId] = {
      'data': dayData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await write(keyTripDayDataCache, allCache);
    LoggerService.d('Cached day data for trip: $tripId');
  }

  /// Get cached trip day data
  Map<String, dynamic>? getCachedTripDayData(String tripId) {
    final allCache = read<Map<String, dynamic>>(keyTripDayDataCache);
    if (allCache == null) return null;

    final tripCache = allCache[tripId];
    if (tripCache == null) return null;

    return Map<String, dynamic>.from(tripCache['data'] as Map);
  }

  /// Clear all trips cache
  Future<void> clearTripsCache() async {
    await remove(keyTripsCache);
    await remove(keyTripsCacheTimestamp);
    await remove(keyTripDayDataCache);
    LoggerService.d('Trips cache cleared');
  }

  /// Invalidate cache for specific trip
  Future<void> invalidateTripCache(String tripId) async {
    // Remove from day data cache
    final allCache = read<Map<String, dynamic>>(keyTripDayDataCache);
    if (allCache != null && allCache.containsKey(tripId)) {
      allCache.remove(tripId);
      await write(keyTripDayDataCache, allCache);
      LoggerService.d('Invalidated cache for trip: $tripId');
    }

    // Also invalidate trips list cache timestamp to force refresh
    await remove(keyTripsCacheTimestamp);
  }
}
