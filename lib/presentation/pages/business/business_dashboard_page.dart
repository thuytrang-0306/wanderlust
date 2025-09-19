import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/models/business_profile_model.dart';
import 'package:wanderlust/data/models/room_model.dart';
import 'package:wanderlust/data/services/business_service.dart';
import 'package:wanderlust/data/services/room_service.dart';

class BusinessDashboardPage extends StatefulWidget {
  const BusinessDashboardPage({super.key});

  @override
  State<BusinessDashboardPage> createState() => _BusinessDashboardPageState();
}

class _BusinessDashboardPageState extends State<BusinessDashboardPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BusinessService _businessService = Get.find<BusinessService>();
  final RoomService _roomService = Get.find<RoomService>();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _businessService.loadCurrentBusinessProfile();
    _roomService.loadBusinessRooms();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.neutral800),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Business Dashboard',
          style: AppTypography.h4.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.neutral700),
            onPressed: () {
              // TODO: Implement business settings page
              AppSnackbar.showInfo(message: 'Cài đặt doanh nghiệp sẽ sớm được cập nhật');
            },
          ),
        ],
      ),
      body: Obx(() {
        final businessProfile = _businessService.currentBusinessProfile.value;
        
        if (businessProfile == null) {
          return _buildNoBusinessProfile();
        }
        
        return Column(
          children: [
            // Business Profile Header
            _buildBusinessHeader(businessProfile),
            
            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.neutral600,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'Tổng quan'),
                  Tab(text: 'Listings'),
                  Tab(text: 'Đánh giá'),
                  Tab(text: 'Thống kê'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(businessProfile),
                  _buildListingsTab(businessProfile),
                  _buildReviewsTab(businessProfile),
                  _buildAnalyticsTab(businessProfile),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
  
  Widget _buildNoBusinessProfile() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 80.sp,
              color: AppColors.neutral400,
            ),
            SizedBox(height: AppSpacing.s4),
            Text(
              'Chưa có hồ sơ doanh nghiệp',
              style: AppTypography.h3.copyWith(
                color: AppColors.neutral700,
              ),
            ),
            SizedBox(height: AppSpacing.s2),
            Text(
              'Tạo hồ sơ doanh nghiệp để bắt đầu',
              style: AppTypography.bodyM.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.s6),
            SizedBox(
              width: 200.w,
              child: AppButton.primary(
                onPressed: () => Get.offNamed('/business-registration'),
                text: 'Tạo hồ sơ ngay',
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBusinessHeader(BusinessProfileModel business) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(AppSpacing.s5),
      child: Column(
        children: [
          Row(
            children: [
              // Business Type Icon
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    business.typeIcon,
                    style: TextStyle(fontSize: 32.sp),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s4),
              
              // Business Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            business.businessName,
                            style: AppTypography.bodyL.copyWith(
                              color: AppColors.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (business.isVerified)
                          Container(
                            margin: EdgeInsets.only(left: AppSpacing.s2),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.s2,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: AppColors.success,
                                  size: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Đã xác thực',
                                  style: AppTypography.bodyXS.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      business.typeDisplayName,
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.warning, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          business.formattedRating,
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.neutral700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${business.totalReviews} đánh giá)',
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Verification Status
          if (!business.isVerified)
            Container(
              margin: EdgeInsets.only(top: AppSpacing.s4),
              padding: EdgeInsets.all(AppSpacing.s3),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20.sp),
                  SizedBox(width: AppSpacing.s2),
                  Expanded(
                    child: Text(
                      'Hồ sơ đang chờ xác thực. Tải lên giấy tờ để được xác thực.',
                      style: AppTypography.bodyS.copyWith(
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement business verification page
                      AppSnackbar.showInfo(message: 'Tính năng xác thực sẽ sớm được cập nhật');
                    },
                    child: Text('Xác thực'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildOverviewTab(BusinessProfileModel business) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s5),
      child: Column(
        children: [
          // Quick Stats
          Row(
            children: [
              Obx(() => _buildStatCard(
                icon: Icons.list_alt,
                label: 'Listings',
                value: _roomService.businessRooms.length.toString(),
                color: Colors.blue,
              )),
              SizedBox(width: AppSpacing.s3),
              _buildStatCard(
                icon: Icons.star,
                label: 'Rating',
                value: business.formattedRating,
                color: Colors.orange,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.rate_review,
                label: 'Reviews',
                value: business.totalReviews.toString(),
                color: Colors.green,
              ),
              SizedBox(width: AppSpacing.s3),
              _buildStatCard(
                icon: Icons.visibility,
                label: 'Views',
                value: '0', // Will be dynamic
                color: Colors.purple,
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.s5),
          
          // Quick Actions
          Container(
            padding: EdgeInsets.all(AppSpacing.s4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hành động nhanh',
                  style: AppTypography.bodyL.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                SizedBox(height: AppSpacing.s4),
                _buildActionItem(
                  icon: Icons.add_business,
                  title: 'Thêm listing mới',
                  subtitle: _getListingTypeText(business.businessType),
                  onTap: () => _navigateToCreateListing(business.businessType),
                ),
                Divider(height: 24.h),
                _buildActionItem(
                  icon: Icons.edit,
                  title: 'Chỉnh sửa thông tin',
                  subtitle: 'Cập nhật thông tin doanh nghiệp',
                  onTap: () {
                    // TODO: Implement business edit page
                    AppSnackbar.showInfo(message: 'Tính năng chỉnh sửa sẽ sớm được cập nhật');
                  },
                ),
                Divider(height: 24.h),
                _buildActionItem(
                  icon: Icons.campaign,
                  title: 'Tạo khuyến mãi',
                  subtitle: 'Thu hút khách hàng mới',
                  onTap: () {
                    // TODO: Implement promotion page
                    AppSnackbar.showInfo(message: 'Tính năng khuyến mãi sẽ sớm được cập nhật');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListingsTab(BusinessProfileModel business) {
    return Obx(() {
      if (_roomService.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      
      if (_roomService.businessRooms.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80.sp,
                color: AppColors.neutral400,
              ),
              SizedBox(height: AppSpacing.s4),
              Text(
                'Chưa có listing nào',
                style: AppTypography.bodyL.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
              SizedBox(height: AppSpacing.s2),
              Text(
                _getListingEmptyText(business.businessType),
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.s5),
              SizedBox(
                width: 200.w,
                child: AppButton.primary(
                  onPressed: () => _navigateToCreateListing(business.businessType),
                  text: 'Tạo listing đầu tiên',
                ),
              ),
            ],
          ),
        );
      }
      
      // Show room listings
      return RefreshIndicator(
        onRefresh: () async {
          await _roomService.loadBusinessRooms();
        },
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.s5),
          children: [
            // Add new room button
            Container(
              margin: EdgeInsets.only(bottom: AppSpacing.s4),
              child: AppButton.outline(
                onPressed: () async {
                  final result = await Get.toNamed('/create-room-listing');
                  if (result == true) {
                    _roomService.loadBusinessRooms();
                  }
                },
                text: 'Thêm phòng mới',
                icon: Icons.add,
              ),
            ),
            
            // Room list
            ..._roomService.businessRooms.map((room) => _buildRoomCard(room)).toList(),
          ],
        ),
      );
    });
  }
  
  Widget _buildRoomCard(RoomModel room) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.s3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room image
          if (room.images.isNotEmpty)
            Container(
              height: 180.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                image: DecorationImage(
                  image: MemoryImage(_convertBase64ToBytes(room.images.first)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // Room info
          Padding(
            padding: EdgeInsets.all(AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room name and type
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.roomName,
                        style: AppTypography.bodyL.copyWith(
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s2,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(room.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        room.statusDisplayName,
                        style: AppTypography.bodyXS.copyWith(
                          color: _getStatusColor(room.status),
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
                    Text(room.typeIcon, style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 4.w),
                    Text(
                      room.typeDisplayName,
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.s3),
                
                // Room details
                Row(
                  children: [
                    _buildRoomDetail(Icons.people, '${room.maxGuests} khách'),
                    SizedBox(width: AppSpacing.s4),
                    _buildRoomDetail(Icons.bed, '${room.numberOfBeds} giường'),
                    SizedBox(width: AppSpacing.s4),
                    _buildRoomDetail(Icons.square_foot, '${room.roomSize}m²'),
                  ],
                ),
                
                SizedBox(height: AppSpacing.s3),
                
                // Price and actions
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (room.hasDiscount)
                            Text(
                              room.formattedPrice,
                              style: AppTypography.bodyS.copyWith(
                                color: AppColors.neutral500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            room.hasDiscount ? room.formattedDiscountPrice : room.formattedPrice,
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
                    // Action buttons
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility_outlined, color: AppColors.neutral700),
                          onPressed: () {
                            Get.toNamed('/room-detail', arguments: room.id);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: AppColors.neutral700),
                          onPressed: () async {
                            final result = await Get.toNamed('/edit-room-listing', arguments: room.id);
                            if (result == true) {
                              _roomService.loadBusinessRooms();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => _showDeleteRoomDialog(room),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRoomDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.neutral500),
        SizedBox(width: 4.w),
        Text(
          text,
          style: AppTypography.bodyXS.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ],
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
  
  void _showDeleteRoomDialog(RoomModel room) {
    Get.dialog(
      AlertDialog(
        title: Text('Xóa phòng'),
        content: Text('Bạn có chắc chắn muốn xóa phòng "${room.roomName}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await _roomService.deleteRoom(room.id);
              if (success) {
                AppSnackbar.showSuccess(message: 'Đã xóa phòng');
              } else {
                AppSnackbar.showError(message: 'Không thể xóa phòng');
              }
            },
            child: Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewsTab(BusinessProfileModel business) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 80.sp,
            color: AppColors.neutral400,
          ),
          SizedBox(height: AppSpacing.s4),
          Text(
            'Chưa có đánh giá',
            style: AppTypography.bodyL.copyWith(
              color: AppColors.neutral700,
            ),
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Đánh giá sẽ xuất hiện ở đây',
            style: AppTypography.bodyM.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticsTab(BusinessProfileModel business) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê tháng này',
            style: AppTypography.bodyL.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          SizedBox(height: AppSpacing.s4),
          
          Container(
            padding: EdgeInsets.all(AppSpacing.s4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                _buildAnalyticRow('Lượt xem', '0', Icons.visibility),
                Divider(height: 24.h),
                _buildAnalyticRow('Lượt thích', '0', Icons.favorite),
                Divider(height: 24.h),
                _buildAnalyticRow('Booking', '0', Icons.calendar_today),
                Divider(height: 24.h),
                _buildAnalyticRow('Doanh thu', '0 VNĐ', Icons.attach_money),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32.sp),
            SizedBox(height: AppSpacing.s2),
            Text(
              value,
              style: AppTypography.h3.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: AppTypography.bodyS.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppColors.neutral400, size: 16.sp),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neutral600, size: 20.sp),
        SizedBox(width: AppSpacing.s3),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyM.copyWith(
              color: AppColors.neutral700,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyM.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  String _getListingTypeText(BusinessType type) {
    switch (type) {
      case BusinessType.hotel:
        return 'Thêm phòng, suite, villa';
      case BusinessType.tour:
        return 'Thêm tour du lịch';
      case BusinessType.restaurant:
        return 'Thêm menu, món ăn';
      case BusinessType.service:
        return 'Thêm dịch vụ';
    }
  }
  
  String _getListingEmptyText(BusinessType type) {
    switch (type) {
      case BusinessType.hotel:
        return 'Thêm phòng để khách có thể đặt';
      case BusinessType.tour:
        return 'Tạo tour để thu hút khách hàng';
      case BusinessType.restaurant:
        return 'Thêm menu để khách xem';
      case BusinessType.service:
        return 'Liệt kê các dịch vụ của bạn';
    }
  }
  
  void _navigateToCreateListing(BusinessType type) {
    // Navigate to listing pages based on business type
    switch (type) {
      case BusinessType.hotel:
        Get.toNamed('/create-room-listing');
        break;
      case BusinessType.tour:
        AppSnackbar.showInfo(message: 'Tính năng thêm tour sẽ sớm được cập nhật');
        break;
      case BusinessType.restaurant:
        AppSnackbar.showInfo(message: 'Tính năng thêm menu sẽ sớm được cập nhật');
        break;
      case BusinessType.service:
        AppSnackbar.showInfo(message: 'Tính năng thêm dịch vụ sẽ sớm được cập nhật');
        break;
    }
  }
  
  Uint8List _convertBase64ToBytes(String base64String) {
    if (base64String.startsWith('data:image')) {
      base64String = base64String.split(',').last;
    }
    return base64Decode(base64String);
  }
}