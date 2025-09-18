import 'package:cloud_firestore/cloud_firestore.dart';

// Main Tour Model
class TourModel {
  final String id;
  final String name;
  final String description;
  final String category; // adventure, cultural, beach, mountain, city
  final String difficulty; // easy, moderate, hard
  final double price;
  final double originalPrice;
  final String currency;
  final int duration; // in days
  final int nights;
  final String startLocation;
  final String endLocation;
  final List<String> destinations;
  final List<String> images;
  final String coverImage;
  final double rating;
  final int totalReviews;
  final int maxGroupSize;
  final int minGroupSize;
  final int availableSlots;
  final List<String> includedServices;
  final List<String> excludedServices;
  final List<String> highlights;
  final List<TourItinerary> itinerary;
  final TourGuide? guide;
  final List<DateTime> departureDates;
  final CancellationPolicy cancellationPolicy;
  final List<String> languages;
  final Map<String, dynamic> metadata;
  final bool isFeatured;
  final bool isPopular;
  final bool isRecommended;
  final String status; // active, inactive, soldout
  final String providerId;
  final String providerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  TourModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.price,
    required this.originalPrice,
    required this.currency,
    required this.duration,
    required this.nights,
    required this.startLocation,
    required this.endLocation,
    required this.destinations,
    required this.images,
    required this.coverImage,
    required this.rating,
    required this.totalReviews,
    required this.maxGroupSize,
    required this.minGroupSize,
    required this.availableSlots,
    required this.includedServices,
    required this.excludedServices,
    required this.highlights,
    required this.itinerary,
    this.guide,
    required this.departureDates,
    required this.cancellationPolicy,
    required this.languages,
    required this.metadata,
    required this.isFeatured,
    required this.isPopular,
    required this.isRecommended,
    required this.status,
    required this.providerId,
    required this.providerName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Display helpers
  String get displayPrice {
    final formatter = price.toStringAsFixed(0);
    return '$formatter $currency';
  }
  
  String get displayDuration {
    if (nights > 0) {
      return '${duration}N/${nights + 1}D';
    }
    return '$duration ngày';
  }
  
  double get discountPercentage {
    if (originalPrice > price) {
      return ((originalPrice - price) / originalPrice * 100);
    }
    return 0;
  }
  
  bool get hasDiscount => originalPrice > price;
  
  String get difficultyText {
    switch (difficulty) {
      case 'easy': return 'Dễ';
      case 'moderate': return 'Trung bình';
      case 'hard': return 'Khó';
      default: return difficulty;
    }
  }

