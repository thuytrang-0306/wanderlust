import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/data/models/ai_itinerary_model.dart';
import 'package:wanderlust/presentation/pages/trip/ai_itinerary_detail_page.dart';

/// Card to display AI-generated itinerary in trip timeline
class AiItineraryCard extends StatelessWidget {
  final AiItineraryModel itinerary;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRegenerate;

  const AiItineraryCard({
    super.key,
    required this.itinerary,
    this.onTap,
    this.onDelete,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.s3),
      decoration: BoxDecoration(
        gradient: AppColors.gradient101, // ✅ Sử dụng gradient từ design system
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight, // ✅ Sử dụng shadow từ design system
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => _navigateToDetail(context),
          onLongPress: () => _showActions(context),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with AI badge
                Row(
                  children: [
                    // AI Sparkle Icon
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 20.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s3),
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'AI',
                                  style: AppTypography.bodyXS.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  'Lịch trình gợi ý',
                                  style: AppTypography.bodyM.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.neutral800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            itinerary.summary,
                            style: AppTypography.bodyS.copyWith(
                              color: AppColors.neutral600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // More menu
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20.sp,
                        color: AppColors.neutral600,
                      ),
                      onPressed: () => _showActions(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.s3),

                // Stats
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.event_note,
                      label: '${itinerary.activityCount} hoạt động',
                    ),
                    SizedBox(width: AppSpacing.s4),
                    _buildStatItem(
                      icon: Icons.attach_money,
                      label: '~${itinerary.formattedTotalCost}',
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.s3),

                // Preview activities
                if (itinerary.activities.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(AppSpacing.s3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hoạt động:',
                          style: AppTypography.bodyS.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral700,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        ...itinerary.previewActivities.map((activity) => Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Row(
                              children: [
                                Text(
                                  activity.getTypeIcon(),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    '${activity.time} - ${activity.title}',
                                    style: AppTypography.bodyS.copyWith(
                                      color: AppColors.neutral700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (itinerary.activityCount > 3) ...[
                          SizedBox(height: 4.h),
                          Text(
                            '+${itinerary.activityCount - 3} hoạt động khác',
                            style: AppTypography.bodyXS.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                SizedBox(height: AppSpacing.s2),

                // Tap to view detail hint
                Center(
                  child: Text(
                    'Nhấn để xem chi tiết',
                    style: AppTypography.bodyXS.copyWith(
                      color: AppColors.neutral500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: AppColors.neutral600,
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: AppTypography.bodyS.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _navigateToDetail(BuildContext context) {
    Get.to(
      () => AiItineraryDetailPage(itinerary: itinerary),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _showActions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Title
            Text(
              'Lịch trình AI',
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.s4),

            // View detail
            ListTile(
              leading: Icon(Icons.visibility, color: AppColors.primary),
              title: const Text('Xem chi tiết'),
              onTap: () {
                Get.back();
                _navigateToDetail(context);
              },
            ),

            // Regenerate
            if (onRegenerate != null)
              ListTile(
                leading: Icon(Icons.refresh, color: AppColors.primary),
                title: const Text('Tạo lại lịch trình'),
                onTap: () {
                  Get.back();
                  onRegenerate!();
                },
              ),

            // Delete
            if (onDelete != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Xóa lịch trình AI'),
                onTap: () {
                  Get.back();
                  _confirmDelete(context);
                },
              ),

            // Cancel
            ListTile(
              leading: Icon(Icons.cancel, color: AppColors.neutral500),
              title: const Text('Hủy'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xóa lịch trình AI'),
        content: const Text('Bạn có chắc muốn xóa lịch trình này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onDelete?.call();
            },
            child: Text(
              'Xóa',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
