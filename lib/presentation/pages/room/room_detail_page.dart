import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/models/room_model.dart';
import 'package:wanderlust/data/services/room_service.dart';

class RoomDetailPage extends StatefulWidget {
  const RoomDetailPage({super.key});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  final RoomService _roomService = Get.find<RoomService>();
  final PageController _pageController = PageController();
  
  RoomModel? room;
  bool isLoading = true;
  int currentImageIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadRoomDetails();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  Future<void> _loadRoomDetails() async {
    try {
      final roomId = Get.arguments as String?;
      if (roomId == null) {
        Get.back();
        AppSnackbar.showError(message: 'Không tìm thấy thông tin phòng');
        return;
      }
      
      final loadedRoom = await _roomService.getRoomById(roomId);
      if (loadedRoom == null) {
        Get.back();
        AppSnackbar.showError(message: 'Không tìm thấy phòng');
        return;
      }
      
      setState(() {
        room = loadedRoom;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.back();
      AppSnackbar.showError(message: 'Lỗi khi tải thông tin phòng');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    
    if (room == null) {
      return Scaffold(
        body: Center(
          child: Text('Không tìm thấy phòng'),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          // Image gallery with custom app bar
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppColors.neutral800, size: 20.sp),
                onPressed: () => Get.back(),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.share_outlined, color: AppColors.neutral800, size: 20.sp),
                  onPressed: () {
                    AppSnackbar.showInfo(message: 'Tính năng chia sẻ sẽ sớm được cập nhật');
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 8.w, top: 8.h, bottom: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.favorite_border, color: AppColors.neutral800, size: 20.sp),
                  onPressed: () {
                    AppSnackbar.showInfo(message: 'Tính năng yêu thích sẽ sớm được cập nhật');
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image carousel
                  if (room!.images.isNotEmpty)
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentImageIndex = index;
                        });
                      },
                      itemCount: room!.images.length,
                      itemBuilder: (context, index) {
                        return Image.memory(
                          room!.images[index].toImageBytes(),
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  else
                    Container(
                      color: AppColors.neutral200,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 64.sp,
                          color: AppColors.neutral400,
                        ),
                      ),
                    ),
                  
                  // Image indicators
                  if (room!.images.length > 1)
                    Positioned(
                      bottom: 20.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          room!.images.length,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            width: currentImageIndex == index ? 24.w : 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic info section
                _buildBasicInfoSection(),
                
                // Price section
                _buildPriceSection(),
                
                // Room details section
                _buildRoomDetailsSection(),
                
                // Facilities section
                _buildFacilitiesSection(),
                
                // Amenities section
                if (room!.amenities.isNotEmpty)
                  _buildAmenitiesSection(),
                
                // Description section
                _buildDescriptionSection(),
                
                // Business info section
                _buildBusinessInfoSection(),
                
                // Policies section
                _buildPoliciesSection(),
                
                SizedBox(height: 100.h), // Space for bottom button
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
  
  Widget _buildBasicInfoSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s5),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room name and status
          Row(
            children: [
              Expanded(
                child: Text(
                  room!.roomName,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s3,
                  vertical: AppSpacing.s1,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(room!.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  room!.statusDisplayName,
                  style: AppTypography.bodyS.copyWith(
                    color: _getStatusColor(room!.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.s2),
          
          // Room type
          Row(
            children: [
              Text(room!.typeIcon, style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: AppSpacing.s2),
              Text(
                room!.typeDisplayName,
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
            ],
          ),
          
          if (room!.viewType != null)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.s2),
              child: Row(
                children: [
                  Icon(Icons.landscape_outlined, size: 16.sp, color: AppColors.neutral600),
                  SizedBox(width: AppSpacing.s2),
                  Text(
                    room!.viewType!,
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildPriceSection() {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.s2),
      padding: EdgeInsets.all(AppSpacing.s5),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (room!.hasDiscount)
            Text(
              room!.formattedPrice,
              style: AppTypography.bodyL.copyWith(
                color: AppColors.neutral500,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                room!.hasDiscount ? room!.formattedDiscountPrice : room!.formattedPrice,
                style: AppTypography.h2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' /đêm',
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
          if (room!.hasDiscount)
            Container(
              margin: EdgeInsets.only(top: AppSpacing.s2),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s2,
                vertical: AppSpacing.s1,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Giảm ${room!.discountPercentage.toStringAsFixed(0)}%',
                style: AppTypography.bodyS.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildRoomDetailsSection() {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.s2),
      padding: EdgeInsets.all(AppSpacing.s5),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin phòng',
            style: AppTypography.bodyL.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s4),
          Row(
            children: [
              _buildDetailItem(Icons.people_outline, '${room!.maxGuests} khách'),
              SizedBox(width: AppSpacing.s5),
              _buildDetailItem(Icons.bed_outlined, '${room!.numberOfBeds} giường'),
            ],
          ),
          SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              _buildDetailItem(Icons.square_foot, '${room!.roomSize}m²'),
              if (room!.floor != null)
                Padding(
                  padding: EdgeInsets.only(left: AppSpacing.s5),
                  child: _buildDetailItem(Icons.stairs, 'Tầng ${room!.floor}'),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.neutral600),
        SizedBox(width: AppSpacing.s2),
        Text(
          text,
          style: AppTypography.bodyM.copyWith(
            color: AppColors.neutral800,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFacilitiesSection() {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.s2),
      padding: EdgeInsets.all(AppSpacing.s5),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiện nghi trong phòng',
            style: AppTypography.bodyL.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s4),
          Wrap(
            spacing: AppSpacing.s4,
            runSpacing: AppSpacing.s3,
            children: [
              if (room!.hasWifi)
                _buildFacilityChip(Icons.wifi, 'Wifi miễn phí'),
              if (room!.hasAirConditioner)
                _buildFacilityChip(Icons.ac_unit, 'Máy lạnh'),
              if (room!.hasTV)
                _buildFacilityChip(Icons.tv, 'TV'),
              if (room!.hasRefrigerator)
                _buildFacilityChip(Icons.kitchen, 'Tủ lạnh'),
              if (room!.hasBathroom)
                _buildFacilityChip(Icons.bathroom, 'Phòng tắm riêng'),
              if (room!.hasHotWater)
                _buildFacilityChip(Icons.hot_tub, 'Nước nóng'),
              if (room!.hasBalcony)
                _buildFacilityChip(Icons.balcony, 'Ban công'),
              if (room!.hasKitchen)
                _buildFacilityChip(Icons.countertops, 'Bếp'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFacilityChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.neutral700),
          SizedBox(width: AppSpacing.s1),
          Text(
            label,
            style: AppTypography.bodyS.copyWith(
              color: AppColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAmenitiesSection() {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.s2),
      padding: EdgeInsets.all(AppSpacing.s5),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiện ích khác',
            style: AppTypography.bodyL.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s4),
          Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: room!.amenities.map((amenity) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s3,
                  vertical: AppSpacing.s2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  amenity,
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDescriptionSection() {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.s2),
      padding: EdgeInsets.all(AppSpacing.s5),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mô tả',
            style: AppTypography.bodyL.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s3),
          Text(
            room!.description,
            style: AppTypography.bodyM.copyWith(
              color: AppColors.neutral700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBusinessInfoSection() {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.s2),
      padding: EdgeInsets.all(AppSpacing.s5),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin khách sạn',
            style: AppTypography.bodyL.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    '🏨',
                    style: TextStyle(fontSize: 24.sp),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room!.businessName,
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.warning, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '4.5',
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.neutral700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (120 đánh giá)',
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  AppSnackbar.showInfo(message: 'Tính năng xem khách sạn sẽ sớm được cập nhật');
                },
                child: Text('Xem thêm'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPoliciesSection() {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.s2),
      padding: EdgeInsets.all(AppSpacing.s5),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chính sách',
            style: AppTypography.bodyL.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s4),
          _buildPolicyItem(
            Icons.schedule,
            'Nhận phòng',
            'Từ 14:00',
          ),
          SizedBox(height: AppSpacing.s3),
          _buildPolicyItem(
            Icons.schedule,
            'Trả phòng',
            'Trước 12:00',
          ),
          SizedBox(height: AppSpacing.s3),
          _buildPolicyItem(
            Icons.cancel_outlined,
            'Hủy đặt phòng',
            'Miễn phí hủy trước 24h',
          ),
          SizedBox(height: AppSpacing.s3),
          _buildPolicyItem(
            Icons.pets_outlined,
            'Thú cưng',
            'Không cho phép',
          ),
        ],
      ),
    );
  }
  
  Widget _buildPolicyItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.neutral600),
        SizedBox(width: AppSpacing.s3),
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodyM.copyWith(
              color: AppColors.neutral700,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyM.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (room!.hasDiscount)
                    Text(
                      room!.formattedPrice,
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.neutral500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    room!.hasDiscount ? room!.formattedDiscountPrice : room!.formattedPrice,
                    style: AppTypography.bodyL.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '/đêm',
                    style: AppTypography.bodyXS.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 180.w,
              child: AppButton.primary(
                onPressed: room!.status == RoomStatus.available
                    ? () {
                        AppSnackbar.showInfo(message: 'Tính năng đặt phòng sẽ sớm được cập nhật');
                      }
                    : null,
                text: room!.status == RoomStatus.available
                    ? 'Đặt ngay'
                    : room!.statusDisplayName,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return AppColors.success;
      case RoomStatus.booked:
        return AppColors.warning;
      case RoomStatus.maintenance:
        return AppColors.neutral500;
      case RoomStatus.inactive:
        return AppColors.error;
    }
  }
}

// Extension to convert base64 to bytes
extension Base64Image on String {
  Uint8List toImageBytes() {
    if (startsWith('data:image')) {
      final base64String = split(',').last;
      return Uri.parse('data:image/png;base64,$base64String')
          .data!
          .contentAsBytes();
    }
    return Uri.parse('data:image/png;base64,$this')
        .data!
        .contentAsBytes();
  }
}