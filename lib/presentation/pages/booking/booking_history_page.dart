import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/presentation/controllers/booking/booking_history_controller.dart';
import 'package:wanderlust/data/models/booking_model.dart';
import 'package:intl/intl.dart';

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
        tabs: const [
          Tab(text: 'Sắp tới'),
          Tab(text: 'Hoàn thành'),
          Tab(text: 'Đã hủy'),
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

  Widget _buildBookingList(RxList<BookingModel> bookings) {
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

  Widget _buildBookingCard(BookingModel booking) {
    final statusColor =
        booking.status == 'confirmed' || booking.status == 'pending'
            ? AppColors.success
            : booking.status == 'completed'
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.navigateToBookingDetail(booking),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking code and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BK${booking.id.substring(0, 8).toUpperCase()}',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
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
                        booking.displayStatus,
                        style: AppTypography.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.s3),

                // Hotel name
                Text(
                  booking.itemName,
                  style: AppTypography.heading6,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: AppSpacing.s2),

                // Dates
                Text(
                  '${DateFormat('dd/MM/yyyy').format(booking.checkIn)} - ${booking.checkOut != null ? DateFormat('dd/MM/yyyy').format(booking.checkOut!) : "N/A"}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),

                SizedBox(height: AppSpacing.s3),
                const Divider(height: 1),
                SizedBox(height: AppSpacing.s3),

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng tiền',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      booking.displayPrice,
                      style: AppTypography.heading6.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
