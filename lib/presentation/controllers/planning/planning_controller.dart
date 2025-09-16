import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/presentation/pages/planning/planning_page.dart';
import 'package:wanderlust/app/routes/app_pages.dart';

class PlanningController extends GetxController {
  // Search controller
  final TextEditingController searchController = TextEditingController();
  
  // Observable list of trips
  final RxList<TripModel> trips = <TripModel>[].obs;
  final RxList<TripModel> filteredTrips = <TripModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadFakeTrips();
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  void _loadFakeTrips() {
    // Fake data matching the design
    trips.value = [
      TripModel(
        id: '1',
        name: 'Đà nẵng chào nành',
        imageUrl: 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800',
        dateRange: 'CN, 9/1 - T3, 11/1',
        description: '1 địa điểm dã lưu',
        status: TripStatus.ongoing,
        statusText: 'Đang diễn ra',
      ),
      TripModel(
        id: '2',
        name: 'Đà Nạt giông bão',
        imageUrl: 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800',
        dateRange: 'CN, 12/1 - T3, 14/1',
        description: '1 địa điểm dã lưu',
        status: TripStatus.planned,
        statusText: 'Cần 5 ngày',
      ),
      TripModel(
        id: '3',
        name: 'Hải Phòng hoa cải và tôi',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        dateRange: 'CN, 12/12 - T3, 14/12',
        description: '1 địa điểm dã lưu',
        status: TripStatus.upcoming,
        statusText: 'Sắp tới',
      ),
      TripModel(
        id: '4',
        name: 'Nha Trang',
        imageUrl: 'https://images.unsplash.com/photo-1559628233-100c798642d4?w=800',
        dateRange: 'CN, 12/12 - T3, 14/12',
        description: '1 địa điểm dã lưu',
        status: TripStatus.upcoming,
        statusText: 'Sắp tới',
      ),
    ];
    
    // Initialize filtered trips
    filteredTrips.value = trips;
  }
  
  void onSearchChanged(String query) {
    if (query.isEmpty) {
      filteredTrips.value = trips;
    } else {
      filteredTrips.value = trips.where((trip) {
        return trip.name.toLowerCase().contains(query.toLowerCase()) ||
               trip.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }
  
  void createNewTrip() async {
    // Navigate to create trip page
    final result = await Get.toNamed(Routes.TRIP_EDIT);
    
    if (result != null) {
      // Refresh trips list after creating new trip
      _loadFakeTrips();
    }
  }
  
  void showTripOptions(TripModel trip) {
    // TODO: Show bottom sheet with options
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa'),
              onTap: () async {
                Get.back();
                // Navigate to edit trip page
                final result = await Get.toNamed(
                  Routes.TRIP_EDIT,
                  arguments: {'tripId': trip.id},
                );
                
                if (result != null) {
                  // Refresh trips list after editing
                  _loadFakeTrips();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Chia sẻ'),
              onTap: () {
                Get.back();
                // TODO: Share trip
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                // TODO: Delete trip
              },
            ),
          ],
        ),
      ),
    );
  }
}