import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String id;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final String? avatar; // Base64 encoded avatar
  final String? avatarThumbnail; // Base64 encoded thumbnail
  final String? coverPhoto; // Base64 encoded cover photo
  final String bio;
  final String location;
  final List<String> interests;
  final List<String> languages;
  final DateTime joinDate;
  final DateTime? lastActive;
  final bool isVerified;
  final bool isPremium;
  final UserStats stats;
  final UserSettings? settings;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.photoUrl,
    this.avatar,
    this.avatarThumbnail,
    this.coverPhoto,
    required this.bio,
    required this.location,
    required this.interests,
    required this.languages,
    required this.joinDate,
    this.lastActive,
    required this.isVerified,
    this.isPremium = false,
    required this.stats,
    this.settings,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json, String id) {
    return UserProfileModel(
      id: id,
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      avatar: json['avatar'],
      avatarThumbnail: json['avatarThumbnail'],
      coverPhoto: json['coverPhoto'],
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      joinDate: (json['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (json['lastActive'] as Timestamp?)?.toDate(),
      isVerified: json['isVerified'] ?? false,
      isPremium: json['isPremium'] ?? false,
      stats: UserStats.fromJson(json['stats'] ?? {}),
      settings: json['settings'] != null ? UserSettings.fromJson(json['settings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'location': location,
      'interests': interests,
      'languages': languages,
      'joinDate': Timestamp.fromDate(joinDate),
      'isVerified': isVerified,
      'isPremium': isPremium,
      'stats': stats.toJson(),
      'searchableDisplayName': _createSearchableTokens(displayName),
    };

    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (avatar != null) data['avatar'] = avatar;
    if (avatarThumbnail != null) data['avatarThumbnail'] = avatarThumbnail;
    if (coverPhoto != null) data['coverPhoto'] = coverPhoto;
    if (lastActive != null) data['lastActive'] = Timestamp.fromDate(lastActive!);
    if (settings != null) data['settings'] = settings!.toJson();

    return data;
  }

  // Create searchable tokens for name search
  List<String> _createSearchableTokens(String name) {
    final tokens = <String>{};
    final nameLower = name.toLowerCase();

    // Add full name
    tokens.add(nameLower);

    // Add each word
    final words = nameLower.split(' ');
    tokens.addAll(words);

    // Add progressive substrings
    for (final word in words) {
      for (int i = 1; i <= word.length; i++) {
        tokens.add(word.substring(0, i));
      }
    }

    return tokens.toList();
  }

  // Get display avatar (base64 thumbnail or URL)
  String? get displayAvatar => avatarThumbnail ?? avatar ?? photoUrl;

  // Check if user has custom avatar
  bool get hasCustomAvatar => avatar != null && avatar!.isNotEmpty;

  // Get initials for avatar placeholder
  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  UserProfileModel copyWith({
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? avatar,
    String? avatarThumbnail,
    String? coverPhoto,
    String? bio,
    String? location,
    List<String>? interests,
    List<String>? languages,
    DateTime? lastActive,
    bool? isVerified,
    bool? isPremium,
    UserStats? stats,
    UserSettings? settings,
  }) {
    return UserProfileModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      avatar: avatar ?? this.avatar,
      avatarThumbnail: avatarThumbnail ?? this.avatarThumbnail,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      languages: languages ?? this.languages,
      joinDate: joinDate,
      lastActive: lastActive ?? this.lastActive,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      stats: stats ?? this.stats,
      settings: settings ?? this.settings,
    );
  }
}

class UserStats {
  final int tripsCount;
  final int reviewsCount;
  final int photosCount;
  final int followersCount;
  final int followingCount;
  final int savedCount;
  final int collectionsCount;

  UserStats({
    required this.tripsCount,
    required this.reviewsCount,
    required this.photosCount,
    required this.followersCount,
    required this.followingCount,
    this.savedCount = 0,
    this.collectionsCount = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      tripsCount: json['tripsCount'] ?? 0,
      reviewsCount: json['reviewsCount'] ?? 0,
      photosCount: json['photosCount'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      savedCount: json['savedCount'] ?? 0,
      collectionsCount: json['collectionsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripsCount': tripsCount,
      'reviewsCount': reviewsCount,
      'photosCount': photosCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'savedCount': savedCount,
      'collectionsCount': collectionsCount,
    };
  }
}

class UserSettings {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final String language;
  final String currency;
  final String theme;
  final PrivacySettings privacy;

  UserSettings({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.language = 'vi',
    this.currency = 'VND',
    this.theme = 'light',
    required this.privacy,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      language: json['language'] ?? 'vi',
      currency: json['currency'] ?? 'VND',
      theme: json['theme'] ?? 'light',
      privacy: PrivacySettings.fromJson(json['privacy'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'language': language,
      'currency': currency,
      'theme': theme,
      'privacy': privacy.toJson(),
    };
  }
}

class PrivacySettings {
  final bool profilePublic;
  final bool showEmail;
  final bool showPhone;
  final bool showLocation;
  final bool allowMessages;
  final bool allowFollowers;

  PrivacySettings({
    this.profilePublic = true,
    this.showEmail = false,
    this.showPhone = false,
    this.showLocation = true,
    this.allowMessages = true,
    this.allowFollowers = true,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      profilePublic: json['profilePublic'] ?? true,
      showEmail: json['showEmail'] ?? false,
      showPhone: json['showPhone'] ?? false,
      showLocation: json['showLocation'] ?? true,
      allowMessages: json['allowMessages'] ?? true,
      allowFollowers: json['allowFollowers'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profilePublic': profilePublic,
      'showEmail': showEmail,
      'showPhone': showPhone,
      'showLocation': showLocation,
      'allowMessages': allowMessages,
      'allowFollowers': allowFollowers,
    };
  }
}
