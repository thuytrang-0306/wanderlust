import 'package:flutter/material.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Thông báo',
          style: AppTypography.h4.copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Trang Thông báo\n(Đang phát triển)',
          style: AppTypography.bodyL,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}