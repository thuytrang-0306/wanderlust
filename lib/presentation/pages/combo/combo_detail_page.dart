import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/widgets/app_map.dart';
import 'package:wanderlust/data/models/location_point.dart';
import 'package:wanderlust/presentation/controllers/combo/combo_detail_controller.dart';

class ComboDetailPage extends GetView<ComboDetailController> {
  const ComboDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ComboDetailController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header image with app bar
              _buildSliverAppBar(),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tour title and info
                    _buildTourInfo(),

                    // Tour description
                    _buildTourDescription(),

                    // Creator info
                    _buildCreatorInfo(),

                    // Itinerary header
                    _buildItineraryHeader(),

                    // Map
                    _buildMap(),

                    // Daily schedule
                    _buildDailySchedule(),

                    // Bottom spacing
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ],
          ),

          // Bottom button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.chevron_left, color: AppColors.primary, size: 28.sp),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: controller.toggleBookmark,
          child: Container(
            margin: EdgeInsets.all(8.w),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: Obx(
              () => Icon(
                controller.isBookmarked.value ? Icons.bookmark : Icons.bookmark_border,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl:
              controller.comboData['image'] ??
              'https://images.unsplash.com/photo-1559628233-100c798642d4?w=800',
          fit: BoxFit.cover,
          errorWidget:
              (context, url, error) => Container(
                color: AppColors.neutral100,
                child: Icon(Icons.image, size: 50.sp, color: AppColors.neutral400),
              ),
        ),
      ),
    );
  }

  Widget _buildTourInfo() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location and rating
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18.sp, color: AppColors.neutral500),
              SizedBox(width: 4.w),
              Text(
                controller.comboData['location'] ?? 'Nha Trang, Khánh Hòa',
                style: TextStyle(fontSize: 14.sp, color: AppColors.neutral600),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.star, size: 18.sp, color: Colors.amber),
              SizedBox(width: 4.w),
              Text(
                controller.comboData['rating'] ?? '4.8',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral700,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Tour title
          Text(
            controller.comboData['title'] ?? 'Tour Nha Trang - Chuyên đi chữa lành cảm xúc',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giới thiệu trip',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              'Mô tả chi tiết đang được cập nhật. Hãy khám phá combo du lịch tuyệt vời này. ${controller.showFullDescription.value ? "Combo này bao gồm nhiều hoạt động thú vị và trải nghiệm đáng nhớ, được thiết kế dành cho những người yêu thích khám phá và tham gia các hoạt động nước ngoài." : ""}',
              style: TextStyle(fontSize: 14.sp, color: AppColors.neutral600, height: 1.5),
            ),
          ),
          GestureDetector(
            onTap: controller.toggleDescription,
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                controller.showFullDescription.value ? 'Thu gọn' : '...Xem thêm',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Trip info
          Text(
            'Cập nhật cuối: 9/1/2024',
            style: TextStyle(fontSize: 12.sp, color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorInfo() {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: CachedNetworkImageProvider('https://i.pravatar.cc/150?img=6'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Được tạo bởi',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.neutral500),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Hiếu Thủ Hải',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
          ),

          // Duration
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '2 giờ trước',
              style: TextStyle(fontSize: 12.sp, color: AppColors.neutral600),
            ),
          ),

          SizedBox(width: 12.w),

          // Location
          Text('Nha Trang', style: TextStyle(fontSize: 14.sp, color: AppColors.neutral600)),
        ],
      ),
    );
  }

  Widget _buildItineraryHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Text(
        'Lịch trình',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.neutral900),
      ),
    );
  }

  Widget _buildMap() {
    // Sample waypoints for tour route (TP.HCM -> Nha Trang)
    final waypoints = [
      LocationPoint(
        id: '1',
        name: 'TP.HCM',
        latitude: 10.8231,
        longitude: 106.6297,
        type: 'transport',
      ),
      LocationPoint(
        id: '2',
        name: 'Phan Thiết',
        latitude: 10.9289,
        longitude: 108.1024,
        type: 'attraction',
      ),
      LocationPoint(
        id: '3',
        name: 'Nha Trang',
        latitude: 12.2388,
        longitude: 109.1967,
        type: 'hotel',
      ),
    ];

    return Container(
      height: 200.h,
      margin: EdgeInsets.all(20.w),
      child: Stack(
        children: [
          // Real Map with route display
          AppMap.routeDisplay(
            waypoints: waypoints,
            height: 200.h,
            borderRadius: BorderRadius.circular(12.r),
          ),

          // Navigation button
          Positioned(
            bottom: 12.h,
            right: 12.w,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.navigation, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day tabs
        Container(
          height: 40.h,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            itemBuilder: (context, index) {
              return Obx(
                () => GestureDetector(
                  onTap: () => controller.selectDay(index + 1),
                  child: Container(
                    margin: EdgeInsets.only(right: 12.w),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color:
                          controller.selectedDay.value == index + 1
                              ? AppColors.primary
                              : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color:
                            controller.selectedDay.value == index + 1
                                ? AppColors.primary
                                : AppColors.neutral200,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Ngày ${index + 1}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              controller.selectedDay.value == index + 1
                                  ? Colors.white
                                  : AppColors.neutral700,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 20.h),

        // Day content
        Obx(() => controller.selectedDay.value == 1 ? _buildDay1Content() : _buildDay2Content()),
      ],
    );
  }

  Widget _buildDay1Content() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day title
          Text(
            'Ngày 1: TP.HCM → Nha Trang',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),

          SizedBox(height: 16.h),

          // Flight info
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F8),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.flight_takeoff, size: 20.sp, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Text(
                      'Vietnam Airlines, TP. Hồ Chí Minh',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Time and price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• 05:00 - 06:00: Di chuyển từ TP.HCM đến Nha Trang',
                      style: TextStyle(fontSize: 13.sp, color: AppColors.neutral700, height: 1.5),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '• Vé khách: Giá vé 250.000 - 350.000 VND (Phương Trang, Thành Bưởi)',
                      style: TextStyle(fontSize: 13.sp, color: AppColors.neutral700, height: 1.5),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '• Máy bay: Vé khứ hồi khoảng 1.500.000 - 2.500.000 VND (Vietnam Airlines, Bamboo Airways, Vietjet Air)',
                      style: TextStyle(fontSize: 13.sp, color: AppColors.neutral700, height: 1.5),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Places to visit
          _buildPlaceCard('Xuất phát', 'TP. Hồ Chí Minh', '6:00 - 8:00', Icons.location_city),

          SizedBox(height: 12.h),

          _buildPlaceCard('Trạm 1', 'Nhận phòng', '7:30 - 10:00', Icons.hotel),
        ],
      ),
    );
  }

  Widget _buildDay2Content() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day title
          Text(
            'Ngày 2: Khám phá Nha Trang',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),

          SizedBox(height: 16.h),

          // Places
          _buildPlaceCard(
            'Buổi sáng',
            'Viếng chùa Long Sơn',
            '8:00 - 10:00',
            Icons.temple_buddhist,
          ),

          SizedBox(height: 12.h),

          _buildPlaceCard(
            'Buổi trưa',
            'Tham quan Tháp Bà Ponagar',
            '10:30 - 12:00',
            Icons.account_balance,
          ),

          SizedBox(height: 12.h),

          _buildPlaceCard('Buổi chiều', 'Vịnh Nha Trang', '14:00 - 17:00', Icons.beach_access),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(String label, String place, String time, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.neutral500)),
                SizedBox(height: 2.h),
                Text(
                  place,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
          ),

          // Time
          Text(time, style: TextStyle(fontSize: 13.sp, color: AppColors.neutral600)),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: controller.initializeCombo,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFB794F4), AppColors.primary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Center(
                child: Text(
                  'Khai tạo',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
