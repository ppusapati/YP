import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';

/// Represents the current connectivity state of the device.
enum ConnectivityState {
  /// The device is connected to the internet.
  online,

  /// The device has no internet connection.
  offline,

  /// The connectivity state is unknown (e.g., during initialisation).
  unknown,
}

/// Monitors network connectivity and emits state changes.
///
/// Wraps [connectivity_plus] to provide a simplified, application-level
/// view of online/offline status with automatic reconnection detection.
///
/// Usage:
/// ```dart
/// final monitor = ConnectivityMonitor();
/// await monitor.initialize();
///
/// monitor.stateStream.listen((state) {
///   if (state == ConnectivityState.online) {
///     syncManager.onConnectivityRestored();
///   } else if (state == ConnectivityState.offline) {
///     syncManager.onConnectivityLost();
///   }
/// });
///
/// // Clean up when done
/// monitor.dispose();
/// ```
class ConnectivityMonitor {
  ConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  static final _log = Logger('ConnectivityMonitor');

  final StreamController<ConnectivityState> _stateController =
      StreamController<ConnectivityState>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectivityState _currentState = ConnectivityState.unknown;

  /// Stream of connectivity state changes.
  ///
  /// Only emits when the state actually changes (deduplicates).
  Stream<ConnectivityState> get stateStream => _stateController.stream;

  /// The current connectivity state.
  ConnectivityState get currentState => _currentState;

  /// Whether the device currently has a network connection.
  bool get isOnline => _currentState == ConnectivityState.online;

  /// Whether the device is currently offline.
  bool get isOffline => _currentState == ConnectivityState.offline;

  /// Initialises the monitor and begins listening for connectivity changes.
  ///
  /// Checks the current connectivity state immediately and then subscribes
  /// to ongoing changes.
  Future<void> initialize() async {
    // Check initial connectivity state.
    try {
      final results = await _connectivity.checkConnectivity();
      _updateState(_mapResults(results));
      _log.info('Initial connectivity state: $_currentState');
    } on Exception catch (e) {
      _log.warning('Failed to check initial connectivity: $e');
      _updateState(ConnectivityState.unknown);
    }

    // Subscribe to connectivity changes.
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final newState = _mapResults(results);
        _log.fine('Connectivity changed: $newState (raw: $results)');
        _updateState(newState);
      },
      onError: (Object error) {
        _log.warning('Connectivity stream error: $error');
        _updateState(ConnectivityState.unknown);
      },
    );
  }

  /// Forces a re-check of the current connectivity state.
  ///
  /// Useful for verifying connectivity after a sync failure.
  Future<ConnectivityState> checkNow() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final state = _mapResults(results);
      _updateState(state);
      return state;
    } on Exception catch (e) {
      _log.warning('Connectivity check failed: $e');
      return _currentState;
    }
  }

  /// Releases resources and stops listening for connectivity changes.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _stateController.close();
    _log.fine('ConnectivityMonitor disposed');
  }

  /// Maps a list of [ConnectivityResult] values to a [ConnectivityState].
  ///
  /// The device is considered online if any result indicates a connection
  /// (wifi, mobile, ethernet, vpn). It is offline only when the sole
  /// result is [ConnectivityResult.none].
  ConnectivityState _mapResults(List<ConnectivityResult> results) {
    if (results.isEmpty) return ConnectivityState.unknown;

    final hasConnection = results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);

    if (hasConnection) return ConnectivityState.online;

    if (results.contains(ConnectivityResult.none)) {
      return ConnectivityState.offline;
    }

    return ConnectivityState.unknown;
  }

  /// Updates the state and emits to the stream only when it changes.
  void _updateState(ConnectivityState newState) {
    if (newState == _currentState) return;

    final previousState = _currentState;
    _currentState = newState;

    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }

    _log.info('Connectivity: $previousState -> $newState');
  }
}
