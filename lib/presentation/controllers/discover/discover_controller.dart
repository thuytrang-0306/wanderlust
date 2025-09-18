import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/data/models/destination_model.dart';
import 'package:wanderlust/data/models/tour_model.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';
import 'package:wanderlust/data/services/destination_service.dart';
import 'package:wanderlust/data/services/tour_service.dart';
import 'package:wanderlust/data/services/blog_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DiscoverController extends BaseController {
  // Services
  final DestinationService _destinationService = Get.find<DestinationService>();
  final TourService _tourService = Get.find<TourService>();
  final BlogService _blogService = Get.find<BlogService>();
  
  // Data
  final RxList<DestinationModel> featuredDestinations = <DestinationModel>[].obs;
  final RxList<DestinationModel> popularDestinations = <DestinationModel>[].obs;
  final RxList<TourModel> featuredTours = <TourModel>[].obs;
  final RxList<TourModel> discountedTours = <TourModel>[].obs;
  final RxList<BlogPostModel> recentBlogs = <BlogPostModel>[].obs;
  
  // UI State
  final RxInt currentBannerIndex = 0.obs;
  final PageController bannerPageController = PageController();
  final RxBool isLoadingDestinations = true.obs;
  final RxBool isLoadingTours = true.obs;
  final RxBool isLoadingBlogs = true.obs;
  
  // User info
  final Rx<User?> currentUser = FirebaseAuth.instance.currentUser.obs;
  
  // Search
  final RxString searchQuery = ''.obs;
  
  // Banner images will be loaded from service
  final List<String> bannerImages = [];

  // Regions will be loaded from service
  final List<Map<String, dynamic>> regions = [];

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut(() => DiscoverController());
    loadAllData();
  }

  @override
  void loadData() {
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadDestinations(),
      loadTours(),
      loadBlogs(),
    ]);
  }

  Future<void> loadDestinations() async {
    try {
      isLoadingDestinations.value = true;
      
      // Load featured destinations
      final featured = await _destinationService.getFeaturedDestinations(limit: 5);
      featuredDestinations.value = featured;
      
      // Load popular destinations  
      final popular = await _destinationService.getPopularDestinations(limit: 10);
      popularDestinations.value = popular;
      
      // No longer auto-creating sample data
      if (featured.isEmpty && popular.isEmpty) {
        LoggerService.i('No destinations found in database');
        // Sample data creation disabled - data should come from real user content
      }
      
    } catch (e) {
      LoggerService.e('Error loading destinations', error: e);
      // Use fallback data
      _useFallbackDestinationData();
    } finally {
      isLoadingDestinations.value = false;
    }
  }

  Future<void> loadTours() async {
    try {
      isLoadingTours.value = true;
      
      // Load featured tours
      final featured = await _tourService.getFeaturedTours(limit: 5);
      featuredTours.value = featured;
      
      // Load discounted tours
      final discounted = await _tourService.getDiscountedTours(limit: 10);
      discountedTours.value = discounted;
      
      // No longer auto-creating sample data
      if (featured.isEmpty && discounted.isEmpty) {
        LoggerService.i('No tours found in database');
        // Sample data creation disabled - data should come from real user content
      }
      
    } catch (e) {
      LoggerService.e('Error loading tours', error: e);
      // Use fallback data
      _useFallbackTourData();
    } finally {
      isLoadingTours.value = false;
    }
  }

  Future<void> loadBlogs() async {
    try {
      isLoadingBlogs.value = true;
      
      final blogs = await _blogService.getRecentPosts(limit: 5);
      recentBlogs.value = blogs;
      
    } catch (e) {
      LoggerService.e('Error loading blogs', error: e);
    } finally {
      isLoadingBlogs.value = false;
    }
  }

  void _useFallbackDestinationData() {
    // No fallback data for production
    featuredDestinations.value = [];
    popularDestinations.value = [];
  }

  void _useFallbackTourData() {
    // No fallback data for production
    featuredTours.value = [];
    discountedTours.value = [];
  }

  void onBannerChanged(int index) {
    currentBannerIndex.value = index;
  }
  
  // Compatibility methods for DiscoverPage
  void onPageChanged(int index) {
    onBannerChanged(index);
  }
  
  PageController get pageController => bannerPageController;
  
  RxInt get currentPage => currentBannerIndex;
  
  void createTrip() {
    onPlanTrip();
  }

  void onSearchSubmitted(String query) {
    searchQuery.value = query;
    if (query.isNotEmpty) {
      Get.toNamed('/search', arguments: {'query': query});
    }
  }

  void onDestinationTapped(DestinationModel destination) {
    Get.toNamed('/destination-detail', arguments: {'destination': destination});
  }

  void onTourTapped(TourModel tour) {
    Get.toNamed('/tour-detail', arguments: {'tour': tour});
  }

  void onRegionTapped(String region) {
    Get.toNamed('/region', arguments: {'region': region});
  }

  void onSeeAllDestinations() {
    Get.toNamed('/all-destinations');
  }

  void onSeeAllTours() {
    Get.toNamed('/all-tours');
  }

  void onPlanTrip() {
    Get.toNamed('/trip-planning');
  }

  void onBlogTapped(BlogPostModel blog) {
    Get.toNamed('/blog-detail', arguments: {'postId': blog.id});
  }

  @override
  void onClose() {
    bannerPageController.dispose();
    super.onClose();
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng';
    } else if (hour < 18) {
      return 'Chào buổi chiều';
    } else {
      return 'Chào buổi tối';
    }
  }

  String get userName {
    return currentUser.value?.displayName ?? 'Khách';
  }
}