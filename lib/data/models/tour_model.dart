import 'package:cloud_firestore/cloud_firestore.dart';

class TourModel {
  final String id;
  final String title;
  final String description;
  final String destinationId;
  final String destinationName;
  final String duration; // e.g., "3D2N"
  final double price;
  final double? discountPrice;
  final List<String> images;
  final List<TourItinerary> itinerary;
  final List<String> inclusions;
  final List<String> exclusions;
  final int maxGroupSize;
  final List<DateTime> availableDates;
  final double rating;
  final int reviewCount;
  final String hostId;
  final String hostName;
  final List<String> tags;
  final bool featured;
  final String status; // active/inactive
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TourModel({
    required this.id,
    required this.title,
    required this.description,
    required this.destinationId,
    required this.destinationName,
    required this.duration,
    required this.price,
    this.discountPrice,
    required this.images,
    required this.itinerary,
    required this.inclusions,
    required this.exclusions,
    required this.maxGroupSize,
    required this.availableDates,
    required this.rating,
    required this.reviewCount,
    required this.hostId,
    required this.hostName,
    required this.tags,
    this.featured = false,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory TourModel.fromJson(Map<String, dynamic> json, String id) {
    return TourModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      destinationId: json['destinationId'] ?? '',
      destinationName: json['destinationName'] ?? '',
      duration: json['duration'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      images: List<String>.from(json['images'] ?? []),
      itinerary: (json['itinerary'] as List<dynamic>? ?? [])
          .map((item) => TourItinerary.fromJson(item))
          .toList(),
      inclusions: List<String>.from(json['inclusions'] ?? []),
      exclusions: List<String>.from(json['exclusions'] ?? []),
      maxGroupSize: json['maxGroupSize'] ?? 0,
      availableDates: (json['availableDates'] as List<dynamic>? ?? [])
          .map((date) => (date as Timestamp).toDate())
          .toList(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      hostId: json['hostId'] ?? '',
      hostName: json['hostName'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      featured: json['featured'] ?? false,
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'destinationId': destinationId,
      'destinationName': destinationName,
      'duration': duration,
      'price': price,
      'discountPrice': discountPrice,
      'images': images,
      'itinerary': itinerary.map((item) => item.toJson()).toList(),
      'inclusions': inclusions,
      'exclusions': exclusions,
      'maxGroupSize': maxGroupSize,
      'availableDates': availableDates
          .map((date) => Timestamp.fromDate(date))
          .toList(),
      'rating': rating,
      'reviewCount': reviewCount,
      'hostId': hostId,
      'hostName': hostName,
      'tags': tags,
      'featured': featured,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper methods
  String get formattedPrice => '${price.toStringAsFixed(0)}₫';
  
  String get formattedDiscountPrice => 
      discountPrice != null ? '${discountPrice!.toStringAsFixed(0)}₫' : '';

  double get discountPercentage {
    if (discountPrice == null) return 0;
    return ((price - discountPrice!) / price * 100);
  }

  String get discountPercentageText => 
      discountPercentage > 0 ? '-${discountPercentage.toStringAsFixed(0)}%' : '';

  String get primaryImage => images.isNotEmpty ? images.first : '';

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  bool get isActive => status == 'active';

  String get ratingDisplay => rating.toStringAsFixed(1);
}

class TourItinerary {
  final String day;
  final String title;
  final String description;
  final List<String> activities;

  TourItinerary({
    required this.day,
    required this.title,
    required this.description,
    required this.activities,
  });

  factory TourItinerary.fromJson(Map<String, dynamic> json) {
    return TourItinerary(
      day: json['day'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      activities: List<String>.from(json['activities'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'title': title,
      'description': description,
      'activities': activities,
    };
  }
}