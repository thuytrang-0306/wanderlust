import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/data/models/zalopay_payment_model.dart';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get currently selected method from arguments
    final currentMethod = Get.arguments?['currentMethod'] as PaymentMethod? ?? PaymentMethod.vietQR;
    final selectedMethod = Rx<PaymentMethod>(currentMethod);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutral900),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Phương thức thanh toán',
          style: AppTypography.h4.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.s5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chọn phương thức thanh toán',
                      style: AppTypography.bodyL.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4),

                    // VietQR (PayOS)
                    Obx(() => _buildPaymentOption(
                      method: PaymentMethod.vietQR,
                      selectedMethod: selectedMethod,
                      icon: Icons.qr_code_2,
                      iconColor: AppColors.primary,
                    )),

                    SizedBox(height: AppSpacing.s3),

                    // ZaloPay
                    Obx(() => _buildPaymentOption(
                      method: PaymentMethod.zaloPay,
                      selectedMethod: selectedMethod,
                      icon: Icons.account_balance_wallet,
                      iconColor: const Color(0xFF0068FF), // ZaloPay blue
                    )),

                    SizedBox(height: AppSpacing.s3),

                    // MoMo (Coming soon)
                    Obx(() => _buildPaymentOption(
                      method: PaymentMethod.momo,
                      selectedMethod: selectedMethod,
                      icon: Icons.phone_android,
                      iconColor: const Color(0xFFAE2070), // MoMo pink
                    )),

                    SizedBox(height: AppSpacing.s3),

                    // Cash
                    Obx(() => _buildPaymentOption(
                      method: PaymentMethod.cash,
                      selectedMethod: selectedMethod,
                      icon: Icons.money,
                      iconColor: AppColors.success,
                    )),

                    SizedBox(height: AppSpacing.s6),

                    // Info box
                    _buildInfoBox(),
                  ],
                ),
              ),
            ),

            // Confirm button
            Container(
              padding: EdgeInsets.all(AppSpacing.s5),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(result: selectedMethod.value);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Xác nhận',
                      style: AppTypography.bodyM.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildPaymentOption({
    required PaymentMethod method,
    required Rx<PaymentMethod> selectedMethod,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = selectedMethod.value == method;
    final isEnabled = method.isEnabled;

    return GestureDetector(
      onTap: isEnabled
          ? () => selectedMethod.value = method
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : AppColors.neutral100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
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
                color: isEnabled ? iconColor : AppColors.neutral400,
                size: 24.w,
              ),
            ),
            SizedBox(width: AppSpacing.s3),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        method.displayName,
                        style: AppTypography.bodyM.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isEnabled ? AppColors.neutral900 : AppColors.neutral500,
                        ),
                      ),
                      if (!isEnabled) ...[
                        SizedBox(width: AppSpacing.s2),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral200,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Sắp ra mắt',
                            style: AppTypography.bodyXS.copyWith(
                              color: AppColors.neutral600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    method.description,
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),

            // Radio indicator
            if (isEnabled)
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.neutral300,
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 20.w,
          ),
          SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thanh toán an toàn',
                  style: AppTypography.bodyS.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Tất cả giao dịch được mã hóa và bảo mật. Thông tin thanh toán của bạn sẽ không được lưu trữ.',
                  style: AppTypography.bodyXS.copyWith(
                    color: AppColors.neutral600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
