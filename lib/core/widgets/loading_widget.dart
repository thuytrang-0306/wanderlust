import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool isOverlay;
  final Color? color;
  
  const LoadingWidget({
    super.key,
    this.message,
    this.isOverlay = false,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final loadingContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
          strokeWidth: 3,
        ),
        if (message != null) ...[
          SizedBox(height: 16.h),
          Text(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: isOverlay ? AppColors.white : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
    
    if (isOverlay) {
      return Container(
        color: AppColors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: loadingContent,
          ),
        ),
      );
    }
    
    return Center(child: loadingContent);
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  
  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: LoadingWidget(
              isOverlay: true,
              message: message,
            ),
          ),
      ],
    );
  }
}