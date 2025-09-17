import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String coverImage;
  final DateTime startDate;
  final DateTime endDate;
  final TripStatus status;
  final List<TripParticipant> participants;
  final TripBudget budget;
  final bool isPublic;
  final List<String> sharedWith;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.participants,
    required this.budget,
    this.isPublic = false,
    this.sharedWith = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      coverImage: data['coverImage'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: TripStatus.fromString(data['status'] ?? 'planning'),
      participants: (data['participants'] as List<dynamic>?)
          ?.map((e) => TripParticipant.fromMap(e))
          .toList() ?? [],
      budget: TripBudget.fromMap(data['budget'] ?? {}),
      isPublic: data['isPublic'] ?? false,
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status.value,
      'participants': participants.map((e) => e.toMap()).toList(),
      'budget': budget.toMap(),
      'isPublic': isPublic,
      'sharedWith': sharedWith,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TripModel copyWith({
    String? name,
    String? description,
    String? coverImage,
    DateTime? startDate,
    DateTime? endDate,
    TripStatus? status,
    List<TripParticipant>? participants,
    TripBudget? budget,
    bool? isPublic,
    List<String>? sharedWith,
  }) {
    return TripModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      participants: participants ?? this.participants,
      budget: budget ?? this.budget,
      isPublic: isPublic ?? this.isPublic,
      sharedWith: sharedWith ?? this.sharedWith,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Calculate trip duration in days
  int get duration => endDate.difference(startDate).inDays + 1;

  // Format date range
  String get dateRange {
    final startMonth = _getMonthName(startDate.month);
    final endMonth = _getMonthName(endDate.month);
    
    if (startDate.month == endDate.month) {
      return '${startDate.day} - ${endDate.day} $startMonth';
    }
    return '${startDate.day} $startMonth - ${endDate.day} $endMonth';
  }

  String _getMonthName(int month) {
    const months = [
      'Thg 1', 'Thg 2', 'Thg 3', 'Thg 4', 'Thg 5', 'Thg 6',
      'Thg 7', 'Thg 8', 'Thg 9', 'Thg 10', 'Thg 11', 'Thg 12'
    ];
    return months[month - 1];
  }
}

enum TripStatus {
  planning('planning', 'Đang lên kế hoạch'),
  ongoing('ongoing', 'Đang diễn ra'),
  completed('completed', 'Hoàn thành'),
  cancelled('cancelled', 'Đã hủy');

  final String value;
  final String displayName;
  
  const TripStatus(this.value, this.displayName);

  static TripStatus fromString(String value) {
    return TripStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TripStatus.planning,
    );
  }
}

class TripParticipant {
  final String userId;
  final String role; // owner, editor, viewer
  final DateTime joinedAt;

  TripParticipant({
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory TripParticipant.fromMap(Map<String, dynamic> map) {
    return TripParticipant(
      userId: map['userId'] ?? '',
      role: map['role'] ?? 'viewer',
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }
}

class TripBudget {
  final double total;
  final double spent;
  final String currency;

  TripBudget({
    required this.total,
    required this.spent,
    required this.currency,
  });

  factory TripBudget.fromMap(Map<String, dynamic> map) {
    return TripBudget(
      total: (map['total'] ?? 0).toDouble(),
      spent: (map['spent'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'VND',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'spent': spent,
      'currency': currency,
    };
  }

  double get remaining => total - spent;
  double get spentPercentage => total > 0 ? (spent / total * 100) : 0;
}