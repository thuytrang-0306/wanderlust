import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationModel {
  final String id;
  final String name;
  final String description;
  final GeoPoint? location;
  final String region;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final double basePrice;
  final String currency;
  final List<String> highlights;
  final List<String> bestTimeToVisit;
  final List<String> activities;
  final List<String> tags;
  final bool featured;
  final bool popular;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DestinationModel({
    required this.id,
    required this.name,
    required this.description,
    this.location,
    required this.region,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.basePrice,
    this.currency = 'VND',
    required this.highlights,
    required this.bestTimeToVisit,
    required this.activities,
    required this.tags,
    this.featured = false,
    this.popular = false,
    this.createdAt,
    this.updatedAt,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json, String id) {
    return DestinationModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] as GeoPoint?,
      region: json['region'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'VND',
      highlights: List<String>.from(json['highlights'] ?? []),
      bestTimeToVisit: List<String>.from(json['bestTimeToVisit'] ?? []),
      activities: List<String>.from(json['activities'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      featured: json['featured'] ?? false,
      popular: json['popular'] ?? false,
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
      'name': name,
      'description': description,
      'location': location,
      'region': region,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'basePrice': basePrice,
      'currency': currency,
      'highlights': highlights,
      'bestTimeToVisit': bestTimeToVisit,
      'activities': activities,
      'tags': tags,
      'featured': featured,
      'popular': popular,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper methods
  String get formattedPrice {
    if (currency == 'VND') {
      return '${basePrice.toStringAsFixed(0)}₫';
    }
    return '$currency ${basePrice.toStringAsFixed(2)}';
  }

  String get primaryImage => images.isNotEmpty ? images.first : '';

  bool get hasImages => images.isNotEmpty;

  String get ratingDisplay => rating.toStringAsFixed(1);

  DestinationModel copyWith({
    String? id,
    String? name,
    String? description,
    GeoPoint? location,
    String? region,
    List<String>? images,
    double? rating,
    int? reviewCount,
    double? basePrice,
    String? currency,
    List<String>? highlights,
    List<String>? bestTimeToVisit,
    List<String>? activities,
    List<String>? tags,
    bool? featured,
    bool? popular,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      region: region ?? this.region,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      basePrice: basePrice ?? this.basePrice,
      currency: currency ?? this.currency,
      highlights: highlights ?? this.highlights,
      bestTimeToVisit: bestTimeToVisit ?? this.bestTimeToVisit,
      activities: activities ?? this.activities,
      tags: tags ?? this.tags,
      featured: featured ?? this.featured,
      popular: popular ?? this.popular,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}