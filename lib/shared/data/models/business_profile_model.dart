import 'package:cloud_firestore/cloud_firestore.dart';

/// Business types available in the platform
enum BusinessType {
  hotel('hotel', 'Khách sạn/Homestay', '🏨'),
  tour('tour', 'Tour Operator', '✈️'),
  restaurant('restaurant', 'Nhà hàng', '🍽️'),
  service('service', 'Dịch vụ', '🚗');

  final String value;
  final String displayName;
  final String icon;

  const BusinessType(this.value, this.displayName, this.icon);

  static BusinessType fromString(String value) {
    return BusinessType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BusinessType.service,
    );
  }
}

/// Business verification status
enum VerificationStatus {
  pending('pending', 'Đang xác thực'),
  verified('verified', 'Đã xác thực'),
  rejected('rejected', 'Từ chối'),
  expired('expired', 'Hết hạn');

  final String value;
  final String displayName;

  const VerificationStatus(this.value, this.displayName);

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}

/// Business profile model for business users
class BusinessProfileModel {
  final String id;
  final String userId;
  final String businessName;
  final BusinessType businessType;
  final String? taxNumber;
  final String businessPhone;
  final String businessEmail;
  final String address;
  final String description;
  final String? verificationDoc; // base64 image
  final VerificationStatus verificationStatus;
  final DateTime? verifiedAt;
  final double rating;
  final int totalReviews;
  final int totalListings;
  final Map<String, dynamic>? socialLinks;
  final List<String>? businessImages; // base64 images
  final Map<String, dynamic>? operatingHours;
  final List<String>? services;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  BusinessProfileModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessType,
    this.taxNumber,
    required this.businessPhone,
    required this.businessEmail,
    required this.address,
    required this.description,
    this.verificationDoc,
    this.verificationStatus = VerificationStatus.pending,
    this.verifiedAt,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalListings = 0,
    this.socialLinks,
    this.businessImages,
    this.operatingHours,
    this.services,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  /// Create from Firestore document
  factory BusinessProfileModel.fromJson(Map<String, dynamic> json, String docId) {
    return BusinessProfileModel(
      id: docId,
      userId: json['userId'] ?? '',
      businessName: json['businessName'] ?? '',
      businessType: BusinessType.fromString(json['businessType'] ?? 'service'),
      taxNumber: json['taxNumber'],
      businessPhone: json['businessPhone'] ?? '',
      businessEmail: json['businessEmail'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      verificationDoc: json['verificationDoc'],
      verificationStatus: VerificationStatus.fromString(
        json['verificationStatus'] ?? 'pending',
      ),
      verifiedAt: json['verifiedAt'] != null
          ? (json['verifiedAt'] as Timestamp).toDate()
          : null,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      totalListings: json['totalListings'] ?? 0,
      socialLinks: json['socialLinks'],
      businessImages: json['businessImages'] != null
          ? List<String>.from(json['businessImages'])
          : null,
      operatingHours: json['operatingHours'],
      services: json['services'] != null
          ? List<String>.from(json['services'])
          : null,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'businessName': businessName,
      'businessType': businessType.value,
      'taxNumber': taxNumber,
      'businessPhone': businessPhone,
      'businessEmail': businessEmail,
      'address': address,
      'description': description,
      'verificationDoc': verificationDoc,
      'verificationStatus': verificationStatus.value,
      'verifiedAt': verifiedAt != null
          ? Timestamp.fromDate(verifiedAt!)
          : null,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalListings': totalListings,
      'socialLinks': socialLinks,
      'businessImages': businessImages,
      'operatingHours': operatingHours,
      'services': services,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': isActive,
    };
  }

  /// Copy with method for updates
  BusinessProfileModel copyWith({
    String? businessName,
    BusinessType? businessType,
    String? taxNumber,
    String? businessPhone,
    String? businessEmail,
    String? address,
    String? description,
    String? verificationDoc,
    VerificationStatus? verificationStatus,
    DateTime? verifiedAt,
    double? rating,
    int? totalReviews,
    int? totalListings,
    Map<String, dynamic>? socialLinks,
    List<String>? businessImages,
    Map<String, dynamic>? operatingHours,
    List<String>? services,
    bool? isActive,
  }) {
    return BusinessProfileModel(
      id: id,
      userId: userId,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      taxNumber: taxNumber ?? this.taxNumber,
      businessPhone: businessPhone ?? this.businessPhone,
      businessEmail: businessEmail ?? this.businessEmail,
      address: address ?? this.address,
      description: description ?? this.description,
      verificationDoc: verificationDoc ?? this.verificationDoc,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalListings: totalListings ?? this.totalListings,
      socialLinks: socialLinks ?? this.socialLinks,
      businessImages: businessImages ?? this.businessImages,
      operatingHours: operatingHours ?? this.operatingHours,
      services: services ?? this.services,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  /// Check if business is verified
  bool get isVerified => verificationStatus == VerificationStatus.verified;

  /// Get formatted rating
  String get formattedRating => rating.toStringAsFixed(1);

  /// Get business type icon
  String get typeIcon => businessType.icon;

  /// Get business type display name
  String get typeDisplayName => businessType.displayName;

  /// Get verification badge color
  String get verificationColor {
    switch (verificationStatus) {
      case VerificationStatus.verified:
        return '#4CAF50'; // Green
      case VerificationStatus.pending:
        return '#FF9800'; // Orange
      case VerificationStatus.rejected:
        return '#F44336'; // Red
      case VerificationStatus.expired:
        return '#9E9E9E'; // Grey
    }
  }
}