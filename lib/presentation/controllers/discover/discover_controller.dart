import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/data/models/destination_model.dart';
import 'package:wanderlust/data/models/tour_model.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:wanderlust/data/services/destination_service.dart';
import 'package:wanderlust/data/services/tour_service.dart';
import 'package:wanderlust/data/services/trip_service.dart';
import 'package:wanderlust/data/services/blog_service.dart';
import 'package:wanderlust/data/services/listing_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DiscoverController extends BaseController {
  // Services
  final DestinationService _destinationService = Get.find<DestinationService>();
  final TourService _tourService = Get.find<TourService>();
  final TripService _tripService = Get.find<TripService>();
  final BlogService _blogService = Get.find<BlogService>();
  final ListingService _listingService = Get.find<ListingService>();

  // Data
  final RxList<DestinationModel> featuredDestinations = <DestinationModel>[].obs;
  final RxList<DestinationModel> popularDestinations = <DestinationModel>[].obs;
  final RxList<TourModel> featuredTours = <TourModel>[].obs;
  final RxList<TourModel> discountedTours = <TourModel>[].obs;
  final RxList<TourModel> comboTours = <TourModel>[].obs; // Combo tours
  final RxList<BlogPostModel> recentBlogs = <BlogPostModel>[].obs;
  final RxList<Map<String, dynamic>> exploreRegions = <Map<String, dynamic>>[].obs; // Regions
  final RxList<ListingModel> businessListings = <ListingModel>[].obs; // Business listings

  // UI State
  final RxInt currentBannerIndex = 0.obs;
  final PageController bannerPageController = PageController();
  final RxBool isLoadingDestinations = true.obs;
  final RxBool isLoadingTours = true.obs;
  final RxBool isLoadingBlogs = true.obs;
  final RxBool isLoadingCombos = true.obs;
  final RxBool isLoadingBusinessListings = true.obs;

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
      loadComboTours(),
      loadRegions(),
      loadBusinessListings(),
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

      // Try to load real tours from TourService first
      final featured = await _tourService.getFeaturedTours(limit: 5);
      featuredTours.value = featured;

      final discounted = await _tourService.getDiscountedTours(limit: 10);
      discountedTours.value = discounted;

      // For now, tours are empty - users should use Trips in Planning tab
      if (featured.isEmpty && discounted.isEmpty) {
        LoggerService.i('No tours found - use Trips feature in Planning tab');
      }
    } catch (e) {
      LoggerService.e('Error loading tours', error: e);
      featuredTours.value = [];
      discountedTours.value = [];
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
    Get.toNamed('/blog-detail', arguments: {
      'postId': blog.id,
      'blogPost': blog, // Pass the full object to avoid re-fetching
      'heroTag': 'discover-blog-image-${blog.id}', // Pass hero tag for animation
    });
  }

  Future<void> loadComboTours() async {
    try {
      isLoadingCombos.value = true;

      // Load combo tours from TourService
      final combos = await _tourService.getComboTours(limit: 5);
      comboTours.value = combos;

      // For now, combo tours are empty - this is a future feature
      if (combos.isEmpty) {
        LoggerService.i('No combo tours available yet');
      }
    } catch (e) {
      LoggerService.e('Error loading combo tours', error: e);
      comboTours.value = [];
    } finally {
      isLoadingCombos.value = false;
    }
  }

  Future<void> loadRegions() async {
    try {
      // Load regions data from Firestore in future
      // For now, empty until real data is available
      exploreRegions.value = [];

      // TODO: Implement RegionService to load from Firestore
      // Example structure for future implementation:
      // final regionService = Get.find<RegionService>();
      // final regions = await regionService.getRegions();
      // exploreRegions.value = regions;

      LoggerService.i('Regions feature pending real data implementation');
    } catch (e) {
      LoggerService.e('Error loading regions', error: e);
      exploreRegions.value = [];
    }
  }

  void onComboTourTapped(TourModel combo) {
    Get.toNamed('/combo-detail', arguments: {'tour': combo});
  }

  void onSeeAllCombos() {
    Get.toNamed('/all-combos');
  }

  void onRegionTapped(Map<String, dynamic> region) {
    Get.toNamed('/region', arguments: {'region': region});
  }

  Future<void> loadBusinessListings() async {
    try {
      isLoadingBusinessListings.value = true;

      // Load all active business listings
      final listings = await _listingService.searchListings();

      // Filter active listings and sort by rating/popularity
      final activeListings = listings
          .where((l) => l.isActive)
          .toList()
        ..sort((a, b) {
          // Sort by rating first, then by reviews count
          final ratingCompare = b.rating.compareTo(a.rating);
          if (ratingCompare != 0) return ratingCompare;
          return b.reviews.compareTo(a.reviews);
        });

      // Take top 10 listings
      businessListings.value = activeListings.take(10).toList();

      LoggerService.i('Loaded ${businessListings.length} business listings');
    } catch (e) {
      LoggerService.e('Error loading business listings', error: e);
      businessListings.value = [];
    } finally {
      isLoadingBusinessListings.value = false;
    }
  }

  void onSeeAllRegions() {
    Get.toNamed('/all-regions');
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
