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
          .map((doc) => TourModel.fromJson(doc.data(), doc.id))
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
          .map((doc) => TourModel.fromJson(doc.data(), doc.id))
          .where((tour) => tour.featured && tour.status == 'active')
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
          .map((doc) => TourModel.fromJson(doc.data(), doc.id))
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
          .map((doc) => TourModel.fromJson(doc.data(), doc.id))
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
        return TourModel.fromJson(doc.data()!, doc.id);
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
          .map((doc) => TourModel.fromJson(doc.data(), doc.id))
          .toList();

      // Additional client-side filtering
      final allTours = await getAllTours();
      final additionalResults = allTours.where((tour) {
        final matchesDesc = tour.description.toLowerCase().contains(lowercaseQuery);
        final matchesDest = tour.destinationName.toLowerCase().contains(lowercaseQuery);
        final matchesTag = tour.tags.any((tag) => 
            tag.toLowerCase().contains(lowercaseQuery));
        
        // Avoid duplicates
        final alreadyInResults = results.any((r) => r.id == tour.id);
        
        return !alreadyInResults && (matchesDesc || matchesDest || matchesTag);
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
          .map((doc) => TourModel.fromJson(doc.data(), doc.id))
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
            .map((doc) => TourModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Create sample data (for development)
  Future<void> createSampleTours() async {
    final sampleTours = [
      TourModel(
        id: '',
        title: 'Tour Hạ Long 2N1Đ - Du thuyền 5 sao',
        description: 'Khám phá vịnh Hạ Long tuyệt đẹp với du thuyền 5 sao sang trọng.',
        destinationId: 'halong1',
        destinationName: 'Hạ Long Bay',
        duration: '2N1Đ',
        price: 3500000,
        discountPrice: 2900000,
        images: [
          'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
          'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800',
        ],
        itinerary: [
          TourItinerary(
            day: 'Ngày 1',
            title: 'Hà Nội - Hạ Long - Hang Sửng Sốt',
            description: 'Khởi hành từ Hà Nội, tham quan Hang Sửng Sốt',
            activities: ['Di chuyển', 'Check-in du thuyền', 'Tham quan hang', 'Ăn tối trên du thuyền'],
          ),
          TourItinerary(
            day: 'Ngày 2',
            title: 'Đảo Ti Tốp - Hà Nội',
            description: 'Tham quan đảo Ti Tốp, trở về Hà Nội',
            activities: ['Bơi lội', 'Leo núi ngắm cảnh', 'Ăn trưa', 'Về Hà Nội'],
          ),
        ],
        inclusions: [
          'Xe đưa đón khứ hồi',
          'Du thuyền 5 sao',
          '3 bữa ăn chính + 1 bữa sáng',
          'Vé tham quan',
          'Hướng dẫn viên',
        ],
        exclusions: [
          'Chi phí cá nhân',
          'Đồ uống trong bữa ăn',
          'Tip cho hướng dẫn viên',
        ],
        maxGroupSize: 20,
        availableDates: [
          DateTime.now().add(const Duration(days: 7)),
          DateTime.now().add(const Duration(days: 14)),
          DateTime.now().add(const Duration(days: 21)),
        ],
        rating: 4.8,
        reviewCount: 156,
        hostId: 'host1',
        hostName: 'Wanderlust Travel',
        tags: ['du thuyền', 'biển', 'hạ long', 'luxury'],
        featured: true,
        status: 'active',
      ),
      TourModel(
        id: '',
        title: 'Sapa Trekking 3N2Đ - Khám phá Fansipan',
        description: 'Chinh phục đỉnh Fansipan và khám phá văn hóa dân tộc Sapa.',
        destinationId: 'sapa1',
        destinationName: 'Sapa',
        duration: '3N2Đ',
        price: 2800000,
        images: [
          'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800',
        ],
        itinerary: [
          TourItinerary(
            day: 'Ngày 1',
            title: 'Hà Nội - Sapa - Bản Cát Cát',
            description: 'Di chuyển đến Sapa, tham quan bản Cát Cát',
            activities: ['Di chuyển', 'Check-in khách sạn', 'Thăm bản Cát Cát'],
          ),
        ],
        inclusions: [
          'Xe đưa đón',
          'Khách sạn 3 sao',
          'Bữa ăn theo chương trình',
          'Vé cáp treo Fansipan',
        ],
        exclusions: [
          'Chi phí cá nhân',
        ],
        maxGroupSize: 15,
        availableDates: [
          DateTime.now().add(const Duration(days: 10)),
        ],
        rating: 4.7,
        reviewCount: 89,
        hostId: 'host1',
        hostName: 'Wanderlust Travel',
        tags: ['trekking', 'núi', 'sapa', 'adventure'],
        featured: false,
        status: 'active',
      ),
    ];

    try {
      for (final tour in sampleTours) {
        await _firestore.collection(_collection).add(tour.toJson());
      }
      LoggerService.i('Sample tours created successfully');
    } catch (e) {
      LoggerService.e('Error creating sample tours', error: e);
    }
  }
}