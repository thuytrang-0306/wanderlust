import 'package:cloud_firestore/cloud_firestore.dart';

class AccommodationModel {
  final String id;
  final String name;
  final String type; // hotel, homestay, resort, apartment
  final String description;
  final String address;
  final String city;
  final String province;
  final String country;
  final GeoPoint location;
  final double rating;
  final int totalReviews;
  final double pricePerNight;
  final double originalPrice;
  final String currency;
  final List<String> images;
  final List<String> amenities;
  final List<RoomType> roomTypes;
  final AccommodationPolicy policy;
  final String hostId;
  final String hostName;
  final String hostAvatar;
  final bool isVerified;
  final bool isFeatured;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccommodationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.address,
    required this.city,
    required this.province,
    required this.country,
    required this.location,
    required this.rating,
    required this.totalReviews,
    required this.pricePerNight,
    required this.originalPrice,
    this.currency = 'VND',
    required this.images,
    required this.amenities,
    required this.roomTypes,
    required this.policy,
    required this.hostId,
    required this.hostName,
    required this.hostAvatar,
    this.isVerified = false,
    this.isFeatured = false,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters
  String get fullAddress => '$address, $city, $province';
  String get displayPrice => '${pricePerNight.toStringAsFixed(0)} $currency';
  double get discountPercent => originalPrice > 0 
    ? ((originalPrice - pricePerNight) / originalPrice * 100) 
    : 0;
  bool get hasDiscount => originalPrice > pricePerNight;
  String get typeDisplay {
    switch (type) {
      case 'hotel': return 'Khách sạn';
      case 'homestay': return 'Homestay';
      case 'resort': return 'Resort';
      case 'apartment': return 'Căn hộ';
      default: return type;
    }
  }

  // Helper method to parse GeoPoint from various formats
  static GeoPoint? _parseGeoPoint(dynamic location) {
    if (location == null) return null;
    
    if (location is GeoPoint) {
      return location;
    }
    
    if (location is Map<String, dynamic>) {
      final latitude = location['latitude'] ?? location['_latitude'] ?? 0.0;
      final longitude = location['longitude'] ?? location['_longitude'] ?? 0.0;
      return GeoPoint(latitude.toDouble(), longitude.toDouble());
    }
    
    return null;
  }

  // From Firestore
  factory AccommodationModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return AccommodationModel(
      id: docId,
      name: data['name'] ?? '',
      type: data['type'] ?? 'hotel',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      province: data['province'] ?? '',
      country: data['country'] ?? 'Vietnam',
      location: _parseGeoPoint(data['location']) ?? const GeoPoint(0, 0),
      rating: (data['rating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      pricePerNight: (data['pricePerNight'] ?? 0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'VND',
      images: List<String>.from(data['images'] ?? []),
      amenities: List<String>.from(data['amenities'] ?? []),
      roomTypes: (data['roomTypes'] as List<dynamic>?)
          ?.map((e) => RoomType.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      policy: AccommodationPolicy.fromMap(
        data['policy'] ?? AccommodationPolicy.defaultPolicy().toMap()
      ),
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? '',
      hostAvatar: data['hostAvatar'] ?? '',
      isVerified: data['isVerified'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      metadata: data['metadata'] ?? {},
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'address': address,
      'city': city,
      'province': province,
      'country': country,
      'location': location,
      'rating': rating,
      'totalReviews': totalReviews,
      'pricePerNight': pricePerNight,
      'originalPrice': originalPrice,
      'currency': currency,
      'images': images,
      'amenities': amenities,
      'roomTypes': roomTypes.map((e) => e.toMap()).toList(),
      'policy': policy.toMap(),
      'hostId': hostId,
      'hostName': hostName,
      'hostAvatar': hostAvatar,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with
  AccommodationModel copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    String? address,
    String? city,
    String? province,
    String? country,
    GeoPoint? location,
    double? rating,
    int? totalReviews,
    double? pricePerNight,
    double? originalPrice,
    String? currency,
    List<String>? images,
    List<String>? amenities,
    List<RoomType>? roomTypes,
    AccommodationPolicy? policy,
    String? hostId,
    String? hostName,
    String? hostAvatar,
    bool? isVerified,
    bool? isFeatured,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccommodationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      country: country ?? this.country,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      originalPrice: originalPrice ?? this.originalPrice,
      currency: currency ?? this.currency,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      roomTypes: roomTypes ?? this.roomTypes,
      policy: policy ?? this.policy,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Room Type Model
class RoomType {
  final String id;
  final String name;
  final String description;
  final int maxGuests;
  final int beds;
  final String bedType;
  final double size; // in m2
  final double pricePerNight;
  final int available;
  final List<String> amenities;
  final List<String> images;

  RoomType({
    required this.id,
    required this.name,
    required this.description,
    required this.maxGuests,
    required this.beds,
    required this.bedType,
    required this.size,
    required this.pricePerNight,
    required this.available,
    required this.amenities,
    required this.images,
  });

  factory RoomType.fromMap(Map<String, dynamic> map) {
    return RoomType(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      maxGuests: map['maxGuests'] ?? 2,
      beds: map['beds'] ?? 1,
      bedType: map['bedType'] ?? 'Double',
      size: (map['size'] ?? 0).toDouble(),
      pricePerNight: (map['pricePerNight'] ?? 0).toDouble(),
      available: map['available'] ?? 0,
      amenities: List<String>.from(map['amenities'] ?? []),
      images: List<String>.from(map['images'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'maxGuests': maxGuests,
      'beds': beds,
      'bedType': bedType,
      'size': size,
      'pricePerNight': pricePerNight,
      'available': available,
      'amenities': amenities,
      'images': images,
    };
  }
}

// Accommodation Policy
class AccommodationPolicy {
  final String checkInTime;
  final String checkOutTime;
  final String cancellationPolicy;
  final bool petsAllowed;
  final bool smokingAllowed;
  final bool partiesAllowed;
  final int minStay;
  final int maxStay;
  final List<String> houseRules;

  AccommodationPolicy({
    required this.checkInTime,
    required this.checkOutTime,
    required this.cancellationPolicy,
    required this.petsAllowed,
    required this.smokingAllowed,
    required this.partiesAllowed,
    required this.minStay,
    required this.maxStay,
    required this.houseRules,
  });

  factory AccommodationPolicy.defaultPolicy() {
    return AccommodationPolicy(
      checkInTime: '14:00',
      checkOutTime: '12:00',
      cancellationPolicy: 'Flexible',
      petsAllowed: false,
      smokingAllowed: false,
      partiesAllowed: false,
      minStay: 1,
      maxStay: 30,
      houseRules: [],
    );
  }

  factory AccommodationPolicy.fromMap(Map<String, dynamic> map) {
    return AccommodationPolicy(
      checkInTime: map['checkInTime'] ?? '14:00',
      checkOutTime: map['checkOutTime'] ?? '12:00',
      cancellationPolicy: map['cancellationPolicy'] ?? 'Flexible',
      petsAllowed: map['petsAllowed'] ?? false,
      smokingAllowed: map['smokingAllowed'] ?? false,
      partiesAllowed: map['partiesAllowed'] ?? false,
      minStay: map['minStay'] ?? 1,
      maxStay: map['maxStay'] ?? 30,
      houseRules: List<String>.from(map['houseRules'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'cancellationPolicy': cancellationPolicy,
      'petsAllowed': petsAllowed,
      'smokingAllowed': smokingAllowed,
      'partiesAllowed': partiesAllowed,
      'minStay': minStay,
      'maxStay': maxStay,
      'houseRules': houseRules,
    };
  }
}