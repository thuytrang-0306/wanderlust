import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/booking/booking_history_controller.dart';

class BookingHistoryPage extends GetView<BookingHistoryController> {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Lịch sử đặt phòng', style: AppTypography.heading5),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildBookingList(controller.upcomingBookings),
                _buildBookingList(controller.completedBookings),
                _buildBookingList(controller.cancelledBookings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller.tabController,
        tabs: [
          Obx(
            () => Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sắp tới'),
                  if (controller.upcomingBookings.isNotEmpty) ...[
                    SizedBox(width: AppSpacing.s1),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        controller.upcomingBookings.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Tab(text: 'Hoàn thành'),
          const Tab(text: 'Đã hủy'),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.bodyMedium,
      ),
    );
  }

  Widget _buildBookingList(RxList<Map<String, dynamic>> bookings) {
    return Obx(() {
      if (controller.isLoadingBookings.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (bookings.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppSpacing.s5),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(bookings[index]);
        },
      );
    });
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final statusColor =
        booking['status'] == 'upcoming'
            ? AppColors.success
            : booking['status'] == 'completed'
            ? AppColors.neutral500
            : AppColors.error;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.navigateToBookingDetail(booking),
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            // Header with booking code and status
            Container(
              padding: EdgeInsets.all(AppSpacing.s4),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã đặt phòng',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: AppSpacing.s1),
                      Text(
                        booking['bookingCode'],
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s3,
                      vertical: AppSpacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      booking['statusText'],
                      style: AppTypography.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Booking details
            Padding(
              padding: EdgeInsets.all(AppSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel/Tour name
                  Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: AppColors.neutral200,
                        ),
                        child: Icon(
                          booking['type'] == 'hotel' ? Icons.hotel : Icons.tour,
                          color: AppColors.primary,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: AppSpacing.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['name'],
                              style: AppTypography.heading6,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppSpacing.s1),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14.sp,
                                  color: AppColors.grey,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    booking['location'],
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.s4),

                  // Dates and guests
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.calendar_today_outlined,
                          label: 'Ngày nhận phòng',
                          value: booking['checkIn'],
                        ),
                      ),
                      SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.calendar_today_outlined,
                          label: 'Ngày trả phòng',
                          value: booking['checkOut'],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.s3),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.people_outline,
                          label: 'Số khách',
                          value: '${booking['guests']} người',
                        ),
                      ),
                      SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.meeting_room_outlined,
                          label: 'Số phòng',
                          value: '${booking['rooms']} phòng',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.s4),
                  const Divider(height: 1),
                  SizedBox(height: AppSpacing.s4),

                  // Total price and action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng tiền',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          Text(
                            booking['totalPrice'],
                            style: AppTypography.heading5.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),

                      if (booking['status'] == 'upcoming') ...[
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => controller.cancelBooking(booking),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s4,
                                  vertical: AppSpacing.s2,
                                ),
                                side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text(
                                'Hủy',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.s2),
                            ElevatedButton(
                              onPressed: () => controller.viewTicket(booking),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s4,
                                  vertical: AppSpacing.s2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text(
                                'Xem vé',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (booking['status'] == 'completed') ...[
                        ElevatedButton(
                          onPressed: () => controller.rebook(booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.s4,
                              vertical: AppSpacing.s2,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          ),
                          child: Text(
                            'Đặt lại',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.grey),
        SizedBox(width: AppSpacing.s2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10.sp,
                ),
              ),
              Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64.sp, color: AppColors.neutral400),
          SizedBox(height: AppSpacing.s4),
          Text('Chưa có đặt phòng nào', style: AppTypography.heading5),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Bạn chưa có lịch sử đặt phòng nào',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppSpacing.s6),
          ElevatedButton(
            onPressed: () => Get.toNamed('/discover'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s6, vertical: AppSpacing.s3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            ),
            child: Text(
              'Khám phá ngay',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
