import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

import '../models/auth_token.dart';

/// Manages JWT token persistence and lifecycle using secure storage.
///
/// Responsibilities:
/// - Store and retrieve tokens from [FlutterSecureStorage].
/// - Check token expiry.
/// - Decode JWT payload for extracting claims (user ID, roles, etc.).
///
/// Usage:
/// ```dart
/// final tokenService = TokenService();
/// await tokenService.saveToken(authToken);
///
/// final token = await tokenService.getToken();
/// if (token != null && !token.isExpired) {
///   // use the token
/// }
/// ```
class TokenService {
  TokenService({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;
  static final _log = Logger('TokenService');

  static const _accessTokenKey = 'yp_access_token';
  static const _refreshTokenKey = 'yp_refresh_token';
  static const _expiresAtKey = 'yp_token_expires_at';

  /// Persists the given [token] to secure storage.
  Future<void> saveToken(AuthToken token) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: token.accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: token.refreshToken),
      _secureStorage.write(
        key: _expiresAtKey,
        value: token.expiresAt.millisecondsSinceEpoch.toString(),
      ),
    ]);
    _log.fine('Token saved to secure storage');
  }

  /// Retrieves the stored token, or `null` if no token exists.
  Future<AuthToken?> getToken() async {
    final results = await Future.wait([
      _secureStorage.read(key: _accessTokenKey),
      _secureStorage.read(key: _refreshTokenKey),
      _secureStorage.read(key: _expiresAtKey),
    ]);

    final accessToken = results[0];
    final refreshToken = results[1];
    final expiresAtStr = results[2];

    if (accessToken == null || refreshToken == null || expiresAtStr == null) {
      return null;
    }

    final expiresAtMs = int.tryParse(expiresAtStr);
    if (expiresAtMs == null) {
      _log.warning('Invalid expires_at value in storage: $expiresAtStr');
      return null;
    }

    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expiresAtMs),
    );
  }

  /// Returns the current access token string, or `null` if not stored.
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  /// Returns the current refresh token string, or `null` if not stored.
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  /// Checks whether a stored token exists and has not expired.
  Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && !token.isExpired;
  }

  /// Checks whether the stored token is expired or will expire within
  /// [buffer] (defaults to 60 seconds).
  Future<bool> isTokenExpiringSoon({
    Duration buffer = const Duration(seconds: 60),
  }) async {
    final token = await getToken();
    if (token == null) return true;
    return token.isExpiringSoon(buffer: buffer);
  }

  /// Deletes all stored token data from secure storage.
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _expiresAtKey),
    ]);
    _log.fine('Tokens cleared from secure storage');
  }

  /// Decodes the payload of a JWT access token without signature verification.
  ///
  /// Returns a map of claims, or `null` if decoding fails. This is intended
  /// for reading claims client-side (e.g., user ID, expiry). **Never use
  /// this for security validation** — that is the server's responsibility.
  Map<String, dynamic>? decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        _log.warning('Invalid JWT format: expected 3 parts, got ${parts.length}');
        return null;
      }

      final payload = parts[1];
      // JWT uses base64url encoding without padding.
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(decoded) as Map<String, dynamic>;
      return map;
    } on Exception catch (e) {
      _log.warning('Failed to decode JWT payload: $e');
      return null;
    }
  }

  /// Extracts the expiration [DateTime] from a JWT token, or `null` if
  /// the `exp` claim is missing or the token is malformed.
  DateTime? getTokenExpiry(String token) {
    final payload = decodeJwtPayload(token);
    if (payload == null) return null;

    final exp = payload['exp'];
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    }
    return null;
  }

  /// Extracts the user ID (`sub` claim) from a JWT token.
  String? getUserIdFromToken(String token) {
    final payload = decodeJwtPayload(token);
    return payload?['sub'] as String?;
  }
}
