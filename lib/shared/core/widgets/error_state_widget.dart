import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_button.dart';

class ErrorStateWidget extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;
  final bool showDetails;

  const ErrorStateWidget({
    super.key,
    this.error,
    this.onRetry,
    this.retryText,
    this.icon,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon ?? Icons.error_outline, size: 40.sp, color: AppColors.error),
            ),
            SizedBox(height: 24.h),
            Text(
              'Oops! Something went wrong',
              style: AppTypography.heading5.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              _getErrorMessage(),
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (showDetails && error != null) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  error!,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: 'monospace',
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              AppButton.primary(
                text: retryText ?? 'Try Again',
                onPressed: onRetry,
                size: ButtonSize.medium,
                fullWidth: false,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getErrorMessage() {
    if (error == null) {
      return 'An unexpected error occurred. Please try again.';
    }

    // Map common errors to user-friendly messages
    if (error!.toLowerCase().contains('network')) {
      return 'Network error. Please check your internet connection.';
    }
    if (error!.toLowerCase().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (error!.toLowerCase().contains('permission')) {
      return 'You don\'t have permission to perform this action.';
    }
    if (error!.toLowerCase().contains('not found')) {
      return 'The requested data could not be found.';
    }
    if (error!.toLowerCase().contains('server')) {
      return 'Server error. Please try again later.';
    }

    // Return the original error if it's already user-friendly
    if (error!.length < 100) {
      return error!;
    }

    // For long technical errors, show generic message
    return 'An unexpected error occurred. Please try again.';
  }
}
