import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wanderlust/data/models/tour_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class TourService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tours';

  // Get all tours
  Future<List<TourModel>> getAllTours() async {
    try {
      // Simplified query
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('rating', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TourModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting tours', error: e);
      return [];
    }
  }

  // Get featured tours
  Future<List<TourModel>> getFeaturedTours({int limit = 5}) async {
    try {
      // Get all tours then filter
      final snapshot = await _firestore
          .collection(_collection)
          .limit(limit * 2) // Get more to filter
          .get();

      // Filter for featured and active tours
      return snapshot.docs
          .map((doc) => TourModel.fromFirestore(doc.data(), doc.id))
          .where((tour) => tour.isFeatured && tour.status == 'active')
          .take(limit)
          .toList();
    } catch (e) {
      LoggerService.e('Error getting featured tours', error: e);
      return [];
    }
  }

  // Get tours with discount
  Future<List<TourModel>> getDiscountedTours({int limit = 10}) async {
    try {
      // Get all tours then filter for discounted ones
      final snapshot = await _firestore
          .collection(_collection)
          .limit(limit * 3)
          .get();

      return snapshot.docs
          .map((doc) => TourModel.fromFirestore(doc.data(), doc.id))
          .where((tour) => tour.hasDiscount && tour.status == 'active')
          .take(limit)
          .toList();
    } catch (e) {
      LoggerService.e('Error getting discounted tours', error: e);
      return [];
    }
  }

  // Get tours by destination
  Future<List<TourModel>> getToursByDestination(String destinationId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('destinationId', isEqualTo: destinationId)
          .where('status', isEqualTo: 'active')
          .orderBy('rating', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TourModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting tours by destination', error: e);
      return [];
    }
  }

  // Get single tour
  Future<TourModel?> getTour(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (doc.exists && doc.data() != null) {
        return TourModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error getting tour', error: e);
      return null;
    }
  }

  // Search tours
  Future<List<TourModel>> searchTours(String query) async {
    try {
      final lowercaseQuery = query.toLowerCase();
      
      // Search by title prefix
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'active')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + '\uf8ff')
          .limit(20)
          .get();

      final results = snapshot.docs
          .map((doc) => TourModel.fromFirestore(doc.data(), doc.id))
          .toList();

      // Additional client-side filtering
      final allTours = await getAllTours();
      final additionalResults = allTours.where((tour) {
        final matchesDesc = tour.description.toLowerCase().contains(lowercaseQuery);
        final matchesDest = tour.destinations.any((dest) => 
            dest.toLowerCase().contains(lowercaseQuery));
        final matchesHighlight = tour.highlights.any((highlight) => 
            highlight.toLowerCase().contains(lowercaseQuery));
        
        // Avoid duplicates
        final alreadyInResults = results.any((r) => r.id == tour.id);
        
        return !alreadyInResults && (matchesDesc || matchesDest || matchesHighlight);
      }).toList();

      return [...results, ...additionalResults];
    } catch (e) {
      LoggerService.e('Error searching tours', error: e);
      return [];
    }
  }

  // Filter tours by price range
  Future<List<TourModel>> filterToursByPrice(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'active')
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .orderBy('price')
          .get();

      return snapshot.docs
          .map((doc) => TourModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error filtering tours by price', error: e);
      return [];
    }
  }

  // Stream tours for real-time updates
  Stream<List<TourModel>> streamTours() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TourModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Sample data creation removed for production
}