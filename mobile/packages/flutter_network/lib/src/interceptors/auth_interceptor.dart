import 'dart:async';

import 'package:flutter_network/src/client/connect_client.dart';
import 'package:logging/logging.dart';

/// Signature for a function that reads the current access token.
typedef TokenReader = Future<String?> Function();

/// Signature for a function that refreshes an expired token and returns
/// the new access token.
typedef TokenRefresher = Future<String?> Function();

/// JWT authentication interceptor for ConnectRPC requests.
///
/// Injects the `Authorization: Bearer <token>` header on every outgoing
/// request. When a 401 response is received, it attempts a single token
/// refresh and retries the original request.
///
/// Usage:
/// ```dart
/// final authInterceptor = AuthInterceptor(
///   tokenReader: () => tokenService.getAccessToken(),
///   tokenRefresher: () => tokenService.refreshAccessToken(),
/// );
/// client.addRequestInterceptor(authInterceptor.interceptRequest);
/// client.addResponseInterceptor(authInterceptor.interceptResponse);
/// ```
class AuthInterceptor {
  AuthInterceptor({
    required this.tokenReader,
    required this.tokenRefresher,
  });

  /// Reads the current access token from secure storage.
  final TokenReader tokenReader;

  /// Refreshes the access token when the current one is expired or rejected.
  final TokenRefresher tokenRefresher;

  static final _log = Logger('AuthInterceptor');

  /// Tracks whether a token refresh is already in flight to avoid
  /// concurrent refresh calls from multiple intercepted requests.
  Completer<String?>? _refreshCompleter;

  /// Request interceptor that injects the Authorization header.
  Future<ConnectRequest> interceptRequest(ConnectRequest request) async {
    final token = await tokenReader();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return request;
  }

  /// Response interceptor that triggers a token refresh on 401 responses.
  ///
  /// After a successful refresh the caller should retry the request. This
  /// interceptor updates the stored token but does not re-execute the
  /// request itself — the retry logic in [ConnectClient] handles that.
  Future<ConnectResponse> interceptResponse(ConnectResponse response) async {
    if (response.statusCode != 401) {
      return response;
    }

    _log.info('Received 401 — attempting token refresh');

    final newToken = await _refreshTokenOnce();

    if (newToken == null) {
      _log.warning('Token refresh failed — returning original 401');
      return response;
    }

    _log.info('Token refreshed successfully');
    return response;
  }

  /// Ensures only one token refresh executes at a time. Concurrent callers
  /// await the same [Completer].
  Future<String?> _refreshTokenOnce() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();

    try {
      final newToken = await tokenRefresher();
      _refreshCompleter!.complete(newToken);
      return newToken;
    } on Exception catch (e) {
      _log.severe('Token refresh error: $e');
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }
}
