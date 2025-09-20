import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wanderlust/shared/core/utils/logger_service.dart';
import 'package:wanderlust/shared/data/models/business_profile_model.dart';
import 'package:wanderlust/admin/services/admin_auth_service.dart';

class AdminBusinessService extends GetxService {
  static AdminBusinessService get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminAuthService _adminAuthService = Get.find<AdminAuthService>();
  final String _collection = 'business_profiles';
  
  // Reactive lists
  final RxList<BusinessProfileModel> allBusinesses = <BusinessProfileModel>[].obs;
  final RxList<BusinessProfileModel> filteredBusinesses = <BusinessProfileModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs; // all, pending, verified, rejected, expired
  final RxString selectedType = 'all'.obs; // all, hotel, tour, restaurant, service
  
  // Statistics
  final RxInt totalBusinesses = 0.obs;
  final RxInt pendingBusinesses = 0.obs;
  final RxInt verifiedBusinesses = 0.obs;
  final RxInt rejectedBusinesses = 0.obs;
  final RxInt newBusinessesToday = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadAllBusinesses();
    _setupRealtimeListener();
    _setupSearchListener();
    LoggerService.i('AdminBusinessService initialized');
  }
  
  // Load all businesses from Firestore
  Future<void> loadAllBusinesses() async {
    try {
      isLoading.value = true;
      LoggerService.i('Loading all businesses from Firestore');
      
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();
      
      final List<BusinessProfileModel> businesses = snapshot.docs
          .map((doc) => BusinessProfileModel.fromJson(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      allBusinesses.value = businesses;
      _applyFilters();
      _updateStatistics();
      
      LoggerService.i('Loaded ${businesses.length} businesses successfully');
    } catch (e, stackTrace) {
      LoggerService.e('Error loading businesses', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to load businesses: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Setup real-time listener for business changes
  void _setupRealtimeListener() {
    _firestore.collection(_collection).snapshots().listen(
      (QuerySnapshot snapshot) {
        LoggerService.d('Real-time business update received: ${snapshot.docs.length} businesses');
        
        final List<BusinessProfileModel> businesses = snapshot.docs
            .map((doc) => BusinessProfileModel.fromJson(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        
        allBusinesses.value = businesses;
        _applyFilters();
        _updateStatistics();
      },
      onError: (error) {
        LoggerService.e('Real-time business listener error', error: error);
      },
    );
  }

  // Setup search listener
  void _setupSearchListener() {
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedFilter, (_) => _applyFilters());
    ever(selectedType, (_) => _applyFilters());
  }

  // Apply search and filter
  void _applyFilters() {
    List<BusinessProfileModel> filtered = List.from(allBusinesses);
    
    // Apply verification status filter
    if (selectedFilter.value != 'all') {
      filtered = filtered.where((business) => 
          business.verificationStatus.value == selectedFilter.value).toList();
    }
    
    // Apply business type filter
    if (selectedType.value != 'all') {
      filtered = filtered.where((business) => 
          business.businessType.value == selectedType.value).toList();
    }
    
    // Apply search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((business) {
        return business.businessName.toLowerCase().contains(query) ||
            business.businessEmail.toLowerCase().contains(query) ||
            business.businessPhone.toLowerCase().contains(query) ||
            business.address.toLowerCase().contains(query);
      }).toList();
    }
    
    filteredBusinesses.value = filtered;
    LoggerService.d('Applied filters: ${filtered.length} businesses after filtering');
  }

  // Update statistics
  void _updateStatistics() {
    totalBusinesses.value = allBusinesses.length;
    pendingBusinesses.value = allBusinesses.where((business) => 
        business.verificationStatus == VerificationStatus.pending).length;
    verifiedBusinesses.value = allBusinesses.where((business) => 
        business.verificationStatus == VerificationStatus.verified).length;
    rejectedBusinesses.value = allBusinesses.where((business) => 
        business.verificationStatus == VerificationStatus.rejected).length;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    newBusinessesToday.value = allBusinesses.where((business) {
      final businessDate = DateTime(
        business.createdAt.year,
        business.createdAt.month,
        business.createdAt.day,
      );
      return businessDate == today;
    }).length;
        
    LoggerService.d('Statistics updated: Total: ${totalBusinesses.value}, Pending: ${pendingBusinesses.value}');
  }

  // Get business by ID
  Future<BusinessProfileModel?> getBusinessById(String businessId) async {
    try {
      LoggerService.d('Fetching business by ID: $businessId');
      
      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(businessId)
          .get();
      
      if (doc.exists) {
        final business = BusinessProfileModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
        LoggerService.d('Business found: ${business.businessName}');
        return business;
      } else {
        LoggerService.w('Business not found with ID: $businessId');
        return null;
      }
    } catch (e, stackTrace) {
      LoggerService.e('Error fetching business by ID', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Approve business verification
  Future<bool> approveBusiness(String businessId, {String? notes}) async {
    try {
      LoggerService.i('Approving business: $businessId');
      
      final updates = {
        'verificationStatus': VerificationStatus.verified.value,
        'verifiedAt': FieldValue.serverTimestamp(),
        'verifiedBy': _adminAuthService.currentAdmin?.id,
        'verificationNotes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection(_collection).doc(businessId).update(updates);
      
      // Log admin activity
      await _logAdminActivity(
        action: 'business_approved',
        targetId: businessId,
        details: {'notes': notes},
      );
      
      LoggerService.i('Business approved successfully: $businessId');
      Get.snackbar('Success', 'Business verification approved');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error approving business', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to approve business: ${e.toString()}');
      return false;
    }
  }

  // Reject business verification
  Future<bool> rejectBusiness(String businessId, {required String reason}) async {
    try {
      LoggerService.i('Rejecting business: $businessId');
      
      final updates = {
        'verificationStatus': VerificationStatus.rejected.value,
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': _adminAuthService.currentAdmin?.id,
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection(_collection).doc(businessId).update(updates);
      
      // Log admin activity
      await _logAdminActivity(
        action: 'business_rejected',
        targetId: businessId,
        details: {'reason': reason},
      );
      
      LoggerService.i('Business rejected successfully: $businessId');
      Get.snackbar('Success', 'Business verification rejected');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error rejecting business', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to reject business: ${e.toString()}');
      return false;
    }
  }

  // Suspend business (temporary deactivation)
  Future<bool> suspendBusiness(String businessId, {required String reason}) async {
    try {
      LoggerService.i('Suspending business: $businessId');
      
      final updates = {
        'isActive': false,
        'suspendedAt': FieldValue.serverTimestamp(),
        'suspendedBy': _adminAuthService.currentAdmin?.id,
        'suspensionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection(_collection).doc(businessId).update(updates);
      
      // Log admin activity
      await _logAdminActivity(
        action: 'business_suspended',
        targetId: businessId,
        details: {'reason': reason},
      );
      
      LoggerService.i('Business suspended successfully: $businessId');
      Get.snackbar('Success', 'Business suspended');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error suspending business', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to suspend business: ${e.toString()}');
      return false;
    }
  }

  // Reactivate business
  Future<bool> reactivateBusiness(String businessId) async {
    try {
      LoggerService.i('Reactivating business: $businessId');
      
      final updates = {
        'isActive': true,
        'reactivatedAt': FieldValue.serverTimestamp(),
        'reactivatedBy': _adminAuthService.currentAdmin?.id,
        'suspendedAt': null,
        'suspensionReason': null,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection(_collection).doc(businessId).update(updates);
      
      // Log admin activity
      await _logAdminActivity(
        action: 'business_reactivated',
        targetId: businessId,
      );
      
      LoggerService.i('Business reactivated successfully: $businessId');
      Get.snackbar('Success', 'Business reactivated');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error reactivating business', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to reactivate business: ${e.toString()}');
      return false;
    }
  }

  // Update business information (admin override)
  Future<bool> updateBusinessInfo(String businessId, Map<String, dynamic> updates) async {
    try {
      LoggerService.i('Updating business info: $businessId');
      
      // Add admin metadata
      updates.addAll({
        'lastModifiedBy': _adminAuthService.currentAdmin?.id,
        'lastModifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      await _firestore.collection(_collection).doc(businessId).update(updates);
      
      // Log admin activity
      await _logAdminActivity(
        action: 'business_info_updated',
        targetId: businessId,
        details: {'fields': updates.keys.toList()},
      );
      
      LoggerService.i('Business info updated successfully: $businessId');
      Get.snackbar('Success', 'Business information updated');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error updating business info', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to update business: ${e.toString()}');
      return false;
    }
  }

  // Get business verification history
  Future<List<Map<String, dynamic>>> getBusinessHistory(String businessId) async {
    try {
      LoggerService.d('Fetching business history: $businessId');
      
      final QuerySnapshot snapshot = await _firestore
          .collection('admin_activities')
          .where('targetId', isEqualTo: businessId)
          .where('action', whereIn: [
            'business_approved',
            'business_rejected',
            'business_suspended',
            'business_reactivated',
            'business_info_updated'
          ])
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      final history = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      
      LoggerService.d('Business history loaded: ${history.length} records');
      return history;
    } catch (e, stackTrace) {
      LoggerService.e('Error fetching business history', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Log admin activity
  Future<void> _logAdminActivity({
    required String action,
    required String targetId,
    Map<String, dynamic>? details,
  }) async {
    try {
      await _firestore.collection('admin_activities').add({
        'adminId': _adminAuthService.currentAdmin?.id,
        'adminEmail': _adminAuthService.currentAdmin?.email,
        'action': action,
        'targetType': 'business',
        'targetId': targetId,
        'details': details ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': 'admin_panel', // Could get real IP in production
      });
    } catch (e) {
      LoggerService.e('Error logging admin activity', error: e);
    }
  }

  // Search methods
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateStatusFilter(String filter) {
    selectedFilter.value = filter;
  }

  void updateTypeFilter(String type) {
    selectedType.value = type;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  // Export businesses data
  Future<List<Map<String, dynamic>>> getExportData() async {
    try {
      LoggerService.i('Preparing business export data');
      
      return filteredBusinesses.map((business) => {
        'ID': business.id,
        'Business Name': business.businessName,
        'Type': business.businessType.displayName,
        'Email': business.businessEmail,
        'Phone': business.businessPhone,
        'Address': business.address,
        'Status': business.verificationStatus.displayName,
        'Rating': business.formattedRating,
        'Total Reviews': business.totalReviews,
        'Created At': business.createdAt.toIso8601String(),
        'Verified At': business.verifiedAt?.toIso8601String() ?? 'Not verified',
        'Is Active': business.isActive ? 'Active' : 'Suspended',
      }).toList();
    } catch (e, stackTrace) {
      LoggerService.e('Error preparing export data', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    LoggerService.i('Refreshing business data');
    await loadAllBusinesses();
  }

  // Bulk operations
  Future<bool> bulkApproveBusiness(List<String> businessIds) async {
    try {
      final batch = _firestore.batch();
      
      for (final businessId in businessIds) {
        final docRef = _firestore.collection(_collection).doc(businessId);
        batch.update(docRef, {
          'verificationStatus': VerificationStatus.verified.value,
          'verifiedAt': FieldValue.serverTimestamp(),
          'verifiedBy': _adminAuthService.currentAdmin?.id,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      
      LoggerService.i('Bulk approved ${businessIds.length} businesses');
      Get.snackbar('Success', '${businessIds.length} businesses approved');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error bulk approving businesses', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to bulk approve businesses');
      return false;
    }
  }
}