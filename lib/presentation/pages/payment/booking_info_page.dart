import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
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
          icon: Icon(Icons.chevron_left, color: AppColors.primary, size: 32.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          controller.pageTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Room info card with gradient
                    _buildRoomInfoCard(),

                    // Room details grid - only for Room type
                    if (controller.isRoom) _buildRoomDetailsGrid(),

                    // Check-in/out times
                    _buildCheckInOutSection(),

                    // Cancellation policy
                    _buildCancellationPolicy(),

                    // Type-specific details
                    if (controller.isTour) _buildTourBookingDetails(),
                    if (controller.isFood) _buildFoodBookingDetails(),
                    if (controller.isService) _buildServiceBookingDetails(),

                    // Guest info
                    _buildGuestInfoSection(),

                    // Contact info
                    _buildContactInfoSection(),

                    // Payment method
                    _buildPaymentMethodSection(),

                    // Price details
                    _buildPriceDetailsSection(),

                    // Small bottom padding for last item
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

            // Bottom payment bar (not overlapping)
            _buildBottomPaymentBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomInfoCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFB794F4), AppColors.primary],
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
            child: Icon(Icons.apartment, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 12.w),

          // Room info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  controller.bookingData['accommodationName'] ?? '',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      controller.bookingData['roomType'] ?? '',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.9)),
                    )),
                    Obx(() => Text(
                      'x ${controller.bookingData['roomCount'] ?? 1}',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.9)),
                    )),
                  ],
                ),
                SizedBox(height: 4.h),
                Obx(() => Text(
                  controller.bookingData['roomSize'] ?? '',
                  style: TextStyle(fontSize: 13.sp, color: Colors.white.withOpacity(0.8)),
                )),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          // Số đêm
          Expanded(
            child: Column(
              children: [
                Icon(Icons.dark_mode_outlined, size: 20.sp, color: const Color(0xFF6B7280)),
                SizedBox(height: 4.h),
                Text('Số đêm', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF))),
                SizedBox(height: 2.h),
                Obx(() => Text(
                  '${controller.bookingData['nights'] ?? 1} đêm',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                )),
              ],
            ),
          ),

          // Khách
          Expanded(
            child: Column(
              children: [
                Icon(Icons.person_outline, size: 20.sp, color: const Color(0xFF6B7280)),
                SizedBox(height: 4.h),
                Text('Khách', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF))),
                SizedBox(height: 2.h),
                Obx(() => Text(
                  '${controller.bookingData['guests'] ?? 1} người',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                )),
              ],
            ),
          ),

          // Loại giường
          Expanded(
            child: Column(
              children: [
                Icon(Icons.bed_outlined, size: 20.sp, color: const Color(0xFF6B7280)),
                SizedBox(height: 4.h),
                Text(
                  'Loại giường',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                ),
                SizedBox(height: 2.h),
                Obx(() => Text(
                  controller.bookingData['bedType'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                )),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        children: [
          // Check-in
          Row(
            children: [
              Icon(Icons.access_time_outlined, size: 18.sp, color: const Color(0xFF6B7280)),
              SizedBox(width: 8.w),
              Text(
                controller.isTour ? 'Ngày khởi hành' :
                controller.isFood ? 'Thời gian giao' :
                controller.isService ? 'Ngày hẹn' : 'Nhận phòng',
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Obx(() => Text(
            controller.bookingData['checkIn'] ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          )),

          // Only show check-out for rooms
          if (controller.isRoom) ...[
            SizedBox(height: 16.h),

            // Check-out
            Row(
              children: [
                Icon(Icons.access_time_outlined, size: 18.sp, color: const Color(0xFF6B7280)),
                SizedBox(width: 8.w),
                Text('Trả phòng', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280))),
              ],
            ),
            SizedBox(height: 4.h),
            Obx(() => Text(
              controller.bookingData['checkOut'] ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            )),
            SizedBox(height: 16.h),
          ],

          // Free cancellation
          Row(
            children: [
              Icon(Icons.check_circle, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                controller.isTour ? 'Chính sách hủy tour' :
                controller.isFood ? 'Chính sách hủy đơn' :
                controller.isService ? 'Chính sách hủy dịch vụ' :
                'Miễn phí hủy phòng',
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF374151)),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Policy
          Row(
            children: [
              Icon(Icons.check_circle, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'Áp dụng chính sách đổi lịch',
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF374151)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chính sách hủy đặt chỗ',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 8.h),
          Builder(builder: (context) {
            // Calculate default policy based on type (static, no reactivity needed)
            String defaultPolicy = 'Miễn phí hủy phòng trước 24 giờ. Sau thời gian này sẽ tính phí hủy 50% giá trị đặt phòng.';
            if (controller.isTour) {
              defaultPolicy = 'Miễn phí hủy tour trước 48 giờ. Sau thời gian này sẽ tính phí hủy 70% giá trị tour.';
            } else if (controller.isFood) {
              defaultPolicy = 'Miễn phí hủy đơn trước 2 giờ. Sau thời gian này sẽ tính phí hủy 30% giá trị đơn hàng.';
            } else if (controller.isService) {
              defaultPolicy = 'Miễn phí hủy dịch vụ trước 12 giờ. Sau thời gian này sẽ tính phí hủy 50% giá trị dịch vụ.';
            }

            // Only wrap observable access with Obx
            return Obx(() => Text(
              controller.bookingData['cancellationPolicy'] ?? defaultPolicy,
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280), height: 1.4),
            ));
          }),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
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
                Icon(Icons.chevron_right, size: 24.sp, color: const Color(0xFF9CA3AF)),
              ],
            ),
            SizedBox(height: 12.h),

            // Guest name
            Row(
              children: [
                Icon(Icons.person_outline, size: 18.sp, color: const Color(0xFF6B7280)),
                SizedBox(width: 8.w),
                Text(
                  'Tên khách',
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Obx(
              () => Padding(
                padding: EdgeInsets.only(left: 26.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    controller.bookingData['guestName'] ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
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
              Text('Họ tên', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280))),
              Obx(
                () => Text(
                  controller.bookingData['userName'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Số điện thoại
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số điện thoại',
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
              ),
              Obx(
                () => Text(
                  controller.bookingData['phone'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Email', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280))),
              Obx(
                () => Text(
                  controller.bookingData['email'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
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
                Icon(Icons.chevron_right, size: 24.sp, color: const Color(0xFF9CA3AF)),
              ],
            ),
            SizedBox(height: 12.h),

            // Payment method
            Obx(() {
              final paymentIcon = controller.bookingData['paymentMethodIcon'] ?? 'qr_code';
              final paymentDisplay = controller.bookingData['paymentMethodDisplay'] ?? 'PayOS - QR Ngân hàng';

              return Row(
                children: [
                  // Payment icon based on method
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      paymentIcon == 'qr_code' ? Icons.qr_code_scanner : Icons.account_balance_wallet,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paymentDisplay,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Nhấn để thay đổi',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetailsSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
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

          // Price breakdown
          Obx(() {
            final breakdown = controller.bookingData['priceBreakdown'] ?? '';
            if (breakdown.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    breakdown,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${NumberFormat('#,###').format(controller.bookingData['price'] ?? 0)} VND',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  Text(
                    'Đang cập nhật thông tin chi tiết về điều kiện đặt phòng và chính sách hủy',
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(),
                      Text(
                        '${NumberFormat('#,###').format(controller.bookingData['price'] ?? 0)} VND',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          }),

          SizedBox(height: 12.h),

          // Tax
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thuế và phí',
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
              ),
              Obx(() => Text(
                '${NumberFormat('#,###').format(controller.bookingData['tax'] ?? 0)} VND',
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF374151)),
              )),
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
              Obx(() => Text(
                '${NumberFormat('#,###').format(controller.bookingData['total'] ?? 0)} VND',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPaymentBar() {
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng giá tiền',
                style: TextStyle(fontSize: 15.sp, color: const Color(0xFF6B7280)),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(() => Text(
                    '${NumberFormat('#,###').format(controller.bookingData['total'] ?? 0)} VND',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  )),
                  SizedBox(width: 4.w),
                  Icon(Icons.info_outline, size: 16.sp, color: const Color(0xFF9CA3AF)),
                ],
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Đã bao gồm thuế',
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
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
                  colors: [const Color(0xFFB794F4), AppColors.primary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, color: Colors.white, size: 20.sp),
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
    );
  }

  // ========== TYPE-SPECIFIC BOOKING DETAIL SECTIONS ==========

  /// Tour booking details: duration, departure, included services
  Widget _buildTourBookingDetails() {
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
            'Chi tiết tour',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12.h),

          // Duration
          if (controller.bookingData['duration'] != null) ...[
            _buildDetailRow(
              icon: Icons.schedule,
              label: 'Thời lượng',
              value: controller.bookingData['duration'],
            ),
            SizedBox(height: 8.h),
          ],

          // Departure point
          if (controller.bookingData['departure'] != null) ...[
            _buildDetailRow(
              icon: Icons.location_on,
              label: 'Điểm khởi hành',
              value: controller.bookingData['departure'],
            ),
            SizedBox(height: 8.h),
          ],

          // Included services
          Row(
            children: [
              Icon(Icons.check_circle_outline, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Bao gồm: Xe đưa đón, Hướng dẫn viên, Bữa ăn',
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Food booking details: category, serving, dietary info
  Widget _buildFoodBookingDetails() {
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
            'Thông tin món ăn',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12.h),

          // Category
          if (controller.bookingData['category'] != null) ...[
            _buildDetailRow(
              icon: Icons.category,
              label: 'Loại món',
              value: controller.bookingData['category'],
            ),
            SizedBox(height: 8.h),
          ],

          // Serving size
          if (controller.bookingData['serving'] != null) ...[
            _buildDetailRow(
              icon: Icons.people,
              label: 'Khẩu phần',
              value: controller.bookingData['serving'],
            ),
            SizedBox(height: 8.h),
          ],

          // Dietary info
          Row(
            children: [
              if (controller.bookingData['isVegetarian'] == true) ...[
                Icon(Icons.eco, size: 16.sp, color: Colors.green),
                SizedBox(width: 4.w),
                Text('Chay', style: TextStyle(fontSize: 12.sp, color: Colors.green)),
                SizedBox(width: 12.w),
              ],
              if (controller.bookingData['isSpicy'] == true) ...[
                Icon(Icons.whatshot, size: 16.sp, color: Colors.orange),
                SizedBox(width: 4.w),
                Text('Cay', style: TextStyle(fontSize: 12.sp, color: Colors.orange)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Service booking details: duration, location
  Widget _buildServiceBookingDetails() {
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
            'Thông tin dịch vụ',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12.h),

          // Duration
          if (controller.bookingData['duration'] != null) ...[
            _buildDetailRow(
              icon: Icons.schedule,
              label: 'Thời lượng',
              value: controller.bookingData['duration'],
            ),
            SizedBox(height: 8.h),
          ],

          // Location
          if (controller.bookingData['location'] != null) ...[
            _buildDetailRow(
              icon: Icons.place,
              label: 'Địa điểm',
              value: controller.bookingData['location'],
            ),
          ],
        ],
      ),
    );
  }

  // Helper widget for detail rows
  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: const Color(0xFF6B7280)),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151)),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
