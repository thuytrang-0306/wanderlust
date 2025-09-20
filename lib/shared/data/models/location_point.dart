import 'package:cloud_firestore/cloud_firestore.dart';

class LocationPoint {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;
  final String? address;
  final String? type; // restaurant, hotel, attraction, etc.
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  LocationPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
    this.address,
    this.type,
    this.imageUrl,
    this.metadata,
  });

  factory LocationPoint.fromMap(Map<String, dynamic> map, [String? id]) {
    return LocationPoint(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      description: map['description'],
      address: map['address'],
      type: map['type'],
      imageUrl: map['imageUrl'],
      metadata: map['metadata'],
    );
  }

  factory LocationPoint.fromFirestore(Map<String, dynamic> data, String id) {
    // Handle GeoPoint from Firestore
    if (data['location'] is GeoPoint) {
      final geoPoint = data['location'] as GeoPoint;
      return LocationPoint(
        id: id,
        name: data['name'] ?? '',
        latitude: geoPoint.latitude,
        longitude: geoPoint.longitude,
        description: data['description'],
        address: data['address'],
        type: data['type'],
        imageUrl: data['imageUrl'],
        metadata: data['metadata'],
      );
    }

    // Handle separate lat/lng fields
    return LocationPoint.fromMap(data, id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (type != null) 'type': type,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (metadata != null) 'metadata': metadata,
    };
  }

  // Convert to Firestore format with GeoPoint
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': GeoPoint(latitude, longitude),
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (type != null) 'type': type,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (metadata != null) 'metadata': metadata,
    };
  }

  // Helper method to get display text
  String get displayText {
    if (address != null && address!.isNotEmpty) {
      return '$name\n$address';
    }
    return name;
  }

  // Helper method to check if location is valid
  bool get isValid {
    return latitude != 0.0 && longitude != 0.0;
  }

  LocationPoint copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? description,
    String? address,
    String? type,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return LocationPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      address: address ?? this.address,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}
