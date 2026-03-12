/// API configuration model for ConnectRPC client connections.
///
/// Holds all connection parameters including base URL, timeouts,
/// retry policies, and default headers.
class ApiConfig {
  /// Creates an [ApiConfig] with the given parameters.
  ///
  /// [baseUrl] is the root URL of the API server.
  /// [timeout] defaults to 30 seconds.
  /// [retryCount] defaults to 3.
  /// [headers] are additional headers sent with every request.
  const ApiConfig({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.retryCount = 3,
    this.headers = const {},
    this.useTls = true,
    this.port = 443,
    this.retryBaseDelay = const Duration(milliseconds: 500),
    this.maxRetryDelay = const Duration(seconds: 30),
  });

  /// The base URL for all API requests (e.g., `api.yieldpoint.io`).
  final String baseUrl;

  /// The port number to connect on.
  final int port;

  /// Whether to use TLS (HTTPS) for connections.
  final bool useTls;

  /// The maximum duration to wait for a response before timing out.
  final Duration timeout;

  /// The number of retry attempts for failed requests.
  final int retryCount;

  /// The base delay between retries. Actual delay uses exponential backoff.
  final Duration retryBaseDelay;

  /// The maximum delay between retries when using exponential backoff.
  final Duration maxRetryDelay;

  /// Default headers included in every request.
  final Map<String, String> headers;

  /// Returns the full URI scheme and host.
  String get origin {
    final scheme = useTls ? 'https' : 'http';
    final defaultPort = useTls ? 443 : 80;
    final portSuffix = port == defaultPort ? '' : ':$port';
    return '$scheme://$baseUrl$portSuffix';
  }

  /// Creates a copy of this config with the given overrides.
  ApiConfig copyWith({
    String? baseUrl,
    int? port,
    bool? useTls,
    Duration? timeout,
    int? retryCount,
    Duration? retryBaseDelay,
    Duration? maxRetryDelay,
    Map<String, String>? headers,
  }) {
    return ApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      port: port ?? this.port,
      useTls: useTls ?? this.useTls,
      timeout: timeout ?? this.timeout,
      retryCount: retryCount ?? this.retryCount,
      retryBaseDelay: retryBaseDelay ?? this.retryBaseDelay,
      maxRetryDelay: maxRetryDelay ?? this.maxRetryDelay,
      headers: headers ?? this.headers,
    );
  }

  @override
  String toString() =>
      'ApiConfig(baseUrl: $baseUrl, port: $port, useTls: $useTls, '
      'timeout: $timeout, retryCount: $retryCount)';
}
