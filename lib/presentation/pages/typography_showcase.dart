import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/constants/app_colors.dart';

class TypographyShowcase extends StatelessWidget {
  const TypographyShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Typography System', style: AppTypography.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'HEADINGS',
              [
                _buildTypographyItem('H1', '32px/40px', AppTypography.h1),
                _buildTypographyItem('H2', '24px/28px', AppTypography.h2),
                _buildTypographyItem('H3', '20px/24px', AppTypography.h3),
                _buildTypographyItem('H4', '18px/22px', AppTypography.h4),
              ],
            ),
            _buildDivider(),
            _buildSection(
              'BODY TEXT',
              [
                _buildTypographyItem('Body XL', '18px/22px', AppTypography.bodyXL),
                _buildTypographyItem('Body L', '16px/20px', AppTypography.bodyL),
                _buildTypographyItem('Body M', '14px/17px', AppTypography.bodyM),
                _buildTypographyItem('Body S', '12px/14px', AppTypography.bodyS),
                _buildTypographyItem('Body XS', '10px/12px', AppTypography.bodyXS),
              ],
            ),
            _buildDivider(),
            _buildSection(
              'LABELS',
              [
                _buildTypographyItem('Label 1', '18px/22px', AppTypography.label1),
                _buildTypographyItem('Label 2', '16px/20px', AppTypography.label2),
                _buildTypographyItem('Label 3', '14px/17px', AppTypography.label3),
                _buildTypographyItem('Label 4', '12px/14px', AppTypography.label4),
              ],
            ),
            _buildDivider(),
            _buildSection(
              'CAPTIONS',
              [
                _buildTypographyItem('Caption 1', '16px/20px', AppTypography.caption1),
                _buildTypographyItem('Caption 2', '14px/17px', AppTypography.caption2),
                _buildTypographyItem('Caption 3', '12px/14px', AppTypography.caption3),
              ],
            ),
            _buildDivider(),
            _buildSection(
              'WEIGHT VARIATIONS',
              [
                _buildWeightVariation('Light (300)', AppTypography.light),
                _buildWeightVariation('Regular (400)', AppTypography.regular),
                _buildWeightVariation('Medium (500)', AppTypography.medium),
                _buildWeightVariation('SemiBold (600)', AppTypography.semiBold),
                _buildWeightVariation('Bold (700)', AppTypography.bold),
              ],
            ),
            SizedBox(height: 32.h),
            _buildParagraphExample(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.label4.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 16.h),
        ...items,
      ],
    );
  }

  Widget _buildTypographyItem(String label, String spec, TextStyle style) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTypography.label4.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(width: 8.w),
              Text(
                spec,
                style: AppTypography.caption3,
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Wanderlust Travel App',
            style: style,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightVariation(String label, FontWeight weight) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: AppTypography.caption2,
            ),
          ),
          Expanded(
            child: Text(
              'Gilroy Font',
              style: AppTypography.bodyL.copyWith(fontWeight: weight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraphExample() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paragraph Example',
            style: AppTypography.h3,
          ),
          SizedBox(height: 12.h),
          Text(
            'Become a legendary UX/UI designer through real world and practical courses. '
            'Experience the journey of exploring beautiful destinations around the world '
            'with Wanderlust - your trusted travel companion.',
            style: AppTypography.bodyL.copyWith(height: 1.5),
          ),
          SizedBox(height: 12.h),
          Text(
            'This text demonstrates the Gilroy font family with proper line heights '
            'and spacing according to the 4px grid system.',
            style: AppTypography.bodyM.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: const Divider(color: AppColors.greyLight),
    );
  }
}