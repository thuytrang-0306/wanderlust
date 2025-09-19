import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Điều khoản dịch vụ',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last updated
            Container(
              padding: EdgeInsets.all(AppSpacing.s3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 18.sp),
                  SizedBox(width: AppSpacing.s2),
                  Expanded(
                    child: Text(
                      'Có hiệu lực từ: 01/01/2024',
                      style: AppTypography.bodyS.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.s5),
            
            // Introduction
            Text(
              'Chào mừng bạn đến với Wanderlust!',
              style: AppTypography.h3.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: AppSpacing.s3),
            Text(
              'Điều khoản dịch vụ này ("Điều khoản") điều chỉnh việc sử dụng ứng dụng di động Wanderlust và các dịch vụ liên quan. Bằng việc sử dụng ứng dụng, bạn đồng ý tuân thủ và bị ràng buộc bởi các điều khoản này.',
              style: AppTypography.bodyM.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            
            SizedBox(height: AppSpacing.s6),
            
            // Content sections
            _buildSection(
              title: '1. Chấp nhận điều khoản',
              content: '''
• Bằng việc tạo tài khoản hoặc sử dụng dịch vụ, bạn xác nhận đã đọc, hiểu và đồng ý với điều khoản này
• Bạn phải từ 18 tuổi trở lên hoặc có sự đồng ý của phụ huynh
• Bạn chịu trách nhiệm về tính chính xác của thông tin cung cấp
• Bạn đồng ý nhận thông báo và cập nhật về dịch vụ
              ''',
            ),
            
            _buildSection(
              title: '2. Mô tả dịch vụ',
              content: '''
Wanderlust cung cấp nền tảng kết nối du khách với:

• Đặt phòng khách sạn, homestay, resort
• Đặt tour du lịch trong và ngoài nước  
• Thông tin điểm đến, kinh nghiệm du lịch
• Lập kế hoạch và quản lý chuyến đi
• Cộng đồng chia sẻ trải nghiệm du lịch
• Ưu đãi và khuyến mãi độc quyền

Chúng tôi đóng vai trò trung gian kết nối, không trực tiếp cung cấp dịch vụ lưu trú hay tour.
              ''',
            ),
            
            _buildSection(
              title: '3. Tài khoản người dùng',
              content: '''
Quy định về tài khoản:

• Một người chỉ được tạo một tài khoản
• Bạn phải bảo mật thông tin đăng nhập
• Không chia sẻ tài khoản với người khác
• Thông báo ngay nếu phát hiện truy cập trái phép
• Bạn chịu trách nhiệm về mọi hoạt động dưới tài khoản của mình
• Chúng tôi có quyền tạm ngưng hoặc xóa tài khoản vi phạm
              ''',
            ),
            
            _buildSection(
              title: '4. Quy tắc sử dụng',
              content: '''
Khi sử dụng dịch vụ, bạn cam kết KHÔNG:

• Đăng nội dung sai sự thật, phỉ báng, xúc phạm
• Vi phạm quyền sở hữu trí tuệ của người khác
• Spam, quảng cáo không được phép
• Hack, phá hoại hệ thống
• Thu thập thông tin người dùng khác trái phép
• Đặt phòng giả hoặc gian lận
• Sử dụng cho mục đích bất hợp pháp
• Can thiệp vào hoạt động của người dùng khác
              ''',
            ),
            
            _buildSection(
              title: '5. Đặt phòng và thanh toán',
              content: '''
• Giá hiển thị đã bao gồm thuế và phí (trừ khi ghi chú khác)
• Xác nhận đặt phòng sẽ được gửi qua email/app
• Chính sách hủy tùy thuộc vào từng nhà cung cấp
• Thanh toán qua các phương thức được hỗ trợ
• Hoàn tiền theo chính sách của nhà cung cấp
• Chúng tôi không chịu trách nhiệm về chất lượng dịch vụ của nhà cung cấp
• Tranh chấp được giải quyết theo quy trình khiếu nại
              ''',
            ),
            
            _buildSection(
              title: '6. Nội dung người dùng',
              content: '''
• Bạn giữ quyền sở hữu nội dung mình tạo
• Bạn cấp cho chúng tôi quyền sử dụng nội dung để vận hành dịch vụ
• Bạn chịu trách nhiệm về nội dung đăng tải
• Chúng tôi có quyền xóa nội dung vi phạm
• Không đăng ảnh/video của người khác mà không có sự đồng ý
• Đánh giá phải trung thực và khách quan
              ''',
            ),
            
            _buildSection(
              title: '7. Quyền sở hữu trí tuệ',
              content: '''
• Logo, thương hiệu Wanderlust thuộc sở hữu của chúng tôi
• Giao diện, tính năng được bảo vệ bản quyền
• Không sao chép, sửa đổi mà không có sự cho phép
• Nội dung đối tác thuộc quyền sở hữu của họ
• Vi phạm bản quyền sẽ bị xử lý theo pháp luật
              ''',
            ),
            
            _buildSection(
              title: '8. Giới hạn trách nhiệm',
              content: '''
Chúng tôi không chịu trách nhiệm về:

• Thiệt hại gián tiếp hoặc ngẫu nhiên
• Mất mát dữ liệu do lỗi của bạn
• Gián đoạn dịch vụ do bảo trì hoặc nâng cấp
• Hành vi của người dùng khác
• Chất lượng dịch vụ của nhà cung cấp
• Thiệt hại do vi-rút hoặc phần mềm độc hại
• Lỗi do bên thứ ba hoặc bất khả kháng

Trách nhiệm tối đa của chúng tôi không vượt quá số tiền bạn đã thanh toán.
              ''',
            ),
            
            _buildSection(
              title: '9. Bồi thường',
              content: '''
Bạn đồng ý bồi thường và giữ cho Wanderlust không bị thiệt hại từ mọi khiếu nại, tổn thất, chi phí phát sinh từ:

• Vi phạm điều khoản này
• Vi phạm quyền của bên thứ ba
• Sử dụng sai mục đích dịch vụ
• Nội dung bạn đăng tải
• Tranh chấp với người dùng khác
              ''',
            ),
            
            _buildSection(
              title: '10. Sửa đổi điều khoản',
              content: '''
• Chúng tôi có quyền sửa đổi điều khoản bất cứ lúc nào
• Thông báo sẽ được gửi qua email hoặc thông báo trong app
• Tiếp tục sử dụng sau khi có thay đổi nghĩa là bạn chấp nhận điều khoản mới
• Bạn có thể dừng sử dụng nếu không đồng ý với thay đổi
              ''',
            ),
            
            _buildSection(
              title: '11. Chấm dứt',
              content: '''
• Bạn có thể xóa tài khoản bất cứ lúc nào
• Chúng tôi có quyền tạm ngưng hoặc chấm dứt tài khoản vi phạm
• Một số điều khoản vẫn có hiệu lực sau khi chấm dứt
• Dữ liệu có thể được lưu giữ theo quy định pháp luật
              ''',
            ),
            
            _buildSection(
              title: '12. Luật áp dụng',
              content: '''
• Điều khoản này được điều chỉnh bởi pháp luật Việt Nam
• Tranh chấp được giải quyết tại tòa án có thẩm quyền tại TP.HCM
• Ưu tiên hòa giải thông qua thương lượng
              ''',
            ),
            
            _buildSection(
              title: '13. Liên hệ',
              content: '''
Mọi thắc mắc về điều khoản dịch vụ, vui lòng liên hệ:

Email: legal@wanderlust.vn
Điện thoại: 1900 1234
Địa chỉ: 123 Nguyễn Huệ, Q.1, TP.HCM
Giờ làm việc: Thứ 2 - Thứ 6, 8:00 - 17:00

Hoặc gửi phản hồi qua mục Trợ giúp trong ứng dụng.
              ''',
            ),
            
            // Agreement section
            Container(
              margin: EdgeInsets.only(top: AppSpacing.s6, bottom: AppSpacing.s8),
              padding: EdgeInsets.all(AppSpacing.s4),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.neutral300),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, 
                    color: AppColors.success, 
                    size: 32.sp
                  ),
                  SizedBox(height: AppSpacing.s3),
                  Text(
                    'Bằng việc sử dụng Wanderlust, bạn xác nhận đã đọc, hiểu và đồng ý với tất cả điều khoản trên.',
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.s3),
        Text(
          content.trim(),
          style: AppTypography.bodyM.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        SizedBox(height: AppSpacing.s5),
      ],
    );
  }
}