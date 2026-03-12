import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';

/// Simplified connectivity status.
enum ConnectivityStatus {
  /// The device has an active network connection.
  online,

  /// The device has no network connection.
  offline,
}

/// Service that monitors network connectivity using `connectivity_plus`.
///
/// Provides both a synchronous check ([isConnected]) and a stream of
/// status changes ([onConnectivityChanged]).
///
/// Usage:
/// ```dart
/// final service = ConnectivityService();
/// await service.initialize();
///
/// if (await service.isConnected) {
///   // proceed with network call
/// }
///
/// service.onConnectivityChanged.listen((status) {
///   print('Connectivity: $status');
/// });
/// ```
class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  static final _log = Logger('ConnectivityService');

  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectivityStatus _currentStatus = ConnectivityStatus.online;

  /// Stream of connectivity status changes.
  Stream<ConnectivityStatus> get onConnectivityChanged =>
      _statusController.stream;

  /// The most recently observed connectivity status.
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Whether the device currently has network connectivity.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    final status = _mapResults(results);
    _updateStatus(status);
    return status == ConnectivityStatus.online;
  }

  /// Initialises the service and begins listening for connectivity changes.
  ///
  /// Must be called before accessing [onConnectivityChanged].
  Future<void> initialize() async {
    // Check initial status.
    final results = await _connectivity.checkConnectivity();
    _currentStatus = _mapResults(results);
    _log.info('Initial connectivity: $_currentStatus');

    // Listen for changes.
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final status = _mapResults(results);
        _updateStatus(status);
      },
      onError: (Object error) {
        _log.warning('Connectivity stream error: $error');
        _updateStatus(ConnectivityStatus.offline);
      },
    );
  }

  /// Releases resources. Call when the service is no longer needed.
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _statusController.close();
  }

  void _updateStatus(ConnectivityStatus status) {
    if (status != _currentStatus) {
      _currentStatus = status;
      _statusController.add(status);
      _log.info('Connectivity changed: $_currentStatus');
    }
  }

  ConnectivityStatus _mapResults(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }
}
