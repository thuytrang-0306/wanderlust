import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/admin/theme/admin_theme.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';

class AdminSearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;
  final IconData? prefixIcon;
  final bool enabled;

  const AdminSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search...',
    this.prefixIcon = Icons.search,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AdminTheme.borderColor),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AdminTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
          ),
          prefixIcon: prefixIcon != null 
              ? Icon(
                  prefixIcon,
                  color: Colors.grey[500],
                  size: 20.r,
                )
              : null,
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[500],
                    size: 20.r,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
        ),
        style: AdminTheme.textTheme.bodyMedium,
      ),
    );
  }
}