import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'api_config.dart';

/// The type signature for request interceptors.
///
/// An interceptor receives a [ConnectRequest], may modify it, and returns
/// the (possibly modified) request. Interceptors are executed in order.
typedef RequestInterceptor = Future<ConnectRequest> Function(
  ConnectRequest request,
);

/// The type signature for response interceptors.
///
/// A response interceptor receives a [ConnectResponse] and may modify it
/// or perform side effects (logging, error mapping, etc.).
typedef ResponseInterceptor = Future<ConnectResponse> Function(
  ConnectResponse response,
);

/// Represents an outgoing ConnectRPC request.
class ConnectRequest {
  ConnectRequest({
    required this.path,
    required this.method,
    this.headers = const {},
    this.body,
    this.queryParameters = const {},
  });

  /// The RPC method path (e.g., `/yieldpoint.farm.v1.FarmService/GetFarm`).
  final String path;

  /// The HTTP method (typically POST for ConnectRPC unary calls).
  final String method;

  /// Request headers. Interceptors may add or modify headers.
  Map<String, String> headers;

  /// The serialised protobuf request body.
  Uint8List? body;

  /// Optional query parameters for GET requests.
  final Map<String, String> queryParameters;
}

/// Represents an incoming ConnectRPC response.
class ConnectResponse {
  const ConnectResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
    this.request,
  });

  /// The HTTP status code.
  final int statusCode;

  /// Response headers.
  final Map<String, String> headers;

  /// The raw response body bytes.
  final Uint8List body;

  /// The original request that produced this response.
  final ConnectRequest? request;

  /// Whether the response indicates success (2xx).
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Exception thrown when a ConnectRPC call fails.
class ConnectException implements Exception {
  const ConnectException({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
  });

  /// The ConnectRPC error code string (e.g., `not_found`, `unauthenticated`).
  final String code;

  /// A human-readable error message.
  final String message;

  /// Optional additional error details.
  final dynamic details;

  /// The HTTP status code, if available.
  final int? statusCode;

  @override
  String toString() => 'ConnectException($code): $message';
}

