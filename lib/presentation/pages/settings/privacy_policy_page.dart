import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          'Chính sách bảo mật',
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
                      'Cập nhật lần cuối: 01/01/2024',
                      style: AppTypography.bodyS.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.s5),
            
            // Content sections
            _buildSection(
              title: '1. Giới thiệu',
              content: '''
Wanderlust ("chúng tôi", "của chúng tôi") cam kết bảo vệ quyền riêng tư và bảo mật thông tin cá nhân của bạn. Chính sách bảo mật này giải thích cách chúng tôi thu thập, sử dụng, tiết lộ và bảo vệ thông tin của bạn khi bạn sử dụng ứng dụng di động Wanderlust.

Bằng việc sử dụng ứng dụng của chúng tôi, bạn đồng ý với việc thu thập và sử dụng thông tin theo chính sách này.
              ''',
            ),
            
            _buildSection(
              title: '2. Thông tin chúng tôi thu thập',
              content: '''
Chúng tôi thu thập các loại thông tin sau:

• Thông tin cá nhân: Họ tên, địa chỉ email, số điện thoại, ngày sinh
• Thông tin tài khoản: Tên đăng nhập, mật khẩu (được mã hóa)
• Thông tin hồ sơ: Ảnh đại diện, sở thích du lịch, địa điểm yêu thích
• Dữ liệu sử dụng: Lịch sử tìm kiếm, đặt phòng, đánh giá
• Thông tin thiết bị: Loại thiết bị, hệ điều hành, địa chỉ IP
• Vị trí: Với sự cho phép của bạn, chúng tôi có thể thu thập vị trí của bạn
              ''',
            ),
            
            _buildSection(
              title: '3. Cách chúng tôi sử dụng thông tin',
              content: '''
Thông tin thu thập được sử dụng để:

• Cung cấp và duy trì dịch vụ
• Cá nhân hóa trải nghiệm người dùng
• Xử lý đặt phòng và thanh toán
• Gửi thông báo về đặt phòng và cập nhật
• Cải thiện dịch vụ và phát triển tính năng mới
• Ngăn chặn gian lận và bảo mật tài khoản
• Tuân thủ nghĩa vụ pháp lý
              ''',
            ),
            
            _buildSection(
              title: '4. Chia sẻ thông tin',
              content: '''
Chúng tôi không bán, cho thuê hoặc chia sẻ thông tin cá nhân của bạn với bên thứ ba, ngoại trừ:

• Nhà cung cấp dịch vụ (khách sạn, tour) để xử lý đặt phòng
• Đối tác thanh toán để xử lý giao dịch
• Khi được yêu cầu bởi pháp luật
• Với sự đồng ý của bạn
• Để bảo vệ quyền lợi của chúng tôi và người dùng khác
              ''',
            ),
            
            _buildSection(
              title: '5. Bảo mật dữ liệu',
              content: '''
Chúng tôi áp dụng các biện pháp bảo mật để bảo vệ thông tin của bạn:

• Mã hóa SSL/TLS cho truyền tải dữ liệu
• Mã hóa mật khẩu với thuật toán bcrypt
• Xác thực hai yếu tố (2FA) tùy chọn
• Giám sát và phát hiện truy cập bất thường
• Sao lưu dữ liệu định kỳ
• Hạn chế quyền truy cập nội bộ
              ''',
            ),
            
            _buildSection(
              title: '6. Quyền của bạn',
              content: '''
Bạn có quyền:

• Truy cập thông tin cá nhân chúng tôi lưu trữ
• Yêu cầu chỉnh sửa thông tin không chính xác
• Yêu cầu xóa tài khoản và dữ liệu
• Rút lại sự đồng ý thu thập dữ liệu
• Từ chối nhận thông tin marketing
• Yêu cầu sao chép dữ liệu của bạn
• Khiếu nại về việc xử lý dữ liệu
              ''',
            ),
            
            _buildSection(
              title: '7. Cookie và công nghệ theo dõi',
              content: '''
Ứng dụng sử dụng cookie và công nghệ tương tự để:

• Duy trì phiên đăng nhập
• Ghi nhớ tùy chọn người dùng
• Phân tích hành vi sử dụng
• Cải thiện hiệu suất ứng dụng

Bạn có thể quản lý cookie trong cài đặt thiết bị.
              ''',
            ),
            
            _buildSection(
              title: '8. Lưu trữ dữ liệu',
              content: '''
• Chúng tôi lưu trữ dữ liệu trong thời gian cần thiết để cung cấp dịch vụ
• Dữ liệu tài khoản được lưu đến khi bạn yêu cầu xóa
• Lịch sử giao dịch được lưu theo quy định pháp luật (5 năm)
• Dữ liệu sao lưu được xóa sau 90 ngày
              ''',
            ),
            
            _buildSection(
              title: '9. Trẻ em',
              content: '''
Dịch vụ của chúng tôi không dành cho người dưới 13 tuổi. Chúng tôi không cố ý thu thập thông tin từ trẻ em dưới 13 tuổi. Nếu phát hiện, chúng tôi sẽ xóa ngay lập tức.
              ''',
            ),
            
            _buildSection(
              title: '10. Thay đổi chính sách',
              content: '''
Chúng tôi có thể cập nhật chính sách này theo thời gian. Chúng tôi sẽ thông báo về bất kỳ thay đổi nào bằng cách đăng chính sách mới trên ứng dụng và gửi thông báo cho bạn.
              ''',
            ),
            
            _buildSection(
              title: '11. Liên hệ',
              content: '''
Nếu bạn có câu hỏi về chính sách bảo mật này, vui lòng liên hệ:

Email: privacy@wanderlust.vn
Điện thoại: 1900 1234
Địa chỉ: 123 Nguyễn Huệ, Q.1, TP.HCM

Hoặc gửi yêu cầu qua mục Trợ giúp trong ứng dụng.
              ''',
            ),
            
            SizedBox(height: AppSpacing.s8),
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