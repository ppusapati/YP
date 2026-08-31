import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter_network/src/client/connect_client.dart';
import 'package:flutter_network/src/services/connectivity_service.dart';
import 'package:logging/logging.dart';

/// Represents a request that was queued while the device was offline.
class QueuedRequest {
  QueuedRequest({
    required this.request,
    required this.completer,
    required this.enqueuedAt,
  });

  /// The original ConnectRPC request.
  final ConnectRequest request;

  /// Completer that resolves when the request is eventually executed.
  final Completer<ConnectRequest> completer;

  /// When the request was queued.
  final DateTime enqueuedAt;
}

/// Interceptor that checks network connectivity before allowing requests
/// to proceed. When the device is offline, requests are queued and
/// automatically dispatched once connectivity is restored.
///
/// Usage:
/// ```dart
/// final connectivity = ConnectivityInterceptor(
///   connectivityService: connectivityService,
/// );
/// client.addRequestInterceptor(connectivity.interceptRequest);
/// ```
class ConnectivityInterceptor {
  ConnectivityInterceptor({
    required this.connectivityService,
    this.offlineTimeout = const Duration(minutes: 5),
  }) {
    _connectivitySubscription =
        connectivityService.onConnectivityChanged.listen(_onConnectivityChange);
  }

  /// The connectivity service used to check network status.
  final ConnectivityService connectivityService;

  /// Maximum time a request can sit in the offline queue before being
  /// rejected with a timeout error.
  final Duration offlineTimeout;

  static final _log = Logger('ConnectivityInterceptor');

  /// The offline request queue. Requests are processed FIFO when
  /// connectivity is restored.
  final Queue<QueuedRequest> _offlineQueue = Queue<QueuedRequest>();

  late final StreamSubscription<ConnectivityStatus> _connectivitySubscription;

  /// The number of requests currently waiting in the offline queue.
  int get queueLength => _offlineQueue.length;

  /// Checks connectivity before allowing the request through.
  ///
  /// If the device is online, the request passes through immediately.
  /// If offline, the request is queued and the returned [Future] completes
  /// when connectivity is restored and the request is dequeued.
  ///
  /// Throws [ConnectException] if the request remains queued longer than
  /// [offlineTimeout].
  Future<ConnectRequest> interceptRequest(ConnectRequest request) async {
    final isConnected = await connectivityService.isConnected;

    if (isConnected) {
      return request;
    }

    _log.info('Device is offline — queuing request: ${request.path}');

    final completer = Completer<ConnectRequest>();
    final queued = QueuedRequest(
      request: request,
      completer: completer,
      enqueuedAt: DateTime.now(),
    );

    _offlineQueue.add(queued);

    // Set a timeout so requests don't wait forever.
    return completer.future.timeout(
      offlineTimeout,
      onTimeout: () {
        _offlineQueue.remove(queued);
        throw const ConnectException(
          code: 'unavailable',
          message: 'Request timed out while waiting for network connectivity',
        );
      },
    );
  }

  /// Drains the offline queue, completing each queued request's completer
  /// so the interceptor chain can continue.
  Future<void> _drainQueue() async {
    _log.info('Connectivity restored — draining ${_offlineQueue.length} '
        'queued requests');

    while (_offlineQueue.isNotEmpty) {
      final queued = _offlineQueue.removeFirst();

      // Drop requests that have been queued too long.
      final age = DateTime.now().difference(queued.enqueuedAt);
      if (age > offlineTimeout) {
        if (!queued.completer.isCompleted) {
          queued.completer.completeError(
            const ConnectException(
              code: 'deadline_exceeded',
              message: 'Queued request expired while offline',
            ),
          );
        }
        continue;
      }

      if (!queued.completer.isCompleted) {
        queued.completer.complete(queued.request);
      }
    }
  }

  void _onConnectivityChange(ConnectivityStatus status) {
    if (status == ConnectivityStatus.online && _offlineQueue.isNotEmpty) {
      _drainQueue();
    }
  }

  /// Releases resources. Call this when the interceptor is no longer needed.
  void dispose() {
    _connectivitySubscription.cancel();

    // Fail any remaining queued requests.
    for (final queued in _offlineQueue) {
      if (!queued.completer.isCompleted) {
        queued.completer.completeError(
          const ConnectException(
            code: 'cancelled',
            message: 'Connectivity interceptor disposed',
          ),
        );
      }
    }
    _offlineQueue.clear();
  }
}
