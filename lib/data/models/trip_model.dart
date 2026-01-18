import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String destination;
  final String? destinationId;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final double spentAmount;
  final List<TripTraveler> travelers;
  final String status; // planning, ongoing, completed, cancelled
  final String visibility; // private, public, friends
  final String coverImage;
  final String notes;
  final List<String> tags;
  final TripStats stats;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ✅ NEW: Day-specific data (type-safe)
  final Map<String, String> dayNotes; // key: "1", "2", etc. value: note text
  final List<TripPrivateLocation> privateLocations;

  TripModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.destination,
    this.destinationId,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.spentAmount = 0,
    required this.travelers,
    this.status = 'planning',
    this.visibility = 'private',
    required this.coverImage,
    this.notes = '',
    this.tags = const [],
    required this.stats,
    this.createdAt,
    this.updatedAt,
    this.dayNotes = const {},
    this.privateLocations = const [],
  });

  factory TripModel.fromJson(Map<String, dynamic> json, String id) {
    // Parse dayNotes
    Map<String, String> parsedDayNotes = {};
    if (json['dayNotes'] != null) {
      final rawNotes = json['dayNotes'] as Map<String, dynamic>;
      parsedDayNotes = rawNotes.map((k, v) => MapEntry(k, v.toString()));
    }

    // Parse privateLocations
    List<TripPrivateLocation> parsedLocations = [];
    if (json['privateLocations'] != null) {
      parsedLocations = (json['privateLocations'] as List<dynamic>)
          .map((l) => TripPrivateLocation.fromJson(l as Map<String, dynamic>))
          .toList();
    }

    return TripModel(
      id: id,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      destination: json['destination'] ?? '',
      destinationId: json['destinationId'],
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      budget: (json['budget'] ?? 0).toDouble(),
      spentAmount: (json['spentAmount'] ?? 0).toDouble(),
      travelers:
          (json['travelers'] as List<dynamic>? ?? []).map((t) => TripTraveler.fromJson(t)).toList(),
      status: json['status'] ?? 'planning',
      visibility: json['visibility'] ?? 'private',
      coverImage: json['coverImage'] ?? '',
      notes: json['notes'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      stats: json['stats'] != null ? TripStats.fromJson(json['stats']) : TripStats.empty(),
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
      dayNotes: parsedDayNotes,
      privateLocations: parsedLocations,
    );
  }

  /// Create from cache JSON (uses int timestamps instead of Firestore Timestamp)
  factory TripModel.fromCacheJson(Map<String, dynamic> json) {
    // Parse dayNotes
    Map<String, String> parsedDayNotes = {};
    if (json['dayNotes'] != null) {
      final rawNotes = json['dayNotes'] as Map<String, dynamic>;
      parsedDayNotes = rawNotes.map((k, v) => MapEntry(k, v.toString()));
    }

    // Parse privateLocations
    List<TripPrivateLocation> parsedLocations = [];
    if (json['privateLocations'] != null) {
      parsedLocations = (json['privateLocations'] as List<dynamic>)
          .map((l) => TripPrivateLocation.fromJson(l as Map<String, dynamic>))
          .toList();
    }

    return TripModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      destination: json['destination'] ?? '',
      destinationId: json['destinationId'],
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(json['endDate'] as int),
      budget: (json['budget'] ?? 0).toDouble(),
      spentAmount: (json['spentAmount'] ?? 0).toDouble(),
      travelers:
          (json['travelers'] as List<dynamic>? ?? []).map((t) => TripTraveler.fromJson(t as Map<String, dynamic>)).toList(),
      status: json['status'] ?? 'planning',
      visibility: json['visibility'] ?? 'private',
      coverImage: json['coverImage'] ?? '',
      notes: json['notes'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      stats: json['stats'] != null ? TripStats.fromJson(json['stats'] as Map<String, dynamic>) : TripStats.empty(),
      createdAt: json['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int) : null,
      dayNotes: parsedDayNotes,
      privateLocations: parsedLocations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'destination': destination,
      'destinationId': destinationId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'budget': budget,
      'spentAmount': spentAmount,
      'travelers': travelers.map((t) => t.toJson()).toList(),
      'status': status,
      'visibility': visibility,
      'coverImage': coverImage,
      'notes': notes,
      'tags': tags,
      'stats': stats.toJson(),
      'dayNotes': dayNotes,
      'privateLocations': privateLocations.map((l) => l.toJson()).toList(),
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert to cache JSON (uses int timestamps for GetStorage compatibility)
  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'destination': destination,
      'destinationId': destinationId,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'budget': budget,
      'spentAmount': spentAmount,
      'travelers': travelers.map((t) => t.toJson()).toList(),
      'status': status,
      'visibility': visibility,
      'coverImage': coverImage,
      'notes': notes,
      'tags': tags,
      'stats': stats.toJson(),
      'dayNotes': dayNotes,
      'privateLocations': privateLocations.map((l) => l.toJson()).toList(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // Helper methods
  int get duration => endDate.difference(startDate).inDays + 1;

  String get durationText {
    final days = duration;
    if (days == 1) return '1 ngày';
    if (days < 7) return '$days ngày';
    final weeks = (days / 7).floor();
    final remainingDays = days % 7;
    if (remainingDays == 0) return '$weeks tuần';
    return '$weeks tuần $remainingDays ngày';
  }

  double get remainingBudget => budget - spentAmount;

  double get budgetProgress => budget > 0 ? (spentAmount / budget) : 0;

  bool get isOverBudget => spentAmount > budget;

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming => DateTime.now().isBefore(startDate);

  bool get isPast => DateTime.now().isAfter(endDate);

  String get statusDisplay {
    if (status == 'cancelled') return 'Đã hủy';
    if (isOngoing) return 'Đang diễn ra';
    if (isUpcoming) return 'Sắp tới';
    if (isPast) return 'Đã kết thúc';
    return 'Đang lập kế hoạch';
  }

  String get formattedBudget => '${budget.toStringAsFixed(0)}₫';

  String get formattedSpent => '${spentAmount.toStringAsFixed(0)}₫';
}

class TripTraveler {
  final String id;
  final String name;
  final String? email;
  final String? avatar;
  final String role; // owner, editor, viewer

  TripTraveler({
    required this.id,
    required this.name,
    this.email,
    this.avatar,
    this.role = 'viewer',
  });

  factory TripTraveler.fromJson(Map<String, dynamic> json) {
    return TripTraveler(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      avatar: json['avatar'],
      role: json['role'] ?? 'viewer',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'avatar': avatar, 'role': role};
  }
}

class TripStats {
  final int placesCount;
  final int photosCount;
  final int notesCount;
  final int expensesCount;

  TripStats({
    this.placesCount = 0,
    this.photosCount = 0,
    this.notesCount = 0,
    this.expensesCount = 0,
  });

  factory TripStats.fromJson(Map<String, dynamic> json) {
    return TripStats(
      placesCount: json['placesCount'] ?? 0,
      photosCount: json['photosCount'] ?? 0,
      notesCount: json['notesCount'] ?? 0,
      expensesCount: json['expensesCount'] ?? 0,
    );
  }

  factory TripStats.empty() => TripStats();

  Map<String, dynamic> toJson() {
    return {
      'placesCount': placesCount,
      'photosCount': photosCount,
      'notesCount': notesCount,
      'expensesCount': expensesCount,
    };
  }
}

// Itinerary Day Model
class TripItinerary {
  final String id;
  final String tripId;
  final int dayNumber;
  final DateTime date;
  final String title;
  final List<ItineraryActivity> activities;

  TripItinerary({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    required this.date,
    required this.title,
    required this.activities,
  });

  factory TripItinerary.fromJson(Map<String, dynamic> json, String id) {
    return TripItinerary(
      id: id,
      tripId: json['tripId'] ?? '',
      dayNumber: json['dayNumber'] ?? 1,
      date: (json['date'] as Timestamp).toDate(),
      title: json['title'] ?? '',
      activities:
          (json['activities'] as List<dynamic>? ?? [])
              .map((a) => ItineraryActivity.fromJson(a))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'dayNumber': dayNumber,
      'date': Timestamp.fromDate(date),
      'title': title,
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }
}

class ItineraryActivity {
  final String id;
  final String time;
  final String title;
  final String location;
  final String? placeId; // Google Places ID
  final String notes;
  final double? cost;
  final String type; // transport, accommodation, food, activity, other
  final Map<String, dynamic>? metadata;

  ItineraryActivity({
    required this.id,
    required this.time,
    required this.title,
    required this.location,
    this.placeId,
    this.notes = '',
    this.cost,
    this.type = 'activity',
    this.metadata,
  });

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      id: json['id'] ?? '',
      time: json['time'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      placeId: json['placeId'],
      notes: json['notes'] ?? '',
      cost: json['cost']?.toDouble(),
      type: json['type'] ?? 'activity',
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'title': title,
      'location': location,
      'placeId': placeId,
      'notes': notes,
      'cost': cost,
      'type': type,
      'metadata': metadata,
    };
  }

  String get typeIcon {
    switch (type) {
      case 'transport':
        return '🚗';
      case 'accommodation':
        return '🏨';
      case 'food':
        return '🍽️';
      case 'activity':
        return '🎯';
      default:
        return '📌';
    }
  }
}

// Private Location Model (for user-added locations)
class TripPrivateLocation {
  final int dayIndex;
  final String time;
  final String title;
  final String address;
  final String? description;
  final String? image;
  final double? latitude;
  final double? longitude;
  final String type; // 'private' or 'listing'
  final String? listingId; // If added from a business listing
  final String? businessName;
  final double? price;
  final String? addedAt;
  final String? updatedAt;

  TripPrivateLocation({
    required this.dayIndex,
    required this.time,
    required this.title,
    required this.address,
    this.description,
    this.image,
    this.latitude,
    this.longitude,
    this.type = 'private',
    this.listingId,
    this.businessName,
    this.price,
    this.addedAt,
    this.updatedAt,
  });

  factory TripPrivateLocation.fromJson(Map<String, dynamic> json) {
    // Helper to convert Timestamp or String to String
    String? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Timestamp) return value.toDate().toIso8601String();
      if (value is DateTime) return value.toIso8601String();
      return value.toString();
    }

    return TripPrivateLocation(
      dayIndex: json['dayIndex'] ?? 0,
      time: json['time'] ?? '',
      title: json['title'] ?? '',
      address: json['address'] ?? '',
      description: json['description'],
      image: json['image'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      type: json['type'] ?? 'private',
      listingId: json['listingId'],
      businessName: json['businessName'],
      price: json['price']?.toDouble(),
      addedAt: parseDateTime(json['addedAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayIndex': dayIndex,
      'time': time,
      'title': title,
      'address': address,
      'description': description,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'listingId': listingId,
      'businessName': businessName,
      'price': price,
      'addedAt': addedAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create a unique identifier for deduplication
  String get uniqueKey => '${dayIndex}_${title}_${time}';
}

// Expense Model
class TripExpense {
  final String id;
  final String tripId;
  final String title;
  final String category;
  final double amount;
  final String currency;
  final DateTime date;
  final String? notes;
  final String paidBy;
  final List<String> sharedWith;
  final DateTime? createdAt;

  TripExpense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.category,
    required this.amount,
    this.currency = 'VND',
    required this.date,
    this.notes,
    required this.paidBy,
    this.sharedWith = const [],
    this.createdAt,
  });

  factory TripExpense.fromJson(Map<String, dynamic> json, String id) {
    return TripExpense(
      id: id,
      tripId: json['tripId'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'VND',
      date: (json['date'] as Timestamp).toDate(),
      notes: json['notes'],
      paidBy: json['paidBy'] ?? '',
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'title': title,
      'category': category,
      'amount': amount,
      'currency': currency,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'paidBy': paidBy,
      'sharedWith': sharedWith,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  String get categoryIcon {
    switch (category) {
      case 'transport':
        return '🚗';
      case 'accommodation':
        return '🏨';
      case 'food':
        return '🍽️';
      case 'activities':
        return '🎯';
      case 'shopping':
        return '🛍️';
      case 'other':
      default:
        return '💰';
    }
  }
}
