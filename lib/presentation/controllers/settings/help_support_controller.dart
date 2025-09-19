import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class HelpSupportController extends BaseController {
  final searchController = TextEditingController();
  final RxMap<String, bool> expandedCategories = <String, bool>{}.obs;
  
  // FAQ Categories
  final List<Map<String, dynamic>> faqCategories = [
    {
      'id': 'booking',
      'icon': Icons.calendar_today_outlined,
      'title': 'Đặt phòng & Tour',
      'count': 8,
      'questions': [
        'Làm sao để đặt phòng khách sạn?',
        'Chính sách hủy đặt phòng như thế nào?',
        'Tôi có thể thay đổi thông tin đặt phòng không?',
        'Làm sao để nhận hóa đơn VAT?',
        'Có thể đặt phòng cho người khác không?',
        'Thanh toán trực tiếp tại khách sạn được không?',
        'Làm sao để sử dụng mã giảm giá?',
        'Tôi có thể đặt nhiều phòng cùng lúc không?',
      ],
    },
    {
      'id': 'payment',
      'icon': Icons.payment,
      'title': 'Thanh toán',
      'count': 6,
      'questions': [
        'Hình thức thanh toán nào được hỗ trợ?',
        'Thanh toán có an toàn không?',
        'Khi nào tiền sẽ bị trừ?',
        'Làm sao để được hoàn tiền?',
        'Có thể thanh toán bằng tiền mặt không?',
        'Tại sao thanh toán của tôi bị từ chối?',
      ],
    },
    {
      'id': 'account',
      'icon': Icons.person_outline,
      'title': 'Tài khoản',
      'count': 5,
      'questions': [
        'Làm sao để đổi mật khẩu?',
        'Tôi quên mật khẩu phải làm sao?',
        'Làm sao để xóa tài khoản?',
        'Có thể liên kết với Facebook không?',
        'Làm sao để cập nhật thông tin cá nhân?',
      ],
    },
    {
      'id': 'promotion',
      'icon': Icons.local_offer_outlined,
      'title': 'Khuyến mãi',
      'count': 4,
      'questions': [
        'Làm sao để nhận mã giảm giá?',
        'Điều kiện sử dụng voucher?',
        'Có thể dùng nhiều mã giảm giá không?',
        'Mã giảm giá hết hạn có thể gia hạn không?',
      ],
    },
  ];
  
  // Popular topics
  final List<String> popularTopics = [
    'Hủy đặt phòng',
    'Hoàn tiền',
    'Mã giảm giá',
    'Đổi lịch trình',
    'Hóa đơn VAT',
    'Check-in online',
    'Điểm thưởng',
    'Đánh giá',
  ];
  
  // Contact info
  final String hotline = '1900 1234';
  final String email = 'support@wanderlust.vn';
  
  @override
  void onInit() {
    super.onInit();
    // Initialize all categories as collapsed
    for (var category in faqCategories) {
      expandedCategories[category['id']] = false;
    }
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  void onSearchChanged(String query) {
    // Implement search logic
    LoggerService.i('Searching for: $query');
  }
  
  void toggleCategory(String categoryId) {
    expandedCategories[categoryId] = !(expandedCategories[categoryId] ?? false);
  }
  
  void openFAQDetail(String question) {
    // Navigate to FAQ detail or show answer
    AppSnackbar.showInfo(message: 'Xem chi tiết: $question');
  }
  
  void searchTopic(String topic) {
    searchController.text = topic;
    onSearchChanged(topic);
  }
  
  void openChat() {
    AppSnackbar.showInfo(message: 'Đang mở chat hỗ trợ...');
    // TODO: Implement chat feature
  }
  
  Future<void> makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: hotline);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        AppSnackbar.showError(message: 'Không thể thực hiện cuộc gọi');
      }
    } catch (e) {
      LoggerService.e('Error making phone call', error: e);
      AppSnackbar.showError(message: 'Có lỗi xảy ra');
    }
  }
  
  Future<void> sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Hỗ trợ từ Wanderlust App',
        'body': 'Xin chào,\n\nTôi cần hỗ trợ về:\n\n',
      },
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        AppSnackbar.showError(message: 'Không thể mở ứng dụng email');
      }
    } catch (e) {
      LoggerService.e('Error sending email', error: e);
      AppSnackbar.showError(message: 'Có lỗi xảy ra');
    }
  }
}