import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:wanderlust/data/models/trip_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:uuid/uuid.dart';

class TripService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();
  
  // Collections
  static const String _tripsCollection = 'trips';
  static const String _itinerariesCollection = 'itineraries';
  static const String _expensesCollection = 'expenses';

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Create a new trip
  Future<String?> createTrip(TripModel trip) async {
    try {
      if (_userId == null) {
        LoggerService.e('User not authenticated');
        return null;
      }

      // Set userId to current user
      final tripData = trip.toJson();
      tripData['userId'] = _userId;

      final docRef = await _firestore
          .collection(_tripsCollection)
          .add(tripData);

      LoggerService.i('Trip created successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      LoggerService.e('Error creating trip', error: e);
      return null;
    }
  }

  // Get all user trips
  Future<List<TripModel>> getUserTrips() async {
    try {
      if (_userId == null) {
        LoggerService.e('User not authenticated');
        return [];
      }

      // Simplified query to avoid index requirement
      final snapshot = await _firestore
          .collection(_tripsCollection)
          .where('userId', isEqualTo: _userId)
          .get();

      // Sort locally after fetching
      final trips = snapshot.docs
          .map((doc) => TripModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // Sort by startDate ascending
      trips.sort((a, b) => a.startDate.compareTo(b.startDate));
      
      return trips;
    } catch (e) {
      LoggerService.e('Error getting user trips', error: e);
      return [];
    }
  }

  // Get all public trips (for discover page)
  Future<List<TripModel>> getAllPublicTrips() async {
    try {
      // Get all trips with public visibility
      final snapshot = await _firestore
          .collection(_tripsCollection)
          .where('visibility', isEqualTo: 'public')
          .orderBy('createdAt', descending: true)
          .limit(20) // Limit to prevent too much data
          .get();

      final trips = snapshot.docs
          .map((doc) => TripModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // If no public trips, get all trips for now (for testing)
      if (trips.isEmpty) {
        final allSnapshot = await _firestore
            .collection(_tripsCollection)
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get();
            
        return allSnapshot.docs
            .map((doc) => TripModel.fromJson(doc.data(), doc.id))
            .toList();
      }
      
      return trips;
    } catch (e) {
      LoggerService.e('Error getting public trips', error: e);
      return [];
    }
  }

  // Get upcoming trips
  Future<List<TripModel>> getUpcomingTrips() async {
    try {
      if (_userId == null) return [];

      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(_tripsCollection)
          .where('userId', isEqualTo: _userId)
          .where('startDate', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('startDate')
          .limit(5)
          .get();

      return snapshot.docs
          .map((doc) => TripModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting upcoming trips', error: e);
      return [];
    }
  }

  // Get ongoing trips
  Future<List<TripModel>> getOngoingTrips() async {
    try {
      if (_userId == null) return [];

      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(_tripsCollection)
          .where('userId', isEqualTo: _userId)
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      return snapshot.docs
          .map((doc) => TripModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting ongoing trips', error: e);
      return [];
    }
  }

  // Get past trips
  Future<List<TripModel>> getPastTrips() async {
    try {
      if (_userId == null) return [];

      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(_tripsCollection)
          .where('userId', isEqualTo: _userId)
          .where('endDate', isLessThan: Timestamp.fromDate(now))
          .orderBy('endDate', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => TripModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting past trips', error: e);
      return [];
    }
  }

  // Get single trip
  Future<TripModel?> getTrip(String tripId) async {
    try {
      final doc = await _firestore
          .collection(_tripsCollection)
          .doc(tripId)
          .get();

      if (doc.exists && doc.data() != null) {
        return TripModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error getting trip', error: e);
      return null;
    }
  }

  // Update trip
  Future<bool> updateTrip(String tripId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(_tripsCollection)
          .doc(tripId)
          .update(updates);

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
      // Delete trip document
      await _firestore
          .collection(_tripsCollection)
          .doc(tripId)
          .delete();

      // Delete all itineraries
      final itineraries = await _firestore
          .collection(_itinerariesCollection)
          .where('tripId', isEqualTo: tripId)
          .get();
      
      for (final doc in itineraries.docs) {
        await doc.reference.delete();
      }

      // Delete all expenses
      final expenses = await _firestore
          .collection(_expensesCollection)
          .where('tripId', isEqualTo: tripId)
          .get();
      
      for (final doc in expenses.docs) {
        await doc.reference.delete();
      }

      LoggerService.i('Trip deleted successfully: $tripId');
      return true;
    } catch (e) {
      LoggerService.e('Error deleting trip', error: e);
      return false;
    }
  }

  // Stream trips for real-time updates
  Stream<List<TripModel>> streamUserTrips() {
    if (_userId == null) return Stream.value([]);

    // Simplified query to avoid index requirement
    return _firestore
        .collection(_tripsCollection)
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
          final trips = snapshot.docs
              .map((doc) => TripModel.fromJson(doc.data(), doc.id))
              .toList();
          
          // Sort locally by startDate
          trips.sort((a, b) => a.startDate.compareTo(b.startDate));
          
          return trips;
        });
  }

  // === ITINERARY METHODS ===

  // Add itinerary day
  Future<String?> addItinerary(TripItinerary itinerary) async {
    try {
      final docRef = await _firestore
          .collection(_itinerariesCollection)
          .add(itinerary.toJson());

      // Update trip stats
      await _updateTripStats(itinerary.tripId, placesIncrement: 1);

      LoggerService.i('Itinerary added successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      LoggerService.e('Error adding itinerary', error: e);
      return null;
    }
  }

  // Get trip itineraries
  Future<List<TripItinerary>> getTripItineraries(String tripId) async {
    try {
      final snapshot = await _firestore
          .collection(_itinerariesCollection)
          .where('tripId', isEqualTo: tripId)
          .orderBy('dayNumber')
          .get();

      return snapshot.docs
          .map((doc) => TripItinerary.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting itineraries', error: e);
      return [];
    }
  }

  // Update itinerary
  Future<bool> updateItinerary(String itineraryId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(_itinerariesCollection)
          .doc(itineraryId)
          .update(updates);

      LoggerService.i('Itinerary updated successfully: $itineraryId');
      return true;
    } catch (e) {
      LoggerService.e('Error updating itinerary', error: e);
      return false;
    }
  }

  // Delete itinerary
  Future<bool> deleteItinerary(String itineraryId, String tripId) async {
    try {
      await _firestore
          .collection(_itinerariesCollection)
          .doc(itineraryId)
          .delete();

      // Update trip stats
      await _updateTripStats(tripId, placesIncrement: -1);

      LoggerService.i('Itinerary deleted successfully: $itineraryId');
      return true;
    } catch (e) {
      LoggerService.e('Error deleting itinerary', error: e);
      return false;
    }
  }

  // === EXPENSE METHODS ===

  // Add expense
  Future<String?> addExpense(TripExpense expense) async {
    try {
      final docRef = await _firestore
          .collection(_expensesCollection)
          .add(expense.toJson());

      // Update trip spent amount
      await _updateTripSpentAmount(expense.tripId, expense.amount);

      LoggerService.i('Expense added successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      LoggerService.e('Error adding expense', error: e);
      return null;
    }
  }

  // Get trip expenses
  Future<List<TripExpense>> getTripExpenses(String tripId) async {
    try {
      final snapshot = await _firestore
          .collection(_expensesCollection)
          .where('tripId', isEqualTo: tripId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TripExpense.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting expenses', error: e);
      return [];
    }
  }

  // Update expense
  Future<bool> updateExpense(String expenseId, Map<String, dynamic> updates, String tripId, double oldAmount) async {
    try {
      await _firestore
          .collection(_expensesCollection)
          .doc(expenseId)
          .update(updates);

      // Update trip spent amount if amount changed
      if (updates.containsKey('amount')) {
        final difference = (updates['amount'] as double) - oldAmount;
        await _updateTripSpentAmount(tripId, difference);
      }

      LoggerService.i('Expense updated successfully: $expenseId');
      return true;
    } catch (e) {
      LoggerService.e('Error updating expense', error: e);
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String expenseId, String tripId, double amount) async {
    try {
      await _firestore
          .collection(_expensesCollection)
          .doc(expenseId)
          .delete();

      // Update trip spent amount
      await _updateTripSpentAmount(tripId, -amount);

      LoggerService.i('Expense deleted successfully: $expenseId');
      return true;
    } catch (e) {
      LoggerService.e('Error deleting expense', error: e);
      return false;
    }
  }

  // === HELPER METHODS ===

  // Update trip stats
  Future<void> _updateTripStats(String tripId, {
    int? placesIncrement,
    int? photosIncrement,
    int? notesIncrement,
    int? expensesIncrement,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (placesIncrement != null) {
        updates['stats.placesCount'] = FieldValue.increment(placesIncrement);
      }
      if (photosIncrement != null) {
        updates['stats.photosCount'] = FieldValue.increment(photosIncrement);
      }
      if (notesIncrement != null) {
        updates['stats.notesCount'] = FieldValue.increment(notesIncrement);
      }
      if (expensesIncrement != null) {
        updates['stats.expensesCount'] = FieldValue.increment(expensesIncrement);
      }

      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore
            .collection(_tripsCollection)
            .doc(tripId)
            .update(updates);
      }
    } catch (e) {
      LoggerService.e('Error updating trip stats', error: e);
    }
  }

  // Update trip spent amount
  Future<void> _updateTripSpentAmount(String tripId, double amount) async {
    try {
      await _firestore
          .collection(_tripsCollection)
          .doc(tripId)
          .update({
        'spentAmount': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update expenses count
      if (amount > 0) {
        await _updateTripStats(tripId, expensesIncrement: 1);
      } else if (amount < 0) {
        await _updateTripStats(tripId, expensesIncrement: -1);
      }
    } catch (e) {
      LoggerService.e('Error updating trip spent amount', error: e);
    }
  }

  // Delete all trips for current user - USE WITH CAUTION!
  Future<bool> deleteAllUserTrips() async {
    try {
      if (_userId == null) {
        LoggerService.e('User not authenticated');
        return false;
      }

      // Get all user trips
      final snapshot = await _firestore
          .collection(_tripsCollection)
          .where('userId', isEqualTo: _userId)
          .get();

      // Delete each trip
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Commit the batch delete
      await batch.commit();
      
      LoggerService.i('Deleted ${snapshot.docs.length} trips for user $_userId');
      return true;
    } catch (e) {
      LoggerService.e('Error deleting all trips', error: e);
      return false;
    }
  }

  // Sample data creation removed for production
}