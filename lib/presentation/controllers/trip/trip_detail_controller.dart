import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wanderlust/core/base/base_controller.dart';

class TripDetailController extends BaseController {
  // Trip basic info
  final RxString tripName = 'Trip Nha Trang của tôi'.obs;
  final RxString tripDateRange = 'T5, 12/1 - CN, 15/1'.obs;
  final RxString tripImage = ''.obs;
  final RxInt peopleCount = 2.obs;
  final RxInt totalDays = 4.obs;
  
  // Selected day
  final RxInt selectedDay = 0.obs;
  
  // Trip data - mock data for now
  final RxList<Map<String, dynamic>> tripDays = <Map<String, dynamic>>[
    {
      'day': 1,
      'date': DateTime(2024, 1, 12),
      'startTime': '8am',
      'locations': [
        // Empty for day 1 - will show empty state
      ],
    },
    {
      'day': 2,
      'date': DateTime(2024, 1, 13),
      'startTime': '8:00',
      'locations': [
        {
          'time': '08:00',
          'title': 'Nhà của hth',
          'address': 'Nhà XY, Khu ZZ',
          'description': 'Đi đến đây nhớ mua cam gà đồi quà',
          'image': 'https://i.pravatar.cc/150?img=1',
        },
        {
          'time': '09:00',
          'title': 'Khách sạn Nha Trang',
          'address': 'Nha Trang, Khánh Hòa',
          'description': 'Ghi chú cá nhân',
          'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200',
        },
        {
          'time': '11:00',
          'title': 'Tháp Bà Ponagar',
          'address': 'Vĩnh Phước, Nha Trang',
          'description': 'Ngắm mình thủ giới tại Suối khoáng nóng Tháp Bà',
          'image': 'https://images.unsplash.com/photo-1557750255-c76072a7aad1?w=200',
        },
      ],
    },
    {
      'day': 3,
      'date': DateTime(2024, 1, 14),
      'startTime': '7:30',
      'locations': [],
    },
    {
      'day': 4,
      'date': DateTime(2024, 1, 15),
      'startTime': '9:00',
      'locations': [],
    },
  ].obs;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize date formatting for Vietnamese locale
    initializeDateFormatting('vi_VN', null);
    
    // Get trip data from arguments if passed
    if (Get.arguments != null) {
      if (Get.arguments['tripName'] != null) {
        tripName.value = Get.arguments['tripName'];
      }
      if (Get.arguments['tripImage'] != null) {
        tripImage.value = Get.arguments['tripImage'];
      }
      if (Get.arguments['dateRange'] != null) {
        tripDateRange.value = Get.arguments['dateRange'];
      }
      if (Get.arguments['peopleCount'] != null) {
        peopleCount.value = Get.arguments['peopleCount'];
      }
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