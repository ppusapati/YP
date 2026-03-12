import 'package:equatable/equatable.dart';

/// The role a user holds within the YieldPoint platform.
enum UserRole {
  /// Farm owner with full administrative access.
  owner,

  /// Farm manager with operational access.
  manager,

  /// Field worker with task-level access.
  worker,

  /// Agronomist with advisory and read access.
  agronomist,

  /// Read-only viewer.
  viewer,
}

/// Represents an authenticated user in the YieldPoint platform.
///
/// Immutable value object containing user identity, role, and
/// associated farm IDs.
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.farmIds = const [],
    this.avatarUrl,
    this.phoneNumber,
  });

  /// Creates a [User] from a decoded JWT payload or API response map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: _parseRole(map['role'] as String?),
      farmIds: (map['farm_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      avatarUrl: map['avatar_url'] as String?,
      phoneNumber: map['phone_number'] as String?,
    );
  }

  /// The unique user identifier.
  final String id;

  /// The user's display name.
  final String name;

  /// The user's email address.
  final String email;

  /// The user's role within the platform.
  final UserRole role;

  /// IDs of farms this user has access to.
  final List<String> farmIds;

  /// Optional URL to the user's avatar image.
  final String? avatarUrl;

  /// Optional phone number.
  final String? phoneNumber;

  /// Converts this user to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'farm_ids': farmIds,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    };
  }

  /// Creates a copy with optional field overrides.
  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    List<String>? farmIds,
    String? avatarUrl,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      farmIds: farmIds ?? this.farmIds,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  static UserRole _parseRole(String? role) {
    if (role == null) return UserRole.viewer;
    return UserRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => UserRole.viewer,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, email, role, farmIds, avatarUrl, phoneNumber];

  @override
  String toString() => 'User(id: $id, name: $name, email: $email, role: $role)';
}
