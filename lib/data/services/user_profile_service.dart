import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/core/services/unified_image_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/user_profile_model.dart';
import 'package:wanderlust/data/models/user_model.dart';
import 'package:wanderlust/data/models/business_profile_model.dart';
import 'package:wanderlust/shared/core/services/notification_service.dart';

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
      final doc = await _firestore.collection(_collection).doc(userId).get();

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

      await _firestore.collection(_collection).doc(profile.id).set(data, SetOptions(merge: true));

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

      await _firestore.collection(_collection).doc(currentUserId).update(fields);

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
      final success = await updateProfileFields({'coverPhoto': base64});

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
    return _firestore.collection(_collection).doc(userId).snapshots().map((doc) {
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

        await _firestore.collection(_collection).doc(currentUserId).update(updates);

        LoggerService.i('User stats updated successfully');
        return true;
      }

      return false;
    } catch (e) {
      LoggerService.e('Error updating user stats', error: e);
      return false;
    }
  }

  /// Update user to business type
  Future<bool> upgradeToBusinessUser(String businessProfileId) async {
    try {
      if (currentUserId == null) return false;
      
      final success = await updateProfileFields({
        'userType': UserType.business.value,
        'businessProfileId': businessProfileId,
        'businessSince': FieldValue.serverTimestamp(),
      });
      
      if (success) {
        LoggerService.i('User upgraded to business type');
      }
      
      return success;
    } catch (e) {
      LoggerService.e('Error upgrading to business user', error: e);
      return false;
    }
  }
  
  /// Get user's business profile if exists
  Future<BusinessProfileModel?> getUserBusinessProfile(String userId) async {
    try {
      // First get user to check if they have business profile
      final userDoc = await _firestore.collection(_collection).doc(userId).get();
      if (!userDoc.exists) return null;
      
      final userData = userDoc.data();
      final businessProfileId = userData?['businessProfileId'];
      
      if (businessProfileId == null) return null;
      
      // Get business profile
      final businessDoc = await _firestore
          .collection('business_profiles')
          .doc(businessProfileId)
          .get();
      
      if (!businessDoc.exists) return null;
      
      return BusinessProfileModel.fromJson(businessDoc.data()!, businessDoc.id);
    } catch (e) {
      LoggerService.e('Error getting user business profile', error: e);
      return null;
    }
  }
  
  /// Check if current user is business type
  Future<bool> isBusinessUser() async {
    try {
      if (currentUserId == null) return false;
      
      final doc = await _firestore.collection(_collection).doc(currentUserId).get();
      if (!doc.exists) return false;
      
      final userType = doc.data()?['userType'] ?? 'regular';
      return userType == UserType.business.value;
    } catch (e) {
      LoggerService.e('Error checking business user status', error: e);
      return false;
    }
  }
  
  /// Search users by name or email
  Future<List<UserProfileModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      final queryLower = query.toLowerCase();

      // Search by display name
      final nameQuery =
          await _firestore
              .collection(_collection)
              .where('searchableDisplayName', arrayContains: queryLower)
              .limit(20)
              .get();

      final users =
          nameQuery.docs.map((doc) => UserProfileModel.fromJson(doc.data(), doc.id)).toList();

      // Search by email if no results from name
      if (users.isEmpty) {
        final emailQuery =
            await _firestore
                .collection(_collection)
                .where('email', isGreaterThanOrEqualTo: query)
                .where('email', isLessThanOrEqualTo: '$query\uf8ff')
                .limit(20)
                .get();

        users.addAll(
          emailQuery.docs.map((doc) => UserProfileModel.fromJson(doc.data(), doc.id)).toList(),
        );
      }

      return users;
    } catch (e) {
      LoggerService.e('Error searching users', error: e);
      return [];
    }
  }

  // ============ USER FOLLOW FUNCTIONALITY ============

  /// Follow/Unfollow a user
  Future<bool> toggleFollow(String targetUserId) async {
    try {
      if (currentUserId == null) {
        LoggerService.w('User not authenticated');
        return false;
      }

      if (currentUserId == targetUserId) {
        LoggerService.w('User cannot follow themselves');
        return false;
      }

      // Check current follow status
      final isCurrentlyFollowing = await isFollowing(targetUserId);

      // Use transaction for atomic update
      await _firestore.runTransaction((transaction) async {
        final currentUserRef = _firestore.collection(_collection).doc(currentUserId);
        final targetUserRef = _firestore.collection(_collection).doc(targetUserId);
        
        final followingRef = currentUserRef.collection('following').doc(targetUserId);
        final followersRef = targetUserRef.collection('followers').doc(currentUserId);

        if (isCurrentlyFollowing) {
          // Unfollow
          transaction.delete(followingRef);
          transaction.delete(followersRef);
          
          // Decrement counts
          transaction.update(currentUserRef, {
            'stats.followingCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          transaction.update(targetUserRef, {
            'stats.followersCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Follow
          final followData = {
            'userId': targetUserId,
            'followedAt': FieldValue.serverTimestamp(),
          };
          final followerData = {
            'userId': currentUserId,
            'followedAt': FieldValue.serverTimestamp(),
          };
          
          transaction.set(followingRef, followData);
          transaction.set(followersRef, followerData);
          
          // Increment counts
          transaction.update(currentUserRef, {
            'stats.followingCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          transaction.update(targetUserRef, {
            'stats.followersCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      // Send notification if it's a new follow (not unfollow)
      if (!isCurrentlyFollowing) {
        _sendUserFollowNotification(targetUserId);
      }

      LoggerService.i('Follow status updated for user: $targetUserId');
      return !isCurrentlyFollowing; // Return new follow status
    } catch (e) {
      LoggerService.e('Error toggling follow status', error: e);
      return false;
    }
  }

  /// Check if current user is following target user
  Future<bool> isFollowing(String targetUserId) async {
    try {
      if (currentUserId == null) return false;

      final followDoc = await _firestore
          .collection(_collection)
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .get();

      return followDoc.exists;
    } catch (e) {
      LoggerService.e('Error checking follow status', error: e);
      return false;
    }
  }

  /// Get user's followers
  Stream<List<UserProfileModel>> getUserFollowers(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('followers')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final followers = <UserProfileModel>[];
      
      for (final doc in snapshot.docs) {
        final followerId = doc['userId'] as String;
        final follower = await getUserProfile(followerId);
        if (follower != null) {
          followers.add(follower);
        }
      }
      
      return followers;
    });
  }

  /// Get user's following list
  Stream<List<UserProfileModel>> getUserFollowing(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('following')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final following = <UserProfileModel>[];
      
      for (final doc in snapshot.docs) {
        final followingId = doc['userId'] as String;
        final user = await getUserProfile(followingId);
        if (user != null) {
          following.add(user);
        }
      }
      
      return following;
    });
  }

  /// Get mutual followers/friends
  Future<List<UserProfileModel>> getMutualFollowers(String targetUserId) async {
    try {
      if (currentUserId == null) return [];

      // Get current user's following list
      final currentUserFollowing = await _firestore
          .collection(_collection)
          .doc(currentUserId)
          .collection('following')
          .get();

      // Get target user's followers list
      final targetUserFollowers = await _firestore
          .collection(_collection)
          .doc(targetUserId)
          .collection('followers')
          .get();

      // Find intersection
      final currentFollowingIds = currentUserFollowing.docs.map((doc) => doc['userId'] as String).toSet();
      final targetFollowerIds = targetUserFollowers.docs.map((doc) => doc['userId'] as String).toSet();
      
      final mutualIds = currentFollowingIds.intersection(targetFollowerIds);

      // Get user profiles for mutual connections
      final mutualUsers = <UserProfileModel>[];
      for (final userId in mutualIds) {
        final user = await getUserProfile(userId);
        if (user != null) {
          mutualUsers.add(user);
        }
      }

      return mutualUsers;
    } catch (e) {
      LoggerService.e('Error getting mutual followers', error: e);
      return [];
    }
  }

  /// Get recommended users to follow
  Future<List<UserProfileModel>> getRecommendedUsers({int limit = 10}) async {
    try {
      if (currentUserId == null) return [];

      // Get users the current user is not following
      // This is a simplified recommendation - in production you'd use more sophisticated algorithms
      final usersSnapshot = await _firestore
          .collection(_collection)
          .where('id', isNotEqualTo: currentUserId)
          .orderBy('stats.followersCount', descending: true)
          .limit(limit * 2) // Get more to filter out already followed users
          .get();

      final recommendedUsers = <UserProfileModel>[];
      
      for (final doc in usersSnapshot.docs) {
        final user = UserProfileModel.fromJson(doc.data(), doc.id);
        
        // Check if already following
        final alreadyFollowing = await isFollowing(user.id);
        if (!alreadyFollowing && recommendedUsers.length < limit) {
          recommendedUsers.add(user);
        }
      }

      return recommendedUsers;
    } catch (e) {
      LoggerService.e('Error getting recommended users', error: e);
      return [];
    }
  }

  // ============ NOTIFICATION HELPERS ============

  /// Send user follow notification (non-blocking)
  void _sendUserFollowNotification(String followedUserId) async {
    try {
      if (currentUserId == null) return;

      // Get current user data
      final currentUserProfile = await getCurrentUserProfile();
      if (currentUserProfile == null) return;

      if (Get.isRegistered<NotificationService>()) {
        NotificationService.to.sendUserFollowNotification(
          followedUserId: followedUserId,
          followerName: currentUserProfile.displayName.isNotEmpty 
              ? currentUserProfile.displayName 
              : 'Ai đó',
          followerAvatar: currentUserProfile.avatar,
          followerId: currentUserId!,
        );
        LoggerService.d('User follow notification sent to: $followedUserId');
      }
    } catch (e) {
      LoggerService.w('Failed to send user follow notification', error: e);
    }
  }
}
