import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/services/blog_service.dart';
import 'package:wanderlust/data/services/trip_service.dart';
import 'package:wanderlust/data/services/listing_service.dart';
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:intl/intl.dart';
import 'package:wanderlust/core/services/storage_service.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchFilterController extends BaseController with GetTickerProviderStateMixin {
  // Controllers
  late TabController tabController;
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  // Observables
  final searchQuery = ''.obs;
  final selectedTab = 0.obs;
  final RxBool isSearching = false.obs;
  final searchResults = <Map<String, dynamic>>[].obs;
  final recentSearches = <String>[].obs;
  final _allFeaturedItems = <Map<String, dynamic>>[].obs; // Store all items

  // Track last search to prevent stale results
  String _lastSearchQuery = '';

  // Computed: Filter featured items based on selected tab
  List<Map<String, dynamic>> get featuredItems {
    // Tab indices: 0=Tất cả, 1=Chỗ ở, 2=Tour, 3=Địa điểm, 4=Ẩm thực
    switch (selectedTab.value) {
      case 1: // Chỗ ở
        return _allFeaturedItems.where((item) => item['category'] == 'room').toList();
      case 2: // Tour
        return _allFeaturedItems.where((item) => item['category'] == 'tour').toList();
      case 3: // Địa điểm - No listings, only blogs (will be empty for featured)
        return [];
      case 4: // Ẩm thực
        return _allFeaturedItems.where((item) => item['category'] == 'food').toList();
      default: // Tất cả
        return _allFeaturedItems;
    }
  }

  // Filters
  final selectedSort = 'default'.obs;
  final selectedLocation = ''.obs;
  final selectedDate = ''.obs;
  final priceRange = RxList<double>([0, 10000000]);
  final selectedRating = 0.0.obs;
  final selectedCategories = <String>[].obs;
  final selectedAmenities = <String>[].obs;

  final hasActiveFilters = false.obs;

  // Search suggestions for empty state
  List<String> get searchSuggestions {
    // Return suggestions based on current tab
    // Tab indices: 0=Tất cả, 1=Chỗ ở, 2=Tour, 3=Địa điểm, 4=Ẩm thực
    switch (selectedTab.value) {
      case 1: // Chỗ ở
        return ['Khách sạn Đà Lạt', 'Resort Phú Quốc', 'Homestay Sapa', 'Villa Nha Trang'];
      case 2: // Tour
        return ['Tour Hạ Long', 'Tour Phú Quốc', 'Tour Đà Nẵng', 'Tour Sapa'];
      case 3: // Địa điểm
        return ['Hội An', 'Đà Lạt', 'Phú Quốc', 'Sapa', 'Nha Trang', 'Vịnh Hạ Long'];
      case 4: // Ẩm thực
        return ['Nhà hàng hải sản', 'Quán ăn địa phương', 'Buffet', 'Ẩm thực Việt'];
      default: // Tất cả
        return ['Đà Lạt', 'Phú Quốc', 'Hạ Long', 'Hội An', 'Nha Trang', 'Sapa'];
    }
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(_handleTabSelection);
    loadRecentSearches();
    loadFeaturedItems();

    // Listen to filter changes
    ever(selectedSort, (_) => _updateActiveFilters());
    ever(selectedLocation, (_) => _updateActiveFilters());
    ever(selectedDate, (_) => _updateActiveFilters());
    ever(priceRange, (_) => _updateActiveFilters());
    ever(selectedRating, (_) => _updateActiveFilters());
    ever(selectedCategories, (_) => _updateActiveFilters());
    ever(selectedAmenities, (_) => _updateActiveFilters());

    // Handle preset filters from navigation arguments
    _handleNavigationArguments();
  }

  void loadFeaturedItems() async {
    try {
      // Load featured/trending items from ListingService
      final listingService = Get.find<ListingService>();
      final listings = await listingService.searchListings(query: '', type: null);

      // Store all listings (will be filtered by tab via getter)
      _allFeaturedItems.value = listings.map((listing) {
        return {
          'id': listing.id,
          'name': listing.title,
          'type': _getTypeDisplay(listing.type),
          'location': '${listing.details['city'] ?? ''}, ${listing.details['province'] ?? ''}',
          'rating': listing.rating,
          'reviews': listing.reviews,
          'price': listing.hasDiscount
              ? '${NumberFormat('#,###').format(listing.discountPrice)}đ'
              : '${NumberFormat('#,###').format(listing.price)}đ',
          'originalPrice': listing.hasDiscount ? '${NumberFormat('#,###').format(listing.price)}đ' : null,
          'isFavorite': false,
          'category': listing.type.value,
          'image': listing.images.isNotEmpty ? listing.images.first : '',
          'businessName': listing.businessName,
          'listingId': listing.id,
        };
      }).toList();

      LoggerService.d('Loaded ${_allFeaturedItems.length} total featured items');
    } catch (e) {
      LoggerService.e('Error loading featured items', error: e);
      // Keep empty if error
    }
  }

  void _handleNavigationArguments() {
    final args = Get.arguments;
    if (args != null && args is Map) {
      // Preset region filter
      if (args['regionFilter'] != null) {
        final region = args['regionFilter'] as String;
        selectedLocation.value = region;
        searchQuery.value = region;
        searchController.text = region;
        LoggerService.i('Search filter preset with region: $region');
      }

      // Auto search if requested
      if (args['autoSearch'] == true) {
        Future.delayed(const Duration(milliseconds: 300), () {
          performSearch();
        });
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Delay focus request to avoid conflict with Hero animation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!isClosed) {
        searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void _handleTabSelection() {
    selectedTab.value = tabController.index;
    performSearch();
  }

  void _updateActiveFilters() {
    hasActiveFilters.value =
        selectedSort.value != 'default' ||
        selectedLocation.value.isNotEmpty ||
        selectedDate.value.isNotEmpty ||
        selectedRating.value > 0 ||
        selectedCategories.isNotEmpty ||
        selectedAmenities.isNotEmpty ||
        (priceRange[0] > 0 || priceRange[1] < 10000000);
  }

  void loadRecentSearches() {
    try {
      final storageService = Get.find<StorageService>();
      recentSearches.value = storageService.searchHistory;
      LoggerService.d('Loaded ${recentSearches.length} recent searches from storage');
    } catch (e) {
      LoggerService.e('Error loading recent searches', error: e);
      recentSearches.value = [];
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (query.isNotEmpty) {
      // Debounce search
      debounce(searchQuery, (_) => performSearch(), time: const Duration(milliseconds: 500));
    } else {
      searchResults.clear();
    }
  }

  void performSearch() async {
    if (searchQuery.value.isEmpty && !hasActiveFilters.value) {
      searchResults.clear();
      return;
    }

    // Track search start time for performance monitoring
    final searchStartTime = DateTime.now();
    final currentQuery = searchQuery.value;
    _lastSearchQuery = currentQuery;

    isSearching.value = true;

    try {
      // Save to recent searches (persist to storage)
      if (currentQuery.isNotEmpty) {
        try {
          final storageService = Get.find<StorageService>();
          await storageService.addSearchHistory(currentQuery);
          // Reload from storage to sync
          recentSearches.value = storageService.searchHistory;
        } catch (e) {
          LoggerService.e('Error saving search history', error: e);
        }
      }

      // Get services
      final listingService = Get.find<ListingService>();
      final blogService = Get.find<BlogService>();
      final tripService = Get.find<TripService>();

      final results = <Map<String, dynamic>>[];
      final query = searchQuery.value;

      // Determine listing type based on tab
      // Tab indices: 0=Tất cả, 1=Chỗ ở, 2=Tour, 3=Địa điểm, 4=Ẩm thực
      ListingType? filterType;
      switch (selectedTab.value) {
        case 1: // Chỗ ở
          filterType = ListingType.room;
          break;
        case 2: // Tour
          filterType = ListingType.tour;
          break;
        case 3: // Địa điểm - will search blogs below
          filterType = null;
          break;
        case 4: // Ẩm thực
          filterType = ListingType.food;
          break;
        default: // Tất cả
          filterType = null;
          break;
      }

      // Search listings with filters
      final listings = await listingService.searchListings(
        query: query,
        type: filterType,
        minPrice: priceRange[0] > 0 ? priceRange[0] : null,
        maxPrice: priceRange[1] < 10000000 ? priceRange[1] : null,
      );

      // Convert listings to search results format
      for (final listing in listings) {
        // Apply all filters using helper method
        if (!_passesFilters(listing)) {
          continue;
        }

        results.add({
          'id': listing.id,
          'name': listing.title,
          'type': _getTypeDisplay(listing.type),
          'location': '${listing.details['city'] ?? ''}, ${listing.details['province'] ?? ''}',
          'rating': listing.rating,
          'reviews': listing.reviews,
          'price': listing.hasDiscount
              ? '${NumberFormat('#,###').format(listing.discountPrice)}đ'
              : '${NumberFormat('#,###').format(listing.price)}đ',
          'originalPrice': listing.hasDiscount ? '${NumberFormat('#,###').format(listing.price)}đ' : null,
          'isFavorite': false,
          'category': listing.type.value,
          'image': listing.images.isNotEmpty ? listing.images.first : '',
          'businessName': listing.businessName,
          'listingId': listing.id,
        });
      }

      // Also search trips if on All or Tour tab
      if (selectedTab.value == 0 || selectedTab.value == 2) {
        try {
          // Get both user trips and public trips
          final userTrips = await tripService.getUserTrips();

          // Try to get public trips, but gracefully handle index errors
          List<dynamic> publicTrips = [];
          try {
            publicTrips = await tripService.getAllPublicTrips();
          } catch (e) {
            LoggerService.w('Skipping public trips due to index requirement: $e');
            // Continue without public trips - only show user trips
          }

          // Combine and deduplicate trips (user trips + public trips)
          final allTrips = <String, dynamic>{};
          for (final trip in [...userTrips, ...publicTrips]) {
            allTrips[trip.id] = trip; // Use map to auto-deduplicate by ID
          }

        for (final trip in allTrips.values) {
          // Apply search query filter
          if (query.isNotEmpty &&
              !trip.title.toLowerCase().contains(query.toLowerCase()) &&
              !trip.destination.toLowerCase().contains(query.toLowerCase())) {
            continue;
          }

          // Apply location filter
          if (selectedLocation.value.isNotEmpty &&
              !trip.destination.toLowerCase().contains(selectedLocation.value.toLowerCase())) {
            continue;
          }

          // Apply date filter (if trip dates overlap with selected date)
          if (selectedDate.value.isNotEmpty) {
            // Skip date filtering for trips for now as it requires date parsing
            // TODO: Implement date range checking if needed
          }

          results.add({
            'id': trip.id,
            'name': trip.title,
            'type': 'Chuyến đi',
            'location': trip.destination,
            'rating': 4.5,
            'reviews': 0,
            'price': '${NumberFormat('#,###').format(trip.budget)}đ',
            'isFavorite': false,
            'category': 'trip',
            'image': trip.coverImage,
          });
        }
        } catch (e) {
          LoggerService.e('Error searching trips', error: e);
          // Continue without trips
        }
      }

      // Search blogs if on All or "Địa điểm" tab
      if (selectedTab.value == 0 || selectedTab.value == 3) {
        try {
          // Use searchPosts with query (empty string returns all recent posts)
          final blogs = await blogService.searchPosts(query.isNotEmpty ? query : '');

          for (final blog in blogs) {
            // Apply location filter (check tags or content)
            if (selectedLocation.value.isNotEmpty &&
                !blog.title.toLowerCase().contains(selectedLocation.value.toLowerCase()) &&
                !blog.content.toLowerCase().contains(selectedLocation.value.toLowerCase()) &&
                !blog.tags.any((tag) => tag.toLowerCase().contains(selectedLocation.value.toLowerCase()))) {
              continue;
            }

            results.add({
              'id': blog.id,
              'name': blog.title,
              'type': 'Địa điểm',
              'location': blog.tags.isNotEmpty ? blog.tags.first : 'Việt Nam',
              'rating': 4.5,
              'reviews': 0,
              'price': null, // Blogs don't have price
              'isFavorite': false,
              'category': 'destination',
              'image': blog.coverImage,
            });
          }
        } catch (e) {
          LoggerService.e('Error searching blogs', error: e);
        }
      }

      // Sort results based on selected sort
      if (selectedSort.value == 'price_low') {
        results.sort((a, b) {
          final priceA = _extractPrice(a['price']);
          final priceB = _extractPrice(b['price']);
          return priceA.compareTo(priceB);
        });
      } else if (selectedSort.value == 'price_high') {
        results.sort((a, b) {
          final priceA = _extractPrice(a['price']);
          final priceB = _extractPrice(b['price']);
          return priceB.compareTo(priceA);
        });
      } else if (selectedSort.value == 'rating') {
        results.sort((a, b) {
          final ratingA = (a['rating'] ?? 0).toDouble();
          final ratingB = (b['rating'] ?? 0).toDouble();
          return ratingB.compareTo(ratingA);
        });
      }

      // Only update results if this is still the latest search
      if (_lastSearchQuery == currentQuery) {
        searchResults.value = results;

        // Log search performance
        final searchDuration = DateTime.now().difference(searchStartTime);
        LoggerService.d(
          'Search completed: query="$currentQuery", results=${results.length}, duration=${searchDuration.inMilliseconds}ms',
        );
      } else {
        LoggerService.d('Search results ignored (newer search in progress)');
      }
    } catch (e) {
      LoggerService.e('Error searching', error: e);
      // Only update if this is still the latest search
      if (_lastSearchQuery == currentQuery) {
        searchResults.value = [];
        AppSnackbar.showError(message: 'Lỗi khi tìm kiếm. Vui lòng thử lại.');
      }
    } finally {
      isSearching.value = false;
    }
  }

  /// Helper: Apply all filters to a listing
  bool _passesFilters(ListingModel listing) {
    // Rating filter
    if (selectedRating.value > 0 && listing.rating < selectedRating.value) {
      return false;
    }

    // Location filter
    if (selectedLocation.value.isNotEmpty) {
      final location = '${listing.details['city'] ?? ''} ${listing.details['province'] ?? ''}'.toLowerCase();
      if (!location.contains(selectedLocation.value.toLowerCase())) {
        return false;
      }
    }

    // Categories filter
    if (selectedCategories.isNotEmpty) {
      final listingCategories = listing.details['categories'] as List<dynamic>?;
      if (listingCategories == null) return false;

      bool hasMatchingCategory = false;
      for (final category in selectedCategories) {
        if (listingCategories.contains(category)) {
          hasMatchingCategory = true;
          break;
        }
      }
      if (!hasMatchingCategory) return false;
    }

    // Amenities filter
    if (selectedAmenities.isNotEmpty) {
      final listingAmenities = listing.details['amenities'] as List<dynamic>?;
      if (listingAmenities == null) return false;

      for (final amenity in selectedAmenities) {
        bool hasAmenity = false;
        for (final listingAmenity in listingAmenities) {
          if (listingAmenity.toString().toLowerCase().contains(amenity.toLowerCase()) ||
              amenity.toLowerCase().contains(listingAmenity.toString().toLowerCase())) {
            hasAmenity = true;
            break;
          }
        }
        if (!hasAmenity) return false;
      }
    }

    return true;
  }

  String _getTypeDisplay(ListingType type) {
    switch (type) {
      case ListingType.room:
        return 'Chỗ ở';
      case ListingType.tour:
        return 'Tour';
      case ListingType.food:
        return 'Ẩm thực';
      case ListingType.service:
        return 'Dịch vụ';
    }
  }

  double _extractPrice(String priceStr) {
    // Extract numeric value from price string like "1,500,000đ"
    final cleanStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleanStr) ?? 0;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }

  void searchFromSuggestion(String suggestion) {
    searchController.text = suggestion;
    searchQuery.value = suggestion;
    performSearch();
  }

  void removeRecentSearch(String search) async {
    try {
      // Remove from memory
      recentSearches.remove(search);

      // Update storage with new list
      final storageService = Get.find<StorageService>();
      await storageService.write(StorageService.keySearchHistory, recentSearches);

      LoggerService.d('Removed search from history: $search');
    } catch (e) {
      LoggerService.e('Error removing search history', error: e);
    }
  }

  void clearRecentSearches() async {
    try {
      final storageService = Get.find<StorageService>();
      await storageService.clearSearchHistory();
      recentSearches.clear();
      LoggerService.i('Cleared all recent searches');
      AppSnackbar.showInfo(message: 'Đã xóa lịch sử tìm kiếm');
    } catch (e) {
      LoggerService.e('Error clearing search history', error: e);
    }
  }

  void applySort() {
    // Apply sorting logic
    performSearch();
  }

  void showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        height: 0.8.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(AppSpacing.s5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bộ lọc', style: AppTypography.h3),
                  TextButton(
                    onPressed: resetFilters,
                    child: Text(
                      'Đặt lại',
                      style: AppTypography.bodyM.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Filter content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.s5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price range
                    Text('Khoảng giá', style: AppTypography.h4),
                    SizedBox(height: AppSpacing.s3),
                    Obx(
                      () => RangeSlider(
                        values: RangeValues(priceRange[0], priceRange[1]),
                        min: 0,
                        max: 10000000,
                        divisions: 100,
                        labels: RangeLabels(
                          '${(priceRange[0] / 1000).round()}k',
                          '${(priceRange[1] / 1000).round()}k',
                        ),
                        onChanged: (values) {
                          priceRange.value = [values.start, values.end];
                        },
                        activeColor: AppColors.primary,
                      ),
                    ),

                    SizedBox(height: AppSpacing.s5),

                    // Rating
                    Text('Đánh giá', style: AppTypography.h4),
                    SizedBox(height: AppSpacing.s3),
                    Wrap(
                      spacing: AppSpacing.s2,
                      children:
                          [1, 2, 3, 4, 5].map((rating) {
                            return Obx(
                              () => FilterChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('$rating'),
                                    Icon(Icons.star, size: 14.sp, color: AppColors.warning),
                                  ],
                                ),
                                selected: selectedRating.value == rating.toDouble(),
                                onSelected: (selected) {
                                  selectedRating.value = selected ? rating.toDouble() : 0;
                                },
                                selectedColor: AppColors.primary.withOpacity(0.2),
                                checkmarkColor: AppColors.primary,
                              ),
                            );
                          }).toList(),
                    ),

                    SizedBox(height: AppSpacing.s5),

                    // Categories
                    Text('Danh mục', style: AppTypography.h4),
                    SizedBox(height: AppSpacing.s3),
                    Wrap(
                      spacing: AppSpacing.s2,
                      runSpacing: AppSpacing.s2,
                      children:
                          [
                            'Lãng mạn',
                            'Gia đình',
                            'Phiêu lưu',
                            'Văn hóa',
                            'Ẩm thực',
                            'Nghỉ dưỡng',
                          ].map((category) {
                            return Obx(
                              () => FilterChip(
                                label: Text(category),
                                selected: selectedCategories.contains(category),
                                onSelected: (selected) {
                                  if (selected) {
                                    selectedCategories.add(category);
                                  } else {
                                    selectedCategories.remove(category);
                                  }
                                },
                                selectedColor: AppColors.primary.withOpacity(0.2),
                                checkmarkColor: AppColors.primary,
                              ),
                            );
                          }).toList(),
                    ),

                    SizedBox(height: AppSpacing.s5),

                    // Amenities
                    Text('Tiện ích', style: AppTypography.h4),
                    SizedBox(height: AppSpacing.s3),
                    Wrap(
                      spacing: AppSpacing.s2,
                      runSpacing: AppSpacing.s2,
                      children:
                          [
                            'WiFi',
                            'Bể bơi',
                            'Gym',
                            'Spa',
                            'Nhà hàng',
                            'Bar',
                            'Bãi đỗ xe',
                            'Phòng họp',
                          ].map((amenity) {
                            return Obx(
                              () => FilterChip(
                                label: Text(amenity),
                                selected: selectedAmenities.contains(amenity),
                                onSelected: (selected) {
                                  if (selected) {
                                    selectedAmenities.add(amenity);
                                  } else {
                                    selectedAmenities.remove(amenity);
                                  }
                                },
                                selectedColor: AppColors.primary.withOpacity(0.2),
                                checkmarkColor: AppColors.primary,
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Apply button
            Container(
              padding: EdgeInsets.all(AppSpacing.s5),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    performSearch();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                  ),
                  child: Text(
                    'Áp dụng bộ lọc',
                    style: AppTypography.bodyL.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void showLocationPicker() {
    final locations = [
      'Hà Nội',
      'TP.HCM',
      'Đà Nẵng',
      'Nha Trang',
      'Đà Lạt',
      'Phú Quốc',
      'Sapa',
      'Hội An',
    ];

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(AppSpacing.s5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chọn khu vực', style: AppTypography.h3),
            SizedBox(height: AppSpacing.s4),
            ...locations.map((location) {
              return ListTile(
                title: Text(location),
                leading: Radio<String>(
                  value: location,
                  groupValue: selectedLocation.value,
                  onChanged: (value) {
                    selectedLocation.value = value!;
                    Get.back();
                    performSearch();
                  },
                  activeColor: AppColors.primary,
                ),
                onTap: () {
                  selectedLocation.value = location;
                  Get.back();
                  performSearch();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void showDatePicker() async {
    final date = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      ),
    );

    if (date != null) {
      selectedDate.value = '${date.day}/${date.month}/${date.year}';
      performSearch();
    }
  }

  void resetFilters() {
    selectedSort.value = 'default';
    selectedLocation.value = '';
    selectedDate.value = '';
    priceRange.value = [0, 10000000];
    selectedRating.value = 0;
    selectedCategories.clear();
    selectedAmenities.clear();
    performSearch();
  }

  void toggleFavorite(Map<String, dynamic> item) {
    final index = searchResults.indexWhere((i) => i['id'] == item['id']);
    if (index != -1) {
      searchResults[index]['isFavorite'] = !searchResults[index]['isFavorite'];
      searchResults.refresh();

      AppSnackbar.showInfo(
        message:
            searchResults[index]['isFavorite'] ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích',
      );
    }
  }

  void navigateToDetail(Map<String, dynamic> item) {
    // Navigate based on category
    final category = item['category'] as String?;

    switch (category) {
      // Listings: room, tour, food, service
      case 'room':
      case 'tour':
      case 'food':
      case 'service':
        // Navigate to accommodation detail page with listingId
        Get.toNamed('/accommodation-detail', arguments: {
          'listingId': item['listingId'] ?? item['id'],
        });
        break;

      // Trips
      case 'trip':
        Get.toNamed('/trip-detail', arguments: {'tripId': item['id']});
        break;

      // Blogs/Destinations
      case 'destination':
        Get.toNamed('/blog-detail', arguments: {'postId': item['id']});
        break;

      default:
        AppSnackbar.showInfo(message: 'Chi tiết ${item["type"]} đang phát triển');
        break;
    }
  }
}
