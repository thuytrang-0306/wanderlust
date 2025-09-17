import 'package:cloud_firestore/cloud_firestore.dart';

class AccommodationModel {
  final String id;
  final String providerId;
  final String name;
  final String description;
  final AccommodationType type;
  final LocationData location;
  final List<String> images;
  final String thumbnail;
  final PricingData pricing;
  final List<String> amenities;
  final List<RoomType> roomTypes;
  final double rating;
  final int totalReviews;
  final PolicyData policies;
  final List<String> tags;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccommodationModel({
    required this.id,
    required this.providerId,
    required this.name,
    required this.description,
    required this.type,
    required this.location,
    required this.images,
    required this.thumbnail,
    required this.pricing,
    required this.amenities,
    required this.roomTypes,
    required this.rating,
    required this.totalReviews,
    required this.policies,
    required this.tags,
    this.isActive = true,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccommodationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccommodationModel(
      id: doc.id,
      providerId: data['providerId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: AccommodationType.fromString(data['type'] ?? 'hotel'),
      location: LocationData.fromMap(data['location'] ?? {}),
      images: List<String>.from(data['images'] ?? []),
      thumbnail: data['thumbnail'] ?? '',
      pricing: PricingData.fromMap(data['pricing'] ?? {}),
      amenities: List<String>.from(data['amenities'] ?? []),
      roomTypes: (data['roomTypes'] as List<dynamic>?)
          ?.map((e) => RoomType.fromMap(e))
          .toList() ?? [],
      rating: (data['rating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      policies: PolicyData.fromMap(data['policies'] ?? {}),
      tags: List<String>.from(data['tags'] ?? []),
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'providerId': providerId,
      'name': name,
      'description': description,
      'type': type.value,
      'location': location.toMap(),
      'images': images,
      'thumbnail': thumbnail,
      'pricing': pricing.toMap(),
      'amenities': amenities,
      'roomTypes': roomTypes.map((e) => e.toMap()).toList(),
      'rating': rating,
      'totalReviews': totalReviews,
      'policies': policies.toMap(),
      'tags': tags,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Format price for display
  String get formattedPrice {
    final price = pricing.basePrice.toStringAsFixed(0);
    final formattedPrice = price.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formattedPriceđ';
  }

  // Get discount percentage text
  String get discountText {
    if (pricing.discountPercentage > 0) {
      return '-${pricing.discountPercentage}%';
    }
    return '';
  }
}

enum AccommodationType {
  hotel('hotel', 'Khách sạn'),
  resort('resort', 'Resort'),
  homestay('homestay', 'Homestay'),
  apartment('apartment', 'Căn hộ');

  final String value;
  final String displayName;
  
  const AccommodationType(this.value, this.displayName);

  static AccommodationType fromString(String value) {
    return AccommodationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AccommodationType.hotel,
    );
  }
}

class LocationData {
  final GeoPoint geoPoint;
  final String address;
  final String city;
  final String country;

  LocationData({
    required this.geoPoint,
    required this.address,
    required this.city,
    required this.country,
  });

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      geoPoint: map['geoPoint'] ?? const GeoPoint(0, 0),
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? 'Vietnam',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'geoPoint': geoPoint,
      'address': address,
      'city': city,
      'country': country,
    };
  }

  String get fullLocation => '$city, $country';
}

class PricingData {
  final double basePrice;
  final String currency;
  final double discountPercentage;
  final double taxes;

  PricingData({
    required this.basePrice,
    this.currency = 'VND',
    this.discountPercentage = 0,
    this.taxes = 0,
  });

  factory PricingData.fromMap(Map<String, dynamic> map) {
    return PricingData(
      basePrice: (map['basePrice'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'VND',
      discountPercentage: (map['discountPercentage'] ?? 0).toDouble(),
      taxes: (map['taxes'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'basePrice': basePrice,
      'currency': currency,
      'discountPercentage': discountPercentage,
      'taxes': taxes,
    };
  }

  double get discountedPrice => basePrice * (1 - discountPercentage / 100);
  double get finalPrice => discountedPrice + taxes;
}

class RoomType {
  final String id;
  final String name;
  final int capacity;
  final double price;
  final int availability;

  RoomType({
    required this.id,
    required this.name,
    required this.capacity,
    required this.price,
    required this.availability,
  });

  factory RoomType.fromMap(Map<String, dynamic> map) {
    return RoomType(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      capacity: map['capacity'] ?? 2,
      price: (map['price'] ?? 0).toDouble(),
      availability: map['availability'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'price': price,
      'availability': availability,
    };
  }
}

class PolicyData {
  final String checkIn;
  final String checkOut;
  final String cancellation;
  final List<String> paymentMethods;

  PolicyData({
    required this.checkIn,
    required this.checkOut,
    required this.cancellation,
    required this.paymentMethods,
  });

  factory PolicyData.fromMap(Map<String, dynamic> map) {
    return PolicyData(
      checkIn: map['checkIn'] ?? '14:00',
      checkOut: map['checkOut'] ?? '12:00',
      cancellation: map['cancellation'] ?? 'Hủy miễn phí trước 24h',
      paymentMethods: List<String>.from(map['paymentMethods'] ?? ['cash', 'card']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'checkIn': checkIn,
      'checkOut': checkOut,
      'cancellation': cancellation,
      'paymentMethods': paymentMethods,
    };
  }
}