import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/data/services/accommodation_service.dart';
import 'package:wanderlust/data/models/accommodation_model.dart';
import 'package:wanderlust/data/services/blog_service.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class DiscoverController extends GetxController {
  // Services
  final AccommodationService _accommodationService = Get.put(AccommodationService());
  final BlogService _blogService = Get.put(BlogService());
  
  // Search controller
  final TextEditingController searchController = TextEditingController();
  
  // Page controller for banner carousel
  final PageController pageController = PageController();
  
  // Current page index for carousel
  final RxInt currentPage = 0.obs;
  
  // Observable lists
  final RxList<AccommodationModel> featuredAccommodations = <AccommodationModel>[].obs;
  final RxList<BlogPostModel> latestBlogs = <BlogPostModel>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadFeaturedAccommodations();
    _loadLatestBlogs();
    _checkAndAddDemoData();
  }
  
  void _loadFeaturedAccommodations() {
    try {
      isLoading.value = true;
      
      // Listen to real-time updates for featured accommodations
      _accommodationService.getFeaturedAccommodations(limit: 10).listen((accommodations) {
        featuredAccommodations.value = accommodations;
        isLoading.value = false;
      }, onError: (error) {
        LoggerService.e('Error loading featured accommodations', error: error);
        isLoading.value = false;
      });
      
    } catch (e) {
      LoggerService.e('Error in _loadFeaturedAccommodations', error: e);
      isLoading.value = false;
    }
  }
  
  void _loadLatestBlogs() {
    try {
      // Listen to real-time updates for latest blogs
      _blogService.getPublishedPosts(limit: 5).listen((blogs) {
        latestBlogs.value = blogs;
      }, onError: (error) {
        LoggerService.e('Error loading latest blogs', error: error);
      });
      
    } catch (e) {
      LoggerService.e('Error in _loadLatestBlogs', error: e);
    }
  }
  
  Future<void> _checkAndAddDemoData() async {
    try {
      // Check if there are any accommodations
      final accSnapshot = await _accommodationService.getFeaturedAccommodations(limit: 1).first;
      if (accSnapshot.isEmpty) {
        await _accommodationService.addDemoAccommodations();
      }
      
      // Check if there are any blogs
      final blogSnapshot = await _blogService.getPublishedPosts(limit: 1).first;
      if (blogSnapshot.isEmpty) {
        await _blogService.addDemoPosts();
      }
    } catch (e) {
      LoggerService.e('Error checking demo data', error: e);
    }
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