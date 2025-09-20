import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/theme/admin_theme.dart';
import 'package:wanderlust/admin/widgets/user_edit_dialog.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/shared/core/models/user_model.dart';

class AdminUserDetailsDialog extends StatelessWidget {
  final UserModel user;

  const AdminUserDetailsDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 600.w,
        constraints: BoxConstraints(maxHeight: 0.8.sh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.s6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserProfile(),
                    SizedBox(height: AppSpacing.s6),
                    _buildUserStats(),
                    SizedBox(height: AppSpacing.s6),
                    _buildAccountInfo(),
                    SizedBox(height: AppSpacing.s6),
                    _buildActivityInfo(),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s6),
      decoration: BoxDecoration(
        color: AdminTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: AdminTheme.primaryColor,
            size: 24.r,
          ),
          SizedBox(width: AppSpacing.s3),
          Text(
            'User Details',
            style: AdminTheme.textTheme.titleLarge?.copyWith(
              color: AdminTheme.primaryColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, size: 20.r),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s5),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.r,
              backgroundImage: user.avatarUrl != null 
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null 
                  ? Text(
                      user.displayName.isNotEmpty 
                          ? user.displayName[0].toUpperCase() 
                          : 'U',
                      style: TextStyle(fontSize: 24.sp),
                    )
                  : null,
            ),
            SizedBox(width: AppSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName.isNotEmpty ? user.displayName : 'No name',
                          style: AdminTheme.textTheme.titleLarge,
                        ),
                      ),
                      _buildStatusChip(user.status),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s2),
                  _buildInfoRow(Icons.email, user.email),
                  if (user.phone.isNotEmpty)
                    _buildInfoRow(Icons.phone, user.phone),
                  if (user.bio?.isNotEmpty == true)
                    _buildInfoRow(Icons.info, user.bio!),
                  if (user.location?.isNotEmpty == true)
                    _buildInfoRow(Icons.location_on, user.location!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.s1),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: Colors.grey[600]),
          SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Text(
              text,
              style: AdminTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ),
          IconButton(
            onPressed: () => _copyToClipboard(text),
            icon: Icon(Icons.copy, size: 14.r),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Copy',
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: AdminTheme.textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.s4),
            Row(
              children: [
                Expanded(child: _buildStatItem('Trips', user.tripCount.toString())),
                Expanded(child: _buildStatItem('Reviews', user.reviewCount.toString())),
                Expanded(child: _buildStatItem('Followers', user.followersCount.toString())),
                Expanded(child: _buildStatItem('Following', user.followingCount.toString())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AdminTheme.textTheme.titleLarge?.copyWith(
            color: AdminTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AdminTheme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: AdminTheme.textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.s4),
            _buildDetailRow('User ID', user.id),
            _buildDetailRow('Status', user.statusText),
            _buildDetailRow('Verified', user.isVerified ? 'Yes' : 'No'),
            _buildDetailRow('Business Account', user.isBusinessAccount ? 'Yes' : 'No'),
            _buildDetailRow('Language', user.language ?? 'Not set'),
            _buildDetailRow('Timezone', user.timezone ?? 'Not set'),
            if (user.bannedAt != null)
              _buildDetailRow('Banned At', _formatDateTime(user.bannedAt!)),
            if (user.deletedAt != null)
              _buildDetailRow('Deleted At', _formatDateTime(user.deletedAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Information',
              style: AdminTheme.textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.s4),
            _buildDetailRow('Member Since', user.memberSince),
            _buildDetailRow('Created At', _formatDateTime(user.createdAt)),
            _buildDetailRow('Last Updated', user.updatedAt != null ? _formatDateTime(user.updatedAt!) : 'Never'),
            _buildDetailRow('Last Login', user.lastLoginAt != null ? _formatDateTime(user.lastLoginAt!) : 'Never'),
            _buildDetailRow('Last Seen', user.lastSeenText),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: AdminTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AdminTheme.textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => _copyToClipboard(value),
                  icon: Icon(Icons.copy, size: 14.r),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Copy',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = Color(int.parse(UserModel(
      id: '', name: '', email: '', phone: '', status: status, createdAt: DateTime.now()
    ).statusColor.replaceFirst('#', '0xFF')));
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s1,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: AdminTheme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          SizedBox(width: AppSpacing.s3),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Get.dialog(
                UserEditDialog(user: user),
                barrierDismissible: false,
              );
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Could show a small tooltip or snackbar here
  }
}