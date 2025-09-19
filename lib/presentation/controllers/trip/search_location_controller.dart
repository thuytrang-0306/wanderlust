import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';

class SearchLocationController extends BaseController {
  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Observable values
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> savedLocations = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> suggestions = <Map<String, dynamic>>[].obs;
  final RxBool isSearching = false.obs;

  // Popular tags
  final List<String> popularTags = [
    'Homestay',
    'TaXua',
    'Haiphong',
    'TP.HoChiMinh',
    'Khachsan',
    'Quan cam',
    'QuangNinh',
  ];

  @override
  void onInit() {
    super.onInit();
    loadSavedLocations();
    loadSuggestions();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void loadSavedLocations() async {
    // TODO: Load saved locations from local storage or Firestore
    savedLocations.value = [];
  }

  void loadSuggestions() async {
    // TODO: Load suggestions from Firestore based on user preferences
    suggestions.value = [];
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    if (value.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    // Simulate search - in real app, call API
    performSearch(value);
  }

  void performSearch(String query) {
    // Filter from all locations
    final allLocations = [...savedLocations, ...suggestions];
    searchResults.value =
        allLocations.where((location) {
          final title = location['title'].toString().toLowerCase();
          final loc = location['location'].toString().toLowerCase();
          final q = query.toLowerCase();
          return title.contains(q) || loc.contains(q);
        }).toList();
  }

  void selectTag(String tag) {
    searchController.text = tag;
    onSearchChanged(tag);
  }

  void selectLocation(Map<String, dynamic> location) {
    // Return selected location to previous page
    Get.back(result: location);
  }
}
