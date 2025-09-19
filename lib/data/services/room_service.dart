import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/room_model.dart';
import 'package:wanderlust/data/services/business_service.dart';

class RoomService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BusinessService _businessService = Get.find<BusinessService>();
  
  // Collections
  static const String _roomsCollection = 'rooms';
  
  // Current business rooms
  final RxList<RoomModel> businessRooms = <RoomModel>[].obs;
  
  // Loading state
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Load rooms if business profile exists
    if (_businessService.currentBusinessProfile.value != null) {
      loadBusinessRooms();
    }
  }
  
  /// Load rooms for current business
  Future<void> loadBusinessRooms() async {
    try {
      isLoading.value = true;
      final businessId = _businessService.currentBusinessProfile.value?.id;
      
      if (businessId == null) {
        LoggerService.w('No business profile to load rooms for');
        return;
      }
      
      final snapshot = await _firestore
          .collection(_roomsCollection)
          .where('businessId', isEqualTo: businessId)
          .orderBy('createdAt', descending: true)
          .get();
      
      businessRooms.value = snapshot.docs
          .map((doc) => RoomModel.fromJson(doc.data(), doc.id))
          .toList();
      
      LoggerService.i('Loaded ${businessRooms.length} rooms');
    } catch (e) {
      LoggerService.e('Error loading business rooms', error: e);
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Create a new room
  Future<RoomModel?> createRoom({
    required String roomName,
    required RoomType roomType,
    required String description,
    required double pricePerNight,
    double? discountPrice,
    required int maxGuests,
    required int numberOfBeds,
    required double roomSize,
    required List<String> amenities,
    required List<String> images,
    String? floor,
    String? viewType,
    bool hasBalcony = false,
    bool hasKitchen = false,
    bool hasAirConditioner = false,
    bool hasWifi = false,
    bool hasTV = false,
    bool hasRefrigerator = false,
    bool hasBathroom = true,
    bool hasHotWater = false,
  }) async {
    try {
      final businessProfile = _businessService.currentBusinessProfile.value;
      if (businessProfile == null) {
        throw Exception('No business profile found');
      }
      
      // Create room model
      final room = RoomModel(
        id: '',
        businessId: businessProfile.id,
        businessName: businessProfile.businessName,
        roomName: roomName,
        roomType: roomType,
        description: description,
        pricePerNight: pricePerNight,
        discountPrice: discountPrice,
        maxGuests: maxGuests,
        numberOfBeds: numberOfBeds,
        roomSize: roomSize,
        amenities: amenities,
        images: images,
        floor: floor,
        viewType: viewType,
        hasBalcony: hasBalcony,
        hasKitchen: hasKitchen,
        hasAirConditioner: hasAirConditioner,
        hasWifi: hasWifi,
        hasTV: hasTV,
        hasRefrigerator: hasRefrigerator,
        hasBathroom: hasBathroom,
        hasHotWater: hasHotWater,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to Firestore
      final docRef = await _firestore
          .collection(_roomsCollection)
          .add(room.toJson());
      
      // Create room with ID
      final createdRoom = RoomModel(
        id: docRef.id,
        businessId: room.businessId,
        businessName: room.businessName,
        roomName: room.roomName,
        roomType: room.roomType,
        description: room.description,
        pricePerNight: room.pricePerNight,
        discountPrice: room.discountPrice,
        maxGuests: room.maxGuests,
        numberOfBeds: room.numberOfBeds,
        roomSize: room.roomSize,
        amenities: room.amenities,
        images: room.images,
        status: room.status,
        isActive: room.isActive,
        floor: room.floor,
        viewType: room.viewType,
        hasBalcony: room.hasBalcony,
        hasKitchen: room.hasKitchen,
        hasAirConditioner: room.hasAirConditioner,
        hasWifi: room.hasWifi,
        hasTV: room.hasTV,
        hasRefrigerator: room.hasRefrigerator,
        hasBathroom: room.hasBathroom,
        hasHotWater: room.hasHotWater,
        createdAt: room.createdAt,
        updatedAt: room.updatedAt,
      );
      
      // Add to local list
      businessRooms.add(createdRoom);
      
      // Update business total listings count
      await _updateBusinessListingsCount();
      
      LoggerService.i('Room created: ${docRef.id}');
      return createdRoom;
    } catch (e) {
      LoggerService.e('Error creating room', error: e);
      rethrow;
    }
  }
  
  /// Update room
  Future<bool> updateRoom(String roomId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(_roomsCollection)
          .doc(roomId)
          .update(updates);
      
      // Reload rooms
      await loadBusinessRooms();
      
      LoggerService.i('Room updated: $roomId');
      return true;
    } catch (e) {
      LoggerService.e('Error updating room', error: e);
      return false;
    }
  }
  
  /// Delete room
  Future<bool> deleteRoom(String roomId) async {
    try {
      await _firestore
          .collection(_roomsCollection)
          .doc(roomId)
          .delete();
      
      // Remove from local list
      businessRooms.removeWhere((room) => room.id == roomId);
      
      // Update business total listings count
      await _updateBusinessListingsCount();
      
      LoggerService.i('Room deleted: $roomId');
      return true;
    } catch (e) {
      LoggerService.e('Error deleting room', error: e);
      return false;
    }
  }
  
  /// Toggle room status
  Future<bool> toggleRoomStatus(String roomId, RoomStatus newStatus) async {
    try {
      await _firestore
          .collection(_roomsCollection)
          .doc(roomId)
          .update({
        'status': newStatus.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Reload rooms
      await loadBusinessRooms();
      
      LoggerService.i('Room status updated: $roomId to ${newStatus.value}');
      return true;
    } catch (e) {
      LoggerService.e('Error updating room status', error: e);
      return false;
    }
  }
  
  /// Update business listings count
  Future<void> _updateBusinessListingsCount() async {
    try {
      final businessId = _businessService.currentBusinessProfile.value?.id;
      if (businessId != null) {
        await _firestore
            .collection('business_profiles')
            .doc(businessId)
            .update({
          'totalListings': businessRooms.length,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      LoggerService.e('Error updating business listings count', error: e);
    }
  }
  
  /// Get room by ID
  Future<RoomModel?> getRoomById(String roomId) async {
    try {
      final doc = await _firestore
          .collection(_roomsCollection)
          .doc(roomId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return RoomModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error getting room', error: e);
      return null;
    }
  }
  
  /// Search rooms
  Future<List<RoomModel>> searchRooms({
    String? query,
    RoomType? roomType,
    double? minPrice,
    double? maxPrice,
    int? maxGuests,
  }) async {
    try {
      Query<Map<String, dynamic>> queryRef = _firestore
          .collection(_roomsCollection)
          .where('isActive', isEqualTo: true)
          .where('status', isEqualTo: RoomStatus.available.value);
      
      if (roomType != null) {
        queryRef = queryRef.where('roomType', isEqualTo: roomType.value);
      }
      
      if (minPrice != null) {
        queryRef = queryRef.where('pricePerNight', isGreaterThanOrEqualTo: minPrice);
      }
      
      if (maxPrice != null) {
        queryRef = queryRef.where('pricePerNight', isLessThanOrEqualTo: maxPrice);
      }
      
      if (maxGuests != null) {
        queryRef = queryRef.where('maxGuests', isGreaterThanOrEqualTo: maxGuests);
      }
      
      final snapshot = await queryRef.get();
      
      var rooms = snapshot.docs
          .map((doc) => RoomModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // Filter by query if provided
      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        rooms = rooms.where((room) =>
            room.roomName.toLowerCase().contains(lowerQuery) ||
            room.description.toLowerCase().contains(lowerQuery) ||
            room.businessName.toLowerCase().contains(lowerQuery)
        ).toList();
      }
      
      return rooms;
    } catch (e) {
      LoggerService.e('Error searching rooms', error: e);
      return [];
    }
  }
}