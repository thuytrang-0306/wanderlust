import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String id;
  final String name;
  final String email;
  final String role; // super_admin, moderator, analyst, business_manager
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final String? createdBy; // UID of admin who created this admin
  final String? avatar;
  final String? phone;
  final Map<String, dynamic>? permissions; // Custom permissions override
  final Map<String, dynamic>? metadata; // Additional data

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.createdBy,
    this.avatar,
    this.phone,
    this.permissions,
    this.metadata,
  });

  // Factory constructor from Firestore document
  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AdminModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'moderator',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      createdBy: data['createdBy'],
      avatar: data['avatar'],
      phone: data['phone'],
      permissions: data['permissions'],
      metadata: data['metadata'],
    );
  }

  // Factory constructor from JSON
  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'moderator',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      createdBy: json['createdBy'],
      avatar: json['avatar'],
      phone: json['phone'],
      permissions: json['permissions'],
      metadata: json['metadata'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdBy': createdBy,
      'avatar': avatar,
      'phone': phone,
      'permissions': permissions,
      'metadata': metadata,
    };
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'createdBy': createdBy,
      'avatar': avatar,
      'phone': phone,
      'permissions': permissions,
      'metadata': metadata,
    };
  }

  // CopyWith method
  AdminModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    String? createdBy,
    String? avatar,
    String? phone,
    Map<String, dynamic>? permissions,
    Map<String, dynamic>? metadata,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdBy: createdBy ?? this.createdBy,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      permissions: permissions ?? this.permissions,
      metadata: metadata ?? this.metadata,
    );
  }

  // Getters for UI
  String get displayName => name.isNotEmpty ? name : email.split('@').first;
  
  String get roleDisplayName {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'moderator':
        return 'Moderator';
      case 'analyst':
        return 'Analyst';
      case 'business_manager':
        return 'Business Manager';
      default:
        return role.replaceAll('_', ' ').split(' ').map((e) => 
            e[0].toUpperCase() + e.substring(1)).join(' ');
    }
  }

  String get roleColor {
    switch (role) {
      case 'super_admin':
        return '#E91E63'; // Pink
      case 'moderator':
        return '#2196F3'; // Blue
      case 'analyst':
        return '#4CAF50'; // Green
      case 'business_manager':
        return '#FF9800'; // Orange
      default:
        return '#9E9E9E'; // Grey
    }
  }

  String get statusText => isActive ? 'Active' : 'Inactive';
  String get statusColor => isActive ? '#4CAF50' : '#F44336';

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
      return lastLoginAt!.toLocal().toString().split(' ')[0];
    }
  }

  // Permission checking for this admin
  bool hasBasePermission(String permission) {
    // Super admin has all permissions
    if (role == 'super_admin') return true;
    
    // Check custom permissions first
    if (permissions != null && permissions!.containsKey(permission)) {
      return permissions![permission] == true;
    }
    
    // Default role-based permissions
    final rolePermissions = _getDefaultPermissions();
    return rolePermissions.contains(permission);
  }

  List<String> _getDefaultPermissions() {
    switch (role) {
      case 'super_admin':
        return [
          // All permissions
          'view_dashboard',
          'view_analytics',
          'view_users',
          'edit_users',
          'delete_users',
          'ban_users',
          'view_businesses',
          'edit_businesses',
          'approve_businesses',
          'delete_businesses',
          'view_content',
          'moderate_content',
          'delete_content',
          'view_reports',
          'export_data',
          'manage_admins',
          'create_admin',
          'edit_admin',
          'delete_admin',
          'system_settings',
          'view_logs',
        ];
      case 'moderator':
        return [
          'view_dashboard',
          'view_users',
          'ban_users',
          'view_businesses',
          'view_content',
          'moderate_content',
          'delete_content',
          'view_reports',
        ];
      case 'analyst':
        return [
          'view_dashboard',
          'view_analytics',
          'view_users',
          'view_businesses',
          'view_content',
          'view_reports',
          'export_data',
        ];
      case 'business_manager':
        return [
          'view_dashboard',
          'view_businesses',
          'edit_businesses',
          'approve_businesses',
          'view_content',
          'view_reports',
        ];
      default:
        return ['view_dashboard'];
    }
  }

  // Get all permissions for this admin
  List<String> getAllPermissions() {
    Set<String> allPermissions = Set.from(_getDefaultPermissions());
    
    // Add custom permissions
    if (permissions != null) {
      permissions!.forEach((key, value) {
        if (value == true) {
          allPermissions.add(key);
        } else if (value == false) {
          allPermissions.remove(key); // Remove if explicitly denied
        }
      });
    }
    
    return allPermissions.toList();
  }

  @override
  String toString() {
    return 'AdminModel(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}