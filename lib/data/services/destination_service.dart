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
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('rating', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DestinationModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting destinations', error: e);
      return [];
    }
  }

  // Get featured destinations
  Future<List<DestinationModel>> getFeaturedDestinations({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('featured', isEqualTo: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => DestinationModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting featured destinations', error: e);
      return [];
    }
  }

  // Get popular destinations
  Future<List<DestinationModel>> getPopularDestinations({int limit = 10}) async {
    try {
      // Simplified query - just get top rated destinations
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => DestinationModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting popular destinations', error: e);
      return [];
    }
  }

  // Get destinations by region
  Future<List<DestinationModel>> getDestinationsByRegion(String region) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('region', isEqualTo: region)
          .orderBy('rating', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DestinationModel.fromJson(doc.data(), doc.id))
          .toList();
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
      final snapshot = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .limit(20)
          .get();

      final results = snapshot.docs
          .map((doc) => DestinationModel.fromJson(doc.data(), doc.id))
          .toList();

      // Additional client-side filtering for tags and description
      final allDestinations = await getAllDestinations();
      final additionalResults = allDestinations.where((dest) {
        final matchesTag = dest.tags.any((tag) => 
            tag.toLowerCase().contains(lowercaseQuery));
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
        .map((snapshot) => snapshot.docs
            .map((doc) => DestinationModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Create sample data (for development)
  Future<void> createSampleDestinations() async {
    final sampleDestinations = [
      DestinationModel(
        id: '',
        name: 'Hạ Long Bay',
        description: 'Vịnh Hạ Long với hàng nghìn đảo đá vôi tuyệt đẹp, di sản thiên nhiên thế giới.',
        region: 'Miền Bắc',
        images: [
          'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
          'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800',
        ],
        rating: 4.8,
        reviewCount: 2543,
        basePrice: 1500000,
        highlights: ['Di sản UNESCO', 'Hang Sửng Sốt', 'Đảo Ti Tốp', 'Kayaking'],
        bestTimeToVisit: ['Tháng 4-6', 'Tháng 9-11'],
        activities: ['Du thuyền', 'Kayak', 'Bơi lội', 'Leo núi'],
        tags: ['biển', 'di sản', 'du thuyền', 'hạ long'],
        featured: true,
        popular: true,
      ),
      DestinationModel(
        id: '',
        name: 'Sapa',
        description: 'Thị trấn mù sương với ruộng bậc thang tuyệt đẹp và văn hóa dân tộc đa dạng.',
        region: 'Miền Bắc',
        images: [
          'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800',
          'https://images.unsplash.com/photo-1598935898639-81586f7d2129?w=800',
        ],
        rating: 4.7,
        reviewCount: 1832,
        basePrice: 800000,
        highlights: ['Fansipan', 'Ruộng bậc thang', 'Chợ phiên', 'Bản Cát Cát'],
        bestTimeToVisit: ['Tháng 9-11', 'Tháng 3-5'],
        activities: ['Trekking', 'Văn hóa', 'Chụp ảnh', 'Cáp treo'],
        tags: ['núi', 'trekking', 'dân tộc', 'sapa'],
        featured: true,
        popular: true,
      ),
      DestinationModel(
        id: '',
        name: 'Đà Nẵng',
        description: 'Thành phố đáng sống với bãi biển đẹp, ẩm thực phong phú và cuộc sống hiện đại.',
        region: 'Miền Trung',
        images: [
          'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800',
          'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800',
        ],
        rating: 4.6,
        reviewCount: 2156,
        basePrice: 1200000,
        highlights: ['Cầu Vàng', 'Bà Nà Hills', 'Biển Mỹ Khê', 'Ngũ Hành Sơn'],
        bestTimeToVisit: ['Tháng 2-8'],
        activities: ['Biển', 'Ẩm thực', 'Vui chơi', 'Văn hóa'],
        tags: ['biển', 'thành phố', 'ẩm thực', 'đà nẵng'],
        featured: false,
        popular: true,
      ),
    ];

    try {
      for (final destination in sampleDestinations) {
        await _firestore.collection(_collection).add(destination.toJson());
      }
      LoggerService.i('Sample destinations created successfully');
    } catch (e) {
      LoggerService.e('Error creating sample destinations', error: e);
    }
  }
}