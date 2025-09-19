import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:wanderlust/data/services/business_service.dart';

/// Unified Listing Service - One service for ALL listing types
/// Simple, powerful, maintainable
class ListingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BusinessService _businessService = Get.find<BusinessService>();
  
  // Single collection for all listings
  static const String _collection = 'listings';
  
  // Observable listings
  final RxList<ListingModel> businessListings = <ListingModel>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Auto-load if business exists
    if (_businessService.currentBusinessProfile.value != null) {
      loadBusinessListings();
    }
  }
  
  /// Load all listings for current business
  Future<void> loadBusinessListings({ListingType? type}) async {
    try {
      isLoading.value = true;
      final businessId = _businessService.currentBusinessProfile.value?.id;
      
      if (businessId == null) {
        LoggerService.w('No business profile');
        return;
      }
      
      Query<Map<String, dynamic>> query = _firestore
          .collection(_collection)
          .where('businessId', isEqualTo: businessId);
      
      // Filter by type if specified
      if (type != null) {
        query = query.where('type', isEqualTo: type.value);
      }
      
      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .get();
      
      businessListings.value = snapshot.docs
          .map((doc) => ListingModel.fromJson(doc.data(), doc.id))
          .toList();
      
      LoggerService.i('Loaded ${businessListings.length} listings');
    } catch (e) {
      LoggerService.e('Error loading listings', error: e);
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Create new listing (any type)
  Future<ListingModel?> createListing({
    required ListingType type,
    required String title,
    required String description,
    required double price,
    double? discountPrice,
    String? priceUnit,
    required List<String> images,
    required Map<String, dynamic> details,
  }) async {
    try {
      final business = _businessService.currentBusinessProfile.value;
      if (business == null) {
        throw Exception('No business profile');
      }
      
      final listing = ListingModel(
        id: '',
        businessId: business.id,
        businessName: business.businessName,
        type: type,
        title: title,
        description: description,
        price: price,
        discountPrice: discountPrice,
        priceUnit: priceUnit ?? _getDefaultPriceUnit(type),
        images: images,
        details: details,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to Firestore
      final docRef = await _firestore
          .collection(_collection)
          .add(listing.toJson());
      
      // Create with ID
      final created = ListingModel(
        id: docRef.id,
        businessId: listing.businessId,
        businessName: listing.businessName,
        type: listing.type,
        title: listing.title,
        description: listing.description,
        price: listing.price,
        discountPrice: listing.discountPrice,
        priceUnit: listing.priceUnit,
        images: listing.images,
        details: listing.details,
        createdAt: listing.createdAt,
        updatedAt: listing.updatedAt,
      );
      
      businessListings.add(created);
      await _updateBusinessStats();
      
      LoggerService.i('Created listing: ${docRef.id}');
      return created;
    } catch (e) {
      LoggerService.e('Error creating listing', error: e);
      return null;
    }
  }
  
  /// Update listing
  Future<bool> updateListing(String id, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(updates);
      
      await loadBusinessListings();
      
      LoggerService.i('Updated listing: $id');
      return true;
    } catch (e) {
      LoggerService.e('Error updating listing', error: e);
      return false;
    }
  }
  
  /// Delete listing
  Future<bool> deleteListing(String id) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .delete();
      
      businessListings.removeWhere((l) => l.id == id);
      await _updateBusinessStats();
      
      LoggerService.i('Deleted listing: $id');
      return true;
    } catch (e) {
      LoggerService.e('Error deleting listing', error: e);
      return false;
    }
  }
  
  /// Get listing by ID
  Future<ListingModel?> getListingById(String id) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return ListingModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error getting listing', error: e);
      return null;
    }
  }
  
  /// Search listings
  Future<List<ListingModel>> searchListings({
    String? query,
    ListingType? type,
    double? minPrice,
    double? maxPrice,
    String? businessId,
  }) async {
    try {
      Query<Map<String, dynamic>> queryRef = _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true);
      
      if (type != null) {
        queryRef = queryRef.where('type', isEqualTo: type.value);
      }
      
      if (businessId != null) {
        queryRef = queryRef.where('businessId', isEqualTo: businessId);
      }
      
      if (minPrice != null) {
        queryRef = queryRef.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      
      if (maxPrice != null) {
        queryRef = queryRef.where('price', isLessThanOrEqualTo: maxPrice);
      }
      
      final snapshot = await queryRef.get();
      
      var listings = snapshot.docs
          .map((doc) => ListingModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // Filter by query text
      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        listings = listings.where((l) =>
            l.title.toLowerCase().contains(lowerQuery) ||
            l.description.toLowerCase().contains(lowerQuery) ||
            l.businessName.toLowerCase().contains(lowerQuery)
        ).toList();
      }
      
      return listings;
    } catch (e) {
      LoggerService.e('Error searching listings', error: e);
      return [];
    }
  }
  
  /// Update business statistics
  Future<void> _updateBusinessStats() async {
    try {
      final businessId = _businessService.currentBusinessProfile.value?.id;
      if (businessId != null) {
        final stats = getStatistics();
        await _firestore
            .collection('business_profiles')
            .doc(businessId)
            .update({
          'totalListings': stats['total'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      LoggerService.e('Error updating business stats', error: e);
    }
  }
  
  /// Get statistics by type
  Map<String, dynamic> getStatistics() {
    return {
      'total': businessListings.length,
      'rooms': businessListings.where((l) => l.type == ListingType.room).length,
      'tours': businessListings.where((l) => l.type == ListingType.tour).length,
      'foods': businessListings.where((l) => l.type == ListingType.food).length,
      'services': businessListings.where((l) => l.type == ListingType.service).length,
    };
  }
  
  /// Get listings by type
  List<ListingModel> getListingsByType(ListingType type) {
    return businessListings.where((l) => l.type == type).toList();
  }
  
  /// Helper to get default price unit
  String _getDefaultPriceUnit(ListingType type) {
    switch (type) {
      case ListingType.room:
        return '/đêm';
      case ListingType.tour:
        return '/người';
      case ListingType.food:
        return '/phần';
      case ListingType.service:
        return '/lần';
    }
  }
  
  /// MIGRATION HELPER: Import old rooms to new listings
  Future<bool> migrateRoomsToListings() async {
    try {
      final businessId = _businessService.currentBusinessProfile.value?.id;
      if (businessId == null) return false;
      
      // Get old rooms
      final roomsSnapshot = await _firestore
          .collection('rooms')
          .where('businessId', isEqualTo: businessId)
          .get();
      
      if (roomsSnapshot.docs.isEmpty) {
        LoggerService.i('No rooms to migrate');
        return true;
      }
      
      // Convert and save as listings
      for (final doc in roomsSnapshot.docs) {
        final roomData = doc.data();
        final listing = ListingModel.fromJson(roomData, doc.id);
        
        // Check if already migrated
        final existing = await _firestore
            .collection(_collection)
            .where('businessId', isEqualTo: businessId)
            .where('title', isEqualTo: listing.title)
            .get();
        
        if (existing.docs.isEmpty) {
          await _firestore.collection(_collection).add(listing.toJson());
          LoggerService.i('Migrated room: ${listing.title}');
        }
      }
      
      LoggerService.i('Migration complete');
      return true;
    } catch (e) {
      LoggerService.e('Migration failed', error: e);
      return false;
    }
  }
}