import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/data/models/accommodation_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'dart:math' as math;

class AccommodationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const String _collection = 'accommodations';
  static const String _favoritesCollection = 'favorites';
  static const String _reviewsCollection = 'reviews';
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Get all accommodations
  Future<List<AccommodationModel>> getAllAccommodations() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('rating', descending: true)
          .limit(50)
          .get();
      
      return querySnapshot.docs
          .map((doc) => AccommodationModel.fromFirestore(
              doc.data(), 
              doc.id
          ))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting accommodations', error: e);
      return [];
    }
  }
  
  // Get featured accommodations
  Future<List<AccommodationModel>> getFeaturedAccommodations() async {
    try {
      // Simplified query to avoid index requirement
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isFeatured', isEqualTo: true)
          .limit(10)
          .get();
      
      // Sort in memory instead of using orderBy to avoid index requirement
      final accommodations = querySnapshot.docs
          .map((doc) => AccommodationModel.fromFirestore(
              doc.data(), 
              doc.id
          ))
          .toList();
      
      // Sort by rating descending
      accommodations.sort((a, b) => b.rating.compareTo(a.rating));
      
      return accommodations;
    } catch (e) {
      LoggerService.e('Error getting featured accommodations', error: e);
      return [];
    }
  }
  
  // Get accommodations by city
  Future<List<AccommodationModel>> getAccommodationsByCity(String city) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('city', isEqualTo: city)
          .orderBy('rating', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => AccommodationModel.fromFirestore(
              doc.data(), 
              doc.id
          ))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting accommodations by city', error: e);
      return [];
    }
  }
  
  // Search accommodations
  Future<List<AccommodationModel>> searchAccommodations({
    String? query,
    String? city,
    String? type,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    List<String>? amenities,
  }) async {
    try {
      Query<Map<String, dynamic>> firestoreQuery = _firestore.collection(_collection);
      
      // Apply filters
      if (city != null && city.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('city', isEqualTo: city);
      }
      
      if (type != null && type.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('type', isEqualTo: type);
      }
      
      if (minPrice != null) {
        firestoreQuery = firestoreQuery.where('pricePerNight', isGreaterThanOrEqualTo: minPrice);
      }
      
      if (maxPrice != null) {
        firestoreQuery = firestoreQuery.where('pricePerNight', isLessThanOrEqualTo: maxPrice);
      }
      
      if (minRating != null) {
        firestoreQuery = firestoreQuery.where('rating', isGreaterThanOrEqualTo: minRating);
      }
      
      // Execute query
      final querySnapshot = await firestoreQuery.limit(100).get();
      
      var accommodations = querySnapshot.docs
          .map((doc) => AccommodationModel.fromFirestore(
              doc.data(), 
              doc.id
          ))
          .toList();
      
      // Client-side filtering for complex queries
      if (query != null && query.isNotEmpty) {
        final searchQuery = query.toLowerCase();
        accommodations = accommodations.where((acc) =>
            acc.name.toLowerCase().contains(searchQuery) ||
            acc.description.toLowerCase().contains(searchQuery) ||
            acc.city.toLowerCase().contains(searchQuery)
        ).toList();
      }
      
      if (amenities != null && amenities.isNotEmpty) {
        accommodations = accommodations.where((acc) =>
            amenities.every((amenity) => acc.amenities.contains(amenity))
        ).toList();
      }
      
      // Sort by rating
      accommodations.sort((a, b) => b.rating.compareTo(a.rating));
      
      return accommodations;
    } catch (e) {
      LoggerService.e('Error searching accommodations', error: e);
      return [];
    }
  }
  
  // Get single accommodation
  Future<AccommodationModel?> getAccommodation(String accommodationId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(accommodationId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return AccommodationModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error getting accommodation', error: e);
      return null;
    }
  }
  
  // Stream single accommodation
  Stream<AccommodationModel?> streamAccommodation(String accommodationId) {
    return _firestore
        .collection(_collection)
        .doc(accommodationId)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return AccommodationModel.fromFirestore(doc.data()!, doc.id);
          }
          return null;
        });
  }
  
  // Create accommodation (for hosts)
  Future<String?> createAccommodation(AccommodationModel accommodation) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final docRef = await _firestore.collection(_collection).add(
        accommodation.copyWith(
          hostId: currentUserId!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ).toFirestore(),
      );
      
      LoggerService.i('Accommodation created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      LoggerService.e('Error creating accommodation', error: e);
      return null;
    }
  }
  
  // Update accommodation
  Future<bool> updateAccommodation(String accommodationId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      
      await _firestore
          .collection(_collection)
          .doc(accommodationId)
          .update(updates);
      
      LoggerService.i('Accommodation updated: $accommodationId');
      return true;
    } catch (e) {
      LoggerService.e('Error updating accommodation', error: e);
      return false;
    }
  }
  
  // Delete accommodation
  Future<bool> deleteAccommodation(String accommodationId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(accommodationId)
          .delete();
      
      LoggerService.i('Accommodation deleted: $accommodationId');
      return true;
    } catch (e) {
      LoggerService.e('Error deleting accommodation', error: e);
      return false;
    }
  }
  
  // Favorite operations
  Future<bool> toggleFavorite(String accommodationId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final favoriteDoc = _firestore
          .collection(_favoritesCollection)
          .doc('${currentUserId}_$accommodationId');
      
      final doc = await favoriteDoc.get();
      
      if (doc.exists) {
        // Remove favorite
        await favoriteDoc.delete();
        LoggerService.i('Removed favorite: $accommodationId');
        return false;
      } else {
        // Add favorite
        await favoriteDoc.set({
          'userId': currentUserId,
          'accommodationId': accommodationId,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
        LoggerService.i('Added favorite: $accommodationId');
        return true;
      }
    } catch (e) {
      LoggerService.e('Error toggling favorite', error: e);
      return false;
    }
  }
  
  // Check if favorited
  Future<bool> isFavorited(String accommodationId) async {
    try {
      if (currentUserId == null) return false;
      
      final doc = await _firestore
          .collection(_favoritesCollection)
          .doc('${currentUserId}_$accommodationId')
          .get();
      
      return doc.exists;
    } catch (e) {
      LoggerService.e('Error checking favorite', error: e);
      return false;
    }
  }
  
  // Get user favorites
  Future<List<AccommodationModel>> getUserFavorites() async {
    try {
      if (currentUserId == null) return [];
      
      final favoritesSnapshot = await _firestore
          .collection(_favoritesCollection)
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final accommodationIds = favoritesSnapshot.docs
          .map((doc) => doc.data()['accommodationId'] as String)
          .toList();
      
      if (accommodationIds.isEmpty) return [];
      
      // Get accommodations
      final accommodations = await Future.wait(
        accommodationIds.map((id) => getAccommodation(id))
      );
      
      return accommodations
          .where((acc) => acc != null)
          .cast<AccommodationModel>()
          .toList();
    } catch (e) {
      LoggerService.e('Error getting user favorites', error: e);
      return [];
    }
  }
  
  // Get nearby accommodations
  Future<List<AccommodationModel>> getNearbyAccommodations(
    double latitude, 
    double longitude, 
    double radiusInKm,
  ) async {
    try {
      // For simplicity, we'll get all accommodations and filter by distance
      // In production, use geohashing or Firebase GeoFire
      
      final allAccommodations = await getAllAccommodations();
      
      return allAccommodations.where((acc) {
        final distance = _calculateDistance(
          latitude, 
          longitude,
          acc.location.latitude,
          acc.location.longitude,
        );
        return distance <= radiusInKm;
      }).toList()
        ..sort((a, b) {
          final distA = _calculateDistance(
            latitude, longitude,
            a.location.latitude, a.location.longitude,
          );
          final distB = _calculateDistance(
            latitude, longitude,
            b.location.latitude, b.location.longitude,
          );
          return distA.compareTo(distB);
        });
    } catch (e) {
      LoggerService.e('Error getting nearby accommodations', error: e);
      return [];
    }
  }
  
  // Calculate distance between two points (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = 
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) * 
      math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}