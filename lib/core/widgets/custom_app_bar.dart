import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/constants/app_colors.dart';

/// Custom AppBar widget following Figma design specs
/// Used in Community, Planning, and Notifications tabs
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => Size(double.infinity, 107.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 107.h,
      padding: EdgeInsets.only(
        top: 57.h,
        right: 16.w,
        bottom: 1.h,
        left: 16.w,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0661, 0.7532],
          colors: [
            Color(0xCCC4CDF4), // rgba(196, 205, 244, 0.8)
            Color(0xFFEDE0FF), // #EDE0FF
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9455FD).withValues(alpha: 0.1), // #9455FD1A
            offset: const Offset(0, 4),
            blurRadius: 5.9,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Leading (back button if needed)
          if (showBackButton)
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: const Color(0xFF54189A),
                size: 24.sp,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            const SizedBox.shrink(),

          // Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                height: 36 / 24, // line-height / font-size
                letterSpacing: 0,
                color: const Color(0xFF54189A),
              ),
              textAlign: showBackButton ? TextAlign.center : TextAlign.start,
            ),
          ),

          // Actions
          if (actions != null && actions!.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!.map((action) {
                // Apply icon color to action buttons
                if (action is IconButton) {
                  return IconTheme(
                    data: IconThemeData(
                      color: const Color(0xFF54189A),
                      size: 24.sp,
                    ),
                    child: action,
                  );
                }
                return action;
              }).toList(),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
