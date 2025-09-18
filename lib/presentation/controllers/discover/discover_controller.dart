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
  
  // Banner images
  final List<String> bannerImages = [
    'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
    'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800',
    'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800',
  ];

  // Regions
  final List<Map<String, dynamic>> regions = [
    {
      'name': 'Miền Bắc',
      'image': 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400',
      'count': 28,
    },
    {
      'name': 'Miền Trung',
      'image': 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400',
      'count': 24,
    },
    {
      'name': 'Miền Nam',
      'image': 'https://images.unsplash.com/photo-1583417267826-64235a0a6c0a?w=400',
      'count': 18,
    },
  ];

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
      
      // If no data, create sample data
      if (featured.isEmpty && popular.isEmpty) {
        LoggerService.i('No destinations found, creating sample data');
        await _destinationService.createSampleDestinations();
        
        // Reload after creating sample data
        featuredDestinations.value = await _destinationService.getFeaturedDestinations(limit: 5);
        popularDestinations.value = await _destinationService.getPopularDestinations(limit: 10);
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
      
      // If no data, create sample data
      if (featured.isEmpty && discounted.isEmpty) {
        LoggerService.i('No tours found, creating sample data');
        await _tourService.createSampleTours();
        
        // Reload after creating sample data
        featuredTours.value = await _tourService.getFeaturedTours(limit: 5);
        discountedTours.value = await _tourService.getDiscountedTours(limit: 10);
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
    // Fallback data when Firestore fails
    featuredDestinations.value = [
      DestinationModel(
        id: '1',
        name: 'Hạ Long Bay',
        description: 'Vịnh Hạ Long tuyệt đẹp',
        region: 'Miền Bắc',
        images: ['https://images.unsplash.com/photo-1528127269322-539801943592?w=800'],
        rating: 4.8,
        reviewCount: 1234,
        basePrice: 1500000,
        highlights: [],
        bestTimeToVisit: [],
        activities: [],
        tags: ['biển', 'di sản'],
        featured: true,
        popular: true,
      ),
      DestinationModel(
        id: '2',
        name: 'Sapa',
        description: 'Thị trấn mù sương',
        region: 'Miền Bắc',
        images: ['https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800'],
        rating: 4.7,
        reviewCount: 987,
        basePrice: 800000,
        highlights: [],
        bestTimeToVisit: [],
        activities: [],
        tags: ['núi', 'trekking'],
        featured: true,
        popular: true,
      ),
    ];
    
    popularDestinations.value = featuredDestinations;
  }

  void _useFallbackTourData() {
    // Fallback data when Firestore fails
    featuredTours.value = [
      TourModel(
        id: '1',
        title: 'Tour Hạ Long 2N1Đ',
        description: 'Du thuyền 5 sao',
        destinationId: '1',
        destinationName: 'Hạ Long Bay',
        duration: '2N1Đ',
        price: 3500000,
        discountPrice: 2900000,
        images: ['https://images.unsplash.com/photo-1528127269322-539801943592?w=800'],
        itinerary: [],
        inclusions: [],
        exclusions: [],
        maxGroupSize: 20,
        availableDates: [],
        rating: 4.8,
        reviewCount: 156,
        hostId: '1',
        hostName: 'Wanderlust Travel',
        tags: ['luxury', 'cruise'],
        featured: true,
      ),
    ];
    
    discountedTours.value = featuredTours;
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