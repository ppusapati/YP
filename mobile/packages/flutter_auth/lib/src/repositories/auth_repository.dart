import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/auth_token.dart';
import '../models/user_model.dart';
import '../services/token_service.dart';

/// Exception thrown when an authentication operation fails.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// Repository that manages authentication operations including login,
/// logout, token refresh, and user retrieval.
///
/// This repository coordinates between the remote auth API and the
/// local [TokenService] for token persistence.
class AuthRepository {
  AuthRepository({
    required this.baseUrl,
    required this.tokenService,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// The base URL for the authentication API.
  final String baseUrl;

  /// The token service for persisting and retrieving JWT tokens.
  final TokenService tokenService;

  final http.Client _httpClient;
  static final _log = Logger('AuthRepository');

  /// Authenticates a user with email and password credentials.
  ///
  /// On success, persists the returned tokens and returns the authenticated
  /// user. Throws [AuthException] on failure.
  Future<({User user, AuthToken token})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        final body = _tryDecodeBody(response.body);
        final message =
            body?['message'] as String? ?? 'Login failed (${response.statusCode})';
        throw AuthException(message);
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      final token = AuthToken.fromMap(body['token'] as Map<String, dynamic>);
      final user = User.fromMap(body['user'] as Map<String, dynamic>);

      await tokenService.saveToken(token);
      _log.info('User logged in: ${user.email}');

      return (user: user, token: token);
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      _log.severe('Login error: $e');
      throw AuthException('Failed to login: $e');
    }
  }

  /// Logs the current user out by clearing stored tokens and notifying
  /// the server.
  Future<void> logout() async {
    try {
      final accessToken = await tokenService.getAccessToken();
      if (accessToken != null) {
        // Best-effort server-side logout.
        await _httpClient.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () => http.Response('', 200),
        );
      }
    } on Exception catch (e) {
      _log.warning('Server logout failed (non-critical): $e');
    } finally {
      await tokenService.clearTokens();
      _log.info('User logged out');
    }
  }

  /// Refreshes the access token using the stored refresh token.
  ///
  /// Returns the new [AuthToken] on success. Throws [AuthException] if
  /// no refresh token is available or the refresh request fails.
  Future<AuthToken> refreshToken() async {
    final currentRefreshToken = await tokenService.getRefreshToken();
    if (currentRefreshToken == null) {
      throw const AuthException('No refresh token available');
    }

    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': currentRefreshToken}),
      );

      if (response.statusCode != 200) {
        // Refresh failed — clear stale tokens.
        await tokenService.clearTokens();
        throw AuthException(
          'Token refresh failed (${response.statusCode})',
        );
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      final newToken = AuthToken.fromMap(body['token'] as Map<String, dynamic>);
      await tokenService.saveToken(newToken);

      _log.info('Token refreshed successfully');
      return newToken;
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      _log.severe('Token refresh error: $e');
      throw AuthException('Failed to refresh token: $e');
    }
  }

  /// Retrieves the current authenticated user's profile.
  ///
  /// Returns `null` if no valid token is stored.
  /// Throws [AuthException] if the API call fails.
  Future<User?> getCurrentUser() async {
    final token = await tokenService.getToken();
    if (token == null || token.isExpired) {
      return null;
    }

    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer ${token.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        // Token was rejected — try refresh.
        try {
          final newToken = await refreshToken();
          return _fetchUser(newToken.accessToken);
        } on AuthException {
          return null;
        }
      }

      if (response.statusCode != 200) {
        throw AuthException(
          'Failed to get current user (${response.statusCode})',
        );
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      return User.fromMap(body);
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      _log.severe('Get current user error: $e');
      throw AuthException('Failed to get current user: $e');
    }
  }

  /// Checks whether the user has an active session (valid, non-expired token).
  Future<bool> hasActiveSession() async {
    return tokenService.hasValidToken();
  }

  Future<User> _fetchUser(String accessToken) async {
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw AuthException(
        'Failed to get user after token refresh (${response.statusCode})',
      );
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    return User.fromMap(body);
  }

  Map<String, dynamic>? _tryDecodeBody(String body) {
    try {
      return json.decode(body) as Map<String, dynamic>;
    } on Exception {
      return null;
    }
  }
}
