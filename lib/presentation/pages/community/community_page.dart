import 'package:flutter/material.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Cộng đồng',
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
          'Trang Cộng đồng\n(Đang phát triển)',
          style: AppTypography.bodyL,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}