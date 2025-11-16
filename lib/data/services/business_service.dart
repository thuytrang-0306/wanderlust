import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:wanderlust/data/models/business_profile_model.dart';
import 'package:wanderlust/data/models/user_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/shared/core/services/notification_service.dart';
import 'package:wanderlust/shared/data/models/notification_model.dart';

class BusinessService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collections
  static const String _businessProfilesCollection = 'business_profiles';
  static const String _usersCollection = 'users';
  
  // Current business profile
  final Rxn<BusinessProfileModel> currentBusinessProfile = Rxn<BusinessProfileModel>();
  
  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;
  
  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        LoggerService.i('User logged in: ${user.uid}, loading business profile...');
        loadCurrentBusinessProfile();
      } else {
        LoggerService.i('User logged out, clearing business profile...');
        currentBusinessProfile.value = null;
      }
    });
    
    // Load immediately if user exists
    if (_userId != null) {
      loadCurrentBusinessProfile();
    }
  }
  
  /// Load current user's business profile
  Future<void> loadCurrentBusinessProfile() async {
    try {
      if (_userId == null) return;
      
      final snapshot = await _firestore
          .collection(_businessProfilesCollection)
          .where('userId', isEqualTo: _userId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        currentBusinessProfile.value = BusinessProfileModel.fromJson(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
        LoggerService.i('Business profile loaded');
      }
    } catch (e) {
      LoggerService.e('Error loading business profile', error: e);
    }
  }
  
  /// Create business profile
  Future<BusinessProfileModel?> createBusinessProfile({
    required String businessName,
    required BusinessType businessType,
    required String businessPhone,
    required String businessEmail,
    required String address,
    required String description,
    String? taxNumber,
    String? verificationDoc,
    List<String>? services,
  }) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Check if user already has a business profile
      final existing = await getBusinessProfileByUserId(_userId!);
      if (existing != null) {
        throw Exception('User already has a business profile');
      }
      
      // Create business profile
      final businessProfile = BusinessProfileModel(
        id: '',
        userId: _userId!,
        businessName: businessName,
        businessType: businessType,
        businessPhone: businessPhone,
        businessEmail: businessEmail,
        address: address,
        description: description,
        taxNumber: taxNumber,
        verificationDoc: verificationDoc,
        services: services,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to Firestore
      final docRef = await _firestore
          .collection(_businessProfilesCollection)
          .add(businessProfile.toJson());
      
      // Update user document with business info
      await _updateUserBusinessInfo(docRef.id);
      
      // Send business registration pending notification
      _sendBusinessRegistrationNotification(_userId!, businessName);
      
      // Return created profile with ID (use the original object, not from JSON)
      currentBusinessProfile.value = BusinessProfileModel(
        id: docRef.id,
        userId: businessProfile.userId,
        businessName: businessProfile.businessName,
        businessType: businessProfile.businessType,
        taxNumber: businessProfile.taxNumber,
        businessPhone: businessProfile.businessPhone,
        businessEmail: businessProfile.businessEmail,
        address: businessProfile.address,
        description: businessProfile.description,
        verificationDoc: businessProfile.verificationDoc,
        verificationStatus: businessProfile.verificationStatus,
        verifiedAt: businessProfile.verifiedAt,
        rating: businessProfile.rating,
        totalReviews: businessProfile.totalReviews,
        totalListings: businessProfile.totalListings,
        socialLinks: businessProfile.socialLinks,
        businessImages: businessProfile.businessImages,
        operatingHours: businessProfile.operatingHours,
        services: businessProfile.services,
        createdAt: businessProfile.createdAt,
        updatedAt: businessProfile.updatedAt,
        isActive: businessProfile.isActive,
      );
      
      LoggerService.i('Business profile created: ${docRef.id}');
      return currentBusinessProfile.value;
    } catch (e) {
      LoggerService.e('Error creating business profile', error: e);
      rethrow;
    }
  }
  
  /// Update user document with business info
  Future<void> _updateUserBusinessInfo(String businessProfileId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(_userId)
          .update({
        'userType': UserType.business.value,
        'businessProfileId': businessProfileId,
        'businessSince': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      LoggerService.i('User updated to business type');
    } catch (e) {
      LoggerService.e('Error updating user business info', error: e);
    }
  }
  
  /// Get business profile by user ID
  Future<BusinessProfileModel?> getBusinessProfileByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_businessProfilesCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      return BusinessProfileModel.fromJson(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } catch (e) {
      LoggerService.e('Error getting business profile', error: e);
      return null;
    }
  }
  
  /// Get business profile by ID
  Future<BusinessProfileModel?> getBusinessProfile(String profileId) async {
    try {
      final doc = await _firestore
          .collection(_businessProfilesCollection)
          .doc(profileId)
          .get();
      
      if (!doc.exists) return null;
      
      return BusinessProfileModel.fromJson(doc.data()!, doc.id);
    } catch (e) {
      LoggerService.e('Error getting business profile', error: e);
      return null;
    }
  }
  
  /// Update business profile
  Future<bool> updateBusinessProfile({
    required String profileId,
    String? businessName,
    String? businessPhone,
    String? businessEmail,
    String? address,
    String? description,
    String? taxNumber,
    List<String>? businessImages,
    Map<String, dynamic>? operatingHours,
    List<String>? services,
    Map<String, dynamic>? socialLinks,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (businessName != null) updates['businessName'] = businessName;
      if (businessPhone != null) updates['businessPhone'] = businessPhone;
      if (businessEmail != null) updates['businessEmail'] = businessEmail;
      if (address != null) updates['address'] = address;
      if (description != null) updates['description'] = description;
      if (taxNumber != null) updates['taxNumber'] = taxNumber;
      if (businessImages != null) updates['businessImages'] = businessImages;
      if (operatingHours != null) updates['operatingHours'] = operatingHours;
      if (services != null) updates['services'] = services;
      if (socialLinks != null) updates['socialLinks'] = socialLinks;
      
      await _firestore
          .collection(_businessProfilesCollection)
          .doc(profileId)
          .update(updates);
      
      // Reload current profile if it's the updated one
      if (currentBusinessProfile.value?.id == profileId) {
        await loadCurrentBusinessProfile();
      }
      
      LoggerService.i('Business profile updated: $profileId');
      return true;
    } catch (e) {
      LoggerService.e('Error updating business profile', error: e);
      return false;
    }
  }
  
  /// Submit verification document
  Future<bool> submitVerification({
    required String profileId,
    required String verificationDoc,
  }) async {
    try {
      await _firestore
          .collection(_businessProfilesCollection)
          .doc(profileId)
          .update({
        'verificationDoc': verificationDoc,
        'verificationStatus': VerificationStatus.pending.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      LoggerService.i('Verification submitted for: $profileId');
      return true;
    } catch (e) {
      LoggerService.e('Error submitting verification', error: e);
      return false;
    }
  }
  
  /// Get business profiles by type
  Future<List<BusinessProfileModel>> getBusinessesByType(
    BusinessType type, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_businessProfilesCollection)
          .where('businessType', isEqualTo: type.value)
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => BusinessProfileModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting businesses by type', error: e);
      return [];
    }
  }
  
  /// Get verified businesses
  Future<List<BusinessProfileModel>> getVerifiedBusinesses({
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_businessProfilesCollection)
          .where('verificationStatus', isEqualTo: VerificationStatus.verified.value)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => BusinessProfileModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting verified businesses', error: e);
      return [];
    }
  }
  
  /// Search businesses
  Future<List<BusinessProfileModel>> searchBusinesses(String query) async {
    try {
      // Simple search by business name (case-insensitive)
      // For more advanced search, consider using Algolia or ElasticSearch
      final snapshot = await _firestore
          .collection(_businessProfilesCollection)
          .where('isActive', isEqualTo: true)
          .get();
      
      final businesses = snapshot.docs
          .map((doc) => BusinessProfileModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // Filter locally for now
      final searchQuery = query.toLowerCase();
      return businesses
          .where((business) =>
              business.businessName.toLowerCase().contains(searchQuery) ||
              business.description.toLowerCase().contains(searchQuery) ||
              business.services?.any((service) =>
                  service.toLowerCase().contains(searchQuery)) == true)
          .toList();
    } catch (e) {
      LoggerService.e('Error searching businesses', error: e);
      return [];
    }
  }
  
  /// Get business statistics
  Future<Map<String, dynamic>> getBusinessStats(String profileId) async {
    try {
      // This would aggregate data from various collections
      // For now, return basic stats
      return {
        'totalViews': 0,
        'totalBookings': 0,
        'totalReviews': 0,
        'averageRating': 0.0,
        'monthlyEarnings': 0.0,
      };
    } catch (e) {
      LoggerService.e('Error getting business stats', error: e);
      return {};
    }
  }
  
  /// Toggle business active status
  Future<bool> toggleBusinessActive(String profileId, bool isActive) async {
    try {
      await _firestore
          .collection(_businessProfilesCollection)
          .doc(profileId)
          .update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      LoggerService.i('Business active status updated: $isActive');
      return true;
    } catch (e) {
      LoggerService.e('Error toggling business active status', error: e);
      return false;
    }
  }
  
  /// Check if current user has business profile
  bool get hasBusinessProfile => currentBusinessProfile.value != null;
  
  /// Check if current business is verified
  bool get isBusinessVerified => 
      currentBusinessProfile.value?.isVerified ?? false;

  // ============ ADMIN BUSINESS MANAGEMENT ============

  /// Admin approve business (Admin only)
  Future<bool> approveBusinessProfile({
    required String profileId,
    String? adminMessage,
  }) async {
    try {
      // Update business profile
      await _firestore
          .collection(_businessProfilesCollection)
          .doc(profileId)
          .update({
        'verificationStatus': VerificationStatus.verified.value,
        'verifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (adminMessage != null) 'adminMessage': adminMessage,
      });

      // Get business profile to send notification
      final businessProfile = await getBusinessProfile(profileId);
      if (businessProfile != null) {
        _sendBusinessApprovalNotification(
          businessProfile.userId,
          businessProfile.businessName,
        );
      }

      LoggerService.i('Business approved: $profileId');
      return true;
    } catch (e) {
      LoggerService.e('Error approving business', error: e);
      return false;
    }
  }

  /// Admin reject business (Admin only)
  Future<bool> rejectBusinessProfile({
    required String profileId,
    required String rejectionReason,
    String? adminMessage,
  }) async {
    try {
      // Update business profile
      await _firestore
          .collection(_businessProfilesCollection)
          .doc(profileId)
          .update({
        'verificationStatus': VerificationStatus.rejected.value,
        'rejectionReason': rejectionReason,
        'updatedAt': FieldValue.serverTimestamp(),
        if (adminMessage != null) 'adminMessage': adminMessage,
      });

      // Get business profile to send notification
      final businessProfile = await getBusinessProfile(profileId);
      if (businessProfile != null) {
        _sendBusinessRejectionNotification(
          businessProfile.userId,
          rejectionReason,
        );
      }

      LoggerService.i('Business rejected: $profileId');
      return true;
    } catch (e) {
      LoggerService.e('Error rejecting business', error: e);
      return false;
    }
  }

  /// Admin suspend business (Admin only)
  Future<bool> suspendBusinessProfile({
    required String profileId,
    required String suspensionReason,
    String? adminMessage,
  }) async {
    try {
      // Update business profile
      await _firestore
          .collection(_businessProfilesCollection)
          .doc(profileId)
          .update({
        'verificationStatus': VerificationStatus.rejected.value,
        'suspensionReason': suspensionReason,
        'isActive': false,
        'suspendedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (adminMessage != null) 'adminMessage': adminMessage,
      });

      // Get business profile to send notification
      final businessProfile = await getBusinessProfile(profileId);
      if (businessProfile != null) {
        _sendBusinessSuspensionNotification(
          businessProfile.userId,
          businessProfile.businessName,
          suspensionReason,
        );
      }

      LoggerService.i('Business suspended: $profileId');
      return true;
    } catch (e) {
      LoggerService.e('Error suspending business', error: e);
      return false;
    }
  }

  // ============ NOTIFICATION HELPERS ============

  /// Send business registration notification (non-blocking)
  void _sendBusinessRegistrationNotification(String userId, String businessName) {
    try {
      if (Get.isRegistered<NotificationService>()) {
        NotificationService.to.sendBusinessRegistrationNotification(userId);
        LoggerService.d('Business registration notification sent for: $businessName');
      }
    } catch (e) {
      LoggerService.w('Failed to send business registration notification', error: e);
      // Don't throw error - notification failure shouldn't block business registration
    }
  }

  /// Send business approval notification (non-blocking)
  void _sendBusinessApprovalNotification(String userId, String businessName) {
    try {
      if (Get.isRegistered<NotificationService>()) {
        NotificationService.to.sendBusinessApprovalNotification(userId, businessName);
        LoggerService.d('Business approval notification sent for: $businessName');
      }
    } catch (e) {
      LoggerService.w('Failed to send business approval notification', error: e);
    }
  }

  /// Send business rejection notification (non-blocking)
  void _sendBusinessRejectionNotification(String userId, String reason) {
    try {
      if (Get.isRegistered<NotificationService>()) {
        NotificationService.to.sendBusinessRejectionNotification(userId, reason);
        LoggerService.d('Business rejection notification sent: $reason');
      }
    } catch (e) {
      LoggerService.w('Failed to send business rejection notification', error: e);
    }
  }

  /// Send business suspension notification (non-blocking)
  void _sendBusinessSuspensionNotification(String userId, String businessName, String reason) {
    try {
      if (Get.isRegistered<NotificationService>()) {
        NotificationService.to.createNotification(
          recipientId: userId,
          title: 'Tài khoản kinh doanh bị đình chỉ ⚠️',
          body: 'Tài khoản "$businessName" đã bị đình chỉ: $reason. Vui lòng liên hệ hỗ trợ.',
          type: NotificationType.businessSuspended,
          priority: NotificationPriority.urgent,
          actionUrl: '/support',
          metadata: {'businessName': businessName, 'suspensionReason': reason},
        );
        LoggerService.d('Business suspension notification sent for: $businessName');
      }
    } catch (e) {
      LoggerService.w('Failed to send business suspension notification', error: e);
    }
  }
}