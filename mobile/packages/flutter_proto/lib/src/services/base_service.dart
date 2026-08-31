import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:protobuf/protobuf.dart' as $pb;

/// Base class for all ConnectRPC service clients.
///
/// Provides common functionality for making unary and streaming RPC calls
/// using the ConnectRPC protocol over HTTP.
abstract class BaseService {
  BaseService({
    required this.baseUrl,
    this.httpClient,
    this.interceptors = const [],
  });

  /// The base URL for this service (e.g., `https://api.yieldpoint.io`).
  final String baseUrl;

  /// Optional HTTP client. A default client is used if not provided.
  final http.Client? httpClient;

  /// Request interceptors applied to every outgoing request.
  final List<RequestInterceptorFn> interceptors;

  http.Client get _client => httpClient ?? http.Client();

  /// The fully qualified protobuf service name
  /// (e.g., `yieldpoint.farm.v1.FarmService`).
  String get serviceName;

  /// Makes a unary RPC call and returns the raw response bytes.
  ///
  /// [method] is the RPC method name (e.g., `GetFarm`).
  /// [request] is the protobuf request message.
  Future<Uint8List> callUnary(
    String method,
    $pb.GeneratedMessage request,
  ) async {
    final url = '$baseUrl/$serviceName/$method';
    var headers = <String, String>{
      'Content-Type': 'application/proto',
      'Connect-Protocol-Version': '1',
    };

    // Apply interceptors.
    for (final interceptor in interceptors) {
      headers = await interceptor(headers);
    }

    final response = await _client.post(
      Uri.parse(url),
      headers: headers,
      body: request.writeToBuffer(),
    );

    if (response.statusCode != 200) {
      throw ServiceException(
        method: '$serviceName/$method',
        statusCode: response.statusCode,
        message: 'RPC call failed with status ${response.statusCode}',
      );
    }

    return response.bodyBytes;
  }

  /// Makes a server-streaming RPC call and yields raw response frame bytes.
  Stream<Uint8List> callServerStream(
    String method,
    $pb.GeneratedMessage request,
  ) async* {
    final url = '$baseUrl/$serviceName/$method';
    var headers = <String, String>{
      'Content-Type': 'application/proto',
      'Connect-Protocol-Version': '1',
      'Connect-Content-Encoding': 'identity',
    };

    for (final interceptor in interceptors) {
      headers = await interceptor(headers);
    }

    final streamedRequest =
        http.StreamedRequest('POST', Uri.parse(url));
    headers.forEach((k, v) => streamedRequest.headers[k] = v);
    streamedRequest.sink.add(request.writeToBuffer());
    streamedRequest.sink.close();

    final streamedResponse = await _client.send(streamedRequest);

    if (streamedResponse.statusCode != 200) {
      throw ServiceException(
        method: '$serviceName/$method',
        statusCode: streamedResponse.statusCode,
        message: 'Streaming RPC call failed',
      );
    }

    await for (final chunk in streamedResponse.stream) {
      yield Uint8List.fromList(chunk);
    }
  }
}

/// Signature for a request interceptor function.
typedef RequestInterceptorFn = Future<Map<String, String>> Function(
  Map<String, String> headers,
);

/// Exception thrown when a service RPC call fails.
class ServiceException implements Exception {
  const ServiceException({
    required this.method,
    required this.statusCode,
    required this.message,
  });

  final String method;
  final int statusCode;
  final String message;

  @override
  String toString() => 'ServiceException($method, $statusCode): $message';
}
