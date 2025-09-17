import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/services/storage_service.dart';
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
    hasActiveFilters.value = selectedSort.value != 'default' ||
        selectedLocation.value.isNotEmpty ||
        selectedDate.value.isNotEmpty ||
        selectedRating.value > 0 ||
        selectedCategories.isNotEmpty ||
        selectedAmenities.isNotEmpty ||
        (priceRange[0] > 0 || priceRange[1] < 10000000);
  }
  
  void loadRecentSearches() {
    // Load from storage
    final searches = StorageService.to.searchHistory;
    recentSearches.value = searches.take(5).toList();
  }
  
  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (query.isNotEmpty) {
      // Debounce search
      debounce(
        searchQuery,
        (_) => performSearch(),
        time: const Duration(milliseconds: 500),
      );
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
    
    // Save to recent searches
    if (searchQuery.value.isNotEmpty && !recentSearches.contains(searchQuery.value)) {
      await StorageService.to.addSearchHistory(searchQuery.value);
      loadRecentSearches();
    }
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock results based on tab
    final tabTypes = ['all', 'hotel', 'tour', 'destination', 'restaurant'];
    final currentType = tabTypes[selectedTab.value];
    
    searchResults.value = _getMockResults(currentType);
    
    isSearching.value = false;
  }
  
  List<Map<String, dynamic>> _getMockResults(String type) {
    final baseResults = [
      {
        'id': '1',
        'name': 'Khách sạn Mường Thanh Đà Lạt',
        'type': 'Khách sạn',
        'location': 'Đà Lạt, Lâm Đồng',
        'rating': 4.5,
        'reviews': 234,
        'price': '1,200,000đ',
        'isFavorite': false,
        'category': 'hotel',
      },
      {
        'id': '2',
        'name': 'Tour khám phá Đà Lạt 3N2Đ',
        'type': 'Tour',
        'location': 'Đà Lạt, Lâm Đồng',
        'rating': 4.8,
        'reviews': 156,
        'price': '2,500,000đ',
        'isFavorite': true,
        'category': 'tour',
      },
      {
        'id': '3',
        'name': 'Thung lũng Tình Yêu',
        'type': 'Địa điểm',
        'location': 'Đà Lạt, Lâm Đồng',
        'rating': 4.3,
        'reviews': 512,
        'price': '150,000đ',
        'isFavorite': false,
        'category': 'destination',
      },
      {
        'id': '4',
        'name': 'Nhà hàng Le Chalet',
        'type': 'Nhà hàng',
        'location': 'Đà Lạt, Lâm Đồng',
        'rating': 4.6,
        'reviews': 89,
        'price': '300,000đ',
        'isFavorite': false,
        'category': 'restaurant',
      },
      {
        'id': '5',
        'name': 'Ana Mandara Villas Đà Lạt',
        'type': 'Khách sạn',
        'location': 'Đà Lạt, Lâm Đồng',
        'rating': 4.9,
        'reviews': 412,
        'price': '3,500,000đ',
        'isFavorite': true,
        'category': 'hotel',
      },
    ];
    
    // Filter by type if not 'all'
    if (type != 'all') {
      return baseResults.where((item) => item['category'] == type).toList();
    }
    
    return baseResults;
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
    // Update storage
    await StorageService.to.clearSearchHistory();
    for (var s in recentSearches) {
      await StorageService.to.addSearchHistory(s);
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
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(AppSpacing.s5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bộ lọc',
                    style: AppTypography.heading5,
                  ),
                  TextButton(
                    onPressed: resetFilters,
                    child: Text(
                      'Đặt lại',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
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
                    Text(
                      'Khoảng giá',
                      style: AppTypography.heading6,
                    ),
                    SizedBox(height: AppSpacing.s3),
                    Obx(() => RangeSlider(
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
                    )),
                    
                    SizedBox(height: AppSpacing.s5),
                    
                    // Rating
                    Text(
                      'Đánh giá',
                      style: AppTypography.heading6,
                    ),
                    SizedBox(height: AppSpacing.s3),
                    Wrap(
                      spacing: AppSpacing.s2,
                      children: [1, 2, 3, 4, 5].map((rating) {
                        return Obx(() => FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$rating'),
                              Icon(
                                Icons.star,
                                size: 14.sp,
                                color: AppColors.warning,
                              ),
                            ],
                          ),
                          selected: selectedRating.value == rating.toDouble(),
                          onSelected: (selected) {
                            selectedRating.value = selected ? rating.toDouble() : 0;
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                        ));
                      }).toList(),
                    ),
                    
                    SizedBox(height: AppSpacing.s5),
                    
                    // Categories
                    Text(
                      'Danh mục',
                      style: AppTypography.heading6,
                    ),
                    SizedBox(height: AppSpacing.s3),
                    Wrap(
                      spacing: AppSpacing.s2,
                      runSpacing: AppSpacing.s2,
                      children: [
                        'Lãng mạn',
                        'Gia đình',
                        'Phiêu lưu',
                        'Văn hóa',
                        'Ẩm thực',
                        'Nghỉ dưỡng',
                      ].map((category) {
                        return Obx(() => FilterChip(
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
                        ));
                      }).toList(),
                    ),
                    
                    SizedBox(height: AppSpacing.s5),
                    
                    // Amenities
                    Text(
                      'Tiện ích',
                      style: AppTypography.heading6,
                    ),
                    SizedBox(height: AppSpacing.s3),
                    Wrap(
                      spacing: AppSpacing.s2,
                      runSpacing: AppSpacing.s2,
                      children: [
                        'WiFi',
                        'Bể bơi',
                        'Gym',
                        'Spa',
                        'Nhà hàng',
                        'Bar',
                        'Bãi đỗ xe',
                        'Phòng họp',
                      ].map((amenity) {
                        return Obx(() => FilterChip(
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
                        ));
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  child: Text(
                    'Áp dụng bộ lọc',
                    style: AppTypography.button.copyWith(
                      color: Colors.white,
                    ),
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
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn khu vực',
              style: AppTypography.heading5,
            ),
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
            }).toList(),
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
        message: searchResults[index]['isFavorite']
            ? 'Đã thêm vào yêu thích'
            : 'Đã xóa khỏi yêu thích',
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
        Get.toNamed('/combo-detail', arguments: item);
        break;
      case 'destination':
      case 'restaurant':
        AppSnackbar.showInfo(message: 'Chi tiết ${item["type"]} đang phát triển');
        break;
    }
  }
}