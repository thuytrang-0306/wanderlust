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
      if (Get.arguments['trip'] != null) {
        // Load full trip model
        final TripModel passedTrip = Get.arguments['trip'] as TripModel;
        loadTrip(passedTrip); // Fire and forget - loading state will be managed
      } else if (Get.arguments['tripId'] != null) {
        // Load trip by ID
        loadTripById(Get.arguments['tripId'] as String); // Fire and forget
      }
    }
  }

  // Load trip from passed model
  Future<void> loadTrip(TripModel tripModel) async {
    isInitialLoading.value = true;

    trip.value = tripModel;

    // Update UI bindings
    tripName.value = tripModel.title;
    tripImage.value = tripModel.coverImage;
    peopleCount.value = tripModel.travelers.length;
    totalDays.value = tripModel.duration;

    // Format date range
    final DateFormat formatter = DateFormat('E, dd/MM', 'vi_VN');
    final startStr = formatter.format(tripModel.startDate);
    final endStr = formatter.format(tripModel.endDate);
    tripDateRange.value = '$startStr - $endStr';

    // Generate trip days structure and wait for data to load
    await generateTripDays(tripModel);

    // Load itineraries
    await loadItineraries(tripModel.id);

    // All data loaded
    isInitialLoading.value = false;
  }

  // Load trip by ID from backend
  Future<void> loadTripById(String tripId) async {
    try {
      isInitialLoading.value = true;
      final trips = await _tripService.getUserTrips();
      final tripModel = trips.firstWhereOrNull((t) => t.id == tripId);
      if (tripModel != null) {
        await loadTrip(tripModel);
      } else {
        isInitialLoading.value = false;
        Get.back();
        Get.snackbar('Lỗi', 'Không tìm thấy chuyến đi');
      }
    } catch (e) {
      LoggerService.e('Error loading trip', error: e);
      isInitialLoading.value = false;
      Get.back();
      Get.snackbar('Lỗi', 'Không thể tải thông tin chuyến đi');
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

      // Map itineraries to trip days
      for (var itinerary in itineraries) {
        if (itinerary.dayNumber > 0 && itinerary.dayNumber <= tripDays.length) {
          tripDays[itinerary.dayNumber - 1]['locations'] =
              itinerary.activities
                  .map(
                    (activity) => {
                      'time': activity.time,
                      'title': activity.title,
                      'address': activity.location,
                      'description': activity.notes,
                      'image': '', // No image in current model
                    },
                  )
                  .toList();
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
          await loadTripById(tripId);
          LoggerService.i('Trip updated, reloaded trip detail');
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

  // Add location from search
  void addLocationFromSearch(Map<String, dynamic> locationData) {
    // Add the location to current day's locations
    if (selectedDay.value < tripDays.length) {
      final currentDayData = tripDays[selectedDay.value];
      final locations = List<Map<String, dynamic>>.from(currentDayData['locations'] ?? []);

      // Add new location with time
      locations.add({
        'time':
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'title': locationData['title'] ?? locationData['name'],
        'address': locationData['location'] ?? locationData['address'],
        'description': 'Từ tìm kiếm',
        'image': locationData['image'] ?? locationData['imageUrl'],
        'price': locationData['price'],
      });

      // Update the day's locations
      tripDays[selectedDay.value]['locations'] = locations;
      tripDays.refresh();
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

        // If it's a private location, also remove from database
        if (deletedLocation['type'] == 'private' && trip.value != null) {
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
          // Save private location to trip's custom data
          await _tripService.updateTrip(trip.value!.id, {
            'privateLocations': [...(trip.value!.notes.isNotEmpty ? [] : []), newLocation],
            'updatedAt': DateTime.now(),
          });
          LoggerService.i('Private location saved to database');

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
