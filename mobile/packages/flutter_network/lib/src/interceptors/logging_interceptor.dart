import 'dart:async';

import 'package:flutter_network/src/client/connect_client.dart';
import 'package:logging/logging.dart';

/// Logging interceptor that records outgoing requests and incoming responses.
///
/// Logs include method path, headers, status codes, and timing information.
/// Sensitive headers (e.g., `Authorization`) are redacted by default.
///
/// Usage:
/// ```dart
/// final logging = LoggingInterceptor();
/// client.addRequestInterceptor(logging.interceptRequest);
/// client.addResponseInterceptor(logging.interceptResponse);
/// ```
class LoggingInterceptor {
  LoggingInterceptor({
    this.logHeaders = true,
    this.logBody = false,
    this.redactedHeaders = const {'authorization', 'cookie', 'set-cookie'},
  });

  /// Whether to include headers in log output.
  final bool logHeaders;

  /// Whether to include body byte lengths in log output.
  final bool logBody;

  /// Header names (lowercase) whose values should be redacted.
  final Set<String> redactedHeaders;

  static final _log = Logger('ConnectRPC');

  /// Stores request start times keyed by request identity hash.
  final Map<int, DateTime> _requestTimestamps = {};

  /// Logs the outgoing request and records its start time.
  Future<ConnectRequest> interceptRequest(ConnectRequest request) async {
    final timestamp = DateTime.now();
    _requestTimestamps[identityHashCode(request)] = timestamp;

    final buffer = StringBuffer()
      ..writeln('──▶ ${request.method} ${request.path}');

    if (logHeaders && request.headers.isNotEmpty) {
      buffer.writeln('    Headers:');
      for (final entry in request.headers.entries) {
        final value = redactedHeaders.contains(entry.key.toLowerCase())
            ? '***REDACTED***'
            : entry.value;
        buffer.writeln('      ${entry.key}: $value');
      }
    }

    if (logBody && request.body != null) {
      buffer.writeln('    Body: ${request.body!.length} bytes');
    }

    _log.info(buffer.toString().trimRight());
    return request;
  }

  /// Logs the incoming response including status code and elapsed time.
  Future<ConnectResponse> interceptResponse(ConnectResponse response) async {
    final requestHash =
        response.request != null ? identityHashCode(response.request) : null;

    Duration? elapsed;
    if (requestHash != null && _requestTimestamps.containsKey(requestHash)) {
      elapsed = DateTime.now().difference(_requestTimestamps[requestHash]!);
      _requestTimestamps.remove(requestHash);
    }

    final path = response.request?.path ?? 'unknown';
    final elapsedStr =
        elapsed != null ? ' (${elapsed.inMilliseconds}ms)' : '';

    final statusEmoji = response.isSuccess ? '◀──' : '◀╌╌';

    final buffer = StringBuffer()
      ..writeln('$statusEmoji ${response.statusCode} $path$elapsedStr');

    if (logHeaders && response.headers.isNotEmpty) {
      buffer.writeln('    Headers:');
      for (final entry in response.headers.entries) {
        final value = redactedHeaders.contains(entry.key.toLowerCase())
            ? '***REDACTED***'
            : entry.value;
        buffer.writeln('      ${entry.key}: $value');
      }
    }

    if (logBody) {
      buffer.writeln('    Body: ${response.body.length} bytes');
    }

    if (response.isSuccess) {
      _log.info(buffer.toString().trimRight());
    } else {
      _log.warning(buffer.toString().trimRight());
    }

    return response;
  }
}
