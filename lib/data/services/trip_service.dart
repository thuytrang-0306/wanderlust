import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:wanderlust/data/models/trip_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class TripService extends GetxService {
  static TripService get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection reference
  CollectionReference get _tripsCollection => _firestore.collection('trips');
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Create new trip
  Future<TripModel?> createTrip({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String coverImage = '',
    double budget = 0,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final tripData = {
        'userId': currentUserId,
        'name': name,
        'description': description,
        'coverImage': coverImage,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'status': 'planning',
        'participants': [
          {
            'userId': currentUserId,
            'role': 'owner',
            'joinedAt': FieldValue.serverTimestamp(),
          }
        ],
        'budget': {
          'total': budget,
          'spent': 0,
          'currency': 'VND',
        },
        'isPublic': false,
        'sharedWith': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      final docRef = await _tripsCollection.add(tripData);
      final doc = await docRef.get();
      
      LoggerService.i('Trip created successfully: ${docRef.id}');
      return TripModel.fromFirestore(doc);
      
    } catch (e) {
      LoggerService.e('Error creating trip', error: e);
      return null;
    }
  }
  
  // Get user's trips
  Stream<List<TripModel>> getUserTrips() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    
    return _tripsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TripModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get trips by status
  Stream<List<TripModel>> getTripsByStatus(TripStatus status) {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    
    return _tripsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('status', isEqualTo: status.value)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TripModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get single trip
  Future<TripModel?> getTrip(String tripId) async {
    try {
      final doc = await _tripsCollection.doc(tripId).get();
      
      if (doc.exists) {
        return TripModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error getting trip', error: e);
      return null;
    }
  }
  
  // Stream single trip (for real-time updates)
  Stream<TripModel?> streamTrip(String tripId) {
    return _tripsCollection.doc(tripId).snapshots().map((doc) {
      if (doc.exists) {
        return TripModel.fromFirestore(doc);
      }
      return null;
    });
  }
  
  // Update trip
  Future<bool> updateTrip(String tripId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _tripsCollection.doc(tripId).update(data);
      
      LoggerService.i('Trip updated successfully: $tripId');
      return true;
    } catch (e) {
      LoggerService.e('Error updating trip', error: e);
      return false;
    }
  }
  
  // Delete trip
  Future<bool> deleteTrip(String tripId) async {
    try {
      // Delete all subcollections (days, activities) first
      await _deleteTripDays(tripId);
      
      // Delete the trip document
      await _tripsCollection.doc(tripId).delete();
      
      LoggerService.i('Trip deleted successfully: $tripId');
      return true;
    } catch (e) {
      LoggerService.e('Error deleting trip', error: e);
      return false;
    }
  }
  
  // Delete trip days subcollection
  Future<void> _deleteTripDays(String tripId) async {
    final daysCollection = _tripsCollection.doc(tripId).collection('days');
    final daysDocs = await daysCollection.get();
    
    for (final doc in daysDocs.docs) {
      await doc.reference.delete();
    }
  }
  
  // Add participant to trip
  Future<bool> addParticipant(String tripId, String userId, String role) async {
    try {
      await _tripsCollection.doc(tripId).update({
        'participants': FieldValue.arrayUnion([
          {
            'userId': userId,
            'role': role,
            'joinedAt': FieldValue.serverTimestamp(),
          }
        ]),
        'sharedWith': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      LoggerService.e('Error adding participant', error: e);
      return false;
    }
  }
  
  // Update trip status
  Future<bool> updateTripStatus(String tripId, TripStatus status) async {
    try {
      await _tripsCollection.doc(tripId).update({
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      LoggerService.e('Error updating trip status', error: e);
      return false;
    }
  }
  
  // Get upcoming trips
  Stream<List<TripModel>> getUpcomingTrips() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    
    final now = DateTime.now();
    
    return _tripsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('startDate', isGreaterThan: Timestamp.fromDate(now))
        .where('status', isEqualTo: 'planning')
        .orderBy('startDate')
        .limit(5)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TripModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get ongoing trips
  Stream<List<TripModel>> getOngoingTrips() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    
    return _tripsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'ongoing')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TripModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Search trips
  Future<List<TripModel>> searchTrips(String query) async {
    try {
      if (currentUserId == null || query.isEmpty) {
        return [];
      }
      
      // Note: Firestore doesn't support full-text search
      // For production, consider using Algolia or Elasticsearch
      
      final snapshot = await _tripsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();
      
      final trips = snapshot.docs
          .map((doc) => TripModel.fromFirestore(doc))
          .where((trip) => 
              trip.name.toLowerCase().contains(query.toLowerCase()) ||
              trip.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      return trips;
    } catch (e) {
      LoggerService.e('Error searching trips', error: e);
      return [];
    }
  }
}