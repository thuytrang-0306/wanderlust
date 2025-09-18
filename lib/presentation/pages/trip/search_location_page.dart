import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/presentation/controllers/trip/search_location_controller.dart';

class SearchLocationPage extends StatelessWidget {
  const SearchLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchLocationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: AppColors.primary, size: 32.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Tìm kiếm',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          _buildSearchBar(controller),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Popular tags section
                  _buildTagsSection(controller),

                  // Saved destinations section
                  _buildSavedSection(controller),

                  // Suggestions section
                  _buildSuggestionsSection(controller),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(SearchLocationController controller) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: TextField(
          controller: controller.searchController,
          onChanged: controller.onSearchChanged,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm theo địa điểm',
            hintStyle: TextStyle(fontSize: 16.sp, color: const Color(0xFF9CA3AF)),
            prefixIcon: Icon(Icons.search, color: const Color(0xFF9CA3AF), size: 20.sp),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection(SearchLocationController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nổi bật',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Xem thêm',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Tag chips
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildTagChip('Homestay'),
              _buildTagChip('TaXua'),
              _buildTagChip('Haiphong'),
              _buildTagChip('TP.HoChiMinh'),
              _buildTagChip('Khachsan'),
              _buildTagChip('Quan cam'),
              _buildTagChip('QuangNinh'),
            ],
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        ),
        child: Text(label, style: TextStyle(fontSize: 14.sp, color: AppColors.primary)),
      ),
    );
  }

  Widget _buildSavedSection(SearchLocationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã lưu',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColors.textSecondary),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Horizontal scroll list
        SizedBox(
          height: 240.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildDestinationCard(
                title: index == 0 ? 'Vĩnh Hạ Long' : 'Biển Nha Trang',
                location: index == 0 ? 'Quảng Ninh' : 'Nha Trang',
                price: index == 0 ? '550.000' : '400.000',
                rating: 4.9,
                duration: '4N/5D',
                imageUrl:
                    index == 0
                        ? 'https://images.unsplash.com/photo-1528127269322-539801943592?w=400'
                        : 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400',
                isHorizontal: true,
              );
            },
          ),
        ),

        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildSuggestionsSection(SearchLocationController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đề xuất',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Xem thêm',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Grid view
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              final isVinh = index % 2 == 0;
              return _buildDestinationCard(
                title: isVinh ? 'Vĩnh Hạ Long' : 'Biển Nha Trang',
                location: isVinh ? 'Quảng Ninh' : 'Nha Trang',
                price: isVinh ? '550.000' : '400.000',
                rating: 4.9,
                duration: '4N/5D',
                imageUrl:
                    isVinh
                        ? 'https://images.unsplash.com/photo-1528127269322-539801943592?w=400'
                        : 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400',
                isHorizontal: false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard({
    required String title,
    required String location,
    required String price,
    required double rating,
    required String duration,
    required String imageUrl,
    required bool isHorizontal,
  }) {
    final width = isHorizontal ? 160.w : double.infinity;

    return GestureDetector(
      onTap: () {
        Get.back(result: {'title': title, 'location': location, 'price': price});
      },
      child: Container(
        width: width,
        margin: isHorizontal ? EdgeInsets.only(right: 12.w) : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badge
            Stack(
              children: [
                Container(
                  height: isHorizontal ? 140.h : 120.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Duration badge
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF812C),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      duration,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$price VND',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12.sp, color: AppColors.textTertiary),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.star, size: 12.sp, color: const Color(0xFFFBBF24)),
                      SizedBox(width: 2.w),
                      Text(
                        rating.toString(),
                        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
