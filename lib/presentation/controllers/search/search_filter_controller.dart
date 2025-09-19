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
// import 'package:wanderlust/core/services/storage_service.dart'; // TODO: Implement later
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchFilterController extends BaseController with GetTickerProviderStateMixin {
  // Controllers
  late TabController tabController;
  final searchController = TextEditingController();

  // Observables
  final searchQuery = ''.obs;
  final selectedTab = 0.obs;
  final RxBool isSearching = false.obs;
  final searchResults = <Map<String, dynamic>>[].obs;
  final recentSearches = <String>[].obs;

  // Filters
  final selectedSort = 'default'.obs;
  final selectedLocation = ''.obs;
  final selectedDate = ''.obs;
  final priceRange = RxList<double>([0, 10000000]);
  final selectedRating = 0.0.obs;
  final selectedCategories = <String>[].obs;
  final selectedAmenities = <String>[].obs;

  final hasActiveFilters = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(_handleTabSelection);
    loadRecentSearches();

    // Listen to filter changes
    ever(selectedSort, (_) => _updateActiveFilters());
    ever(selectedLocation, (_) => _updateActiveFilters());
    ever(selectedDate, (_) => _updateActiveFilters());
    ever(priceRange, (_) => _updateActiveFilters());
    ever(selectedRating, (_) => _updateActiveFilters());
    ever(selectedCategories, (_) => _updateActiveFilters());
    ever(selectedAmenities, (_) => _updateActiveFilters());
  }

  @override
  void onClose() {
    tabController.dispose();
    searchController.dispose();
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
    // TODO: Load from storage when StorageService is implemented
    // For now, start with empty recent searches
    recentSearches.value = [];
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

    isSearching.value = true;

    try {
      // Save to recent searches
      if (searchQuery.value.isNotEmpty && !recentSearches.contains(searchQuery.value)) {
        recentSearches.insert(0, searchQuery.value);
        if (recentSearches.length > 5) recentSearches.removeLast();
      }

      // Get services
      final listingService = Get.find<ListingService>();
      final blogService = Get.find<BlogService>();
      final tripService = Get.find<TripService>();

      final results = <Map<String, dynamic>>[];
      final query = searchQuery.value;

      // Determine listing type based on tab
      ListingType? filterType;
      switch (selectedTab.value) {
        case 1: // Chỗ ở
          filterType = ListingType.room;
          break;
        case 2: // Tour
          filterType = ListingType.tour;
          break;
        case 3: // Ẩm thực
          filterType = ListingType.food;
          break;
        case 4: // Dịch vụ
          filterType = ListingType.service;
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
        // Apply additional filters
        if (selectedRating.value > 0 && listing.rating < selectedRating.value) {
          continue;
        }
        
        if (selectedLocation.value.isNotEmpty) {
          final location = '${listing.details['city'] ?? ''} ${listing.details['province'] ?? ''}'.toLowerCase();
          if (!location.contains(selectedLocation.value.toLowerCase())) {
            continue;
          }
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
        final trips = await tripService.getUserTrips();
        for (final trip in trips) {
          if (query.isEmpty || 
              trip.title.toLowerCase().contains(query.toLowerCase()) ||
              trip.destination.toLowerCase().contains(query.toLowerCase())) {
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

      searchResults.value = results;
      // Remove snackbar - we have empty state UI
    } catch (e) {
      LoggerService.e('Error searching', error: e);
      searchResults.value = [];
      AppSnackbar.showError(message: 'Lỗi khi tìm kiếm');
    } finally {
      isSearching.value = false;
    }
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
    recentSearches.remove(search);
    // TODO: Update storage when StorageService is implemented
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
    // Navigate based on type
    switch (item['category']) {
      case 'hotel':
        Get.toNamed('/accommodation-detail', arguments: item);
        break;
      case 'tour':
        // Navigate to trip detail for now
        Get.toNamed('/trip-detail', arguments: {'tripId': item['id']});
        break;
      case 'destination':
        // Navigate to blog detail for blogs
        if (item['type'] == 'Bài viết') {
          Get.toNamed('/blog-detail', arguments: {'postId': item['id']});
        } else {
          AppSnackbar.showInfo(message: 'Chi tiết ${item["type"]} đang phát triển');
        }
        break;
      case 'restaurant':
        AppSnackbar.showInfo(message: 'Chi tiết ${item["type"]} đang phát triển');
        break;
    }
  }
}
