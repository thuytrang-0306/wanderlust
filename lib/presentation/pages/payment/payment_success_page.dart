import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/presentation/controllers/payment/payment_success_controller.dart';
import 'package:lottie/lottie.dart';

class PaymentSuccessPage extends GetView<PaymentSuccessController> {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => PaymentSuccessController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Success animation and message
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.s5),
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.s8),

                    // Success animation or icon
                    _buildSuccessAnimation(),

                    SizedBox(height: AppSpacing.s6),

                    // Success message
                    Text(
                      'Thanh toán thành công!',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.s3),

                    Text(
                      'Đặt phòng của bạn đã được xác nhận',
                      style: AppTypography.bodyM.copyWith(color: AppColors.neutral600),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: AppSpacing.s8),

                    // QR Code section
                    _buildQRCodeSection(),

                    SizedBox(height: AppSpacing.s6),

                    // Booking details
                    _buildBookingDetails(),

                    SizedBox(height: AppSpacing.s6),

                    // Important notes
                    _buildImportantNotes(),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Try to load Lottie, fallback to icon
          FutureBuilder(
            future: Future.delayed(Duration.zero),
            builder: (context, snapshot) {
              try {
                return Lottie.network(
                  'https://assets2.lottiefiles.com/packages/lf20_success.json',
                  width: 100.w,
                  height: 100.h,
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.check_circle, size: 60.sp, color: AppColors.primary);
                  },
                );
              } catch (e) {
                return Icon(Icons.check_circle, size: 60.sp, color: AppColors.primary);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            'Mã đặt phòng',
            style: AppTypography.bodyL.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),

          SizedBox(height: AppSpacing.s3),

          // Booking code
          Text(
            controller.bookingCode,
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),

          SizedBox(height: AppSpacing.s4),

          // QR Code
          Container(
            padding: EdgeInsets.all(AppSpacing.s3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: QrImageView(
              data: controller.bookingCode,
              version: QrVersions.auto,
              size: 180.w,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            ),
          ),

          SizedBox(height: AppSpacing.s3),

          Text(
            'Vui lòng xuất trình mã này khi nhận phòng',
            style: AppTypography.bodyS.copyWith(
              color: AppColors.neutral600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.hotel, size: 20.sp, color: AppColors.primary),
              SizedBox(width: AppSpacing.s2),
              Text(
                'Chi tiết đặt phòng',
                style: AppTypography.bodyL.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.s4),

          // Details
          _buildDetailRow('Khách sạn', controller.hotelName),
          _buildDetailRow('Loại phòng', controller.roomType),
          _buildDetailRow('Khách', controller.guestName),
          _buildDetailRow('Nhận phòng', controller.checkIn),
          _buildDetailRow('Trả phòng', controller.checkOut),
          _buildDetailRow('Số đêm', '${controller.nights} đêm'),

          Divider(height: AppSpacing.s6, color: AppColors.neutral200),

          // Total amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng thanh toán',
                style: AppTypography.bodyL.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                '${controller.totalAmount} VND',
                style: AppTypography.bodyL.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(label, style: AppTypography.bodyS.copyWith(color: AppColors.neutral500)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyS.copyWith(
                color: AppColors.neutral800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotes() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18.sp, color: Colors.amber.shade700),
              SizedBox(width: AppSpacing.s2),
              Text(
                'Lưu ý quan trọng',
                style: AppTypography.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            '• Vui lòng đến trước 15:00 để làm thủ tục nhận phòng\n'
            '• Mang theo CMND/CCCD khi nhận phòng\n'
            '• Chi tiết đặt phòng đã được gửi qua email',
            style: AppTypography.bodyXS.copyWith(color: Colors.amber.shade800, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s5),
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
        children: [
          // View ticket button
          GestureDetector(
            onTap: controller.viewTicket,
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
              child: Center(
                child: Text(
                  'Xem vé điện tử',
                  style: AppTypography.bodyL.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: AppSpacing.s3),

          // Secondary buttons row
          Row(
            children: [
              // Share button
              Expanded(
                child: GestureDetector(
                  onTap: controller.shareBooking,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_outlined, size: 18.sp, color: AppColors.primary),
                        SizedBox(width: AppSpacing.s2),
                        Text(
                          'Chia sẻ',
                          style: AppTypography.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: AppSpacing.s3),

              // Back to home button
              Expanded(
                child: GestureDetector(
                  onTap: controller.backToHome,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_outlined, size: 18.sp, color: AppColors.neutral700),
                        SizedBox(width: AppSpacing.s2),
                        Text(
                          'Về trang chủ',
                          style: AppTypography.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
