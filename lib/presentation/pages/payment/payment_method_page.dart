import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/presentation/controllers/payment/payment_method_controller.dart';

class PaymentMethodPage extends GetView<PaymentMethodController> {
  const PaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => PaymentMethodController());

    return Scaffold(
      backgroundColor: Colors.white,
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
          style: TextStyle(color: AppColors.primary, fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Security notice
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFF86EFAC), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline, size: 20.sp, color: const Color(0xFF16A34A)),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Mọi dữ liệu thanh toán được mã hóa và bảo mật',
                            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF16A34A)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Credit/Debit Card Option
                  Obx(
                    () => GestureDetector(
                      onTap: () => controller.selectPaymentType('card'),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color:
                              controller.selectedPaymentType.value == 'card'
                                  ? const Color(0xFFF3F0FF)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color:
                                controller.selectedPaymentType.value == 'card'
                                    ? AppColors.primary
                                    : const Color(0xFFE5E7EB),
                            width: controller.selectedPaymentType.value == 'card' ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          controller.selectedPaymentType.value == 'card'
                                              ? AppColors.primary
                                              : const Color(0xFF9CA3AF),
                                      width: 2,
                                    ),
                                  ),
                                  child:
                                      controller.selectedPaymentType.value == 'card'
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
                                SizedBox(width: 12.w),
                                Text(
                                  'Thẻ tín dụng/Thẻ ghi nợ',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),

                            // Card brand logos
                            if (controller.selectedPaymentType.value == 'card') ...[
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  _buildCardLogo('JCB'),
                                  SizedBox(width: 8.w),
                                  _buildCardLogo('UnionPay'),
                                  SizedBox(width: 8.w),
                                  _buildCardLogo('Mastercard'),
                                  SizedBox(width: 8.w),
                                  _buildCardLogo('Visa'),
                                ],
                              ),

                              SizedBox(height: 20.h),

                              // Card number field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Số thẻ tín dụng/Thẻ ghi nợ *',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextField(
                                    controller: controller.cardNumberController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: const Color(0xFF111827),
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 14.h,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(
                                          color: const Color(0xFFE5E7EB),
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(
                                          color: const Color(0xFFE5E7EB),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              // Cardholder name field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tên trên thẻ',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextField(
                                    controller: controller.cardHolderController,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: const Color(0xFF111827),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Nguyen Thuy Trang',
                                      hintStyle: TextStyle(
                                        fontSize: 16.sp,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 14.h,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(
                                          color: const Color(0xFFE5E7EB),
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(
                                          color: const Color(0xFFE5E7EB),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              // Expiry and CVV row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ngày hết hạn *',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        TextField(
                                          controller: controller.expiryController,
                                          keyboardType: TextInputType.datetime,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: const Color(0xFF111827),
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'TT/NN',
                                            hintStyle: TextStyle(
                                              fontSize: 16.sp,
                                              color: const Color(0xFF9CA3AF),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 14.h,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: const Color(0xFFE5E7EB),
                                                width: 1,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: const Color(0xFFE5E7EB),
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: AppColors.primary,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mã bảo mật CVC *',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        TextField(
                                          controller: controller.cvvController,
                                          keyboardType: TextInputType.number,
                                          obscureText: true,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: const Color(0xFF111827),
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 14.h,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: const Color(0xFFE5E7EB),
                                                width: 1,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: const Color(0xFFE5E7EB),
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: AppColors.primary,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Digital payment option
                  Obx(
                    () => GestureDetector(
                      onTap: () => controller.selectPaymentType('digital'),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color:
                              controller.selectedPaymentType.value == 'digital'
                                  ? const Color(0xFFF3F0FF)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color:
                                controller.selectedPaymentType.value == 'digital'
                                    ? AppColors.primary
                                    : const Color(0xFFE5E7EB),
                            width: controller.selectedPaymentType.value == 'digital' ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          controller.selectedPaymentType.value == 'digital'
                                              ? AppColors.primary
                                              : const Color(0xFF9CA3AF),
                                      width: 2,
                                    ),
                                  ),
                                  child:
                                      controller.selectedPaymentType.value == 'digital'
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
                                SizedBox(width: 12.w),
                                Text(
                                  'Thanh toán kỹ thuật số',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),

                            // Digital payment logos
                            if (controller.selectedPaymentType.value == 'digital') ...[
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  _buildDigitalPaymentLogo('PayPal'),
                                  SizedBox(width: 12.w),
                                  _buildDigitalPaymentLogo('Apple Pay'),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom button
          Container(
            padding: EdgeInsets.all(20.w),
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
                        'Tiếp tục',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20.sp),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLogo(String brand) {
    switch (brand) {
      case 'JCB':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'JCB',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF003A70),
            ),
          ),
        );
      case 'UnionPay':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF003B70), const Color(0xFFED1C24), const Color(0xFF003B70)],
            ),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            '银联',
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      case 'Mastercard':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Stack(
            children: [
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(color: const Color(0xFFEB001B), shape: BoxShape.circle),
              ),
              Positioned(
                left: 10.w,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(color: const Color(0xFFF79E1B), shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        );
      case 'Visa':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'VISA',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1F71),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildDigitalPaymentLogo(String brand) {
    if (brand == 'PayPal') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            Text(
              'Pay',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF003087),
              ),
            ),
            Text(
              'Pal',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF009CDE),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6.r)),
        child: Row(
          children: [
            Icon(Icons.apple, color: Colors.white, size: 16.sp),
            SizedBox(width: 4.w),
            Text('Pay', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
          ],
        ),
      );
    }
  }
}
