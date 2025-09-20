import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_user_management_controller.dart';
import 'package:wanderlust/admin/widgets/stats_card.dart';
import 'package:wanderlust/admin/widgets/admin_search_field.dart';
import 'package:wanderlust/admin/widgets/admin_filters.dart';
import 'package:wanderlust/admin/widgets/admin_user_details_dialog.dart';
import 'package:wanderlust/admin/widgets/admin_confirmation_dialog.dart';
import 'package:wanderlust/shared/core/models/user_model.dart';
import 'package:wanderlust/core/widgets/app_image.dart';

class AdminUserManagementTab extends GetView<AdminUserManagementController> {
  const AdminUserManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        SizedBox(height: 16.h),
        _buildFilters(),
        SizedBox(height: 16.h),
        Expanded(child: _buildUsersList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Management',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Row(
                children: [
                  Obx(() => Text(
                    '${controller.selectedUsers.length} selected',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: controller.selectedUsers.isNotEmpty 
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF64748B),
                    ),
                  )),
                  SizedBox(width: 16.w),
                  ElevatedButton.icon(
                    onPressed: controller.exportUsers,
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Stats overview
          Obx(() => Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Total Users',
                  value: controller.userStats.value.totalUsers.toString(),
                  icon: Icons.people,
                  color: const Color(0xFF3B82F6),
                  subtitle: 'registered users',
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: StatsCard(
                  title: 'Active Users',
                  value: controller.userStats.value.activeUsers.toString(),
                  icon: Icons.verified_user,
                  color: const Color(0xFF10B981),
                  subtitle: 'active accounts',
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: StatsCard(
                  title: 'New Today',
                  value: controller.userStats.value.newToday.toString(),
                  icon: Icons.person_add,
                  color: const Color(0xFF8B5CF6),
                  subtitle: 'joined today',
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: StatsCard(
                  title: 'Banned',
                  value: controller.userStats.value.bannedUsers.toString(),
                  icon: Icons.block,
                  color: const Color(0xFFEF4444),
                  subtitle: 'restricted users',
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: AdminSearchField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              hintText: 'Search users by name, email, or phone...',
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: AdminFilters(
              filters: [
                FilterOption(
                  key: 'status',
                  label: 'Status',
                  options: const [
                    FilterValue('all', 'All Status'),
                    FilterValue('active', 'Active'),
                    FilterValue('banned', 'Banned'),
                    FilterValue('pending', 'Pending'),
                    FilterValue('deleted', 'Deleted'),
                  ],
                  selectedValue: controller.selectedStatus.value,
                  onChanged: controller.onStatusFilterChanged,
                ),
                FilterOption(
                  key: 'userType',
                  label: 'User Type',
                  options: const [
                    FilterValue('all', 'All Types'),
                    FilterValue('regular', 'Regular'),
                    FilterValue('business', 'Business'),
                    FilterValue('verified', 'Verified'),
                  ],
                  selectedValue: controller.selectedUserType.value,
                  onChanged: controller.onUserTypeFilterChanged,
                ),
                FilterOption(
                  key: 'dateRange',
                  label: 'Created',
                  options: const [
                    FilterValue('all', 'All Time'),
                    FilterValue('today', 'Today'),
                    FilterValue('week', 'This Week'),
                    FilterValue('month', 'This Month'),
                    FilterValue('year', 'This Year'),
                  ],
                  selectedValue: controller.selectedDateRange.value,
                  onChanged: controller.onDateRangeFilterChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40.w,
                  child: Obx(() => Checkbox(
                    value: controller.isAllSelected,
                    onChanged: controller.toggleSelectAll,
                  )),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 3,
                  child: Text(
                    'User',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Type',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Activity',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Joined',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100.w,
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // Users list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.users.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.users.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  return _buildUserRow(user, index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(UserModel user, int index) {
    final isSelected = controller.selectedUsers.contains(user.id);
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40.w,
            child: Checkbox(
              value: isSelected,
              onChanged: (selected) => controller.toggleUserSelection(user.id),
            ),
          ),
          SizedBox(width: 16.w),
          
          // User info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? AppImage(
                          imageData: user.avatarUrl!,
                          width: 40.w,
                          height: 40.h,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Center(
                            child: Text(
                              user.displayName.isNotEmpty 
                                  ? user.displayName[0].toUpperCase() 
                                  : 'U',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                ),
                SizedBox(width: 12.w),
                
                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName.isNotEmpty ? user.displayName : 'No name',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.phone.isNotEmpty)
                        Text(
                          user.phone,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Status
          Expanded(
            child: _buildStatusChip(user.status),
          ),
          
          // User type
          Expanded(
            child: _buildUserTypeChip(user),
          ),
          
          // Activity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.lastSeenText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  '${user.tripCount} trips • ${user.reviewCount} reviews',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          
          // Joined
          Expanded(
            child: Text(
              user.memberSince,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          
          // Actions
          SizedBox(
            width: 100.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _showUserDetails(user),
                  icon: const Icon(Icons.visibility, size: 18),
                  tooltip: 'View Details',
                ),
                PopupMenuButton<String>(
                  onSelected: (action) => _handleUserAction(action, user),
                  itemBuilder: (context) => [
                    if (user.isActive)
                      const PopupMenuItem(
                        value: 'ban',
                        child: Row(
                          children: [
                            Icon(Icons.block, color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            Text('Ban User'),
                          ],
                        ),
                      )
                    else
                      const PopupMenuItem(
                        value: 'unban',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            SizedBox(width: 8),
                            Text('Unban User'),
                          ],
                        ),
                      ),
                    if (!user.isVerified)
                      const PopupMenuItem(
                        value: 'verify',
                        child: Row(
                          children: [
                            Icon(Icons.verified, color: Colors.blue, size: 16),
                            SizedBox(width: 8),
                            Text('Verify User'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'reset_password',
                      child: Row(
                        children: [
                          Icon(Icons.lock_reset, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text('Reset Password'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text('Delete User'),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(Icons.more_vert, size: 18),
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserTypeChip(UserModel user) {
    if (user.isVerified && user.isBusinessAccount) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
        ),
        child: Text(
          'VERIFIED BIZ',
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.purple,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (user.isVerified) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Text(
          'VERIFIED',
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (user.isBusinessAccount) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Text(
          'BUSINESS',
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Text(
        'REGULAR',
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80.r,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            controller.searchController.text.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Users will appear here once they start using the app',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: controller.refreshUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    Get.dialog(
      AdminUserDetailsDialog(user: user),
      barrierDismissible: true,
    );
  }

  void _handleUserAction(String action, UserModel user) async {
    switch (action) {
      case 'ban':
        await _confirmAndExecute(
          title: 'Ban User',
          message: 'Are you sure you want to ban ${user.displayName}?',
          action: () => controller.banUser(user.id),
        );
        break;
      case 'unban':
        await _confirmAndExecute(
          title: 'Unban User',
          message: 'Are you sure you want to unban ${user.displayName}?',
          action: () => controller.unbanUser(user.id),
        );
        break;
      case 'verify':
        await _confirmAndExecute(
          title: 'Verify User',
          message: 'Are you sure you want to verify ${user.displayName}?',
          action: () => controller.verifyUser(user.id),
        );
        break;
      case 'reset_password':
        await _confirmAndExecute(
          title: 'Reset Password',
          message: 'Send password reset email to ${user.email}?',
          action: () => controller.resetUserPassword(user.email),
        );
        break;
      case 'delete':
        await _confirmAndExecute(
          title: 'Delete User',
          message: 'Are you sure you want to permanently delete ${user.displayName}? This action cannot be undone.',
          action: () => controller.deleteUser(user.id),
          isDangerous: true,
        );
        break;
    }
  }

  Future<void> _confirmAndExecute({
    required String title,
    required String message,
    required VoidCallback action,
    bool isDangerous = false,
  }) async {
    final confirmed = await Get.dialog<bool>(
      AdminConfirmationDialog(
        title: title,
        message: message,
        isDangerous: isDangerous,
      ),
    );

    if (confirmed == true) {
      action();
    }
  }
}