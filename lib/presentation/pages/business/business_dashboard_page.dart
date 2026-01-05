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
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:wanderlust/data/services/business_service.dart';
import 'package:wanderlust/data/services/listing_service.dart';

class BusinessDashboardPage extends StatefulWidget {
  const BusinessDashboardPage({super.key});

  @override
  State<BusinessDashboardPage> createState() => _BusinessDashboardPageState();
}

class _BusinessDashboardPageState extends State<BusinessDashboardPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BusinessService _businessService = Get.find<BusinessService>();
  final ListingService _listingService = Get.find<ListingService>();
  
  // Filter state
  final Rx<ListingType?> selectedFilter = Rx<ListingType?>(null);
  final RxString sortBy = 'newest'.obs; // newest, oldest, price_low, price_high
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Non-blocking async load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  Future<void> _loadData() async {
    // Load in parallel for better performance
    await Future.wait([
      _businessService.loadCurrentBusinessProfile(),
      _listingService.loadBusinessListings(),
    ]);
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
            icon: Icon(Icons.edit_outlined, color: AppColors.neutral700),
            onPressed: () async {
              final result = await Get.toNamed('/business-edit');
              if (result == true) {
                _loadData();
              }
            },
            tooltip: 'Chỉnh sửa thông tin',
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
                      'Hồ sơ đang chờ xác thực. Tải lên giấy tờ trong phần "Chỉnh sửa thông tin" để được xác thực.',
                      style: AppTypography.bodyS.copyWith(
                        color: Colors.orange[800],
                      ),
                    ),
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
                value: _listingService.businessListings.length.toString(),
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
                  onTap: () async {
                    final result = await Get.toNamed('/business-edit');
                    if (result == true) {
                      _loadData();
                    }
                  },
                ),
                // Migration helper (temporary - remove after migration)
                if (business.businessType == BusinessType.hotel) ...[
                  Divider(height: 24.h),
                  _buildActionItem(
                    icon: Icons.sync_alt,
                    title: 'Di chuyển dữ liệu phòng',
                    subtitle: 'Chuyển từ hệ thống cũ sang mới',
                    onTap: () async {
                      final confirm = await Get.dialog<bool>(
                        AlertDialog(
                          title: Text('Di chuyển dữ liệu'),
                          content: Text('Chuyển toàn bộ phòng từ hệ thống cũ sang hệ thống listing mới?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              child: Text('Di chuyển'),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirm == true) {
                        AppSnackbar.showInfo(message: 'Đang di chuyển dữ liệu...');
                        final success = await _listingService.migrateRoomsToListings();
                        if (success) {
                          AppSnackbar.showSuccess(message: 'Di chuyển dữ liệu thành công!');
                          _listingService.loadBusinessListings();
                        } else {
                          AppSnackbar.showError(message: 'Lỗi khi di chuyển dữ liệu');
                        }
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListingsTab(BusinessProfileModel business) {
    return Obx(() {
      if (_listingService.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      
      if (_listingService.businessListings.isEmpty) {
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
                  onPressed: () => Get.toNamed('/create-listing'),
                  text: 'Tạo listing đầu tiên',
                ),
              ),
            ],
          ),
        );
      }
      
      // Show listings with filters
      return RefreshIndicator(
        onRefresh: () async {
          await _listingService.loadBusinessListings();
        },
        child: Column(
          children: [
            // Filter chips
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s3),
              child: Column(
                children: [
                  // Type filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(() => Row(
                      children: [
                        _buildFilterChip('Tất cả', null),
                        SizedBox(width: AppSpacing.s2),
                        _buildFilterChip('Phòng', ListingType.room),
                        SizedBox(width: AppSpacing.s2),
                        _buildFilterChip('Tour', ListingType.tour),
                        SizedBox(width: AppSpacing.s2),
                        _buildFilterChip('Ẩm thực', ListingType.food),
                        SizedBox(width: AppSpacing.s2),
                        _buildFilterChip('Dịch vụ', ListingType.service),
                      ],
                    )),
                  ),
                  SizedBox(height: AppSpacing.s2),
                  // Sort dropdown
                  Row(
                    children: [
                      Text('Sắp xếp:', style: AppTypography.bodyS),
                      SizedBox(width: AppSpacing.s2),
                      Obx(() => DropdownButton<String>(
                        value: sortBy.value,
                        underline: SizedBox(),
                        style: AppTypography.bodyS.copyWith(color: AppColors.neutral700),
                        items: [
                          DropdownMenuItem(value: 'newest', child: Text('Mới nhất')),
                          DropdownMenuItem(value: 'oldest', child: Text('Cũ nhất')),
                          DropdownMenuItem(value: 'price_low', child: Text('Giá thấp → cao')),
                          DropdownMenuItem(value: 'price_high', child: Text('Giá cao → thấp')),
                        ],
                        onChanged: (value) {
                          sortBy.value = value!;
                        },
                      )),
                    ],
                  ),
                ],
              ),
            ),
            
            // Listings
            Expanded(
              child: Obx(() {
                // Apply filters and sorting
                var filteredListings = selectedFilter.value == null 
                    ? _listingService.businessListings.toList()
                    : _listingService.businessListings.where((l) => l.type == selectedFilter.value).toList();
                
                // Apply sorting
                switch (sortBy.value) {
                  case 'oldest':
                    filteredListings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                    break;
                  case 'price_low':
                    filteredListings.sort((a, b) => a.price.compareTo(b.price));
                    break;
                  case 'price_high':
                    filteredListings.sort((a, b) => b.price.compareTo(a.price));
                    break;
                  default: // newest
                    filteredListings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                }
                
                return ListView(
                  padding: EdgeInsets.all(AppSpacing.s5),
                  children: [
                    // Add new listing button
                    Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.s4),
                      child: AppButton.outline(
                        onPressed: () async {
                          final result = await Get.toNamed('/create-listing');
                          if (result == true) {
                            _listingService.loadBusinessListings();
                          }
                        },
                        text: 'Thêm listing mới',
                        icon: Icons.add,
                      ),
                    ),
                    
                    // Listing cards
                    if (filteredListings.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.s10),
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 60.sp, color: AppColors.neutral400),
                            SizedBox(height: AppSpacing.s3),
                            Text(
                              'Không có listing nào',
                              style: AppTypography.bodyM.copyWith(color: AppColors.neutral600),
                            ),
                          ],
                        ),
                      )
                    else
                      ...filteredListings.map((listing) => _buildListingCard(listing)),
                  ],
                );
              }),
            ),
          ],
        ),
      );
    });
  }
  
  Widget _buildFilterChip(String label, ListingType? type) {
    final isSelected = selectedFilter.value == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        selectedFilter.value = selected ? type : null;
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withOpacity(0.1),
      labelStyle: AppTypography.bodyS.copyWith(
        color: isSelected ? AppColors.primary : AppColors.neutral600,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.neutral300,
        ),
      ),
    );
  }
  
  Widget _buildListingCard(ListingModel listing) {
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
          if (listing.images.isNotEmpty)
            Container(
              height: 180.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                image: DecorationImage(
                  image: MemoryImage(_convertBase64ToBytes(listing.images.first)),
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
                        listing.title,
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
                        color: listing.isActive ? AppColors.success : AppColors.neutral500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        listing.isActive ? 'Hoạt động' : 'Tạm dẫng',
                        style: AppTypography.bodyXS.copyWith(
                          color: listing.isActive ? AppColors.success : AppColors.neutral500,
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
                    Text(_getListingIcon(listing.type), style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 4.w),
                    Text(
                      _getListingTypeLabel(listing.type),
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.s3),
                
                // Listing details
                _buildListingDetails(listing),
                
                SizedBox(height: AppSpacing.s3),
                
                // Price and actions
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (listing.hasDiscount)
                            Text(
                              listing.formattedPrice,
                              style: AppTypography.bodyS.copyWith(
                                color: AppColors.neutral500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            listing.hasDiscount ? listing.formattedDiscountPrice : listing.formattedPrice,
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
                        // Toggle active status
                        IconButton(
                          icon: Icon(
                            listing.isActive ? Icons.toggle_on : Icons.toggle_off_outlined,
                            color: listing.isActive ? AppColors.success : AppColors.neutral500,
                            size: 28.sp,
                          ),
                          onPressed: () async {
                            final newStatus = !listing.isActive;
                            final success = await _listingService.updateListing(
                              listing.id, 
                              {'isActive': newStatus}
                            );
                            if (success) {
                              AppSnackbar.showSuccess(
                                message: newStatus ? 'Đã kích hoạt' : 'Đã tạm dừng'
                              );
                              _listingService.loadBusinessListings();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: AppColors.neutral700),
                          onPressed: () async {
                            final result = await Get.toNamed('/create-listing', arguments: {
                              'isEdit': true,
                              'listingId': listing.id,
                            });
                            if (result == true) {
                              _listingService.loadBusinessListings();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => _showDeleteListingDialog(listing),
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
  
  String _getListingIcon(ListingType type) {
    switch (type) {
      case ListingType.room:
        return '🏨';
      case ListingType.tour:
        return '✈️';
      case ListingType.food:
        return '🍴';
      case ListingType.service:
        return '🛠️';
    }
  }
  
  String _getListingTypeLabel(ListingType type) {
    switch (type) {
      case ListingType.room:
        return 'Phòng';
      case ListingType.tour:
        return 'Tour du lịch';
      case ListingType.food:
        return 'Ẩm thực';
      case ListingType.service:
        return 'Dịch vụ';
    }
  }
  
  Widget _buildListingDetails(ListingModel listing) {
    switch (listing.type) {
      case ListingType.room:
        return Row(
          children: [
            _buildRoomDetail(Icons.people, '${listing.details['maxGuests'] ?? 0} khách'),
            SizedBox(width: AppSpacing.s4),
            _buildRoomDetail(Icons.bed, '${listing.details['numberOfBeds'] ?? 0} giường'),
            SizedBox(width: AppSpacing.s4),
            _buildRoomDetail(Icons.square_foot, '${listing.details['roomSize'] ?? 0}m²'),
          ],
        );
      case ListingType.tour:
        return Row(
          children: [
            _buildRoomDetail(Icons.timer, '${listing.details['duration'] ?? 0} giờ'),
            SizedBox(width: AppSpacing.s4),
            _buildRoomDetail(Icons.people, '${listing.details['groupSize'] ?? 0} người'),
          ],
        );
      case ListingType.food:
        return Row(
          children: [
            _buildRoomDetail(Icons.restaurant_menu, listing.details['category'] ?? 'Khác'),
            SizedBox(width: AppSpacing.s4),
            _buildRoomDetail(Icons.people, '${listing.details['servingSize'] ?? 0} người'),
          ],
        );
      case ListingType.service:
        return Row(
          children: [
            _buildRoomDetail(Icons.timer, '${listing.details['duration'] ?? 0} giờ'),
            SizedBox(width: AppSpacing.s4),
            _buildRoomDetail(Icons.location_on, listing.details['location'] ?? 'Tại chỗ'),
          ],
        );
    }
  }
  
  void _showDeleteListingDialog(ListingModel listing) {
    Get.dialog(
      AlertDialog(
        title: Text('Xóa listing'),
        content: Text('Bạn có chắc chắn muốn xóa "${listing.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await _listingService.deleteListing(listing.id);
              if (success) {
                AppSnackbar.showSuccess(message: 'Đã xóa listing');
              } else {
                AppSnackbar.showError(message: 'Không thể xóa listing');
              }
            },
            child: Text('Xóa', style: TextStyle(color: AppColors.error)),
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
  
  void _navigateToCreateListing(BusinessType type) async {
    // Map business type to default listing type
    ListingType defaultListingType;
    switch (type) {
      case BusinessType.hotel:
        defaultListingType = ListingType.room;
        break;
      case BusinessType.tour:
        defaultListingType = ListingType.tour;
        break;
      case BusinessType.restaurant:
        defaultListingType = ListingType.food;
        break;
      case BusinessType.service:
        defaultListingType = ListingType.service;
        break;
    }

    // Navigate to unified create listing page with default type
    final result = await Get.toNamed('/create-listing', arguments: {
      'type': defaultListingType,
      'isEdit': false,
    });

    // Reload listings if created successfully
    if (result == true) {
      _listingService.loadBusinessListings();
    }
  }
  
  Uint8List _convertBase64ToBytes(String base64String) {
    if (base64String.startsWith('data:image')) {
      base64String = base64String.split(',').last;
    }
    return base64Decode(base64String);
  }
}