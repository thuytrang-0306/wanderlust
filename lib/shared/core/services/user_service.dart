import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger_service.dart';
import '../models/user_model.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';
  
  // Reactive lists
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs; // all, active, banned, pending
  
  // Statistics
  final RxInt totalUsers = 0.obs;
  final RxInt activeUsers = 0.obs;
  final RxInt bannedUsers = 0.obs;
  final RxInt newUsersToday = 0.obs;
  final RxInt newUsersThisWeek = 0.obs;
  final RxInt newUsersThisMonth = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadAllUsers();
    _setupRealtimeListener();
    _setupSearchListener();
    LoggerService.i('UserService initialized');
  }
  
  // Helper method to provide Firestore index creation instructions
  void _logIndexRequirement() {
    LoggerService.i('''
      === FIRESTORE INDEX REQUIRED ===
      Collection: user_activities
      Fields: userId (Ascending), timestamp (Descending)
      
      Create this index in Firebase Console:
      1. Go to Firestore Database
      2. Click "Indexes" tab
      3. Click "Create Index"
      4. Collection ID: user_activities
      5. Add fields:
         - userId: Ascending
         - timestamp: Descending
      6. Click "Create"
      
      Or use Firebase CLI:
      firebase firestore:indexes
      ===================================
    ''');
  }

  // Load all users from Firestore
  Future<void> loadAllUsers() async {
    try {
      isLoading.value = true;
      LoggerService.i('Loading all users from Firestore');
      
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();
      
      final List<UserModel> users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      
      allUsers.value = users;
      _applyFilters();
      _updateStatistics();
      
      LoggerService.i('Loaded ${users.length} users successfully');
    } catch (e, stackTrace) {
      LoggerService.e('Error loading users', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to load users: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Setup real-time listener for user changes
  void _setupRealtimeListener() {
    _firestore.collection(_collection).snapshots().listen(
      (QuerySnapshot snapshot) {
        LoggerService.d('Real-time user update received: ${snapshot.docs.length} users');
        
        final List<UserModel> users = snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList();
        
        allUsers.value = users;
        _applyFilters();
        _updateStatistics();
      },
      onError: (error) {
        LoggerService.e('Real-time user listener error', error: error);
      },
    );
  }

  // Setup search listener
  void _setupSearchListener() {
    // Listen to search query changes and apply filters
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedFilter, (_) => _applyFilters());
  }

  // Apply search and filter
  void _applyFilters() {
    List<UserModel> filtered = List.from(allUsers);
    
    // Apply status filter
    if (selectedFilter.value != 'all') {
      filtered = filtered.where((user) => user.status == selectedFilter.value).toList();
    }
    
    // Apply search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.phone.toLowerCase().contains(query);
      }).toList();
    }
    
    filteredUsers.value = filtered;
    LoggerService.d('Applied filters: ${filtered.length} users after filtering');
  }

  // Update statistics
  void _updateStatistics() {
    totalUsers.value = allUsers.length;
    activeUsers.value = allUsers.where((user) => user.status == 'active').length;
    bannedUsers.value = allUsers.where((user) => user.status == 'banned').length;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    
    newUsersToday.value = allUsers.where((user) {
      final userDate = DateTime(
        user.createdAt.year,
        user.createdAt.month,
        user.createdAt.day,
      );
      return userDate == today;
    }).length;
    
    newUsersThisWeek.value = allUsers.where((user) => 
        user.createdAt.isAfter(weekAgo)).length;
    
    newUsersThisMonth.value = allUsers.where((user) => 
        user.createdAt.isAfter(monthAgo)).length;
        
    LoggerService.d('Statistics updated: Total: ${totalUsers.value}, Active: ${activeUsers.value}');
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      LoggerService.d('Fetching user by ID: $userId');
      
      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final user = UserModel.fromFirestore(doc);
        LoggerService.d('User found: ${user.name}');
        return user;
      } else {
        LoggerService.w('User not found with ID: $userId');
        return null;
      }
    } catch (e, stackTrace) {
      LoggerService.e('Error fetching user by ID', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Update user
  Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      LoggerService.i('Updating user: $userId with data: $updates');
      
      // Add timestamp
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(_collection).doc(userId).update(updates);
      
      LoggerService.i('User updated successfully: $userId');
      Get.snackbar('Success', 'User updated successfully');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error updating user', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to update user: ${e.toString()}');
      return false;
    }
  }

  // Ban/Unban user
  Future<bool> toggleUserBan(String userId, bool shouldBan) async {
    try {
      final action = shouldBan ? 'ban' : 'unban';
      LoggerService.i('${action.capitalize} user: $userId');
      
      await updateUser(userId, {
        'status': shouldBan ? 'banned' : 'active',
        'bannedAt': shouldBan ? FieldValue.serverTimestamp() : null,
      });
      
      Get.snackbar(
        'Success', 
        'User ${shouldBan ? 'banned' : 'unbanned'} successfully',
      );
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error toggling user ban', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Delete user (soft delete - mark as deleted)
  Future<bool> deleteUser(String userId) async {
    try {
      LoggerService.w('Deleting user: $userId');
      
      await updateUser(userId, {
        'status': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
      });
      
      LoggerService.w('User marked as deleted: $userId');
      Get.snackbar('Success', 'User deleted successfully');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error deleting user', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Permanent delete user (use with caution)
  Future<bool> permanentDeleteUser(String userId) async {
    try {
      LoggerService.wtf('PERMANENT DELETE user: $userId');
      
      await _firestore.collection(_collection).doc(userId).delete();
      
      LoggerService.wtf('User permanently deleted: $userId');
      Get.snackbar('Success', 'User permanently deleted');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error permanently deleting user', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Get user activity/login history
  Future<List<Map<String, dynamic>>> getUserActivity(String userId) async {
    try {
      LoggerService.d('Fetching user activity: $userId');
      
      // Try compound query first, fallback to simple query if index missing
      QuerySnapshot? snapshot;
      try {
        snapshot = await _firestore
            .collection('user_activities')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .limit(50)
            .get();
      } catch (e) {
        if (e.toString().contains('requires an index')) {
          LoggerService.w('Composite index missing, using simple query');
          _logIndexRequirement(); // Provide index creation instructions
          // Fallback to simple query without ordering
          snapshot = await _firestore
              .collection('user_activities')
              .where('userId', isEqualTo: userId)
              .limit(50)
              .get();
        } else {
          rethrow;
        }
      }
      
      final activities = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      
      // Sort manually if we used the fallback query
      if (activities.isNotEmpty && activities.first['timestamp'] != null) {
        activities.sort((a, b) {
          final aTime = a['timestamp'] as Timestamp?;
          final bTime = b['timestamp'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime); // descending order
        });
      }
      
      LoggerService.d('User activity loaded: ${activities.length} records');
      return activities;
    } catch (e, stackTrace) {
      LoggerService.e('Error fetching user activity', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Search methods
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  // Export users data
  Future<List<Map<String, dynamic>>> getExportData() async {
    try {
      LoggerService.i('Preparing user export data');
      
      return filteredUsers.map((user) => {
        'ID': user.id,
        'Name': user.name,
        'Email': user.email,
        'Phone': user.phone,
        'Status': user.status,
        'Created At': user.createdAt.toIso8601String(),
        'Last Login': user.lastLoginAt?.toIso8601String() ?? 'Never',
        'Trip Count': user.tripCount,
        'Review Count': user.reviewCount,
      }).toList();
    } catch (e, stackTrace) {
      LoggerService.e('Error preparing export data', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    LoggerService.i('Refreshing user data');
    await loadAllUsers();
  }
}