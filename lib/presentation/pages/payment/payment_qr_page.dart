import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_button.dart';
import 'package:wanderlust/presentation/controllers/payment/payment_qr_controller.dart';
import 'package:intl/intl.dart';

class PaymentQRPage extends GetView<PaymentQRController> {
  const PaymentQRPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog before going back
        final result = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Hủy thanh toán?'),
            content: const Text(
              'Bạn có chắc muốn hủy giao dịch này không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Tiếp tục thanh toán'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Hủy'),
              ),
            ],
          ),
        );

        if (result == true) {
          controller.cancelPayment();
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppColors.neutral900),
            onPressed: () async {
              final result = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Hủy thanh toán?'),
                  content: const Text(
                    'Bạn có chắc muốn hủy giao dịch này không?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Tiếp tục thanh toán'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Hủy'),
                    ),
                  ],
                ),
              );

              if (result == true) {
                controller.cancelPayment();
              }
            },
          ),
          title: Text(
            'Thanh toán',
            style: AppTypography.h4.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.isCreatingPayment.value) {
            return _buildLoadingState();
          }

          if (controller.paymentLink.value == null) {
            return _buildErrorState();
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.s5),
                    child: Column(
                      children: [
                        // Polling status
                        _buildPollingStatus(),

                        SizedBox(height: AppSpacing.s6),

                        // QR Code
                        _buildQRCode(),

                        SizedBox(height: AppSpacing.s6),

                        // Instructions
                        _buildInstructions(),

                        SizedBox(height: AppSpacing.s6),

                        // Payment details
                        _buildPaymentDetails(),

                        SizedBox(height: AppSpacing.s4),

                        // Bank info (if available)
                        if (controller.paymentLink.value?.accountNumber != null)
                          _buildBankInfo(),
                      ],
                    ),
                  ),
                ),

                // Bottom buttons
                _buildBottomButtons(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: AppSpacing.s4),
          Text(
            'Đang tạo mã thanh toán...',
            style: AppTypography.bodyM.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: AppColors.error,
            ),
            SizedBox(height: AppSpacing.s4),
            Text(
              'Không thể tạo mã thanh toán',
              style: AppTypography.h4.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.s3),
            Text(
              'Vui lòng thử lại sau',
              style: AppTypography.bodyM.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.s6),
            AppButton.primary(
              text: 'Quay lại',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollingStatus() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s3,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Text(
                controller.pollingStatusText,
                style: AppTypography.bodyS.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQRCode() {
    final qrData = controller.paymentLink.value?.qrCode ?? '';

    return Container(
      padding: EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Quét mã QR để thanh toán',
            style: AppTypography.h4.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s5),
          if (qrData.isNotEmpty)
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 280.w,
              backgroundColor: Colors.white,
              errorStateBuilder: (ctx, err) {
                return Container(
                  width: 280.w,
                  height: 280.w,
                  alignment: Alignment.center,
                  child: Text(
                    'Lỗi tạo QR code',
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                );
              },
            )
          else
            Container(
              width: 280.w,
              height: 280.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hướng dẫn thanh toán',
            style: AppTypography.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          SizedBox(height: AppSpacing.s3),
          _buildInstructionItem(
            '1',
            'Mở ứng dụng ngân hàng trên điện thoại',
          ),
          _buildInstructionItem(
            '2',
            'Quét mã QR bằng tính năng quét mã trong app',
          ),
          _buildInstructionItem(
            '3',
            'Xác nhận thông tin và hoàn tất thanh toán',
          ),
          _buildInstructionItem(
            '4',
            'Hệ thống sẽ tự động xác nhận sau khi thanh toán thành công',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: AppTypography.bodyXS.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                text,
                style: AppTypography.bodyS.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    final paymentLink = controller.paymentLink.value;
    final amount = controller.totalAmount ?? 0;
    final orderCode = controller.orderCode ?? '';

    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin thanh toán',
            style: AppTypography.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          SizedBox(height: AppSpacing.s3),
          _buildDetailRow('Mã đơn hàng', orderCode),
          _buildDetailRow(
            'Số tiền',
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount),
            isHighlight: true,
          ),
          if (paymentLink?.description != null)
            _buildDetailRow('Nội dung', paymentLink!.description),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyS.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyS.copyWith(
              color: isHighlight ? AppColors.primary : AppColors.neutral900,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfo() {
    final paymentLink = controller.paymentLink.value;

    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20.w,
                color: AppColors.warning,
              ),
              SizedBox(width: AppSpacing.s2),
              Text(
                'Thông tin chuyển khoản',
                style: AppTypography.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s3),
          if (paymentLink?.accountNumber != null)
            _buildBankInfoRow('Số tài khoản', paymentLink!.accountNumber!),
          if (paymentLink?.accountName != null)
            _buildBankInfoRow('Tên tài khoản', paymentLink!.accountName!),
        ],
      ),
    );
  }

  Widget _buildBankInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodyXS.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTypography.bodyS.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
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
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              return AppButton.primary(
                text: 'Đã thanh toán',
                onPressed: controller.manualCheckPayment,
                isLoading: controller.isCheckingStatus.value,
              );
            }),
            SizedBox(height: AppSpacing.s3),
            TextButton(
              onPressed: () async {
                final result = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Hủy thanh toán?'),
                    content: const Text(
                      'Bạn có chắc muốn hủy giao dịch này không?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Tiếp tục thanh toán'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Hủy'),
                      ),
                    ],
                  ),
                );

                if (result == true) {
                  controller.cancelPayment();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Hủy giao dịch'),
            ),
          ],
        ),
      ),
    );
  }
}
