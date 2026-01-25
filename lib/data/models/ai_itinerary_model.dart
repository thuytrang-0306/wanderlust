import 'package:cloud_firestore/cloud_firestore.dart';

/// Activity suggested by AI for itinerary
class AiActivity {
  final String time; // "08:00" or "Sáng" or "8h-10h"
  final String title; // "Ăn sáng"
  final String type; // food, sightseeing, transport, accommodation, entertainment, other
  final String emoji; // "🍜", "🏛️", "🚗"
  final String? location; // "Quán Bánh Mì Phượng"
  final String? description; // Detailed description
  final double? estimatedCost; // Cost in VND
  final String? notes; // Additional notes

  AiActivity({
    required this.time,
    required this.title,
    required this.type,
    this.emoji = '📍',
    this.location,
    this.description,
    this.estimatedCost,
    this.notes,
  });

  // Copy with
  AiActivity copyWith({
    String? time,
    String? title,
    String? type,
    String? emoji,
    String? location,
    String? description,
    double? estimatedCost,
    String? notes,
  }) {
    return AiActivity(
      time: time ?? this.time,
      title: title ?? this.title,
      type: type ?? this.type,
      emoji: emoji ?? this.emoji,
      location: location ?? this.location,
      description: description ?? this.description,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      notes: notes ?? this.notes,
    );
  }

  // To JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'title': title,
      'type': type,
      'emoji': emoji,
      'location': location,
      'description': description,
      'estimatedCost': estimatedCost,
      'notes': notes,
    };
  }

  // From JSON
  factory AiActivity.fromJson(Map<String, dynamic> json) {
    return AiActivity(
      time: json['time'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      emoji: json['emoji'] as String? ?? '📍',
      location: json['location'] as String?,
      description: json['description'] as String?,
      estimatedCost: json['estimatedCost'] != null
          ? (json['estimatedCost'] as num).toDouble()
          : null,
      notes: json['notes'] as String?,
    );
  }

  // Get icon based on type
  String getTypeIcon() {
    if (emoji.isNotEmpty && emoji != '📍') return emoji;

    switch (type.toLowerCase()) {
      case 'food':
      case 'ăn uống':
        return '🍜';
      case 'sightseeing':
      case 'tham quan':
        return '🏛️';
      case 'transport':
      case 'di chuyển':
        return '🚗';
      case 'accommodation':
      case 'chỗ ở':
        return '🏨';
      case 'entertainment':
      case 'giải trí':
        return '🎭';
      case 'shopping':
      case 'mua sắm':
        return '🛍️';
      case 'beach':
      case 'biển':
        return '🏖️';
      case 'nature':
      case 'thiên nhiên':
        return '🌳';
      default:
        return '📍';
    }
  }

  // Format cost to readable string
  String getFormattedCost() {
    if (estimatedCost == null || estimatedCost == 0) return 'Miễn phí';

    if (estimatedCost! >= 1000000) {
      return '${(estimatedCost! / 1000000).toStringAsFixed(1)}M VND';
    } else if (estimatedCost! >= 1000) {
      return '${(estimatedCost! / 1000).toStringAsFixed(0)}K VND';
    }
    return '${estimatedCost!.toStringAsFixed(0)} VND';
  }
}

/// AI-generated itinerary for a specific day
class AiItineraryModel {
  final String id;
  final String tripId;
  final int dayNumber; // 1-based (Day 1, Day 2, etc.)
  final DateTime date;
  final List<AiActivity> activities;
  final String summary; // Brief summary of the day
  final double totalEstimatedCost; // Sum of all activity costs
  final String rawMarkdown; // Original AI response for reference
  final bool aiGenerated;
  final DateTime createdAt;
  final DateTime updatedAt;

