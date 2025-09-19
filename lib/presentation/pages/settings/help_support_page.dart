import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/presentation/controllers/settings/help_support_controller.dart';

class HelpSupportPage extends GetView<HelpSupportController> {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Trợ giúp & Hỗ trợ',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(AppSpacing.s5),
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm câu hỏi...',
                      hintStyle: AppTypography.bodyM.copyWith(color: AppColors.textTertiary),
                      prefixIcon: Icon(Icons.search, color: AppColors.neutral500, size: 24.sp),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s4,
                        vertical: AppSpacing.s3,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: AppSpacing.s3),
              
              // Quick actions
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(AppSpacing.s5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Liên hệ nhanh',
                      style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: AppSpacing.s4),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.chat_bubble_outline,
                            label: 'Chat',
                            onTap: controller.openChat,
                          ),
                        ),
                        SizedBox(width: AppSpacing.s3),
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.phone_outlined,
                            label: 'Gọi điện',
                            onTap: controller.makePhoneCall,
                          ),
                        ),
                        SizedBox(width: AppSpacing.s3),
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            onTap: controller.sendEmail,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSpacing.s3),
              
              // FAQ Categories
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
                      child: Text(
                        'Câu hỏi thường gặp',
                        style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4),
                    ...controller.faqCategories.map((category) => _buildFAQCategory(category)),
                  ],
                ),
              ),
              
              SizedBox(height: AppSpacing.s3),
              
              // Popular topics
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(AppSpacing.s5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chủ đề phổ biến',
                      style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: AppSpacing.s4),
                    Wrap(
                      spacing: AppSpacing.s2,
                      runSpacing: AppSpacing.s2,
                      children: controller.popularTopics
                          .map((topic) => _buildTopicChip(topic))
                          .toList(),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSpacing.s3),
              
              // Contact info
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(AppSpacing.s5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin liên hệ',
                      style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: AppSpacing.s4),
                    _buildContactItem(
                      icon: Icons.location_on_outlined,
                      title: 'Địa chỉ',
                      subtitle: '123 Nguyễn Huệ, Q.1, TP.HCM',
                    ),
                    SizedBox(height: AppSpacing.s3),
                    _buildContactItem(
                      icon: Icons.phone_outlined,
                      title: 'Hotline',
                      subtitle: '1900 1234',
                    ),
                    SizedBox(height: AppSpacing.s3),
                    _buildContactItem(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: 'support@wanderlust.vn',
                    ),
                    SizedBox(height: AppSpacing.s3),
                    _buildContactItem(
                      icon: Icons.access_time,
                      title: 'Giờ làm việc',
                      subtitle: 'Thứ 2 - Thứ 6: 8:00 - 17:00',
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSpacing.s6),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28.sp),
            SizedBox(height: AppSpacing.s2),
            Text(
              label,
              style: AppTypography.bodyS.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFAQCategory(Map<String, dynamic> category) {
    return Obx(() {
      final isExpanded = controller.expandedCategories[category['id']] ?? false;
      return Column(
        children: [
          InkWell(
            onTap: () => controller.toggleCategory(category['id']),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s5,
                vertical: AppSpacing.s3,
              ),
              child: Row(
                children: [
                  Icon(
                    category['icon'],
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category['title'],
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${category['count']} câu hỏi',
                          style: AppTypography.bodyXS.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.neutral500,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              color: AppColors.neutral50,
              padding: EdgeInsets.only(
                left: AppSpacing.s5 + 24.sp + AppSpacing.s3,
                right: AppSpacing.s5,
                bottom: AppSpacing.s3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (category['questions'] as List).map((q) {
                  return Padding(
                    padding: EdgeInsets.only(top: AppSpacing.s2),
                    child: GestureDetector(
                      onTap: () => controller.openFAQDetail(q),
                      child: Text(
                        '• $q',
                        style: AppTypography.bodyS.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (category['id'] != controller.faqCategories.last['id'])
            Divider(height: 1, color: AppColors.neutral100),
        ],
      );
    });
  }
  
  Widget _buildTopicChip(String topic) {
    return GestureDetector(
      onTap: () => controller.searchTopic(topic),
      child: Chip(
        label: Text(topic),
        backgroundColor: AppColors.neutral100,
        labelStyle: AppTypography.bodyS.copyWith(color: AppColors.textPrimary),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s2),
      ),
    );
  }
  
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.neutral600, size: 20.sp),
        SizedBox(width: AppSpacing.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyS.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}