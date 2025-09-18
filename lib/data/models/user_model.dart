class UserModel {
  final String id;
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? phoneNumber;
  final String? bio;
  final String? address;
  final String? city;
  final String? country;
  final int totalTrips;
  final int totalBookings;
  final int totalPosts;
  final int totalFollowers;
  final int totalFollowing;
  final String language;
  final String currency;
  final NotificationSettings notificationSettings;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActive;
  final bool isVerified;
  final String role;

  UserModel({
    required this.id,
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.bio,
    this.address,
    this.city,
    this.country,
    this.totalTrips = 0,
    this.totalBookings = 0,
    this.totalPosts = 0,
    this.totalFollowers = 0,
    this.totalFollowing = 0,
    this.language = 'vi',
    this.currency = 'VND',
    required this.notificationSettings,
    this.createdAt,
    this.updatedAt,
    this.lastActive,
    this.isVerified = false,
    this.role = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'],
      phoneNumber: json['phoneNumber'],
      bio: json['bio'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      totalTrips: json['totalTrips'] ?? 0,
      totalBookings: json['totalBookings'] ?? 0,
      totalPosts: json['totalPosts'] ?? 0,
      totalFollowers: json['totalFollowers'] ?? 0,
      totalFollowing: json['totalFollowing'] ?? 0,
      language: json['language'] ?? 'vi',
      currency: json['currency'] ?? 'VND',
      notificationSettings: NotificationSettings.fromJson(json['notificationSettings'] ?? {}),
      createdAt: json['createdAt']?.toDate(),
      updatedAt: json['updatedAt']?.toDate(),
      lastActive: json['lastActive']?.toDate(),
      isVerified: json['isVerified'] ?? false,
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'address': address,
      'city': city,
      'country': country,
      'totalTrips': totalTrips,
      'totalBookings': totalBookings,
      'totalPosts': totalPosts,
      'totalFollowers': totalFollowers,
      'totalFollowing': totalFollowing,
      'language': language,
      'currency': currency,
      'notificationSettings': notificationSettings.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastActive': lastActive,
      'isVerified': isVerified,
      'role': role,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    String? bio,
    String? address,
    String? city,
    String? country,
    String? language,
    String? currency,
    NotificationSettings? notificationSettings,
    bool? isVerified,
  }) {
    return UserModel(
      id: id,
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      totalTrips: totalTrips,
      totalBookings: totalBookings,
      totalPosts: totalPosts,
      totalFollowers: totalFollowers,
      totalFollowing: totalFollowing,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastActive: lastActive,
      isVerified: isVerified ?? this.isVerified,
      role: role,
    );
  }
}

class NotificationSettings {
  final bool push;
  final bool email;
  final bool sms;
  final bool marketing;

  NotificationSettings({
    this.push = true,
    this.email = true,
    this.sms = false,
    this.marketing = false,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      push: json['push'] ?? true,
      email: json['email'] ?? true,
      sms: json['sms'] ?? false,
      marketing: json['marketing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'push': push, 'email': email, 'sms': sms, 'marketing': marketing};
  }
}
