import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wanderlust/data/models/destination_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class DestinationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'destinations';

  // Get all destinations
  Future<List<DestinationModel>> getAllDestinations() async {
    try {
      final snapshot =
          await _firestore.collection(_collection).orderBy('rating', descending: true).get();

      return snapshot.docs.map((doc) => DestinationModel.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      LoggerService.e('Error getting destinations', error: e);
      return [];
    }
  }

  // Get featured destinations
  Future<List<DestinationModel>> getFeaturedDestinations({int limit = 5}) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('featured', isEqualTo: true)
              .limit(limit)
              .get();

      return snapshot.docs.map((doc) => DestinationModel.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      LoggerService.e('Error getting featured destinations', error: e);
      return [];
    }
  }

  // Get popular destinations
  Future<List<DestinationModel>> getPopularDestinations({int limit = 10}) async {
    try {
      // Simplified query - just get top rated destinations
      final snapshot =
          await _firestore
              .collection(_collection)
              .orderBy('rating', descending: true)
              .limit(limit)
              .get();

      return snapshot.docs.map((doc) => DestinationModel.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      LoggerService.e('Error getting popular destinations', error: e);
      return [];
    }
  }

  // Get destinations by region
  Future<List<DestinationModel>> getDestinationsByRegion(String region) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('region', isEqualTo: region)
              .orderBy('rating', descending: true)
              .get();

      return snapshot.docs.map((doc) => DestinationModel.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      LoggerService.e('Error getting destinations by region', error: e);
      return [];
    }
  }

  // Get single destination
  Future<DestinationModel?> getDestination(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (doc.exists && doc.data() != null) {
        return DestinationModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error getting destination', error: e);
      return null;
    }
  }

  // Search destinations
  Future<List<DestinationModel>> searchDestinations(String query) async {
    try {
      final lowercaseQuery = query.toLowerCase();

      // Search by name prefix (Firestore limitation)
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('name', isGreaterThanOrEqualTo: query)
              .where('name', isLessThan: '$query\uf8ff')
              .limit(20)
              .get();

      final results =
          snapshot.docs.map((doc) => DestinationModel.fromJson(doc.data(), doc.id)).toList();

      // Additional client-side filtering for tags and description
      final allDestinations = await getAllDestinations();
      final additionalResults =
          allDestinations.where((dest) {
            final matchesTag = dest.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
            final matchesDesc = dest.description.toLowerCase().contains(lowercaseQuery);
            final matchesRegion = dest.region.toLowerCase().contains(lowercaseQuery);

            // Avoid duplicates
            final alreadyInResults = results.any((r) => r.id == dest.id);

            return !alreadyInResults && (matchesTag || matchesDesc || matchesRegion);
          }).toList();

      return [...results, ...additionalResults];
    } catch (e) {
      LoggerService.e('Error searching destinations', error: e);
      return [];
    }
  }

  // Stream destinations for real-time updates
  Stream<List<DestinationModel>> streamDestinations() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => DestinationModel.fromJson(doc.data(), doc.id)).toList(),
        );
  }

  // Sample data creation removed for production
}
