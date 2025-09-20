import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/controllers/admin_user_management_controller.dart';
import 'package:wanderlust/shared/core/models/user_model.dart';
import 'package:wanderlust/core/widgets/app_image.dart';

class UserEditDialog extends StatefulWidget {
  final UserModel user;

  const UserEditDialog({
    super.key,
    required this.user,
  });

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminUserManagementController _controller = Get.find<AdminUserManagementController>();
  
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _languageController;
  late TextEditingController _timezoneController;
  
  // Form state
  String _selectedStatus = '';
  bool _isVerified = false;
  bool _isBusinessAccount = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _disposeControllers();
    super.dispose();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.user.displayName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _locationController = TextEditingController(text: widget.user.location ?? '');
    _languageController = TextEditingController(text: widget.user.language ?? '');
    _timezoneController = TextEditingController(text: widget.user.timezone ?? '');
    
    _selectedStatus = widget.user.status;
    _isVerified = widget.user.isVerified;
    _isBusinessAccount = widget.user.isBusinessAccount;
  }

  void _disposeControllers() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _languageController.dispose();
    _timezoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 800.w,
        height: 700.h,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProfileTab(),
                  _buildPermissionsTab(),
                  _buildActionsTab(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 24.r,
            backgroundColor: const Color(0xFFF3F4F6),
            child: widget.user.avatarUrl?.isNotEmpty == true
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: AppImage(
                      imageData: widget.user.avatarUrl!,
                      width: 48.w,
                      height: 48.h,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: const Color(0xFF9CA3AF),
                    size: 28.sp,
                  ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit User: ${widget.user.displayName}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.user.email,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _buildStatusChip(),
          SizedBox(width: 12.w),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            iconSize: 24.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    switch (_selectedStatus.toLowerCase()) {
      case 'active':
        color = const Color(0xFF10B981);
        break;
      case 'suspended':
        color = const Color(0xFFF59E0B);
        break;
      case 'banned':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = const Color(0xFF6B7280);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _selectedStatus.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF3B82F6),
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorColor: const Color(0xFF3B82F6),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 16.sp),
                SizedBox(width: 8.w),
                Text('Profile'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, size: 16.sp),
                SizedBox(width: 8.w),
                Text('Permissions'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings, size: 16.sp),
                SizedBox(width: 8.w),
                Text('Actions'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Display Name',
                  _nameController,
                  'Enter user\'s display name',
                  Icons.person,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildTextField(
                  'Email Address',
                  _emailController,
                  'Enter user\'s email',
                  Icons.email,
                  enabled: false, // Email usually shouldn't be editable
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Phone Number',
                  _phoneController,
                  'Enter user\'s phone',
                  Icons.phone,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildTextField(
                  'Location',
                  _locationController,
                  'Enter user\'s location',
                  Icons.location_on,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          _buildTextField(
            'Bio',
            _bioController,
            'Enter user\'s bio',
            Icons.info,
            maxLines: 3,
          ),
          
          SizedBox(height: 24.h),
          
          // Preferences
          Text(
            'Preferences',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Language',
                  _languageController,
                  'e.g., en, vi, fr',
                  Icons.language,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildTextField(
                  'Timezone',
                  _timezoneController,
                  'e.g., Asia/Ho_Chi_Minh',
                  Icons.access_time,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Status
          Text(
            'Account Status',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'User Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    prefixIcon: const Icon(Icons.flag),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                    DropdownMenuItem(value: 'banned', child: Text('Banned')),
                  ],
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Account Privileges
          Text(
            'Account Privileges',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  'Verified Account',
                  'User has verified their email/phone',
                  Icons.verified,
                  _isVerified,
                  (value) => setState(() => _isVerified = value),
                ),
                Divider(height: 1.h),
                _buildSwitchTile(
                  'Business Account',
                  'User can create business listings',
                  Icons.business,
                  _isBusinessAccount,
                  (value) => setState(() => _isBusinessAccount = value),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Warning for status changes
          if (_selectedStatus != widget.user.status)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: const Color(0xFFD97706),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Changing user status will affect their access to the platform.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Statistics (Read-only)
          Text(
            'User Statistics',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Trips', widget.user.tripCount.toString(), Icons.map),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard('Reviews', widget.user.reviewCount.toString(), Icons.rate_review),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard('Followers', widget.user.followersCount.toString(), Icons.people),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard('Following', widget.user.followingCount.toString(), Icons.person_add),
              ),
            ],
          ),
          
          SizedBox(height: 32.h),
          
          // Dangerous Actions
          Text(
            'Dangerous Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFDC2626),
            ),
          ),
          SizedBox(height: 16.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Column(
              children: [
                _buildDangerousActionButton(
                  'Reset Password',
                  'Send password reset email to user',
                  Icons.lock_reset,
                  const Color(0xFF3B82F6),
                  () => _showResetPasswordDialog(),
                ),
                SizedBox(height: 12.h),
                _buildDangerousActionButton(
                  'Suspend Account',
                  'Temporarily disable user access',
                  Icons.pause_circle,
                  const Color(0xFFF59E0B),
                  () => _showSuspendDialog(),
                ),
                SizedBox(height: 12.h),
                _buildDangerousActionButton(
                  'Delete Account',
                  'Permanently delete user and all data',
                  Icons.delete_forever,
                  const Color(0xFFDC2626),
                  () => _showDeleteDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            filled: !enabled,
            fillColor: !enabled ? const Color(0xFFF9FAFB) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6B7280)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF6B7280),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF3B82F6),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF3B82F6),
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerousActionButton(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          padding: EdgeInsets.all(12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() async {
    setState(() => _isLoading = true);
    
    try {
      // Create updated user model
      final updatedUser = UserModel(
        id: widget.user.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        status: _selectedStatus,
        createdAt: widget.user.createdAt,
        updatedAt: DateTime.now(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        language: _languageController.text.trim().isEmpty ? null : _languageController.text.trim(),
        timezone: _timezoneController.text.trim().isEmpty ? null : _timezoneController.text.trim(),
        isVerified: _isVerified,
        isBusinessAccount: _isBusinessAccount,
      );
      
      await _controller.updateUser(widget.user.id, updatedUser);
      Get.back();
      Get.snackbar(
        'Success',
        'User updated successfully',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update user: $e',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showResetPasswordDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Send a password reset email to ${widget.user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _controller.resetUserPassword(widget.user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Suspend Account'),
        content: Text('Suspend ${widget.user.displayName}\'s account?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _controller.suspendUser(widget.user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
            ),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This will permanently delete ${widget.user.displayName}\'s account and ALL associated data.'),
            SizedBox(height: 16.h),
            Text(
              'This action cannot be undone!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _controller.deleteUser(widget.user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}