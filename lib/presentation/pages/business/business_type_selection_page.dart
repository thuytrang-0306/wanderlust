import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/data/models/business_profile_model.dart';

class BusinessTypeSelectionPage extends StatelessWidget {
  const BusinessTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.neutral800),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Chọn loại hình kinh doanh',
          style: AppTypography.h4.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(AppSpacing.s4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                    SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: Text(
                        'Chọn loại hình phù hợp với doanh nghiệp của bạn',
                        style: AppTypography.bodyM.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSpacing.s6),
              
              // Business Type Options
              Expanded(
                child: ListView(
                  children: [
                    _buildBusinessTypeCard(
                      type: BusinessType.hotel,
                      icon: Icons.hotel,
                      title: BusinessType.hotel.displayName,
                      description: 'Khách sạn, homestay, resort, nhà nghỉ',
                      features: [
                        'Quản lý phòng và giá',
                        'Nhận đặt phòng trực tuyến',
                        'Quản lý khách hàng',
                        'Thống kê doanh thu',
                      ],
                      color: Colors.blue,
                    ),
                    
                    SizedBox(height: AppSpacing.s4),
                    
                    _buildBusinessTypeCard(
                      type: BusinessType.tour,
                      icon: Icons.flight,
                      title: BusinessType.tour.displayName,
                      description: 'Công ty du lịch, tour guide, travel agency',
                      features: [
                        'Tạo và quản lý tour',
                        'Lịch trình chi tiết',
                        'Nhận booking online',
                        'Quản lý đoàn khách',
                      ],
                      color: Colors.orange,
                    ),
                    
                    SizedBox(height: AppSpacing.s4),
                    
                    _buildBusinessTypeCard(
                      type: BusinessType.restaurant,
                      icon: Icons.restaurant,
                      title: BusinessType.restaurant.displayName,
                      description: 'Nhà hàng, quán ăn, coffee, bar',
                      features: [
                        'Menu và giá cả',
                        'Nhận đặt bàn',
                        'Giờ hoạt động',
                        'Khuyến mãi đặc biệt',
                      ],
                      color: Colors.green,
                    ),
                    
                    SizedBox(height: AppSpacing.s4),
                    
                    _buildBusinessTypeCard(
                      type: BusinessType.service,
                      icon: Icons.local_taxi,
                      title: BusinessType.service.displayName,
                      description: 'Taxi, xe thuê, spa, dịch vụ khác',
                      features: [
                        'Danh sách dịch vụ',
                        'Báo giá online',
                        'Lịch booking',
                        'Đánh giá từ khách',
                      ],
                      color: Colors.purple,
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
  
  Widget _buildBusinessTypeCard({
    required BusinessType type,
    required IconData icon,
    required String title,
    required String description,
    required List<String> features,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        // Navigate to business info form with selected type
        Get.toNamed('/business-info-form', arguments: {'businessType': type});
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.s5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.neutral200,
            width: 1,
          ),
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
            // Header
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.s4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyL.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        description,
                        style: AppTypography.bodyS.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.neutral400,
                  size: 20.sp,
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.s4),
            
            // Features
            Wrap(
              spacing: AppSpacing.s2,
              runSpacing: AppSpacing.s2,
              children: features.map((feature) => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s3,
                  vertical: AppSpacing.s1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  feature,
                  style: AppTypography.bodyXS.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}