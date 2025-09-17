import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wanderlust/data/models/accommodation_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class AccommodationService extends GetxService {
  static AccommodationService get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection reference
  CollectionReference get _accommodationsCollection => 
      _firestore.collection('accommodations');
  
  // Get featured accommodations
  Stream<List<AccommodationModel>> getFeaturedAccommodations({int limit = 10}) {
    return _accommodationsCollection
        .where('isFeatured', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AccommodationModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get all active accommodations
  Stream<List<AccommodationModel>> getAccommodations({
    int limit = 20,
    AccommodationType? type,
    String? city,
  }) {
    Query query = _accommodationsCollection
        .where('isActive', isEqualTo: true);
    
    if (type != null) {
      query = query.where('type', isEqualTo: type.value);
    }
    
    if (city != null && city.isNotEmpty) {
      query = query.where('location.city', isEqualTo: city);
    }
    
    return query
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AccommodationModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get single accommodation
  Future<AccommodationModel?> getAccommodation(String id) async {
    try {
      final doc = await _accommodationsCollection.doc(id).get();
      
      if (doc.exists) {
        return AccommodationModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error getting accommodation', error: e);
      return null;
    }
  }
  
  // Search accommodations
  Future<List<AccommodationModel>> searchAccommodations(String query) async {
    try {
      if (query.isEmpty) return [];
      
      // Note: Firestore doesn't support full-text search
      // For production, use Algolia or Elasticsearch
      // This is a simple implementation
      
      final snapshot = await _accommodationsCollection
          .where('isActive', isEqualTo: true)
          .get();
      
      final accommodations = snapshot.docs
          .map((doc) => AccommodationModel.fromFirestore(doc))
          .where((acc) => 
              acc.name.toLowerCase().contains(query.toLowerCase()) ||
              acc.location.city.toLowerCase().contains(query.toLowerCase()) ||
              acc.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      return accommodations;
    } catch (e) {
      LoggerService.e('Error searching accommodations', error: e);
      return [];
    }
  }
  
  // Filter accommodations
  Future<List<AccommodationModel>> filterAccommodations({
    AccommodationType? type,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? city,
    List<String>? amenities,
  }) async {
    try {
      Query query = _accommodationsCollection.where('isActive', isEqualTo: true);
      
      if (type != null) {
        query = query.where('type', isEqualTo: type.value);
      }
      
      if (city != null && city.isNotEmpty) {
        query = query.where('location.city', isEqualTo: city);
      }
      
      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }
      
      final snapshot = await query.get();
      
      var accommodations = snapshot.docs
          .map((doc) => AccommodationModel.fromFirestore(doc))
          .toList();
      
      // Client-side filtering for complex queries
      if (minPrice != null) {
        accommodations = accommodations
            .where((acc) => acc.pricing.finalPrice >= minPrice)
            .toList();
      }
      
      if (maxPrice != null) {
        accommodations = accommodations
            .where((acc) => acc.pricing.finalPrice <= maxPrice)
            .toList();
      }
      
      if (amenities != null && amenities.isNotEmpty) {
        accommodations = accommodations
            .where((acc) => amenities.every((amenity) => 
                acc.amenities.contains(amenity)))
            .toList();
      }
      
      return accommodations;
    } catch (e) {
      LoggerService.e('Error filtering accommodations', error: e);
      return [];
    }
  }
  
  // Get nearby accommodations
  Future<List<AccommodationModel>> getNearbyAccommodations({
    required double latitude,
    required double longitude,
    double radiusInKm = 10,
  }) async {
    try {
      // Simple implementation - get all and filter by distance
      // For production, use GeoFirestore or similar
      
      final snapshot = await _accommodationsCollection
          .where('isActive', isEqualTo: true)
          .get();
      
      final accommodations = snapshot.docs
          .map((doc) => AccommodationModel.fromFirestore(doc))
          .toList();
      
      // Filter by distance (simplified)
      // You'd need to implement proper distance calculation
      
      return accommodations;
    } catch (e) {
      LoggerService.e('Error getting nearby accommodations', error: e);
      return [];
    }
  }
  
  // Add demo data (for testing)
  Future<void> addDemoAccommodations() async {
    try {
      final demoData = [
        {
          'providerId': 'demo_provider_1',
          'name': 'Melia Vinpearl Nha Trang Empire',
          'description': 'Khách sạn 5 sao sang trọng với view biển tuyệt đẹp',
          'type': 'hotel',
          'location': {
            'geoPoint': const GeoPoint(12.2388, 109.1967),
            'address': '44 - 46 Lê Thánh Tôn, Lộc Thọ',
            'city': 'Nha Trang',
            'country': 'Vietnam',
          },
          'images': [
            'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800',
            'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
          ],
          'thumbnail': 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800',
          'pricing': {
            'basePrice': 2500000,
            'currency': 'VND',
            'discountPercentage': 20,
            'taxes': 250000,
          },
          'amenities': ['WiFi', 'Pool', 'Spa', 'Gym', 'Restaurant', 'Bar'],
          'roomTypes': [
            {
              'id': 'deluxe',
              'name': 'Deluxe Room',
              'capacity': 2,
              'price': 2500000,
              'availability': 5,
            },
            {
              'id': 'suite',
              'name': 'Suite',
              'capacity': 4,
              'price': 4500000,
              'availability': 2,
            },
          ],
          'rating': 4.8,
          'totalReviews': 256,
          'policies': {
            'checkIn': '14:00',
            'checkOut': '12:00',
            'cancellation': 'Hủy miễn phí trước 24h',
            'paymentMethods': ['cash', 'card', 'transfer'],
          },
          'tags': ['luxury', 'beach', 'family'],
          'isActive': true,
          'isFeatured': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'providerId': 'demo_provider_2',
          'name': 'The Anam Cam Ranh',
          'description': 'Resort cao cấp phong cách colonial Pháp',
          'type': 'resort',
          'location': {
            'geoPoint': const GeoPoint(12.0167, 109.2167),
            'address': 'Bãi Dài, Cam Hải Đông',
            'city': 'Cam Ranh',
            'country': 'Vietnam',
          },
          'images': [
            'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
            'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
          ],
          'thumbnail': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
          'pricing': {
            'basePrice': 3800000,
            'currency': 'VND',
            'discountPercentage': 15,
            'taxes': 380000,
          },
          'amenities': ['WiFi', 'Pool', 'Spa', 'Beach', 'Restaurant', 'Tennis'],
          'roomTypes': [
            {
              'id': 'villa',
              'name': 'Beach Villa',
              'capacity': 2,
              'price': 3800000,
              'availability': 3,
            },
          ],
          'rating': 4.9,
          'totalReviews': 189,
          'policies': {
            'checkIn': '15:00',
            'checkOut': '12:00',
            'cancellation': 'Hủy miễn phí trước 48h',
            'paymentMethods': ['card', 'transfer'],
          },
          'tags': ['luxury', 'beach', 'romantic'],
          'isActive': true,
          'isFeatured': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];
      
      for (final data in demoData) {
        await _accommodationsCollection.add(data);
      }
      
      LoggerService.i('Demo accommodations added successfully');
    } catch (e) {
      LoggerService.e('Error adding demo accommodations', error: e);
    }
  }
}