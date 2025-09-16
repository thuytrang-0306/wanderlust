import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/app_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? icon;
  final IconData? iconData;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customIcon;
  
  const EmptyStateWidget({
    super.key,
    this.icon,
    this.iconData,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.customIcon,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            SizedBox(height: 24.h),
            Text(
              title,
              style: AppTypography.heading5.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: 24.h),
              AppButton.primary(
                text: buttonText!,
                onPressed: onButtonPressed,
                size: ButtonSize.medium,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildIcon() {
    if (customIcon != null) {
      return customIcon!;
    }
    
    if (icon != null && icon!.endsWith('.svg')) {
      return SvgPicture.asset(
        icon!,
        width: 120.w,
        height: 120.w,
        colorFilter: ColorFilter.mode(
          AppColors.grey,
          BlendMode.srcIn,
        ),
      );
    }
    
    if (icon != null) {
      return Image.asset(
        icon!,
        width: 120.w,
        height: 120.w,
        fit: BoxFit.contain,
      );
    }
    
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData ?? Icons.inbox_outlined,
        size: 60.sp,
        color: AppColors.grey,
      ),
    );
  }
}

// Predefined empty states for common scenarios
class EmptyStates {
  static Widget noData({String? message, VoidCallback? onRetry}) {
    return EmptyStateWidget(
      iconData: Icons.inbox_outlined,
      title: message ?? 'No data available',
      subtitle: 'There is no data to display at the moment',
      buttonText: onRetry != null ? 'Refresh' : null,
      onButtonPressed: onRetry,
    );
  }
  
  static Widget noSearchResults({String? query}) {
    return EmptyStateWidget(
      iconData: Icons.search_off,
      title: 'No results found',
      subtitle: query != null 
        ? 'No results found for "$query"'
        : 'Try adjusting your search criteria',
    );
  }
  
  static Widget noFavorites({VoidCallback? onExplore}) {
    return EmptyStateWidget(
      iconData: Icons.favorite_border,
      title: 'No favorites yet',
      subtitle: 'Start exploring and add your favorite places',
      buttonText: 'Explore',
      onButtonPressed: onExplore,
    );
  }
  
  static Widget noBookings({VoidCallback? onBook}) {
    return EmptyStateWidget(
      iconData: Icons.calendar_today,
      title: 'No bookings yet',
      subtitle: 'Your booking history will appear here',
      buttonText: 'Book Now',
      onButtonPressed: onBook,
    );
  }
  
  static Widget noNotifications() {
    return const EmptyStateWidget(
      iconData: Icons.notifications_none,
      title: 'No notifications',
      subtitle: 'You\'re all caught up!',
    );
  }
  
  static Widget noInternet({VoidCallback? onRetry}) {
    return EmptyStateWidget(
      iconData: Icons.wifi_off,
      title: 'No internet connection',
      subtitle: 'Please check your connection and try again',
      buttonText: 'Retry',
      onButtonPressed: onRetry,
    );
  }
}