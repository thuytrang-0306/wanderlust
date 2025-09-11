import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';

class DesignSystemShowcase extends StatefulWidget {
  const DesignSystemShowcase({super.key});

  @override
  State<DesignSystemShowcase> createState() => _DesignSystemShowcaseState();
}

class _DesignSystemShowcaseState extends State<DesignSystemShowcase> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Design System', style: AppTypography.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Colors'),
            Tab(text: 'Spacing'),
            Tab(text: 'Components'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ColorsTab(),
          _SpacingTab(),
          _ComponentsTab(),
        ],
      ),
    );
  }
}

class _ColorsTab extends StatelessWidget {
  const _ColorsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColorSection('Primary', [
            _ColorItem('50', AppColors.primary50, '#F7FEE7'),
            _ColorItem('100', AppColors.primary100, '#ECFCCA'),
            _ColorItem('200', AppColors.primary200, '#DEFA9B'),
            _ColorItem('300', AppColors.primary300, '#ABEB68'),
            _ColorItem('400', AppColors.primary400, '#84CC16'),
            _ColorItem('500', AppColors.primary500, '#65A30D', isMain: true),
            _ColorItem('600', AppColors.primary600, '#528729'),
            _ColorItem('700', AppColors.primary700, '#446E26'),
            _ColorItem('800', AppColors.primary800, '#355321'),
            _ColorItem('900', AppColors.primary900, '#21330F'),
            _ColorItem('950', AppColors.primary950, '#111907'),
          ]),
          _buildColorSection('Secondary', [
            _ColorItem('50', AppColors.secondary50, '#FFF5F0'),
            _ColorItem('100', AppColors.secondary100, '#FFE6D5'),
            _ColorItem('500', AppColors.secondary500, '#FF812C', isMain: true),
            _ColorItem('700', AppColors.secondary700, '#B35300'),
            _ColorItem('950', AppColors.secondary950, '#421708'),
          ]),
          _buildColorSection('Neutral', [
            _ColorItem('50', AppColors.neutral50, '#F6F6F6'),
            _ColorItem('100', AppColors.neutral100, '#E3E4E1'),
            _ColorItem('200', AppColors.neutral200, '#D5D6D2'),
            _ColorItem('300', AppColors.neutral300, '#BABCB5'),
            _ColorItem('400', AppColors.neutral400, '#9FA196'),
            _ColorItem('500', AppColors.neutral500, '#86877C'),
            _ColorItem('600', AppColors.neutral600, '#73746B'),
            _ColorItem('700', AppColors.neutral700, '#585951'),
            _ColorItem('800', AppColors.neutral800, '#42423D'),
            _ColorItem('900', AppColors.neutral900, '#32332E'),
            _ColorItem('950', AppColors.neutral950, '#1F1F1B'),
          ]),
          _buildColorSection('Semantic', [
            _ColorItem('Success', AppColors.success400, '#37D334', isMain: true),
            _ColorItem('Warning', AppColors.warning300, '#F6DA45', isMain: true),
            _ColorItem('Error', AppColors.error500, '#F04040', isMain: true),
            _ColorItem('Info', AppColors.info, '#2196F3', isMain: true),
          ]),
          _buildGradientSection(),
        ],
      ),
    );
  }

  Widget _buildColorSection(String title, List<_ColorItem> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h3),
        SizedBox(height: AppSpacing.s3),
        ...colors.map((color) => _buildColorRow(color)),
        SizedBox(height: AppSpacing.s6),
      ],
    );
  }

  Widget _buildColorRow(_ColorItem color) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.s2),
      padding: EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        border: color.isMain 
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.s12,
            height: AppSpacing.s12,
            decoration: BoxDecoration(
              color: color.color,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
              border: Border.all(color: AppColors.border),
            ),
          ),
          SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  color.name,
                  style: AppTypography.label3.copyWith(
                    fontWeight: color.isMain ? AppTypography.bold : null,
                  ),
                ),
                Text(color.hex, style: AppTypography.caption3),
              ],
            ),
          ),
          if (color.isMain)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s2,
                vertical: AppSpacing.s1,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
              ),
              child: Text(
                'MAIN',
                style: AppTypography.caption3.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppTypography.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGradientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gradients', style: AppTypography.h3),
        SizedBox(height: AppSpacing.s3),
        _buildGradientRow('Primary Gradient', AppColors.primaryGradient),
        _buildGradientRow('Secondary Gradient', AppColors.secondaryGradient),
        _buildGradientRow('Success Gradient', AppColors.successGradient),
        _buildGradientRow('Dark Gradient', AppColors.darkGradient),
      ],
    );
  }

  Widget _buildGradientRow(String name, LinearGradient gradient) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.s3),
      padding: EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.s12,
            height: AppSpacing.s12,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            ),
          ),
          SizedBox(width: AppSpacing.s3),
          Text(name, style: AppTypography.label3),
        ],
      ),
    );
  }
}

