import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/data/models/ai_itinerary_model.dart';
import 'package:wanderlust/presentation/controllers/trip/ai_itinerary_detail_controller.dart';

/// Detail page for AI-generated itinerary with beautiful UI
class AiItineraryDetailPage extends StatefulWidget {
  final AiItineraryModel itinerary;

  const AiItineraryDetailPage({
    super.key,
    required this.itinerary,
  });

  @override
  State<AiItineraryDetailPage> createState() => _AiItineraryDetailPageState();
}

class _AiItineraryDetailPageState extends State<AiItineraryDetailPage> {
  late AiItineraryDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AiItineraryDetailController());
    controller.init(widget.itinerary);
  }

  @override
  void dispose() {
    Get.delete<AiItineraryDetailController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          _buildAppBar(),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Summary card
                _buildSummaryCard(),

                SizedBox(height: AppSpacing.s4),

                // Activities timeline
                _buildActivitiesTimeline(),

                SizedBox(height: AppSpacing.s4),

                // Cost breakdown
                _buildCostBreakdown(),

                SizedBox(height: 80.h), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient, // ✅ Sử dụng primary gradient từ design system
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 14.sp, color: Colors.white),
                            SizedBox(width: 4.w),
                            Text(
                              'AI GENERATED',
                              style: AppTypography.bodyXS.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Lịch trình Ngày ${widget.itinerary.dayNumber}',
                    style: AppTypography.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.itinerary.summary,
                    style: AppTypography.bodyM.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share, color: Colors.white, size: 22.sp),
          onPressed: () => controller.shareItinerary(),
        ),
        IconButton(
          icon: Icon(Icons.copy, color: Colors.white, size: 20.sp),
          onPressed: () => controller.copyMarkdown(),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight, // ✅ Sử dụng shadow từ design system
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.event_note,
              label: 'Hoạt động',
              value: '${widget.itinerary.activityCount}',
              color: AppColors.primary, // ✅ Sử dụng primary color
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: AppColors.neutral200,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.attach_money,
              label: 'Ước tính',
              value: widget.itinerary.formattedTotalCost,
              color: AppColors.success, // ✅ Sử dụng success color từ design system
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTypography.bodyL.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodyXS.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesTimeline() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lịch trình chi tiết',
            style: AppTypography.h4.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral800,
            ),
          ),
          SizedBox(height: AppSpacing.s3),
          ...widget.itinerary.activities.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            final isLast = index == widget.itinerary.activities.length - 1;

            return _buildActivityCard(activity, index, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildActivityCard(AiActivity activity, int index, bool isLast) {
    return Obx(() {
      final isExpanded = controller.isExpanded(index);

      return Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.s3),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              Column(
                children: [
                  // Time marker
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        activity.getTypeIcon(),
                        style: TextStyle(fontSize: 20.sp),
                      ),
                    ),
                  ),
                  // Connector line
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: EdgeInsets.symmetric(vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(width: AppSpacing.s3),

              // Activity content
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.toggleActivity(index),
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.s3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isExpanded
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.neutral200,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowLight, // ✅ Sử dụng shadow từ design system
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time and title
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                activity.time,
                                style: AppTypography.bodyXS.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                activity.title,
                                style: AppTypography.bodyM.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral800,
                                ),
                              ),
                            ),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 20.sp,
                              color: AppColors.neutral500,
                            ),
                          ],
                        ),

                        // Location (always visible)
                        if (activity.location != null && activity.location!.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14.sp, color: AppColors.neutral500),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  activity.location!,
                                  style: AppTypography.bodyS.copyWith(
                                    color: AppColors.neutral600,
                                  ),
                                  maxLines: isExpanded ? null : 1,
                                  overflow: isExpanded ? null : TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Expanded details
                        if (isExpanded) ...[
                          if (activity.description != null && activity.description!.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.all(AppSpacing.s2),
                              decoration: BoxDecoration(
                                color: AppColors.neutral100,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                activity.description!,
                                style: AppTypography.bodyS.copyWith(
                                  color: AppColors.neutral700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                          if (activity.estimatedCost != null) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.payments, size: 16.sp, color: AppColors.success), // ✅ Success color
                                SizedBox(width: 6.w),
                                Text(
                                  activity.getFormattedCost(),
                                  style: AppTypography.bodyM.copyWith(
                                    color: AppColors.success, // ✅ Success color
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCostBreakdown() {
    // Group activities by type and sum costs
    final costByType = <String, double>{};
    for (final activity in widget.itinerary.activities) {
      if (activity.estimatedCost != null && activity.estimatedCost! > 0) {
        costByType[activity.type] = (costByType[activity.type] ?? 0) + activity.estimatedCost!;
      }
    }

    if (costByType.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight, // ✅ Sử dụng shadow từ design system
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, size: 20.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'Chi phí theo loại',
                style: AppTypography.bodyL.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s3),
          ...costByType.entries.map((entry) {
            final percentage = (entry.value / widget.itinerary.totalEstimatedCost * 100);
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      _getTypeLabel(entry.key),
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.neutral700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColors.neutral200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTypeColor(entry.key),
                        ),
                        minHeight: 8.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          Divider(height: 24.h, color: AppColors.neutral200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng:',
                style: AppTypography.bodyL.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral800,
                ),
              ),
              Text(
                widget.itinerary.formattedTotalCost,
                style: AppTypography.bodyL.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.success, // ✅ Success color
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'food':
        return 'Ăn uống';
      case 'sightseeing':
        return 'Tham quan';
      case 'transport':
        return 'Di chuyển';
      case 'accommodation':
        return 'Chỗ ở';
      case 'entertainment':
        return 'Giải trí';
      case 'shopping':
        return 'Mua sắm';
      default:
        return 'Khác';
    }
  }

  Color _getTypeColor(String type) {
    // ✅ Sử dụng colors từ design system
    switch (type) {
      case 'food':
        return AppColors.error; // Red for food
      case 'sightseeing':
        return AppColors.info; // Blue for sightseeing
      case 'transport':
        return AppColors.warning; // Yellow for transport
      case 'accommodation':
        return AppColors.successLight; // Light green for accommodation
      case 'entertainment':
        return AppColors.primary300; // Light purple for entertainment
      case 'shopping':
        return AppColors.primary600; // Purple for shopping
      default:
        return AppColors.neutral400;
    }
  }
}
