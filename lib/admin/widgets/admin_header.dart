import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AdminHeader extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool showMenuButton;
  
  const AdminHeader({
    super.key,
    required this.title,
    this.actions,
    this.showMenuButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Menu button for mobile
          if (showMenuButton) ...[
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
            ),
            SizedBox(width: 12.w),
          ],
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          
          const Spacer(),
          
          // Actions
          if (actions != null) ...actions!,
          
          // Search button
          IconButton(
            onPressed: () {
              // TODO: Implement global search
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
          
          SizedBox(width: 8.w),
          
          // Notifications
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Show notifications
                },
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}