class _SpacingTab extends StatelessWidget {
  const _SpacingTab();

  @override
  Widget build(BuildContext context) {
    final spacings = [
      ('s0', '0px', AppSpacing.s0),
      ('px', '1px', AppSpacing.px),
      ('s0.5', '2px', AppSpacing.s0_5),
      ('s1', '4px', AppSpacing.s1),
      ('s1.5', '6px', AppSpacing.s1_5),
      ('s2', '8px', AppSpacing.s2),
      ('s2.5', '10px', AppSpacing.s2_5),
      ('s3', '12px', AppSpacing.s3),
      ('s3.5', '14px', AppSpacing.s3_5),
      ('s4', '16px', AppSpacing.s4),
      ('s5', '20px', AppSpacing.s5),
      ('s6', '24px', AppSpacing.s6),
      ('s7', '28px', AppSpacing.s7),
      ('s8', '32px', AppSpacing.s8),
      ('s9', '36px', AppSpacing.s9),
      ('s10', '40px', AppSpacing.s10),
      ('s11', '44px', AppSpacing.s11),
      ('s12', '48px', AppSpacing.s12),
      ('s14', '56px', AppSpacing.s14),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spacing Scale', style: AppTypography.h3),
          SizedBox(height: AppSpacing.s4),
          ...spacings.map((item) => _buildSpacingRow(item.$1, item.$2, item.$3)),
          SizedBox(height: AppSpacing.s8),
          Text('Semantic Spacing', style: AppTypography.h3),
          SizedBox(height: AppSpacing.s4),
          _buildSemanticSpacing(),
        ],
      ),
    );
  }

  Widget _buildSpacingRow(String name, String pixels, double value) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.s2),
      padding: EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60.w,
            child: Text(name, style: AppTypography.label4),
          ),
          SizedBox(
            width: 50.w,
            child: Text(pixels, style: AppTypography.caption3),
          ),
          Container(
            height: AppSpacing.s6,
            width: value,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemanticSpacing() {
    return Column(
      children: [
        _buildSemanticRow('Padding XS', '${AppSpacing.paddingXS.toInt()}px'),
        _buildSemanticRow('Padding SM', '${AppSpacing.paddingSM.toInt()}px'),
        _buildSemanticRow('Padding MD', '${AppSpacing.paddingMD.toInt()}px'),
        _buildSemanticRow('Padding LG', '${AppSpacing.paddingLG.toInt()}px'),
        _buildSemanticRow('Padding XL', '${AppSpacing.paddingXL.toInt()}px'),
        _buildSemanticRow('Padding XXL', '${AppSpacing.paddingXXL.toInt()}px'),
        SizedBox(height: AppSpacing.s4),
        _buildSemanticRow('Button Radius', '${AppSpacing.buttonRadius.toInt()}px'),
        _buildSemanticRow('Card Radius', '${AppSpacing.cardRadius.toInt()}px'),
        _buildSemanticRow('Modal Radius', '${AppSpacing.modalRadius.toInt()}px'),
      ],
    );
  }

  Widget _buildSemanticRow(String name, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: AppTypography.bodyM),
          Text(value, style: AppTypography.label3.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _ComponentsTab extends StatelessWidget {
  const _ComponentsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Button Examples', style: AppTypography.h3),
          SizedBox(height: AppSpacing.s4),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, AppSpacing.buttonHeightLG),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              ),
            ),
            child: Text('Primary Button', style: AppTypography.button.copyWith(color: AppColors.white)),
          ),
          SizedBox(height: AppSpacing.s3),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              minimumSize: Size(double.infinity, AppSpacing.buttonHeightLG),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              ),
            ),
            child: Text('Secondary Button', style: AppTypography.button.copyWith(color: AppColors.white)),
          ),
          SizedBox(height: AppSpacing.s6),
          Text('Card Example', style: AppTypography.h3),
          SizedBox(height: AppSpacing.s4),
          Container(
            padding: EdgeInsets.all(AppSpacing.paddingMD),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Card Title', style: AppTypography.h4),
                SizedBox(height: AppSpacing.s2),
                Text(
                  'This is a card component using the new spacing and color system.',
                  style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorItem {
  final String name;
  final Color color;
  final String hex;
  final bool isMain;

  _ColorItem(this.name, this.color, this.hex, {this.isMain = false});
}