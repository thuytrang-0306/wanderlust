import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/shared/core/services/user_service.dart';
import 'package:wanderlust/admin/services/admin_auth_service.dart';
import 'package:wanderlust/shared/core/models/user_model.dart';
import 'package:wanderlust/shared/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStats {
  final int totalUsers;
  final int activeUsers;
  final int bannedUsers;
  final int newToday;

  UserStats({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.bannedUsers = 0,
    this.newToday = 0,
  });
}

class AdminUserManagementController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final AdminAuthService _adminAuthService = Get.find<AdminAuthService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // UI State
  final RxBool isLoading = false.obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final Rx<UserStats> userStats = UserStats().obs;

  // Search and Filters
  final TextEditingController searchController = TextEditingController();
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedUserType = 'all'.obs;
  final RxString selectedDateRange = 'all'.obs;

  // Selection
  final RxSet<String> selectedUsers = <String>{}.obs;

  // Computed properties
  bool get isAllSelected => selectedUsers.length == users.length && users.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    loadUsers();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _setupListeners() {
    // Listen to real-time user changes
    ever(_userService.allUsers, (userList) {
      allUsers.value = userList as List<UserModel>;
      _updateStats();
      _applyFilters();
      LoggerService.i('Real-time user update: ${userList.length} users');
    });
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      
      // Load users via service
      await _userService.loadAllUsers();
      allUsers.value = _userService.allUsers;
      
      _updateStats();
      _applyFilters();
      
      LoggerService.i('Loaded ${allUsers.length} users successfully');
    } catch (e) {
      LoggerService.e('Error loading users', error: e);
      AppSnackbar.showError(message: 'Failed to load users');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateStats() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final total = allUsers.length;
    final active = allUsers.where((u) => u.isActive).length;
    final banned = allUsers.where((u) => u.isBanned).length;
    final newToday = allUsers.where((u) => u.createdAt.isAfter(startOfDay)).length;
    
    userStats.value = UserStats(
      totalUsers: total,
      activeUsers: active,
      bannedUsers: banned,
      newToday: newToday,
    );
  }

  void _applyFilters() {
    var filteredUsers = List<UserModel>.from(allUsers);

    // Apply search filter
    final searchQuery = searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        return user.name.toLowerCase().contains(searchQuery) ||
               user.email.toLowerCase().contains(searchQuery) ||
               user.phone.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Apply status filter
    if (selectedStatus.value != 'all') {
      filteredUsers = filteredUsers.where((user) => user.status == selectedStatus.value).toList();
    }

    // Apply user type filter
    switch (selectedUserType.value) {
      case 'business':
        filteredUsers = filteredUsers.where((user) => user.isBusinessAccount).toList();
        break;
      case 'verified':
        filteredUsers = filteredUsers.where((user) => user.isVerified).toList();
        break;
      case 'regular':
        filteredUsers = filteredUsers.where((user) => !user.isBusinessAccount && !user.isVerified).toList();
        break;
    }

    // Apply date range filter
    if (selectedDateRange.value != 'all') {
      final now = DateTime.now();
      DateTime startDate;
      
      switch (selectedDateRange.value) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(1970);
      }
      
      filteredUsers = filteredUsers.where((user) => user.createdAt.isAfter(startDate)).toList();
    }

    // Sort by creation date (newest first)
    filteredUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    users.value = filteredUsers;
    
    // Clear selection if users changed
    selectedUsers.removeWhere((id) => !users.any((user) => user.id == id));
  }

  // Search and Filter Methods
  void onSearchChanged(String query) {
    _applyFilters();
  }

  void onStatusFilterChanged(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void onUserTypeFilterChanged(String userType) {
    selectedUserType.value = userType;
    _applyFilters();
  }

  void onDateRangeFilterChanged(String dateRange) {
    selectedDateRange.value = dateRange;
    _applyFilters();
  }

  // Selection Methods
  void toggleUserSelection(String userId) {
    if (selectedUsers.contains(userId)) {
      selectedUsers.remove(userId);
    } else {
      selectedUsers.add(userId);
    }
  }

  void toggleSelectAll(bool? selectAll) {
    if (selectAll == true) {
      selectedUsers.addAll(users.map((user) => user.id));
    } else {
      selectedUsers.clear();
    }
  }

  // User Action Methods
  Future<void> banUser(String userId) async {
    try {
      isLoading.value = true;
      
      final success = await _userService.updateUser(userId, {
        'status': 'banned',
        'bannedAt': DateTime.now(),
        'bannedBy': _adminAuthService.currentAdmin?.id,
      });

      if (success) {
        LoggerService.i('Admin action: User banned - $userId by ${_adminAuthService.currentAdmin?.id}');
        AppSnackbar.showSuccess(message: 'User banned successfully');
      } else {
        AppSnackbar.showError(message: 'Failed to ban user');
      }
    } catch (e) {
      LoggerService.e('Error banning user', error: e);
      AppSnackbar.showError(message: 'Failed to ban user');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unbanUser(String userId) async {
    try {
      isLoading.value = true;
      
      final success = await _userService.updateUser(userId, {
        'status': 'active',
        'bannedAt': null,
        'unbannedBy': _adminAuthService.currentAdmin?.id,
        'unbannedAt': DateTime.now(),
      });

      if (success) {
        LoggerService.i('Admin action: User unbanned - $userId by ${_adminAuthService.currentAdmin?.id}');
        AppSnackbar.showSuccess(message: 'User unbanned successfully');
      } else {
        AppSnackbar.showError(message: 'Failed to unban user');
      }
    } catch (e) {
      LoggerService.e('Error unbanning user', error: e);
      AppSnackbar.showError(message: 'Failed to unban user');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyUser(String userId) async {
    try {
      isLoading.value = true;
      
      final success = await _userService.updateUser(userId, {
        'isVerified': true,
        'verifiedAt': DateTime.now(),
        'verifiedBy': _adminAuthService.currentAdmin?.id,
      });

      if (success) {
        LoggerService.i('Admin action: User verified - $userId by ${_adminAuthService.currentAdmin?.id}');
        AppSnackbar.showSuccess(message: 'User verified successfully');
      } else {
        AppSnackbar.showError(message: 'Failed to verify user');
      }
    } catch (e) {
      LoggerService.e('Error verifying user', error: e);
      AppSnackbar.showError(message: 'Failed to verify user');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetUserPassword(String email) async {
    try {
      isLoading.value = true;
      
      await _auth.sendPasswordResetEmail(email: email);
      
      LoggerService.i('Admin action: Password reset sent - $email by ${_adminAuthService.currentAdmin?.id}');
      
      AppSnackbar.showSuccess(message: 'Password reset email sent successfully');
    } catch (e) {
      LoggerService.e('Error sending password reset', error: e);
      AppSnackbar.showError(message: 'Failed to send password reset email');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      isLoading.value = true;
      
      final success = await _userService.deleteUser(userId);

      if (success) {
        LoggerService.i('Admin action: User deleted - $userId by ${_adminAuthService.currentAdmin?.id}');
        AppSnackbar.showSuccess(message: 'User deleted successfully');
        selectedUsers.remove(userId);
      } else {
        AppSnackbar.showError(message: 'Failed to delete user');
      }
    } catch (e) {
      LoggerService.e('Error deleting user', error: e);
      AppSnackbar.showError(message: 'Failed to delete user');
    } finally {
      isLoading.value = false;
    }
  }

  // Bulk Action Methods
  Future<void> bulkBanUsers() async {
    if (selectedUsers.isEmpty) return;
    
    try {
      isLoading.value = true;
      
      for (final userId in selectedUsers) {
        await _userService.updateUser(userId, {
          'status': 'banned',
          'bannedAt': DateTime.now(),
          'bannedBy': _adminAuthService.currentAdmin?.id,
        });
      }

      LoggerService.i('Admin action: Bulk ban ${selectedUsers.length} users by ${_adminAuthService.currentAdmin?.id}');
      
      AppSnackbar.showSuccess(message: '${selectedUsers.length} users banned successfully');
      selectedUsers.clear();
    } catch (e) {
      LoggerService.e('Error bulk banning users', error: e);
      AppSnackbar.showError(message: 'Failed to ban selected users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bulkVerifyUsers() async {
    if (selectedUsers.isEmpty) return;
    
    try {
      isLoading.value = true;
      
      for (final userId in selectedUsers) {
        await _userService.updateUser(userId, {
          'isVerified': true,
          'verifiedAt': DateTime.now(),
          'verifiedBy': _adminAuthService.currentAdmin?.id,
        });
      }

      LoggerService.i('Admin action: Bulk verify ${selectedUsers.length} users by ${_adminAuthService.currentAdmin?.id}');
      
      AppSnackbar.showSuccess(message: '${selectedUsers.length} users verified successfully');
      selectedUsers.clear();
    } catch (e) {
      LoggerService.e('Error bulk verifying users', error: e);
      AppSnackbar.showError(message: 'Failed to verify selected users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bulkDeleteUsers() async {
    if (selectedUsers.isEmpty) return;
    
    try {
      isLoading.value = true;
      
      for (final userId in selectedUsers) {
        await _userService.deleteUser(userId);
      }

      LoggerService.i('Admin action: Bulk delete ${selectedUsers.length} users by ${_adminAuthService.currentAdmin?.id}');
      
      AppSnackbar.showSuccess(message: '${selectedUsers.length} users deleted successfully');
      selectedUsers.clear();
    } catch (e) {
      LoggerService.e('Error bulk deleting users', error: e);
      AppSnackbar.showError(message: 'Failed to delete selected users');
    } finally {
      isLoading.value = false;
    }
  }

  // Export Methods
  Future<void> exportUsers() async {
    try {
      await _exportUsersToCSV(users);
      
      LoggerService.i('Admin action: Exported ${users.length} users to CSV by ${_adminAuthService.currentAdmin?.id}');
      
      AppSnackbar.showSuccess(message: 'Users exported successfully');
    } catch (e) {
      LoggerService.e('Error exporting users', error: e);
      AppSnackbar.showError(message: 'Failed to export users');
    }
  }

  Future<void> exportSelectedUsers() async {
    if (selectedUsers.isEmpty) return;
    
    try {
      final selectedUsersList = users.where((user) => selectedUsers.contains(user.id)).toList();
      await _exportUsersToCSV(selectedUsersList);
      
      LoggerService.i('Admin action: Exported ${selectedUsers.length} selected users to CSV by ${_adminAuthService.currentAdmin?.id}');
      
      AppSnackbar.showSuccess(message: '${selectedUsers.length} users exported successfully');
    } catch (e) {
      LoggerService.e('Error exporting selected users', error: e);
      AppSnackbar.showError(message: 'Failed to export selected users');
    }
  }

  Future<void> _exportUsersToCSV(List<UserModel> usersToExport) async {
    final csvData = StringBuffer();
    
    // Add header
    csvData.writeln('ID,Name,Email,Phone,Status,User Type,Verified,Business Account,Created At,Last Login,Trip Count,Review Count,Followers,Following');
    
    // Add data rows
    for (final user in usersToExport) {
      csvData.writeln([
        user.id,
        '"${user.name}"',
        user.email,
        user.phone,
        user.status,
        user.isBusinessAccount ? 'Business' : 'Regular',
        user.isVerified ? 'Yes' : 'No',
        user.isBusinessAccount ? 'Yes' : 'No',
        user.createdAt.toIso8601String(),
        user.lastLoginAt?.toIso8601String() ?? 'Never',
        user.tripCount,
        user.reviewCount,
        user.followersCount,
        user.followingCount,
      ].join(','));
    }
    
    // Create and download file
    final bytes = utf8.encode(csvData.toString());
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final filename = 'wanderlust_users_$timestamp.csv';
    
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = filename;
    
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    
    html.Url.revokeObjectUrl(url);
  }

  // Utility Methods
  Future<void> refreshUsers() async {
    selectedUsers.clear();
    await loadUsers();
  }
}