import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/presentation/controllers/search/search_filter_controller.dart';

class SearchFilterPage extends GetView<SearchFilterController> {
  const SearchFilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            _buildTabBar(),
            Expanded(child: Obx(() => _buildContent())),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(AppSpacing.s5),
      child: Column(
        children: [
          // Search bar with back button
          Row(
            children: [
              // Back button
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20.sp),
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
              ),
              // Search field
              Expanded(
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearchChanged,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm địa điểm, khách sạn, tour...',
                      hintStyle: AppTypography.bodyM.copyWith(color: AppColors.textTertiary),
                      prefixIcon: Icon(Icons.search, color: AppColors.neutral500, size: 24.sp),
                      suffixIcon: Obx(
                        () =>
                            controller.searchQuery.value.isNotEmpty
                                ? IconButton(
                                  icon: Icon(Icons.clear, color: AppColors.neutral500, size: 20.sp),
                                  onPressed: controller.clearSearch,
                                )
                                : const SizedBox.shrink(),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s4,
                        vertical: AppSpacing.s3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.s3),

          // Filter chips
          SizedBox(
            height: 32.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  icon: Icons.tune,
                  label: 'Bộ lọc',
                  onTap: controller.showFilterBottomSheet,
                  isActive: controller.hasActiveFilters,
                ),
                SizedBox(width: AppSpacing.s2),
                Obx(() => _buildSortChip()),
                SizedBox(width: AppSpacing.s2),
                _buildFilterChip(
                  icon: Icons.location_on_outlined,
                  label:
                      controller.selectedLocation.value.isEmpty
                          ? 'Khu vực'
                          : controller.selectedLocation.value,
                  onTap: controller.showLocationPicker,
                ),
                SizedBox(width: AppSpacing.s2),
                _buildFilterChip(
                  icon: Icons.calendar_today_outlined,
                  label:
                      controller.selectedDate.value.isEmpty
                          ? 'Ngày'
                          : controller.selectedDate.value,
                  onTap: controller.showDatePicker,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    RxBool? isActive,
  }) {
    if (isActive != null) {
      return Obx(() {
        final active = isActive.value;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s2),
            decoration: BoxDecoration(
              color: active ? AppColors.primary.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: active ? AppColors.primary : AppColors.neutral300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16.sp, color: active ? AppColors.primary : AppColors.grey),
                SizedBox(width: AppSpacing.s1),
                Text(
                  label,
                  style: AppTypography.bodyS.copyWith(
                    color: active ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      });
    } else {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.neutral300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.sp, color: AppColors.grey),
              SizedBox(width: AppSpacing.s1),
              Text(
                label,
                style: AppTypography.bodyS.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSortChip() {
    final sortOptions = {
      'default': 'Mặc định',
      'price_low': 'Giá tăng dần',
      'price_high': 'Giá giảm dần',
      'rating': 'Đánh giá cao',
      'distance': 'Gần nhất',
    };

    return GestureDetector(
      onTap: () {
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
                Text('Sắp xếp theo', style: AppTypography.h3),
                SizedBox(height: AppSpacing.s4),
                ...sortOptions.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.value),
                    leading: Radio<String>(
                      value: entry.key,
                      groupValue: controller.selectedSort.value,
                      onChanged: (value) {
                        controller.selectedSort.value = value!;
                        Get.back();
                        controller.applySort();
                      },
                      activeColor: AppColors.primary,
                    ),
                    onTap: () {
                      controller.selectedSort.value = entry.key;
                      Get.back();
                      controller.applySort();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s2),
        decoration: BoxDecoration(
          color:
              controller.selectedSort.value != 'default'
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                controller.selectedSort.value != 'default'
                    ? AppColors.primary
                    : AppColors.neutral300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 16.sp,
              color:
                  controller.selectedSort.value != 'default' ? AppColors.primary : AppColors.grey,
            ),
            SizedBox(width: AppSpacing.s1),
            Text(
              sortOptions[controller.selectedSort.value]!,
              style: AppTypography.bodyS.copyWith(
                color:
                    controller.selectedSort.value != 'default'
                        ? AppColors.primary
                        : AppColors.textPrimary,
                fontWeight:
                    controller.selectedSort.value != 'default' ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller.tabController,
        tabs: const [
          Tab(text: 'Tất cả'),
          Tab(text: 'Khách sạn'),
          Tab(text: 'Tour'),
          Tab(text: 'Địa điểm'),
          Tab(text: 'Nhà hàng'),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.neutral500,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.bodyM,
      ),
    );
  }

  Widget _buildContent() {
    if (controller.isSearching.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.searchResults.isEmpty && controller.searchQuery.value.isNotEmpty) {
      return _buildEmptyState();
    }

    if (controller.searchQuery.value.isEmpty) {
      return _buildSuggestions();
    }

    return _buildSearchResults();
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tìm kiếm phổ biến', style: AppTypography.h3),
          SizedBox(height: AppSpacing.s4),
          Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children:
                ['Đà Lạt', 'Phú Quốc', 'Sapa', 'Hội An', 'Nha Trang', 'Đà Nẵng'].map((suggestion) {
                  return GestureDetector(
                    onTap: () => controller.searchFromSuggestion(suggestion),
                    child: Chip(
                      label: Text(suggestion),
                      backgroundColor: AppColors.neutral100,
                      labelStyle: AppTypography.bodyS,
                    ),
                  );
                }).toList(),
          ),

          SizedBox(height: AppSpacing.s8),

          Text('Tìm kiếm gần đây', style: AppTypography.h3),
          SizedBox(height: AppSpacing.s4),

          ...controller.recentSearches.map((search) {
            return ListTile(
              leading: Icon(Icons.history, color: AppColors.grey, size: 20.sp),
              title: Text(search, style: AppTypography.bodyM),
              trailing: IconButton(
                icon: Icon(Icons.close, size: 18.sp, color: AppColors.neutral500),
                onPressed: () => controller.removeRecentSearch(search),
              ),
              onTap: () => controller.searchFromSuggestion(search),
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.s5),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final item = controller.searchResults[index];
        return _buildResultCard(item);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.navigateToDetail(item),
          borderRadius: BorderRadius.circular(12.r),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: SizedBox(
                    height: 180.h,
                    width: double.infinity,
                    child: item['image'] != null && item['image'].toString().isNotEmpty
                        ? AppImage(
                            imageData: item['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorWidget: Container(
                              color: AppColors.neutral200,
                              child: Icon(Icons.image, size: 48.sp, color: AppColors.neutral400),
                            ),
                          )
                        : Container(
                            color: AppColors.neutral200,
                            child: Center(
                              child: Icon(Icons.image, size: 48.sp, color: AppColors.neutral400),
                            ),
                          ),
                  ),
                ),

                // Type badge
                Positioned(
                  top: AppSpacing.s3,
                  left: AppSpacing.s3,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s3,
                      vertical: AppSpacing.s1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      item['type'],
                      style: AppTypography.bodyS.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Favorite button
                Positioned(
                  top: AppSpacing.s3,
                  right: AppSpacing.s3,
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(
                        item['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                        color: item['isFavorite'] ? AppColors.error : AppColors.grey,
                      ),
                      onPressed: () => controller.toggleFavorite(item),
                      padding: EdgeInsets.all(AppSpacing.s2),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(AppSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: AppTypography.h4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: AppSpacing.s2),

                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16.sp, color: AppColors.neutral500),
                      SizedBox(width: AppSpacing.s1),
                      Expanded(
                        child: Text(
                          item['location'],
                          style: AppTypography.bodyS.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.s2),

                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          Icon(Icons.star, size: 16.sp, color: AppColors.warning),
                          SizedBox(width: AppSpacing.s1),
                          Text(
                            item['rating'].toString(),
                            style: AppTypography.bodyS.copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: AppSpacing.s1),
                          Text(
                            '(${item['reviews']})',
                            style: AppTypography.bodyS.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Price
                      if (item['price'] != null) ...[
                        Text(
                          'từ ',
                          style: AppTypography.bodyS.copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          item['price'],
                          style: AppTypography.h4.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.sp, color: AppColors.neutral400),
          SizedBox(height: AppSpacing.s4),
          Text('Không tìm thấy kết quả', style: AppTypography.h3),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Thử tìm kiếm với từ khóa khác',
            style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
