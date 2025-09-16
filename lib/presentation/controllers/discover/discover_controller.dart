import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/app/routes/app_pages.dart';

class DiscoverController extends GetxController {
  // Search controller
  final TextEditingController searchController = TextEditingController();
  
  // Page controller for banner carousel
  final PageController pageController = PageController();
  
  // Current page index for carousel
  final RxInt currentPage = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize any data here
  }
  
  @override
  void onClose() {
    searchController.dispose();
    pageController.dispose();
    super.onClose();
  }
  
  // Handle page change in carousel
  void onPageChanged(int index) {
    currentPage.value = index;
  }
  
  // Navigate to create trip
  void createTrip() {
    Get.toNamed(Routes.TRIP_EDIT);
  }
  
  // Handle destination tap
  void onDestinationTap(String destination) {
    // Navigate to destination detail
    Get.snackbar(
      'Destination',
      'Opening $destination',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  
  // Handle region tap
  void onRegionTap(String region) {
    // Navigate to region explore page
    Get.snackbar(
      'Region',
      'Exploring $region',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  
  // Handle blog tap
  void onBlogTap(String blogTitle) {
    // Navigate to blog detail
    Get.snackbar(
      'Blog',
      'Opening blog: $blogTitle',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  
  // Toggle bookmark
  void toggleBookmark(String itemId) {
    // Toggle bookmark state
    Get.snackbar(
      'Bookmark',
      'Item bookmarked',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}