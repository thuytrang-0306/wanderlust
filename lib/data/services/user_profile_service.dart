import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/core/services/unified_image_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/user_profile_model.dart';

class UserProfileService extends GetxService {
  static UserProfileService get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UnifiedImageService _imageService = Get.find<UnifiedImageService>();
  
  static const String _collection = 'users';
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;
  
  /// Get user profile
  Future<UserProfileModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return UserProfileModel.fromJson(doc.data()!, doc.id);
      }
      
      return null;
    } catch (e) {
      LoggerService.e('Error getting user profile', error: e);
      return null;
    }
  }
  
  /// Get current user profile
  Future<UserProfileModel?> getCurrentUserProfile() async {
    if (currentUserId == null) return null;
    return getUserProfile(currentUserId!);
  }
  
  /// Create or update user profile
  Future<bool> createOrUpdateProfile(UserProfileModel profile) async {
    try {
      final data = profile.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(_collection)
          .doc(profile.id)
          .set(data, SetOptions(merge: true));
      
      LoggerService.i('Profile updated successfully');
      return true;
    } catch (e) {
      LoggerService.e('Error updating profile', error: e);
      return false;
    }
  }
  
  /// Update profile fields
  Future<bool> updateProfileFields(Map<String, dynamic> fields) async {
    try {
      if (currentUserId == null) return false;
      
      fields['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(_collection)
          .doc(currentUserId)
          .update(fields);
      
      LoggerService.i('Profile fields updated successfully');
      return true;
    } catch (e) {
      LoggerService.e('Error updating profile fields', error: e);
      return false;
    }
  }
  
  /// Upload and update avatar
  Future<bool> updateAvatar(ImageSource source) async {
    try {
      if (currentUserId == null) return false;
      
      // Pick image
      final image = await _imageService.pickImage(source: source);
      if (image == null) return false;
      
      // Process image (create full size and thumbnail)
      final processed = await _imageService.processImageForUpload(image);
      if (processed == null) return false;
      
      // Update profile with base64 avatar
      final success = await updateProfileFields({
        'avatar': processed['full'],
        'avatarThumbnail': processed['thumbnail'],
      });
      
      if (success) {
        LoggerService.i('Avatar updated successfully');
      }
      
      return success;
    } catch (e) {
      LoggerService.e('Error updating avatar', error: e);
      return false;
    }
  }
  
  /// Remove avatar
  Future<bool> removeAvatar() async {
    try {
      if (currentUserId == null) return false;
      
      final success = await updateProfileFields({
        'avatar': FieldValue.delete(),
        'avatarThumbnail': FieldValue.delete(),
      });
      
      if (success) {
        LoggerService.i('Avatar removed successfully');
      }
      
      return success;
    } catch (e) {
      LoggerService.e('Error removing avatar', error: e);
      return false;
    }
  }
  
  /// Update cover photo
  Future<bool> updateCoverPhoto(ImageSource source) async {
    try {
      if (currentUserId == null) return false;
      
      // Pick image
      final image = await _imageService.pickImage(
        source: source,
        maxWidthOverride: 1920,
        maxHeightOverride: 1080,
      );
      if (image == null) return false;
      
      // Convert to base64
      final base64 = await _imageService.imageToBase64(image);
      if (base64 == null) return false;
      
      // Update profile
      final success = await updateProfileFields({
        'coverPhoto': base64,
      });
      
      if (success) {
        LoggerService.i('Cover photo updated successfully');
      }
      
      return success;
    } catch (e) {
      LoggerService.e('Error updating cover photo', error: e);
      return false;
    }
  }
  
  /// Stream user profile changes
  Stream<UserProfileModel?> streamUserProfile(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfileModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    });
  }
  
  /// Stream current user profile
  Stream<UserProfileModel?> streamCurrentUserProfile() {
    if (currentUserId == null) return Stream.value(null);
    return streamUserProfile(currentUserId!);
  }
  
  /// Initialize profile for new user
  Future<bool> initializeNewUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return false;
      
      // Check if profile already exists
      final existing = await getCurrentUserProfile();
      if (existing != null) return true;
      
      // Create new profile
      final profile = UserProfileModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoURL,
        bio: '',
        location: '',
        interests: [],
        languages: [],
        joinDate: DateTime.now(),
        isVerified: user.emailVerified,
        stats: UserStats(
          tripsCount: 0,
          reviewsCount: 0,
          photosCount: 0,
          followersCount: 0,
          followingCount: 0,
        ),
      );
      
      return await createOrUpdateProfile(profile);
    } catch (e) {
      LoggerService.e('Error initializing user profile', error: e);
      return false;
    }
  }
  
  /// Update user stats
  Future<bool> updateUserStats(Map<String, int> increments) async {
    try {
      if (currentUserId == null) return false;
      
      final updates = <String, dynamic>{};
      
      increments.forEach((key, value) {
        updates['stats.$key'] = FieldValue.increment(value);
      });
      
      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        
        await _firestore
            .collection(_collection)
            .doc(currentUserId)
            .update(updates);
        
        LoggerService.i('User stats updated successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      LoggerService.e('Error updating user stats', error: e);
      return false;
    }
  }
  
  /// Search users by name or email
  Future<List<UserProfileModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];
      
      final queryLower = query.toLowerCase();
      
      // Search by display name
      final nameQuery = await _firestore
          .collection(_collection)
          .where('searchableDisplayName', arrayContains: queryLower)
          .limit(20)
          .get();
      
      final users = nameQuery.docs
          .map((doc) => UserProfileModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // Search by email if no results from name
      if (users.isEmpty) {
        final emailQuery = await _firestore
            .collection(_collection)
            .where('email', isGreaterThanOrEqualTo: query)
            .where('email', isLessThanOrEqualTo: query + '\uf8ff')
            .limit(20)
            .get();
        
        users.addAll(emailQuery.docs
            .map((doc) => UserProfileModel.fromJson(doc.data(), doc.id))
            .toList());
      }
      
      return users;
    } catch (e) {
      LoggerService.e('Error searching users', error: e);
      return [];
    }
  }
}