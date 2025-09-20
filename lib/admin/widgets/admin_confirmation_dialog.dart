import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/admin/theme/admin_theme.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';

class AdminConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final bool isDangerous;
  final VoidCallback? onConfirm;

  const AdminConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.isDangerous = false,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 400.w,
        padding: EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            SizedBox(height: AppSpacing.s4),
            _buildMessage(),
            SizedBox(height: AppSpacing.s6),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.s2),
          decoration: BoxDecoration(
            color: isDangerous 
                ? Colors.red.withOpacity(0.1)
                : AdminTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            isDangerous ? Icons.warning : Icons.help_outline,
            color: isDangerous ? Colors.red : AdminTheme.primaryColor,
            size: 24.r,
          ),
        ),
        SizedBox(width: AppSpacing.s3),
        Expanded(
          child: Text(
            title,
            style: AdminTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        message,
        style: AdminTheme.textTheme.bodyMedium?.copyWith(
          color: Colors.grey[700],
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: AppSpacing.s2,
            ),
          ),
          child: Text(cancelText ?? 'Cancel'),
        ),
        SizedBox(width: AppSpacing.s3),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDangerous ? Colors.red : AdminTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: AppSpacing.s2,
            ),
          ),
          child: Text(confirmText ?? (isDangerous ? 'Delete' : 'Confirm')),
        ),
      ],
    );
  }
}