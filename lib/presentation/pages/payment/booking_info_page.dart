import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/payment/booking_info_controller.dart';

class BookingInfoPage extends GetView<BookingInfoController> {
  const BookingInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => BookingInfoController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: AppColors.primary,
            size: 32.sp,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Thông tin đặt phòng',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Room info card with gradient
                _buildRoomInfoCard(),
                
                // Room details grid
                _buildRoomDetailsGrid(),
                
                // Check-in/out times
                _buildCheckInOutSection(),
                
                // Cancellation policy
                _buildCancellationPolicy(),
                
                // Guest info
                _buildGuestInfoSection(),
                
                // Contact info
                _buildContactInfoSection(),
                
                // Payment method
                _buildPaymentMethodSection(),
                
                // Price details
                _buildPriceDetailsSection(),
                
                // Bottom spacing
                SizedBox(height: 120.h),
              ],
            ),
          ),
          
          // Bottom payment bar
          _buildBottomPaymentBar(),
        ],
      ),
    );
  }
  
  Widget _buildRoomInfoCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFB794F4),
            AppColors.primary,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Hotel icon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.apartment,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          
          // Room info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Homestay Sơn Thủy',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phòng đơn homestay',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      'x 1',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '25.0m2',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRoomDetailsGrid() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Số đêm
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.dark_mode_outlined,
                  size: 20.sp,
                  color: const Color(0xFF6B7280),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Số đêm',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '1 đêm',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
          
          // Khách
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20.sp,
                  color: const Color(0xFF6B7280),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Khách',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '1 người',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
          
          // Loại giường
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.bed_outlined,
                  size: 20.sp,
                  color: const Color(0xFF6B7280),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Loại giường',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '1 giường đơn',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCheckInOutSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Check-in
          Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                size: 18.sp,
                color: const Color(0xFF6B7280),
              ),
              SizedBox(width: 8.w),
              Text(
                'Nhận phòng',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Thứ Hai, 1/1/2025 (15:00 - 03:00)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Check-out
          Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                size: 18.sp,
                color: const Color(0xFF6B7280),
              ),
              SizedBox(width: 8.w),
              Text(
                'Trả phòng',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Thứ Ba, 2/1/2025 (trước 11:00)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Free cancellation
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 18.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Miễn phí hủy phòng',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          // Policy
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 18.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Áp dụng chính sách đổi lịch',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCancellationPolicy() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chính sách khách sạn và phòng',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Áp dụng chính sách hủy phòng',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Miễn phí hủy trước 6-thg 12-2024 14:00. Nếu hủy hoặc sửa đổi sau 6-thg 12-2022 14:01, phí hủy đặt phòng sẽ được tính.',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGuestInfoSection() {
    return GestureDetector(
      onTap: () => controller.editGuestInfo(),
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            // Header with arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thông tin khách',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 24.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          SizedBox(height: 12.h),
          
          // Guest name
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 18.sp,
                color: const Color(0xFF6B7280),
              ),
              SizedBox(width: 8.w),
              Text(
                'Tên khách',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Obx(() => Padding(
            padding: EdgeInsets.only(left: 26.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                controller.bookingData['guestName'] ?? 'NGUYEN THUY TRANG',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
          )),
        ],
      ),
      ),
    );
  }
  
  Widget _buildContactInfoSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin liên hệ',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12.h),
          
          // Họ tên
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Họ tên',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Obx(() => Text(
                controller.bookingData['userName'] ?? 'User name',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              )),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Số điện thoại
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số điện thoại',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Obx(() => Text(
                controller.bookingData['phone'] ?? '012345678',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              )),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Obx(() => Text(
                controller.bookingData['email'] ?? 'thuytrang@gmail.com',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentMethodSection() {
    return GestureDetector(
      onTap: () => controller.selectPaymentMethod(),
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            // Header with arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phương thức thanh toán',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 24.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          SizedBox(height: 12.h),
          
          // Payment method
          Row(
            children: [
              Container(
                width: 40.w,
                height: 25.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEB001B),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 12.w,
                        height: 12.w,
                        margin: EdgeInsets.only(left: 2.w),
                        decoration: BoxDecoration(
                          color: Colors.yellow.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Obx(() => Text(
                controller.bookingData['paymentMethod'] ?? 'VIB ••6969',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              )),
            ],
          ),
        ],
      ),
      ),
    );
  }
  
  Widget _buildPriceDetailsSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết giá',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12.h),
          
          // Price item
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas id sit eu tellus sed cursus eleifend id porta',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              Text(
                '480.000 VND',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Tax
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thuế và phí',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Text(
                '0 VND',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          Divider(color: const Color(0xFFE5E7EB)),
          SizedBox(height: 12.h),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                '480.000 VND',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomPaymentBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng giá tiền',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '480.000 VND',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.info_outline,
                        size: 16.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Đã bao gồm thuế',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              
              SizedBox(height: 12.h),
              
              // Payment button
              GestureDetector(
                onTap: controller.processPayment,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFB794F4),
                        AppColors.primary,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Thanh toán',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}