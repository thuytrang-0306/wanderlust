import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/presentation/controllers/payment/payment_method_controller.dart';

class PaymentMethodPage extends GetView<PaymentMethodController> {
  const PaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => PaymentMethodController());

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
          'Chọn phương thức thanh toán',
          style: AppTypography.h4.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Security notice
                  Container(
                    padding: EdgeInsets.all(AppSpacing.s3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 20.sp,
                          color: AppColors.success,
                        ),
                        SizedBox(width: AppSpacing.s2),
                        Expanded(
                          child: Text(
                            'Mọi giao dịch được mã hóa và bảo mật',
                            style: AppTypography.bodyS.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.s6),

                  // Title
                  Text(
                    'Chọn phương thức thanh toán',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: AppSpacing.s4),

                  // PayOS Option (QR Banking)
                  Obx(() => _buildPaymentOption(
                    id: 'payos',
                    title: 'PayOS - QR Ngân hàng',
                    subtitle: 'Quét mã QR để thanh toán qua ngân hàng',
                    icon: Icons.qr_code_scanner,
                    iconColor: AppColors.primary,
                    recommended: true,
                  )),

                  SizedBox(height: AppSpacing.s3),

                  // ZaloPay Option
                  Obx(() => _buildPaymentOption(
                    id: 'zalopay',
                    title: 'ZaloPay',
                    subtitle: 'Ví điện tử ZaloPay',
                    icon: Icons.account_balance_wallet,
                    iconColor: const Color(0xFF0068FF),
                  )),

                  SizedBox(height: AppSpacing.s6),

                  // Payment method details
                  _buildPaymentDetails(),
                ],
              ),
            ),
          ),

          // Bottom button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    bool recommended = false,
  }) {
    final isSelected = controller.selectedPaymentMethod.value == id;

    return GestureDetector(
      onTap: () => controller.selectPaymentMethod(id),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.neutral400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),

            SizedBox(width: AppSpacing.s3),

            // Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24.sp,
              ),
            ),

            SizedBox(width: AppSpacing.s3),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTypography.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (recommended) ...[
                        SizedBox(width: AppSpacing.s2),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Khuyến nghị',
                            style: AppTypography.bodyXS.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Obx(() {
      final method = controller.selectedPaymentMethod.value;

      if (method == 'payos') {
        return Container(
          padding: EdgeInsets.all(AppSpacing.s4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppSpacing.s2),
                  Text(
                    'Về PayOS',
                    style: AppTypography.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s3),
              _buildInfoItem('✓', 'Hỗ trợ tất cả ngân hàng tại Việt Nam'),
              _buildInfoItem('✓', 'Thanh toán nhanh chóng bằng QR code'),
              _buildInfoItem('✓', 'Không cần đăng ký tài khoản'),
              _buildInfoItem('✓', 'Bảo mật cao với HMAC SHA256'),
            ],
          ),
        );
      } else if (method == 'zalopay') {
        return Container(
          padding: EdgeInsets.all(AppSpacing.s4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20.sp,
                    color: const Color(0xFF0068FF),
                  ),
                  SizedBox(width: AppSpacing.s2),
                  Text(
                    'Về ZaloPay',
                    style: AppTypography.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s3),
              _buildInfoItem('✓', 'Thanh toán qua ví điện tử ZaloPay'),
              _buildInfoItem('✓', 'Hoàn tiền 50% cho giao dịch đầu tiên'),
              _buildInfoItem('✓', 'Ưu đãi cashback hàng tuần'),
              _buildInfoItem('✓', 'Bảo mật tuyệt đối'),
            ],
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildInfoItem(String bullet, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bullet,
            style: AppTypography.bodyS.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyS.copyWith(
                color: AppColors.neutral700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
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
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: controller.savePaymentMethod,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Xác nhận',
                  style: AppTypography.bodyL.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: AppSpacing.s2),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