/// ConnectRPC client wrapper providing interceptor chains, timeouts,
/// and retry logic with exponential backoff.
///
/// Usage:
/// ```dart
/// final client = ConnectClient(
///   config: ApiConfig(baseUrl: 'api.yieldpoint.io'),
/// );
/// client.addRequestInterceptor(authInterceptor);
/// client.addResponseInterceptor(loggingResponseInterceptor);
///
/// final response = await client.unary('/farm.v1.FarmService/GetFarm', body: requestBytes);
/// ```
class ConnectClient {
  /// Creates a [ConnectClient] with the given [config] and optional [httpClient].
  ///
  /// If no [httpClient] is provided, a default [http.Client] is created.
  ConnectClient({
    required this.config,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// The API configuration for this client.
  final ApiConfig config;

  final http.Client _httpClient;

  final List<RequestInterceptor> _requestInterceptors = [];
  final List<ResponseInterceptor> _responseInterceptors = [];

  static final _log = Logger('ConnectClient');
  static final _random = math.Random();

  /// Adds a [RequestInterceptor] to the chain.
  ///
  /// Interceptors are executed in the order they are added.
  void addRequestInterceptor(RequestInterceptor interceptor) {
    _requestInterceptors.add(interceptor);
  }

  /// Adds a [ResponseInterceptor] to the chain.
  void addResponseInterceptor(ResponseInterceptor interceptor) {
    _responseInterceptors.add(interceptor);
  }

  /// Removes a previously added [RequestInterceptor].
  void removeRequestInterceptor(RequestInterceptor interceptor) {
    _requestInterceptors.remove(interceptor);
  }

  /// Removes a previously added [ResponseInterceptor].
  void removeResponseInterceptor(ResponseInterceptor interceptor) {
    _responseInterceptors.remove(interceptor);
  }

  /// Performs a unary (single request / single response) ConnectRPC call.
  ///
  /// [path] is the fully-qualified RPC method path.
  /// [body] is the serialised protobuf bytes.
  /// [headers] are additional per-request headers.
  ///
  /// Retries transient failures using exponential backoff according to
  /// [ApiConfig.retryCount].
  ///
  /// Throws [ConnectException] on non-retryable errors.
  /// Throws [TimeoutException] if the request exceeds [ApiConfig.timeout].
  Future<ConnectResponse> unary(
    String path, {
    Uint8List? body,
    Map<String, String>? headers,
  }) async {
    var request = ConnectRequest(
      path: path,
      method: 'POST',
      headers: {
        'Content-Type': 'application/proto',
        'Connect-Protocol-Version': '1',
        ...config.headers,
        if (headers != null) ...headers,
      },
      body: body,
    );

    // Run request interceptors.
    request = await _runRequestInterceptors(request);

    // Execute with retry logic.
    return _executeWithRetry(request);
  }

  /// Performs a server-streaming ConnectRPC call.
  ///
  /// Returns a [Stream] of [ConnectResponse] frames. Each frame represents
  /// one message in the server stream.
  Stream<ConnectResponse> serverStream(
    String path, {
    Uint8List? body,
    Map<String, String>? headers,
  }) async* {
    var request = ConnectRequest(
      path: path,
      method: 'POST',
      headers: {
        'Content-Type': 'application/proto',
        'Connect-Protocol-Version': '1',
        'Connect-Content-Encoding': 'identity',
        ...config.headers,
        if (headers != null) ...headers,
      },
      body: body,
    );

    request = await _runRequestInterceptors(request);

    final uri = _buildUri(request.path);

    final streamedRequest = http.StreamedRequest(request.method, uri);
    request.headers.forEach((key, value) {
      streamedRequest.headers[key] = value;
    });

    if (request.body != null) {
      streamedRequest.sink.add(request.body!);
    }
    streamedRequest.sink.close();

    final streamedResponse = await _httpClient
        .send(streamedRequest)
        .timeout(config.timeout);

    // Yield response chunks as individual frames.
    await for (final chunk in streamedResponse.stream) {
      final frameBytes = Uint8List.fromList(chunk);
      var response = ConnectResponse(
        statusCode: streamedResponse.statusCode,
        headers: streamedResponse.headers,
        body: frameBytes,
        request: request,
      );
      response = await _runResponseInterceptors(response);
      yield response;
    }
  }

  /// Closes the underlying HTTP client and releases resources.
  void close() {
    _httpClient.close();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<ConnectRequest> _runRequestInterceptors(ConnectRequest request) async {
    var current = request;
    for (final interceptor in _requestInterceptors) {
      current = await interceptor(current);
    }
    return current;
  }

  Future<ConnectResponse> _runResponseInterceptors(
    ConnectResponse response,
  ) async {
    var current = response;
    for (final interceptor in _responseInterceptors) {
      current = await interceptor(current);
    }
    return current;
  }

  Future<ConnectResponse> _executeWithRetry(ConnectRequest request) async {
    var lastException = const ConnectException(
      code: 'unknown',
      message: 'Request failed after all retry attempts',
    );

    for (var attempt = 0; attempt <= config.retryCount; attempt++) {
      try {
        final response = await _executeSingle(request);

        // Run response interceptors.
        final processed = await _runResponseInterceptors(response);

        if (processed.isSuccess) {
          return processed;
        }

        // Map HTTP status to ConnectRPC error code.
        final errorCode = _httpStatusToConnectCode(processed.statusCode);

        // Only retry on transient errors.
        if (!_isRetryable(processed.statusCode)) {
          throw ConnectException(
            code: errorCode,
            message: 'Request failed with status ${processed.statusCode}',
            statusCode: processed.statusCode,
          );
        }

        lastException = ConnectException(
          code: errorCode,
          message: 'Request failed with status ${processed.statusCode}',
          statusCode: processed.statusCode,
        );
      } on TimeoutException {
        lastException = const ConnectException(
          code: 'deadline_exceeded',
          message: 'Request timed out',
        );
      } on ConnectException {
        rethrow;
      } on Exception catch (e) {
        lastException = ConnectException(
          code: 'unavailable',
          message: e.toString(),
        );
      }

      // Wait with exponential backoff + jitter before retrying.
      if (attempt < config.retryCount) {
        final delay = _calculateBackoff(attempt);
        _log.fine(
          'Retry attempt ${attempt + 1}/${config.retryCount} '
          'after ${delay.inMilliseconds}ms',
        );
        await Future<void>.delayed(delay);
      }
    }

    throw lastException;
  }

  Future<ConnectResponse> _executeSingle(ConnectRequest request) async {
    final uri = _buildUri(request.path);

    final httpResponse = await _httpClient
        .post(
          uri,
          headers: request.headers,
          body: request.body,
        )
        .timeout(config.timeout);

    return ConnectResponse(
      statusCode: httpResponse.statusCode,
      headers: httpResponse.headers,
      body: httpResponse.bodyBytes,
      request: request,
    );
  }

  Uri _buildUri(String path) {
    final scheme = config.useTls ? 'https' : 'http';
    final defaultPort = config.useTls ? 443 : 80;
    return Uri(
      scheme: scheme,
      host: config.baseUrl,
      port: config.port != defaultPort ? config.port : null,
      path: path,
    );
  }

  /// Calculates the backoff delay for [attempt] using exponential backoff
  /// with full jitter: `random(0, min(cap, base * 2^attempt))`.
  Duration _calculateBackoff(int attempt) {
    final baseMs = config.retryBaseDelay.inMilliseconds;
    final capMs = config.maxRetryDelay.inMilliseconds;
    final exponentialMs = baseMs * math.pow(2, attempt).toInt();
    final clampedMs = math.min(exponentialMs, capMs);
    final jitteredMs = _random.nextInt(clampedMs + 1);
    return Duration(milliseconds: jitteredMs);
  }

  bool _isRetryable(int statusCode) {
    return statusCode == 408 || // Request Timeout
        statusCode == 429 || // Too Many Requests
        statusCode == 502 || // Bad Gateway
        statusCode == 503 || // Service Unavailable
        statusCode == 504; // Gateway Timeout
  }

  String _httpStatusToConnectCode(int statusCode) {
    return switch (statusCode) {
      400 => 'invalid_argument',
      401 => 'unauthenticated',
      403 => 'permission_denied',
      404 => 'not_found',
      408 => 'deadline_exceeded',
      409 => 'already_exists',
      429 => 'resource_exhausted',
      499 => 'cancelled',
      500 => 'internal',
      501 => 'unimplemented',
      502 => 'unavailable',
      503 => 'unavailable',
      504 => 'deadline_exceeded',
      _ => 'unknown',
    };
  }
}