  AiItineraryModel({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    required this.date,
    required this.activities,
    required this.summary,
    required this.totalEstimatedCost,
    required this.rawMarkdown,
    this.aiGenerated = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create new instance
  factory AiItineraryModel.create({
    required String tripId,
    required int dayNumber,
    required DateTime date,
    required List<AiActivity> activities,
    required String summary,
    required String rawMarkdown,
  }) {
    final now = DateTime.now();
    final totalCost = activities.fold<double>(
      0.0,
      (total, activity) => total + (activity.estimatedCost ?? 0),
    );

    return AiItineraryModel(
      id: 'ai_itinerary_${DateTime.now().millisecondsSinceEpoch}',
      tripId: tripId,
      dayNumber: dayNumber,
      date: date,
      activities: activities,
      summary: summary,
      totalEstimatedCost: totalCost,
      rawMarkdown: rawMarkdown,
      aiGenerated: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Copy with
  AiItineraryModel copyWith({
    String? id,
    String? tripId,
    int? dayNumber,
    DateTime? date,
    List<AiActivity>? activities,
    String? summary,
    double? totalEstimatedCost,
    String? rawMarkdown,
    bool? aiGenerated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiItineraryModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      activities: activities ?? this.activities,
      summary: summary ?? this.summary,
      totalEstimatedCost: totalEstimatedCost ?? this.totalEstimatedCost,
      rawMarkdown: rawMarkdown ?? this.rawMarkdown,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // To JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'dayNumber': dayNumber,
      'date': Timestamp.fromDate(date),
      'activities': activities.map((a) => a.toJson()).toList(),
      'summary': summary,
      'totalEstimatedCost': totalEstimatedCost,
      'rawMarkdown': rawMarkdown,
      'aiGenerated': aiGenerated,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // From JSON
  factory AiItineraryModel.fromJson(Map<String, dynamic> json) {
    return AiItineraryModel(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      dayNumber: json['dayNumber'] as int,
      date: (json['date'] as Timestamp).toDate(),
      activities: (json['activities'] as List)
          .map((a) => AiActivity.fromJson(a as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] as String,
      totalEstimatedCost: (json['totalEstimatedCost'] as num).toDouble(),
      rawMarkdown: json['rawMarkdown'] as String,
      aiGenerated: json['aiGenerated'] as bool? ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  // To cache (convert Timestamp to milliseconds)
  Map<String, dynamic> toCache() {
    return {
      'id': id,
      'tripId': tripId,
      'dayNumber': dayNumber,
      'date': date.millisecondsSinceEpoch,
      'activities': activities.map((a) => a.toJson()).toList(),
      'summary': summary,
      'totalEstimatedCost': totalEstimatedCost,
      'rawMarkdown': rawMarkdown,
      'aiGenerated': aiGenerated,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // From cache
  factory AiItineraryModel.fromCache(Map<String, dynamic> json) {
    return AiItineraryModel(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      dayNumber: json['dayNumber'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      activities: (json['activities'] as List)
          .map((a) => AiActivity.fromJson(a as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] as String,
      totalEstimatedCost: (json['totalEstimatedCost'] as num).toDouble(),
      rawMarkdown: json['rawMarkdown'] as String,
      aiGenerated: json['aiGenerated'] as bool? ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }

  // Get activity count
  int get activityCount => activities.length;

  // Get formatted total cost
  String get formattedTotalCost {
    if (totalEstimatedCost >= 1000000) {
      return '${(totalEstimatedCost / 1000000).toStringAsFixed(1)}M VND';
    } else if (totalEstimatedCost >= 1000) {
      return '${(totalEstimatedCost / 1000).toStringAsFixed(0)}K VND';
    }
    return '${totalEstimatedCost.toStringAsFixed(0)} VND';
  }

  // Get time range (first to last activity)
  String get timeRange {
    if (activities.isEmpty) return '';
    if (activities.length == 1) return activities.first.time;
    return '${activities.first.time} - ${activities.last.time}';
  }

  // Get preview activities (first 3)
  List<AiActivity> get previewActivities =>
      activities.take(3).toList();

  // Get preview text for card
  String get previewText {
    if (activities.isEmpty) return 'Không có hoạt động';

    final preview = previewActivities
        .map((a) => '${a.emoji} ${a.title}')
        .join(', ');

    if (activities.length > 3) {
      return '$preview...';
    }
    return preview;
  }
}
