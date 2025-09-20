import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String status; // active, banned, pending, deleted
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final DateTime? bannedAt;
  final DateTime? deletedAt;
  final int tripCount;
  final int reviewCount;
  final int followersCount;
  final int followingCount;
  final bool isVerified;
  final bool isBusinessAccount;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? socialLinks;
  final String? location;
  final String? language;
  final String? timezone;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.bannedAt,
    this.deletedAt,
    this.tripCount = 0,
    this.reviewCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isVerified = false,
    this.isBusinessAccount = false,
    this.preferences,
    this.socialLinks,
    this.location,
    this.language = 'en',
    this.timezone,
  });

  // Factory constructor from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      status: data['status'] ?? 'active',
      avatarUrl: data['avatarUrl'],
      bio: data['bio'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      bannedAt: data['bannedAt'] != null 
          ? (data['bannedAt'] as Timestamp).toDate()
          : null,
      deletedAt: data['deletedAt'] != null 
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
      tripCount: data['tripCount'] ?? 0,
      reviewCount: data['reviewCount'] ?? 0,
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      isVerified: data['isVerified'] ?? false,
      isBusinessAccount: data['isBusinessAccount'] ?? false,
      preferences: data['preferences'],
      socialLinks: data['socialLinks'],
      location: data['location'],
      language: data['language'] ?? 'en',
      timezone: data['timezone'],
    );
  }

  // Factory constructor from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 'active',
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      bannedAt: json['bannedAt'] != null 
          ? DateTime.parse(json['bannedAt'])
          : null,
      deletedAt: json['deletedAt'] != null 
          ? DateTime.parse(json['deletedAt'])
          : null,
      tripCount: json['tripCount'] ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isBusinessAccount: json['isBusinessAccount'] ?? false,
      preferences: json['preferences'],
      socialLinks: json['socialLinks'],
      location: json['location'],
      language: json['language'] ?? 'en',
      timezone: json['timezone'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'bannedAt': bannedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'tripCount': tripCount,
      'reviewCount': reviewCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isVerified': isVerified,
      'isBusinessAccount': isBusinessAccount,
      'preferences': preferences,
      'socialLinks': socialLinks,
      'location': location,
      'language': language,
      'timezone': timezone,
    };
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'bannedAt': bannedAt != null ? Timestamp.fromDate(bannedAt!) : null,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'tripCount': tripCount,
      'reviewCount': reviewCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isVerified': isVerified,
      'isBusinessAccount': isBusinessAccount,
      'preferences': preferences,
      'socialLinks': socialLinks,
      'location': location,
      'language': language,
      'timezone': timezone,
    };
  }

  // CopyWith method for immutable updates
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? status,
    String? avatarUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    DateTime? bannedAt,
    DateTime? deletedAt,
    int? tripCount,
    int? reviewCount,
    int? followersCount,
    int? followingCount,
    bool? isVerified,
    bool? isBusinessAccount,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? socialLinks,
    String? location,
    String? language,
    String? timezone,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      bannedAt: bannedAt ?? this.bannedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      tripCount: tripCount ?? this.tripCount,
      reviewCount: reviewCount ?? this.reviewCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isVerified: isVerified ?? this.isVerified,
      isBusinessAccount: isBusinessAccount ?? this.isBusinessAccount,
      preferences: preferences ?? this.preferences,
      socialLinks: socialLinks ?? this.socialLinks,
      location: location ?? this.location,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
    );
  }

  // Getters for convenience
  String get displayName => name.isNotEmpty ? name : email.split('@').first;
  
  String get statusColor {
    switch (status) {
      case 'active':
        return '#4CAF50'; // Green
      case 'banned':
        return '#F44336'; // Red
      case 'pending':
        return '#FF9800'; // Orange
      case 'deleted':
        return '#9E9E9E'; // Grey
      default:
        return '#2196F3'; // Blue
    }
  }

  String get statusText {
    switch (status) {
      case 'active':
        return 'Active';
      case 'banned':
        return 'Banned';
      case 'pending':
        return 'Pending';
      case 'deleted':
        return 'Deleted';
      default:
        return 'Unknown';
    }
  }

  bool get isActive => status == 'active';
  bool get isBanned => status == 'banned';
  bool get isPending => status == 'pending';
  bool get isDeleted => status == 'deleted';

  String get memberSince {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }

  String get lastSeenText {
    if (lastLoginAt == null) return 'Never logged in';
    
    final now = DateTime.now();
    final difference = now.difference(lastLoginAt!);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return lastLoginAt!.toLocal().toString().split(' ')[0]; // Date only
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}