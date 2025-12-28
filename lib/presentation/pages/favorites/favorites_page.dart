import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_image.dart';
import 'package:wanderlust/presentation/controllers/favorites/favorites_controller.dart';

class FavoritesPage extends GetView<FavoritesController> {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Yêu thích',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s3),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.neutral100),
              ),
            ),
            child: Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Tất cả', controller.getFilterCount('all')),
                    SizedBox(width: AppSpacing.s2),
                    _buildFilterChip('room', 'Chỗ ở', controller.getFilterCount('room')),
                    SizedBox(width: AppSpacing.s2),
                    _buildFilterChip('tour', 'Tour', controller.getFilterCount('tour')),
                    SizedBox(width: AppSpacing.s2),
                    _buildFilterChip('food', 'Ẩm thực', controller.getFilterCount('food')),
                    SizedBox(width: AppSpacing.s2),
                    _buildFilterChip('service', 'Dịch vụ', controller.getFilterCount('service')),
                  ],
                ),
              ),
            ),
          ),

          // Favorites list
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.isError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
                      SizedBox(height: AppSpacing.s4),
                      Text(
                        controller.errorMessage,
                        style: AppTypography.bodyL.copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: AppSpacing.s4),
                      ElevatedButton(
                        onPressed: controller.loadFavorites,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              final items = controller.filteredFavorites;

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80.sp,
                        color: AppColors.neutral300,
                      ),
                      SizedBox(height: AppSpacing.s4),
                      Text(
                        'Chưa có mục yêu thích',
                        style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
                      ),
                      SizedBox(height: AppSpacing.s2),
                      Text(
                        'Lưu các địa điểm bạn thích để xem sau',
                        style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadFavorites,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.s5),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildFavoriteCard(items[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = controller.selectedFilter.value == value;

    return GestureDetector(
      onTap: () => controller.changeFilter(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.neutral100,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.bodyS.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.3) : AppColors.neutral200,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  count.toString(),
                  style: AppTypography.bodyXS.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> item) {
    final hasDiscount = item['hasDiscount'] as bool? ?? false;
    final price = item['price'] as double;
    final originalPrice = item['originalPrice'] as double?;

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
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: AppImage(
                    imageData: item['image'] ?? '',
                    width: 100.w,
                    height: 100.w,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      width: 100.w,
                      height: 100.w,
                      color: AppColors.neutral200,
                      child: Icon(Icons.image, size: 40.sp, color: AppColors.neutral400),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item['title'] ?? '',
                        style: AppTypography.bodyL.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4.h),

                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14.sp, color: AppColors.neutral500),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              item['location'] ?? '',
                              style: AppTypography.bodyS.copyWith(color: AppColors.neutral600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // Rating & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rating
                          Row(
                            children: [
                              Icon(Icons.star, size: 16.sp, color: AppColors.warning),
                              SizedBox(width: 4.w),
                              Text(
                                '${item['rating'] ?? 0}',
                                style: AppTypography.bodyS.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                ' (${item['reviews'] ?? 0})',
                                style: AppTypography.bodyXS.copyWith(color: AppColors.neutral500),
                              ),
                            ],
                          ),

                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (hasDiscount && originalPrice != null)
                                Text(
                                  '${NumberFormat('#,###').format(originalPrice)}đ',
                                  style: AppTypography.bodyXS.copyWith(
                                    color: AppColors.neutral500,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                '${NumberFormat('#,###').format(price)}đ',
                                style: AppTypography.bodyM.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: hasDiscount ? AppColors.error : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // Remove button
                IconButton(
                  icon: Icon(Icons.favorite, size: 24.sp, color: AppColors.error),
                  onPressed: () => _showRemoveDialog(item),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(Map<String, dynamic> item) {
    Get.dialog(
      AlertDialog(
        title: Text('Xóa khỏi yêu thích?', style: AppTypography.h4),
        content: Text(
          'Bạn có chắc muốn xóa "${item['title']}" khỏi danh sách yêu thích?',
          style: AppTypography.bodyM,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Hủy', style: TextStyle(color: AppColors.neutral600)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeFavorite(item);
            },
            child: Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
