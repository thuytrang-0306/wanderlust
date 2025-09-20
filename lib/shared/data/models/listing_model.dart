import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Listing type enum - simple categories
enum ListingType {
  room('room', 'Phòng', '🛏️'),
  tour('tour', 'Tour', '✈️'),
  food('food', 'Món ăn', '🍽️'),
  service('service', 'Dịch vụ', '🚗');

  final String value;
  final String displayName;
  final String icon;
  
  const ListingType(this.value, this.displayName, this.icon);
  
  static ListingType fromValue(String value) {
    return ListingType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ListingType.service,
    );
  }
}

/// Unified Listing Model for ALL business types
/// Simple, flexible, maintainable
class ListingModel {
  final String id;
  final String businessId;
  final String businessName;
  final ListingType type;
  final String title;
  final String description;
  final double price;
  final double? discountPrice;
  final String priceUnit; // per night, per person, per item, per hour
  final List<String> images;
  final Map<String, dynamic> details; // Flexible details for each type
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Statistics
  final int views;
  final int bookings;
  final double rating;
  final int reviews;

  ListingModel({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.type,
    required this.title,
    required this.description,
    required this.price,
    this.discountPrice,
    this.priceUnit = '',
    required this.images,
    required this.details,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.views = 0,
    this.bookings = 0,
    this.rating = 0,
    this.reviews = 0,
  });

  /// From JSON - Works with both Firestore and old room data
  factory ListingModel.fromJson(Map<String, dynamic> json, String id) {
    // Auto-detect type from data
    ListingType type;
    if (json['type'] != null) {
      type = ListingType.fromValue(json['type']);
    } else if (json['roomType'] != null) {
      // Old room model compatibility
      type = ListingType.room;
    } else {
      type = ListingType.service;
    }
    
    return ListingModel(
      id: id,
      businessId: json['businessId'] ?? '',
      businessName: json['businessName'] ?? '',
      type: type,
      title: json['title'] ?? json['roomName'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? json['pricePerNight'] ?? 0).toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      priceUnit: json['priceUnit'] ?? _getPriceUnit(type),
      images: List<String>.from(json['images'] ?? []),
      details: json['details'] ?? _extractDetails(json, type),
      isActive: json['isActive'] ?? true,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
      views: json['views'] ?? 0,
      bookings: json['bookings'] ?? json['totalBookings'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? json['totalReviews'] ?? 0,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'businessName': businessName,
      'type': type.value,
      'title': title,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'priceUnit': priceUnit,
      'images': images,
      'details': details,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'views': views,
      'bookings': bookings,
      'rating': rating,
      'reviews': reviews,
    };
  }

  /// Helper to get price unit based on type
  static String _getPriceUnit(ListingType type) {
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

  /// Extract details from old models for compatibility
  static Map<String, dynamic> _extractDetails(Map<String, dynamic> json, ListingType type) {
    final details = <String, dynamic>{};
    
    if (type == ListingType.room) {
      // Extract room-specific details
      details['roomType'] = json['roomType'];
      details['maxGuests'] = json['maxGuests'];
      details['numberOfBeds'] = json['numberOfBeds'];
      details['roomSize'] = json['roomSize'];
      details['amenities'] = json['amenities'];
      details['hasWifi'] = json['hasWifi'];
      details['hasAirConditioner'] = json['hasAirConditioner'];
      // Add more as needed
    }
    // Add extractors for other types when needed
    
    return details;
  }

  /// Parse timestamp helper
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return DateTime.now();
  }

  /// Getters for convenience
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((price - discountPrice!) / price) * 100;
  }
  
  String get formattedPrice {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(price)} VNĐ$priceUnit';
  }
  
  String get formattedDiscountPrice {
    if (!hasDiscount) return formattedPrice;
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(discountPrice)} VNĐ$priceUnit';
  }
  
  String get typeIcon => type.icon;
  String get typeDisplayName => type.displayName;

  /// Create from old RoomModel for migration
  factory ListingModel.fromRoomModel(dynamic room, String id) {
    return ListingModel(
      id: id,
      businessId: room.businessId,
      businessName: room.businessName,
      type: ListingType.room,
      title: room.roomName,
      description: room.description,
      price: room.pricePerNight,
      discountPrice: room.discountPrice,
      priceUnit: '/đêm',
      images: room.images,
      details: {
        'roomType': room.roomType.value,
        'maxGuests': room.maxGuests,
        'numberOfBeds': room.numberOfBeds,
        'roomSize': room.roomSize,
        'amenities': room.amenities,
        'floor': room.floor,
        'viewType': room.viewType,
        'hasBalcony': room.hasBalcony,
        'hasKitchen': room.hasKitchen,
        'hasAirConditioner': room.hasAirConditioner,
        'hasWifi': room.hasWifi,
        'hasTV': room.hasTV,
        'hasRefrigerator': room.hasRefrigerator,
        'hasBathroom': room.hasBathroom,
        'hasHotWater': room.hasHotWater,
      },
      isActive: room.isActive,
      createdAt: room.createdAt,
      updatedAt: room.updatedAt,
      bookings: room.totalBookings ?? 0,
      rating: room.rating ?? 0,
      reviews: room.totalReviews ?? 0,
    );
  }
}