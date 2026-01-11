import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/data/models/trip_model.dart';
import 'package:wanderlust/data/services/trip_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

class TripDetailController extends BaseController {
  // Services
  final TripService _tripService = Get.find<TripService>();

  // Trip model
  final Rx<TripModel?> trip = Rx<TripModel?>(null);

  // Trip basic info - will be populated from actual trip
  final RxString tripName = ''.obs;
  final RxString tripDateRange = ''.obs;
  final RxString tripImage = ''.obs;
  final RxInt peopleCount = 1.obs;
  final RxInt totalDays = 1.obs;

  // Selected day
  final RxInt selectedDay = 0.obs;

  // Trip itinerary - will be loaded from backend
  final RxList<TripItinerary> tripItineraries = <TripItinerary>[].obs;

  // Trip days generated from date range
  final RxList<Map<String, dynamic>> tripDays = <Map<String, dynamic>>[].obs;

  // Loading state for initial data load
  final RxBool isInitialLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize date formatting for Vietnamese locale
    initializeDateFormatting('vi_VN', null);

    // Get trip data from arguments
    if (Get.arguments != null) {
      if (Get.arguments is Map && Get.arguments['trip'] != null) {
        // Load full trip model (from PlanningPage)
        final TripModel passedTrip = Get.arguments['trip'] as TripModel;
        loadTrip(passedTrip);
      } else if (Get.arguments is Map && Get.arguments['tripId'] != null) {
        // Load trip by ID (deep link or external navigation)
        loadTripById(Get.arguments['tripId'] as String);
      } else {
        // Handle error - invalid arguments
        LoggerService.e('Invalid arguments passed to TripDetailController');
        isInitialLoading.value = false;
        Get.back();
        AppSnackbar.showError(title: 'Lỗi', message: 'Không thể tải thông tin chuyến đi');
      }
    }
  }

  // Load trip from passed model (OPTIMIZED with optimistic loading)
  Future<void> loadTrip(TripModel tripModel) async {
    // ✅ OPTIMISTIC LOADING - Show data immediately
    trip.value = tripModel;
    updateUIFromTrip(tripModel);
    isInitialLoading.value = false; // ✅ Hide shimmer ASAP

    // ✅ PARALLEL LOADING - Load all data concurrently
    try {
      await Future.wait([
        generateTripDays(tripModel),
        loadItineraries(tripModel.id),
      ]);

      LoggerService.i('Trip data loaded successfully (parallel)');
    } catch (e) {
      LoggerService.e('Error loading trip data', error: e);
      AppSnackbar.showError(title: 'Lỗi', message: 'Không thể tải một số thông tin chuyến đi');
    }
  }

  // Extract UI update logic for reusability
  void updateUIFromTrip(TripModel tripModel) {
    tripName.value = tripModel.title;
    tripImage.value = tripModel.coverImage;
    peopleCount.value = tripModel.travelers.length;
    totalDays.value = tripModel.duration;

    // Format date range
    final DateFormat formatter = DateFormat('E, dd/MM', 'vi_VN');
    final startStr = formatter.format(tripModel.startDate);
    final endStr = formatter.format(tripModel.endDate);
    tripDateRange.value = '$startStr - $endStr';
  }

  // Load trip by ID from backend (OPTIMIZED with direct query)
  Future<void> loadTripById(String tripId) async {
    try {
      isInitialLoading.value = true;

      // ✅ DIRECT QUERY - Much faster than loading all trips
      final tripModel = await _tripService.getTripById(tripId);

      if (tripModel != null) {
        await loadTrip(tripModel);
      } else {
        isInitialLoading.value = false;
        Get.back();
        AppSnackbar.showError(title: 'Lỗi', message: 'Không tìm thấy chuyến đi');
      }
    } catch (e) {
      LoggerService.e('Error loading trip by ID', error: e);
      isInitialLoading.value = false;
      Get.back();
      AppSnackbar.showError(title: 'Lỗi', message: 'Không thể tải thông tin chuyến đi');
    }
  }

  // Generate trip days structure
  Future<void> generateTripDays(TripModel tripModel) async {
    tripDays.clear();

    final startDate = tripModel.startDate;
    for (int i = 0; i < tripModel.duration; i++) {
      final dayDate = startDate.add(Duration(days: i));
      tripDays.add({
        'day': i + 1,
        'date': dayDate,
        'startTime': '8:00',
        'locations': [], // Will be populated from itineraries
        'note': '', // Initialize note field
      });
    }

    // Load day notes and private locations from Firestore (await completion)
    await loadDayNotesAndLocations(tripModel.id);
  }

  // Load day notes and private locations from Firestore
  Future<void> loadDayNotesAndLocations(String tripId) async {
    try {
      // Read directly from Firestore to get custom fields (dayNotes, privateLocations)
      final doc = await FirebaseFirestore.instance.collection('trips').doc(tripId).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          // Load day notes (Map<String, String>)
          final dayNotes = data['dayNotes'] as Map<String, dynamic>?;
          if (dayNotes != null) {
            dayNotes.forEach((key, value) {
              final dayIndex = int.tryParse(key);
              if (dayIndex != null && dayIndex > 0 && dayIndex <= tripDays.length) {
                tripDays[dayIndex - 1]['note'] = value.toString();
              }
            });
          }

          // Load private locations (List<Map>)
          final privateLocations = data['privateLocations'] as List<dynamic>?;
          if (privateLocations != null) {
            for (var location in privateLocations) {
              final locationMap = location as Map<String, dynamic>;
              final dayIndex = locationMap['dayIndex'] as int?;
              if (dayIndex != null && dayIndex >= 0 && dayIndex < tripDays.length) {
                final locations = tripDays[dayIndex]['locations'] as List;
                locations.add(locationMap);
              }
            }
          }

          tripDays.refresh();
          LoggerService.i('Loaded day notes and private locations');
        }
      }
    } catch (e) {
      LoggerService.e('Failed to load day notes and locations', error: e);
    }
  }

  // Load itineraries from backend
  Future<void> loadItineraries(String tripId) async {
    try {
      final itineraries = await _tripService.getTripItineraries(tripId);
      tripItineraries.value = itineraries;

      // Map itineraries to trip days (MERGE with existing locations)
      for (var itinerary in itineraries) {
        if (itinerary.dayNumber > 0 && itinerary.dayNumber <= tripDays.length) {
          // Get existing locations (privateLocations already added)
          final existingLocations = List<Map<String, dynamic>>.from(
            tripDays[itinerary.dayNumber - 1]['locations'] ?? []
          );

          // Add itinerary activities to existing locations
          final itineraryActivities = itinerary.activities
              .map(
                (activity) => {
                  'time': activity.time,
                  'title': activity.title,
                  'address': activity.location,
                  'description': activity.notes,
                  'image': '', // No image in current model
                  'type': 'itinerary', // Mark as itinerary type
                },
              )
              .toList();

          // MERGE: Keep private locations + add itinerary activities
          existingLocations.addAll(itineraryActivities);

          // Sort by time (ascending order)
          existingLocations.sort((a, b) {
            final timeA = a['time'] as String? ?? '00:00';
            final timeB = b['time'] as String? ?? '00:00';
            return timeA.compareTo(timeB);
          });

          // Update trip day with merged and sorted locations
          tripDays[itinerary.dayNumber - 1]['locations'] = existingLocations;
        }
      }
    } catch (e) {
      LoggerService.e('Error loading itineraries', error: e);
    }
  }

  // Select a day tab
  void selectDay(int dayIndex) {
    selectedDay.value = dayIndex;
  }

  // Get formatted date for a specific day
  String getDayDate(int dayIndex) {
    if (dayIndex < tripDays.length) {
      final date = tripDays[dayIndex]['date'] as DateTime;
      // Simple format without using DateFormat to avoid locale issues
      final weekday = date.weekday == 7 ? "CN" : (date.weekday + 1).toString();
      return 'Thứ $weekday, ${date.day}/${date.month}/${date.year}';
    }
    return '';
  }

  // Get start time for a day
  String getStartTime(int dayIndex) {
    if (dayIndex < tripDays.length) {
      return tripDays[dayIndex]['startTime'] ?? '8:00';
    }
    return '8:00';
  }

  // Check if a day has locations
  bool dayHasItems(int dayIndex) {
    if (dayIndex < tripDays.length) {
      final locations = tripDays[dayIndex]['locations'] as List;
      return locations.isNotEmpty;
    }
    return false;
  }

  // Get locations for a specific day
  List<Map<String, dynamic>> getLocationsForDay(int dayIndex) {
    if (dayIndex < tripDays.length) {
      return List<Map<String, dynamic>>.from(tripDays[dayIndex]['locations'] ?? []);
    }
    return [];
  }

  // Edit trip
  void editTrip() async {
    if (trip.value != null) {
      // Navigate to edit page with trip model
      final result = await Get.toNamed(
        '/trip-edit',
        arguments: {
          'trip': trip.value,
        },
      );

      // Reload trip data if updated successfully
      if (result != null && result is Map<String, dynamic> && result['success'] == true) {
        final tripId = result['tripId'] as String?;
        if (tripId != null) {
          // ✅ OPTIMIZED - Direct query instead of loading all trips
          final updatedTrip = await _tripService.getTripById(tripId);
          if (updatedTrip != null) {
            await loadTrip(updatedTrip);
            LoggerService.i('Trip updated, reloaded trip detail');
            AppSnackbar.showSuccess(title: 'Thành công', message: 'Đã cập nhật chuyến đi');
          }
        }
      }
    }
  }

  // Add location to current day
  void addLocation() {
    // TODO: Navigate to add location page
  }

  // Get note for specific day
  String getDayNote(int dayIndex) {
    if (dayIndex < tripDays.length) {
      return tripDays[dayIndex]['note'] ?? '';
    }
    return '';
  }

  // Update note for current day
  void updateDayNote(Map<String, dynamic> noteData) async {
    final dayIndex = selectedDay.value;
    if (dayIndex < tripDays.length) {
      // Update UI immediately
      tripDays[dayIndex]['note'] = noteData['note'];
      tripDays.refresh();

      // Save to database in background
      if (trip.value != null) {
        try {
          // Build day notes map from current tripDays
          final dayNotesMap = <String, String>{};
          for (int i = 0; i < tripDays.length; i++) {
            final note = tripDays[i]['note'] as String?;
            if (note != null && note.isNotEmpty) {
              dayNotesMap['${i + 1}'] = note; // Key as "1", "2", etc.
            }
          }

          await _tripService.updateTrip(trip.value!.id, {
            'dayNotes': dayNotesMap, // Save all day notes as map
            'updatedAt': DateTime.now(),
          });
          LoggerService.i('Note saved to database for day ${dayIndex + 1}');

          // Show success snackbar
          AppSnackbar.showSuccess(title: 'Thành công', message: 'Đã lưu ghi chú');
        } catch (e) {
          LoggerService.e('Failed to save note', error: e);
          AppSnackbar.showError(title: 'Lỗi', message: 'Không thể lưu ghi chú');
        }
      }
    }
  }

  // Add location from search (reload from DB to ensure sync)
  Future<void> addLocationFromSearch(Map<String, dynamic> locationData) async {
    if (trip.value == null) return;

    try {
      // Reload trip data from database to get fresh data
      await loadDayNotesAndLocations(trip.value!.id);

      LoggerService.i('Trip data reloaded after adding business location');
      AppSnackbar.showSuccess(
        title: 'Thành công',
        message: 'Đã thêm ${locationData['title'] ?? locationData['name']} vào kế hoạch',
      );
    } catch (e) {
      LoggerService.e('Error reloading trip data', error: e);
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Không thể tải lại dữ liệu',
      );
    }
  }

  // Delete location from current day
  void deleteLocation(int locationIndex) async {
    if (selectedDay.value < tripDays.length) {
      final locations = List<Map<String, dynamic>>.from(tripDays[selectedDay.value]['locations'] ?? []);

      if (locationIndex >= 0 && locationIndex < locations.length) {
        final deletedLocation = locations[locationIndex];

        // Remove from UI immediately
        locations.removeAt(locationIndex);
        tripDays[selectedDay.value]['locations'] = locations;
        tripDays.refresh();

        // If it's a private location or listing, also remove from database
        final locationType = deletedLocation['type'] as String?;
        if ((locationType == 'private' || locationType == 'listing') && trip.value != null) {
          try {
            // Get current private locations from trip
            final doc = await FirebaseFirestore.instance.collection('trips').doc(trip.value!.id).get();
            final data = doc.data();

            if (data != null) {
              final privateLocations = (data['privateLocations'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];

              // Remove the matching location
              privateLocations.removeWhere((loc) =>
                loc['dayIndex'] == selectedDay.value &&
                loc['title'] == deletedLocation['title'] &&
                loc['time'] == deletedLocation['time']
              );

              // Update database
              await _tripService.updateTrip(trip.value!.id, {
                'privateLocations': privateLocations,
                'updatedAt': DateTime.now(),
              });

              LoggerService.i('Deleted private location from database');
            }
          } catch (e) {
            LoggerService.e('Failed to delete private location from database', error: e);
          }
        }

        AppSnackbar.showSuccess(title: 'Thành công', message: 'Đã xóa địa điểm');
      }
    }
  }

  // Update private location
  void updatePrivateLocation(int locationIndex, Map<String, dynamic> updatedData) async {
    if (selectedDay.value < tripDays.length && trip.value != null) {
      try {
        // Load existing private locations from Firestore
        final doc = await FirebaseFirestore.instance.collection('trips').doc(trip.value!.id).get();
        final data = doc.data();

        if (data != null) {
          final existingLocations = (data['privateLocations'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ?? [];

          // Find and update the matching location
          bool updated = false;
          for (var i = 0; i < existingLocations.length; i++) {
            final loc = existingLocations[i];
            if (loc['dayIndex'] == selectedDay.value) {
              // Match by index in the day's locations
              final dayLocations = tripDays[selectedDay.value]['locations'] as List;
              final currentLocation = dayLocations[locationIndex];

              if (loc['title'] == currentLocation['title'] &&
                  loc['time'] == currentLocation['time']) {
                // Update this location
                existingLocations[i] = {
                  'dayIndex': selectedDay.value,
                  'time': updatedData['time'] ?? loc['time'],
                  'title': updatedData['name'] ?? loc['title'],
                  'address': updatedData['address'] ?? loc['address'],
                  'latitude': updatedData['latitude'] ?? loc['latitude'],
                  'longitude': updatedData['longitude'] ?? loc['longitude'],
                  'type': 'private',
                  'description': 'Địa điểm riêng tư',
                  'addedAt': loc['addedAt'],
                  'updatedAt': DateTime.now().toIso8601String(),
                };
                updated = true;
                break;
              }
            }
          }

          if (updated) {
            // Save back to database
            await _tripService.updateTrip(trip.value!.id, {
              'privateLocations': existingLocations,
              'updatedAt': DateTime.now(),
            });

            // Reload data to refresh UI
            await loadDayNotesAndLocations(trip.value!.id);

            LoggerService.i('Private location updated successfully');
            AppSnackbar.showSuccess(title: 'Thành công', message: 'Đã cập nhật địa điểm');
          }
        }
      } catch (e) {
        LoggerService.e('Failed to update private location', error: e);
        AppSnackbar.showError(title: 'Lỗi', message: 'Không thể cập nhật địa điểm');
      }
    }
  }

  // Add private location
  void addPrivateLocation(Map<String, dynamic> locationData) async {
    // Add the location to current day's locations
    if (selectedDay.value < tripDays.length) {
      final currentDayData = tripDays[selectedDay.value];
      final locations = List<Map<String, dynamic>>.from(currentDayData['locations'] ?? []);

      // Add new location with time
      final newLocation = {
        'dayIndex': selectedDay.value, // Track which day this location belongs to
        'time':
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'title': locationData['name'],
        'address': locationData['address'],
        'description': 'Địa điểm riêng tư',
        'image': null,
        'latitude': locationData['latitude'],
        'longitude': locationData['longitude'],
        'type': 'private',
        'addedAt': DateTime.now(),
      };

      locations.add(newLocation);

      // Update UI immediately
      tripDays[selectedDay.value]['locations'] = locations;
      tripDays.refresh();

      // Save to database in background
      if (trip.value != null) {
        try {
          // ✅ LOAD existing private locations from Firestore
          final doc = await FirebaseFirestore.instance.collection('trips').doc(trip.value!.id).get();
          final data = doc.data();

          // Get existing private locations
          final existingLocations = (data?['privateLocations'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ?? [];

          // ✅ APPEND new location to existing list
          existingLocations.add(newLocation);

          // Save updated list back to database
          await _tripService.updateTrip(trip.value!.id, {
            'privateLocations': existingLocations,
            'updatedAt': DateTime.now(),
          });

          LoggerService.i('Private location saved to database (${existingLocations.length} total)');

          // Show success snackbar
          AppSnackbar.showSuccess(title: 'Thành công', message: 'Đã thêm địa điểm riêng tư');
        } catch (e) {
          LoggerService.e('Failed to save private location', error: e);
          AppSnackbar.showError(title: 'Lỗi', message: 'Không thể thêm địa điểm');
        }
      }
    }
  }
}
