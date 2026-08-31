import 'package:equatable/equatable.dart';

/// Holds the JWT access and refresh tokens with expiry metadata.
///
/// This is an immutable value object. To update tokens (e.g., after a
/// refresh), create a new [AuthToken] instance.
class AuthToken extends Equatable {
  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  /// Creates an [AuthToken] from a map (e.g., from an API response).
  factory AuthToken.fromMap(Map<String, dynamic> map) {
    return AuthToken(
      accessToken: map['access_token'] as String? ?? '',
      refreshToken: map['refresh_token'] as String? ?? '',
      expiresAt: map['expires_at'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['expires_at'] as int)
          : DateTime.tryParse(map['expires_at'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  /// The JWT access token used for API authentication.
  final String accessToken;

  /// The refresh token used to obtain a new access token.
  final String refreshToken;

  /// When the access token expires.
  final DateTime expiresAt;

  /// Whether the access token has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Whether the access token will expire within [buffer].
  ///
  /// Defaults to a 60-second buffer to allow for clock skew and
  /// network latency during refresh.
  bool isExpiringSoon({Duration buffer = const Duration(seconds: 60)}) {
    return DateTime.now().add(buffer).isAfter(expiresAt);
  }

  /// Converts this token to a map representation for serialisation.
  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];

  @override
  String toString() =>
      'AuthToken(accessToken: ${accessToken.substring(0, accessToken.length.clamp(0, 10))}..., '
      'expiresAt: $expiresAt, isExpired: $isExpired)';
}
