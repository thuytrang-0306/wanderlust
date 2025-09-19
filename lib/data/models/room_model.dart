import 'package:cloud_firestore/cloud_firestore.dart';

// Room type enum
enum RoomType {
  single('single', 'Phòng đơn', '🛏️'),
  double('double', 'Phòng đôi', '🛏️🛏️'),
  twin('twin', 'Phòng hai giường', '🛏️🛏️'),
  suite('suite', 'Phòng suite', '🏨'),
  deluxe('deluxe', 'Phòng deluxe', '⭐'),
  family('family', 'Phòng gia đình', '👨‍👩‍👧‍👦'),
  villa('villa', 'Villa', '🏡');

  final String value;
  final String displayName;
  final String icon;
  
  const RoomType(this.value, this.displayName, this.icon);
}

// Room status enum
enum RoomStatus {
  available('available', 'Có sẵn'),
  booked('booked', 'Đã đặt'),
  maintenance('maintenance', 'Bảo trì'),
  inactive('inactive', 'Không hoạt động');

  final String value;
  final String displayName;
  
  const RoomStatus(this.value, this.displayName);
}

class RoomModel {
  final String id;
  final String businessId;
  final String businessName;
  final String roomName;
  final RoomType roomType;
  final String description;
  final double pricePerNight;
  final double? discountPrice;
  final int maxGuests;
  final int numberOfBeds;
  final double roomSize; // in square meters
  final List<String> amenities;
  final List<String> images;
  final RoomStatus status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional details
  final String? floor;
  final String? viewType; // sea view, city view, garden view, etc.
  final bool hasBalcony;
  final bool hasKitchen;
  final bool hasAirConditioner;
  final bool hasWifi;
  final bool hasTV;
  final bool hasRefrigerator;
  final bool hasBathroom;
  final bool hasHotWater;
  
  // Booking info
  final int totalBookings;
  final double rating;
  final int totalReviews;

  RoomModel({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.roomName,
    required this.roomType,
    required this.description,
    required this.pricePerNight,
    this.discountPrice,
    required this.maxGuests,
    required this.numberOfBeds,
    required this.roomSize,
    required this.amenities,
    required this.images,
    this.status = RoomStatus.available,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.floor,
    this.viewType,
    this.hasBalcony = false,
    this.hasKitchen = false,
    this.hasAirConditioner = false,
    this.hasWifi = false,
    this.hasTV = false,
    this.hasRefrigerator = false,
    this.hasBathroom = true,
    this.hasHotWater = false,
    this.totalBookings = 0,
    this.rating = 0.0,
    this.totalReviews = 0,
  });

  // From JSON
  factory RoomModel.fromJson(Map<String, dynamic> json, String id) {
    return RoomModel(
      id: id,
      businessId: json['businessId'] ?? '',
      businessName: json['businessName'] ?? '',
      roomName: json['roomName'] ?? '',
      roomType: RoomType.values.firstWhere(
        (e) => e.value == json['roomType'],
        orElse: () => RoomType.single,
      ),
      description: json['description'] ?? '',
      pricePerNight: (json['pricePerNight'] ?? 0).toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      maxGuests: json['maxGuests'] ?? 1,
      numberOfBeds: json['numberOfBeds'] ?? 1,
      roomSize: (json['roomSize'] ?? 0).toDouble(),
      amenities: List<String>.from(json['amenities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      status: RoomStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => RoomStatus.available,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      floor: json['floor'],
      viewType: json['viewType'],
      hasBalcony: json['hasBalcony'] ?? false,
      hasKitchen: json['hasKitchen'] ?? false,
      hasAirConditioner: json['hasAirConditioner'] ?? false,
      hasWifi: json['hasWifi'] ?? false,
      hasTV: json['hasTV'] ?? false,
      hasRefrigerator: json['hasRefrigerator'] ?? false,
      hasBathroom: json['hasBathroom'] ?? true,
      hasHotWater: json['hasHotWater'] ?? false,
      totalBookings: json['totalBookings'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'businessName': businessName,
      'roomName': roomName,
      'roomType': roomType.value,
      'description': description,
      'pricePerNight': pricePerNight,
      'discountPrice': discountPrice,
      'maxGuests': maxGuests,
      'numberOfBeds': numberOfBeds,
      'roomSize': roomSize,
      'amenities': amenities,
      'images': images,
      'status': status.value,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'floor': floor,
      'viewType': viewType,
      'hasBalcony': hasBalcony,
      'hasKitchen': hasKitchen,
      'hasAirConditioner': hasAirConditioner,
      'hasWifi': hasWifi,
      'hasTV': hasTV,
      'hasRefrigerator': hasRefrigerator,
      'hasBathroom': hasBathroom,
      'hasHotWater': hasHotWater,
      'totalBookings': totalBookings,
      'rating': rating,
      'totalReviews': totalReviews,
    };
  }
  
  // Calculate discounted price
  double get finalPrice => discountPrice ?? pricePerNight;
  
  // Check if has discount
  bool get hasDiscount => discountPrice != null && discountPrice! < pricePerNight;
  
  // Get discount percentage
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((pricePerNight - discountPrice!) / pricePerNight * 100);
  }
  
  // Get formatted price
  String get formattedPrice => '${pricePerNight.toStringAsFixed(0)} VNĐ';
  String get formattedDiscountPrice => discountPrice != null 
      ? '${discountPrice!.toStringAsFixed(0)} VNĐ' 
      : '';
  
  // Get room type icon
  String get typeIcon => roomType.icon;
  String get typeDisplayName => roomType.displayName;
  
  // Get status color
  String get statusDisplayName => status.displayName;
  
  // Get formatted rating
  String get formattedRating => rating > 0 ? rating.toStringAsFixed(1) : 'Chưa có';
}