  // From Firestore
  factory TourModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return TourModel(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'adventure',
      difficulty: data['difficulty'] ?? 'easy',
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'VND',
      duration: data['duration'] ?? 1,
      nights: data['nights'] ?? 0,
      startLocation: data['startLocation'] ?? '',
      endLocation: data['endLocation'] ?? '',
      destinations: List<String>.from(data['destinations'] ?? []),
      images: List<String>.from(data['images'] ?? []),
      coverImage: data['coverImage'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      maxGroupSize: data['maxGroupSize'] ?? 20,
      minGroupSize: data['minGroupSize'] ?? 1,
      availableSlots: data['availableSlots'] ?? 0,
      includedServices: List<String>.from(data['includedServices'] ?? []),
      excludedServices: List<String>.from(data['excludedServices'] ?? []),
      highlights: List<String>.from(data['highlights'] ?? []),
      itinerary: (data['itinerary'] as List<dynamic>?)
          ?.map((e) => TourItinerary.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      guide: data['guide'] != null 
          ? TourGuide.fromMap(data['guide'] as Map<String, dynamic>)
          : null,
      departureDates: (data['departureDates'] as List<dynamic>?)
          ?.map((e) => (e as Timestamp).toDate())
          .toList() ?? [],
      cancellationPolicy: CancellationPolicy.fromMap(
        data['cancellationPolicy'] ?? CancellationPolicy.defaultPolicy().toMap()
      ),
      languages: List<String>.from(data['languages'] ?? ['Tiếng Việt']),
      metadata: data['metadata'] ?? {},
      isFeatured: data['isFeatured'] ?? false,
      isPopular: data['isPopular'] ?? false,
      isRecommended: data['isRecommended'] ?? false,
      status: data['status'] ?? 'active',
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'price': price,
      'originalPrice': originalPrice,
      'currency': currency,
      'duration': duration,
      'nights': nights,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'destinations': destinations,
      'images': images,
      'coverImage': coverImage,
      'rating': rating,
      'totalReviews': totalReviews,
      'maxGroupSize': maxGroupSize,
      'minGroupSize': minGroupSize,
      'availableSlots': availableSlots,
      'includedServices': includedServices,
      'excludedServices': excludedServices,
      'highlights': highlights,
      'itinerary': itinerary.map((e) => e.toMap()).toList(),
      'guide': guide?.toMap(),
      'departureDates': departureDates.map((e) => Timestamp.fromDate(e)).toList(),
      'cancellationPolicy': cancellationPolicy.toMap(),
      'languages': languages,
      'metadata': metadata,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'isRecommended': isRecommended,
      'status': status,
      'providerId': providerId,
      'providerName': providerName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

// Tour Itinerary for each day
class TourItinerary {
  final int day;
  final String title;
  final String description;
  final List<String> activities;
  final String accommodation;
  final String meals; // B, L, D
  final String transportation;
  final List<String> locations;

  TourItinerary({
    required this.day,
    required this.title,
    required this.description,
    required this.activities,
    required this.accommodation,
    required this.meals,
    required this.transportation,
    required this.locations,
  });

  factory TourItinerary.fromMap(Map<String, dynamic> map) {
    return TourItinerary(
      day: map['day'] ?? 1,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      activities: List<String>.from(map['activities'] ?? []),
      accommodation: map['accommodation'] ?? '',
      meals: map['meals'] ?? '',
      transportation: map['transportation'] ?? '',
      locations: List<String>.from(map['locations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'title': title,
      'description': description,
      'activities': activities,
      'accommodation': accommodation,
      'meals': meals,
      'transportation': transportation,
      'locations': locations,
    };
  }
}

// Tour Guide Information
class TourGuide {
  final String id;
  final String name;
  final String avatar;
  final String bio;
  final List<String> languages;
  final double rating;
  final int totalTours;
  final int yearsExperience;

  TourGuide({
    required this.id,
    required this.name,
    required this.avatar,
    required this.bio,
    required this.languages,
    required this.rating,
    required this.totalTours,
    required this.yearsExperience,
  });

  factory TourGuide.fromMap(Map<String, dynamic> map) {
    return TourGuide(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      bio: map['bio'] ?? '',
      languages: List<String>.from(map['languages'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      totalTours: map['totalTours'] ?? 0,
      yearsExperience: map['yearsExperience'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'bio': bio,
      'languages': languages,
      'rating': rating,
      'totalTours': totalTours,
      'yearsExperience': yearsExperience,
    };
  }
}

// Cancellation Policy
class CancellationPolicy {
  final bool isRefundable;
  final int freeCancellationDays;
  final List<RefundRule> refundRules;
  final String description;

  CancellationPolicy({
    required this.isRefundable,
    required this.freeCancellationDays,
    required this.refundRules,
    required this.description,
  });

  factory CancellationPolicy.fromMap(Map<String, dynamic> map) {
    return CancellationPolicy(
      isRefundable: map['isRefundable'] ?? true,
      freeCancellationDays: map['freeCancellationDays'] ?? 7,
      refundRules: (map['refundRules'] as List<dynamic>?)
          ?.map((e) => RefundRule.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isRefundable': isRefundable,
      'freeCancellationDays': freeCancellationDays,
      'refundRules': refundRules.map((e) => e.toMap()).toList(),
      'description': description,
    };
  }

  static CancellationPolicy defaultPolicy() {
    return CancellationPolicy(
      isRefundable: true,
      freeCancellationDays: 7,
      refundRules: [
        RefundRule(daysBeforeDeparture: 30, refundPercentage: 100),
        RefundRule(daysBeforeDeparture: 15, refundPercentage: 50),
        RefundRule(daysBeforeDeparture: 7, refundPercentage: 25),
        RefundRule(daysBeforeDeparture: 0, refundPercentage: 0),
      ],
      description: 'Hủy miễn phí trước 7 ngày khởi hành',
    );
  }
}

// Refund Rule
class RefundRule {
  final int daysBeforeDeparture;
  final double refundPercentage;

  RefundRule({
    required this.daysBeforeDeparture,
    required this.refundPercentage,
  });

  factory RefundRule.fromMap(Map<String, dynamic> map) {
    return RefundRule(
      daysBeforeDeparture: map['daysBeforeDeparture'] ?? 0,
      refundPercentage: (map['refundPercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'daysBeforeDeparture': daysBeforeDeparture,
      'refundPercentage': refundPercentage,
    };
  }
}