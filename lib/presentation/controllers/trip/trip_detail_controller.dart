import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/data/models/trip_model.dart';
import 'package:wanderlust/data/services/trip_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

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
        loadTrip(passedTrip);
      } else if (Get.arguments['tripId'] != null) {
        // Load trip by ID
        loadTripById(Get.arguments['tripId'] as String);
      }
    }
  }
  
  // Load trip from passed model
  void loadTrip(TripModel tripModel) {
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
    
    // Generate trip days structure
    generateTripDays(tripModel);
    
    // Load itineraries
    loadItineraries(tripModel.id);
  }
  
  // Load trip by ID from backend
  Future<void> loadTripById(String tripId) async {
    try {
      setLoading();
      final trips = await _tripService.getUserTrips();
      final tripModel = trips.firstWhereOrNull((t) => t.id == tripId);
      if (tripModel != null) {
        loadTrip(tripModel);
      } else {
        Get.back();
        Get.snackbar('Lỗi', 'Không tìm thấy chuyến đi');
      }
    } catch (e) {
      LoggerService.e('Error loading trip', error: e);
      Get.back();
      Get.snackbar('Lỗi', 'Không thể tải thông tin chuyến đi');
    } finally {
      setLoading();
    }
  }
  
  // Generate trip days structure
  void generateTripDays(TripModel tripModel) {
    tripDays.clear();
    
    final startDate = tripModel.startDate;
    for (int i = 0; i < tripModel.duration; i++) {
      final dayDate = startDate.add(Duration(days: i));
      tripDays.add({
        'day': i + 1,
        'date': dayDate,
        'startTime': '8:00',
        'locations': [], // Will be populated from itineraries
      });
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
          tripDays[itinerary.dayNumber - 1]['locations'] = itinerary.activities.map((activity) => {
            'time': activity.time,
            'title': activity.title,
            'address': activity.location,
            'description': activity.notes,
            'image': '', // No image in current model
          }).toList();
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
  void editTrip() {
    // Navigate to edit page
    Get.toNamed('/trip-edit', arguments: {
      'tripName': tripName.value,
      'dateRange': tripDateRange.value,
      'peopleCount': peopleCount.value,
    });
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
  void updateDayNote(Map<String, dynamic> noteData) {
    final dayIndex = selectedDay.value;
    if (dayIndex < tripDays.length) {
      tripDays[dayIndex]['note'] = noteData['note'];
      tripDays.refresh();
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
        'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
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
  
  // Add private location  
  void addPrivateLocation(Map<String, dynamic> locationData) {
    // Add the location to current day's locations
    if (selectedDay.value < tripDays.length) {
      final currentDayData = tripDays[selectedDay.value];
      final locations = List<Map<String, dynamic>>.from(currentDayData['locations'] ?? []);
      
      // Add new location with time
      locations.add({
        'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'title': locationData['name'],
        'address': locationData['address'],
        'description': 'Địa điểm riêng tư',
        'image': null,
        'latitude': locationData['latitude'],
        'longitude': locationData['longitude'],
      });
      
      // Update the day's locations
      tripDays[selectedDay.value]['locations'] = locations;
      tripDays.refresh();
    }
  }
}