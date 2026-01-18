import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/services/storage_service.dart';
import 'package:wanderlust/data/models/trip_model.dart';
import 'package:wanderlust/data/services/trip_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class PlanningController extends BaseController {
  // Services
  final TripService _tripService = Get.find<TripService>();
  final StorageService _storageService = StorageService.to;

  // Stream subscription for proper cleanup
  StreamSubscription<List<TripModel>>? _tripsSubscription;

  // Retry configuration
  int _retryCount = 0;
  static const int _maxRetries = 3;
  Timer? _retryTimer;

  // Data
  final RxList<TripModel> allTrips = <TripModel>[].obs;
  final RxList<TripModel> upcomingTrips = <TripModel>[].obs;
  final RxList<TripModel> ongoingTrips = <TripModel>[].obs;
  final RxList<TripModel> pastTrips = <TripModel>[].obs;

  // UI State
  final RxInt selectedTab = 0.obs; // 0: All, 1: Upcoming, 2: Ongoing, 3: Past
  final RxBool isLoadingTrips = true.obs;

  // Add reactive state getter
  Rx<ViewState> get state => Rx<ViewState>(viewState);

  // Filtered trips based on selected tab
  List<TripModel> get displayedTrips {
    switch (selectedTab.value) {
      case 1:
        return upcomingTrips;
      case 2:
        return ongoingTrips;
      case 3:
        return pastTrips;
      default:
        return allTrips;
    }
  }

  // User info
  final Rx<User?> currentUser = FirebaseAuth.instance.currentUser.obs;

  // Stats
  int get totalTrips => allTrips.length;
  int get totalDestinations => allTrips.map((t) => t.destination).toSet().length;
  double get totalBudget => allTrips.fold(0, (sum, trip) => sum + trip.budget);
  double get totalSpent => allTrips.fold(0, (sum, trip) => sum + trip.spentAmount);

  @override
  void onInit() {
    super.onInit();

    // Set initial loading state
    isLoadingTrips.value = true;
    setLoading();

    // ✅ CACHE-FIRST: Show cached data immediately if available
    _loadCachedTripsFirst();

    // ✅ THEN subscribe to real-time updates
    _subscribeToTrips();
  }

  /// Load cached trips first for instant UI (offline-first strategy)
  void _loadCachedTripsFirst() {
    final cachedTrips = _storageService.getCachedTripsOffline();
    if (cachedTrips != null && cachedTrips.isNotEmpty) {
      try {
        final trips = cachedTrips.map((json) => TripModel.fromCacheJson(json)).toList();
        allTrips.value = trips;
        _categorizeTrips(trips);

        // Show cached data immediately (still loading fresh data)
        if (isLoadingTrips.value) {
          isLoadingTrips.value = false;
          setSuccess();
        }

        LoggerService.i('Loaded ${trips.length} trips from cache (offline-first)');
      } catch (e) {
        LoggerService.e('Failed to parse cached trips', error: e);
      }
    }
  }

  /// Subscribe to real-time trips stream with proper cleanup
  void _subscribeToTrips({bool isRetry = false}) {
    // Cancel existing subscription if any
    _tripsSubscription?.cancel();

    // Only reset retry count on fresh subscribe, not on retry
    if (!isRetry) {
      _retryCount = 0;
    }

    _tripsSubscription = _tripService.streamUserTrips().listen(
      (trips) {
        allTrips.value = trips;
        _categorizeTrips(trips);

        // ✅ Cache trips for offline-first
        _cacheTrips(trips);

        // Update loading state
        if (isLoadingTrips.value) {
          isLoadingTrips.value = false;
          if (trips.isEmpty) {
            setEmpty();
          } else {
            setSuccess();
          }
        }

        // Reset retry count on success
        _retryCount = 0;

        LoggerService.i('Stream updated with ${trips.length} trips');
      },
      onError: (error) {
        LoggerService.e('Error streaming trips', error: error);

        // ✅ RETRY with exponential backoff
        _handleStreamError(error);
      },
    );
  }

  /// Handle stream error with exponential backoff retry
  void _handleStreamError(dynamic error) {
    _retryCount++;

    if (_retryCount <= _maxRetries) {
      final delay = Duration(seconds: _retryCount * 2); // 2s, 4s, 6s

      LoggerService.w('Stream error, retrying in ${delay.inSeconds}s (attempt $_retryCount/$_maxRetries)');

      _retryTimer?.cancel();
      _retryTimer = Timer(delay, () {
        _subscribeToTrips(isRetry: true); // Pass isRetry to avoid resetting counter
      });
    } else {
      // Max retries reached, fallback to static load
      LoggerService.e('Max retries reached ($_retryCount), falling back to static load');
      setError('Không thể tải danh sách chuyến đi');
      isLoadingTrips.value = false;
      loadTrips();
    }
  }

  /// Cache trips for offline-first
  Future<void> _cacheTrips(List<TripModel> trips) async {
    try {
      final tripsJson = trips.map((t) => t.toCacheJson()).toList();
      await _storageService.cacheTrips(tripsJson);
    } catch (e) {
      LoggerService.e('Failed to cache trips', error: e);
    }
  }

  @override
  void onClose() {
    // ✅ Properly cancel stream subscription to prevent memory leak
    _tripsSubscription?.cancel();
    _tripsSubscription = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    LoggerService.d('PlanningController: Stream subscription cancelled');
    super.onClose();
  }

  @override
  void loadData() {
    // Only reload if not streaming
    if (!isLoadingTrips.value) {
      loadTrips();
    }
  }

  Future<void> loadTrips() async {
    try {
      isLoadingTrips.value = true;
      setLoading();

      final trips = await _tripService.getUserTrips();

      // Simply load the trips without creating sample data
      allTrips.value = trips;
      _categorizeTrips(trips);

      LoggerService.i('Loaded ${trips.length} trips from Firestore');

      if (trips.isEmpty) {
        setEmpty();
      } else {
        setSuccess();
      }
    } catch (e) {
      LoggerService.e('Error loading trips', error: e);
      setError('Không thể tải danh sách chuyến đi');
    } finally {
      isLoadingTrips.value = false;
    }
  }

  void _categorizeTrips(List<TripModel> trips) {
    final now = DateTime.now();

    upcomingTrips.value =
        trips.where((trip) => trip.startDate.isAfter(now) && trip.status != 'cancelled').toList();

    ongoingTrips.value =
        trips.where((trip) => trip.isOngoing && trip.status != 'cancelled').toList();

    pastTrips.value = trips.where((trip) => trip.isPast || trip.status == 'cancelled').toList();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void createNewTrip() async {
    final result = await Get.toNamed('/trip-edit');

    // Reload trips if a new trip was created
    if (result == true) {
      LoggerService.i('Reloading trips after creation');
      await loadTrips();
    }
  }

  void editTrip(TripModel trip) async {
    final result = await Get.toNamed('/trip-edit', arguments: {'trip': trip});

    // Reload trips if updated
    if (result == true) {
      LoggerService.i('Reloading trips after edit');
      await loadTrips();
    }
  }

  void viewTripDetail(TripModel trip) {
    Get.toNamed('/trip-detail', arguments: {'trip': trip});
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      // Show confirmation dialog
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Xóa chuyến đi'),
          content: const Text(
            'Bạn có chắc muốn xóa chuyến đi này? Tất cả dữ liệu sẽ bị xóa vĩnh viễn.',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Hủy')),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setLoading();
      final success = await _tripService.deleteTrip(tripId);

      if (success) {
        AppSnackbar.showSuccess(title: 'Thành công', message: 'Đã xóa chuyến đi');
        await loadTrips();
      } else {
        AppSnackbar.showError(title: 'Lỗi', message: 'Không thể xóa chuyến đi');
      }
    } catch (e) {
      LoggerService.e('Error deleting trip', error: e);
      AppSnackbar.showError(title: 'Lỗi', message: 'Có lỗi xảy ra');
    } finally {
      setIdle();
    }
  }

  Future<void> updateTripStatus(String tripId, String status) async {
    try {
      final success = await _tripService.updateTrip(tripId, {'status': status});

      if (success) {
        AppSnackbar.showSuccess(title: 'Thành công', message: 'Đã cập nhật trạng thái');
        await loadTrips();
      } else {
        AppSnackbar.showError(title: 'Lỗi', message: 'Không thể cập nhật trạng thái');
      }
    } catch (e) {
      LoggerService.e('Error updating trip status', error: e);
    }
  }

  String getTabTitle(int index) {
    switch (index) {
      case 1:
        return 'Sắp tới (${upcomingTrips.length})';
      case 2:
        return 'Đang đi (${ongoingTrips.length})';
      case 3:
        return 'Đã đi (${pastTrips.length})';
      default:
        return 'Tất cả (${allTrips.length})';
    }
  }

  // Quick stats for UI display
  Map<String, dynamic> getTripStats() {
    return {
      'totalTrips': totalTrips,
      'upcomingCount': upcomingTrips.length,
      'destinations': totalDestinations,
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
      'budgetRemaining': totalBudget - totalSpent,
    };
  }

  Future<void> shareTrip(TripModel trip) async {
    try {
      // Format dates
      final dateFormat = DateFormat('dd/MM/yyyy');
      final startDateStr = dateFormat.format(trip.startDate);
      final endDateStr = dateFormat.format(trip.endDate);

      // Build share text
      final shareText = '''
🌍 ${trip.title}

📍 Điểm đến: ${trip.destination}
📅 Thời gian: $startDateStr - $endDateStr
👥 Số người: ${trip.travelers.length}
⏱️ Thời lượng: ${trip.duration} ngày
💰 Ngân sách: ${trip.budget > 0 ? '${NumberFormat('#,###').format(trip.budget)} VNĐ' : 'Chưa xác định'}

${trip.description.isNotEmpty ? '📝 ${trip.description}\n' : ''}
Chia sẻ từ ứng dụng Wanderlust 🧳
''';

      await Share.share(shareText);
      LoggerService.i('Shared trip: ${trip.title}');
    } catch (e) {
      LoggerService.e('Error sharing trip', error: e);
      AppSnackbar.showError(title: 'Lỗi', message: 'Không thể chia sẻ chuyến đi');
    }
  }

  // Clear all trips - USE WITH CAUTION!
  Future<void> clearAllTrips() async {
    try {
      // Show confirmation dialog
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Xóa tất cả chuyến đi'),
          content: const Text(
            'Bạn có chắc muốn xóa TẤT CẢ chuyến đi? \n\n'
            'Hành động này KHÔNG THỂ hoàn tác!',
            style: TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Hủy')),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('XÓA TẤT CẢ'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setLoading();
      final success = await _tripService.deleteAllUserTrips();

      if (success) {
        AppSnackbar.showSuccess(title: 'Thành công', message: 'Đã xóa tất cả chuyến đi');
        // Clear local data
        allTrips.clear();
        upcomingTrips.clear();
        ongoingTrips.clear();
        pastTrips.clear();
        setEmpty();
      } else {
        AppSnackbar.showError(title: 'Lỗi', message: 'Không thể xóa chuyến đi');
      }
    } catch (e) {
      LoggerService.e('Error clearing all trips', error: e);
      AppSnackbar.showError(title: 'Lỗi', message: 'Có lỗi xảy ra');
    } finally {
      setIdle();
    }
  }
}
