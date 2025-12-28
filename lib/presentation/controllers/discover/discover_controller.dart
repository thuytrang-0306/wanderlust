import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/services/saved_blogs_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/destination_model.dart';
import 'package:wanderlust/data/models/tour_model.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:wanderlust/data/services/destination_service.dart';
import 'package:wanderlust/data/services/tour_service.dart';
import 'package:wanderlust/data/services/trip_service.dart';
import 'package:wanderlust/data/services/blog_service.dart';
import 'package:wanderlust/data/services/listing_service.dart';
import 'package:wanderlust/presentation/controllers/main_navigation_controller.dart';

class DiscoverController extends BaseController {
  // Services
  final DestinationService _destinationService = Get.find<DestinationService>();
  final TourService _tourService = Get.find<TourService>();
  final TripService _tripService = Get.find<TripService>();
  final BlogService _blogService = Get.find<BlogService>();
  final ListingService _listingService = Get.find<ListingService>();

  // Lazy load SavedBlogsService
  SavedBlogsService get _savedBlogsService {
    if (!Get.isRegistered<SavedBlogsService>()) {
      Get.put(SavedBlogsService());
    }
    return Get.find<SavedBlogsService>();
  }

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

  // User interaction tracking
  final RxSet<String> bookmarkedPostIds = <String>{}.obs;

  // Banner images will be loaded from service
  final List<String> bannerImages = [];

  // Regions will be loaded from service
  final List<Map<String, dynamic>> regions = [];

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut(() => DiscoverController());
    _trackSavedBlogs();
    loadAllData();
  }

  void _trackSavedBlogs() {
    // Track saved blogs from SavedBlogsService
    ever(_savedBlogsService.savedBlogsCache, (_) {
      _updateBookmarkStatusFromSavedBlogs();
    });

    // Initial update
    _updateBookmarkStatusFromSavedBlogs();
  }

  void _updateBookmarkStatusFromSavedBlogs() {
    final savedBlogIds = _savedBlogsService.savedBlogsCache.keys.toSet();
    bookmarkedPostIds.assignAll(savedBlogIds);
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
    // Navigate to Planning tab (index 2)
    try {
      final mainNavController = Get.find<MainNavigationController>();
      mainNavController.changeTab(2);
    } catch (e) {
      // Fallback to route navigation if controller not found
      onPlanTrip();
    }
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

  // Toggle bookmark for blog post
  Future<void> toggleBookmark(String postId) async {
    // Get blog post
    BlogPostModel? blogPost = recentBlogs.firstWhereOrNull((b) => b.id == postId);
    if (blogPost == null) {
      blogPost = await _blogService.getPost(postId);
      if (blogPost == null) {
        AppSnackbar.showError(message: 'Không thể tải bài viết');
        return;
      }
    }

    // Check if already saved
    final isSaved = _savedBlogsService.isBlogSaved(postId);

    if (isSaved) {
      // If saved, remove from all collections
      await _savedBlogsService.removeBlogFromCollection(postId, 'all');
      AppSnackbar.showInfo(message: 'Đã bỏ lưu bài viết');
    } else {
      // Show collection selector (like Community tab)
      _showCollectionSelector(blogPost);
    }
  }

  void _showCollectionSelector(BlogPostModel blog) {
    final collections = _savedBlogsService.collections;

    // If no collections exist (except default), auto-save to default
    if (collections.length <= 1) {
      _saveBlogToDefault(blog);
      return;
    }

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: AppSpacing.s3),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(AppSpacing.s5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lưu vào bộ sưu tập',
                    style: AppTypography.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 20.sp),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: AppColors.neutral200),

            // Collections list
            Flexible(
              child: Obx(() => ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s3),
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  final isSelected = _savedBlogsService.isBlogInCollection(blog.id, collection.id);

                  return Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () async {
                        await _savedBlogsService.saveBlogToCollection(blog, collection.id);
                        Get.back();

                        AppSnackbar.showSuccess(
                          message: 'Đã lưu vào "${collection.name}"',
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.s5,
                          vertical: AppSpacing.s4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              color: AppColors.primary,
                              size: 24.sp,
                            ),
                            SizedBox(width: AppSpacing.s4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    collection.name,
                                    style: AppTypography.bodyM.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (collection.blogIds.isNotEmpty)
                                    Text(
                                      '${collection.blogIds.length} bài viết',
                                      style: AppTypography.bodyS.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: AppColors.primary, size: 20.sp),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )),
            ),

            // Create new collection button
            Container(
              padding: EdgeInsets.all(AppSpacing.s5),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.neutral200)),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Future.delayed(Duration(milliseconds: 300), () {
                        _showCreateCollectionDialog(blog);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: AppSpacing.s2),
                        Text(
                          'Tạo bộ sưu tập mới',
                          style: AppTypography.bodyM.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isDismissible: true,
    );
  }

  void _saveBlogToDefault(BlogPostModel blog) async {
    await _savedBlogsService.saveBlogToCollection(blog, 'all');
    AppSnackbar.showSuccess(message: 'Đã lưu vào "Tất cả bài viết"');
  }

  void _showCreateCollectionDialog(BlogPostModel blog) {
    final TextEditingController nameController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tạo bộ sưu tập mới',
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.s4),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tên bộ sưu tập',
                  filled: true,
                  fillColor: AppColors.neutral50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Hủy'),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  SizedBox(
                    width: 80.w,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isNotEmpty) {
                          final newCollection = await _savedBlogsService.createCollection(name);
                          await _savedBlogsService.saveBlogToCollection(blog, newCollection.id);
                          Get.back();

                          AppSnackbar.showSuccess(
                            message: 'Đã tạo và lưu vào "$name"',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text('Tạo', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
