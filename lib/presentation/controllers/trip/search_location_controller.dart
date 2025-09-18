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

  void loadSavedLocations() {
    // Mock data for saved locations
    savedLocations.value = [
      {
        'id': '1',
        'title': 'Vĩnh Hạ Long',
        'location': 'Quảng Ninh',
        'price': 550000,
        'rating': 4.9,
        'duration': '4N/5D',
        'image': 'https://images.unsplash.com/photo-1528127269322-539801943592?w=400',
      },
      {
        'id': '2',
        'title': 'Biển Nha Trang',
        'location': 'Nha Trang',
        'price': 400000,
        'rating': 4.9,
        'duration': '4N/5D',
        'image': 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400',
      },
      {
        'id': '3',
        'title': 'Đà Lạt',
        'location': 'Lâm Đồng',
        'price': 350000,
        'rating': 4.8,
        'duration': '3N/4D',
        'image': 'https://images.unsplash.com/photo-1557750255-c76072a7aad1?w=400',
      },
    ];
  }

  void loadSuggestions() {
    // Mock data for suggestions
    suggestions.value = [
      {
        'id': '4',
        'title': 'Vĩnh Hạ Long',
        'location': 'Quảng Ninh',
        'price': 550000,
        'rating': 4.9,
        'duration': '4N/5D',
        'image': 'https://images.unsplash.com/photo-1528127269322-539801943592?w=400',
      },
      {
        'id': '5',
        'title': 'Biển Nha Trang',
        'location': 'Nha Trang',
        'price': 400000,
        'rating': 4.9,
        'duration': '4N/5D',
        'image': 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400',
      },
      {
        'id': '6',
        'title': 'Phú Quốc',
        'location': 'Kiên Giang',
        'price': 600000,
        'rating': 4.8,
        'duration': '5N/6D',
        'image': 'https://images.unsplash.com/photo-1569154941061-e231b4725ef1?w=400',
      },
      {
        'id': '7',
        'title': 'Sapa',
        'location': 'Lào Cai',
        'price': 450000,
        'rating': 4.7,
        'duration': '3N/4D',
        'image': 'https://images.unsplash.com/photo-1586850859138-18d3c229b5db?w=400',
      },
      {
        'id': '8',
        'title': 'Hội An',
        'location': 'Quảng Nam',
        'price': 380000,
        'rating': 4.8,
        'duration': '3N/4D',
        'image': 'https://images.unsplash.com/photo-1599820812214-cf4d7e10e5b8?w=400',
      },
      {
        'id': '9',
        'title': 'Mũi Né',
        'location': 'Phan Thiết',
        'price': 320000,
        'rating': 4.6,
        'duration': '2N/3D',
        'image': 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=400',
      },
    ];
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
