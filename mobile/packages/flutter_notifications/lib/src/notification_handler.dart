import 'dart:async';

import 'package:logging/logging.dart';

import 'notification_service.dart';

/// Callback invoked when a notification should navigate to a specific screen.
///
/// Receives the route path and any arguments extracted from the payload.
typedef NavigationCallback = void Function(
    String route, Map<String, dynamic> arguments);

/// Routes notification payloads to the appropriate screens and actions.
///
/// Listens to [NotificationService] message streams and maps each
/// notification type to a screen route, allowing the app to navigate
/// the user to the correct destination when a notification is tapped.
///
/// Usage:
/// ```dart
/// final handler = NotificationHandler(
///   notificationService: notificationService,
///   onNavigate: (route, args) {
///     router.push(route, extra: args);
///   },
/// );
///
/// handler.initialize();
///
/// // Don't forget to dispose when done
/// handler.dispose();
/// ```
class NotificationHandler {
  NotificationHandler({
    required NotificationService notificationService,
    required this.onNavigate,
  }) : _notificationService = notificationService;

  final NotificationService _notificationService;

  /// Called when a notification tap should trigger navigation.
  final NavigationCallback onNavigate;

  static final _log = Logger('NotificationHandler');

  StreamSubscription<NotificationPayload>? _foregroundSubscription;
  StreamSubscription<NotificationPayload>? _tapSubscription;

  /// Starts listening for notification events.
  void initialize() {
    // Handle foreground messages (log only; the notification is already
    // displayed by [NotificationService.showNotification]).
    _foregroundSubscription = _notificationService.onMessage.listen(
      _handleForegroundMessage,
      onError: (Object error) {
        _log.warning('Foreground message stream error: $error');
      },
    );

    // Handle notification taps — route to the appropriate screen.
    _tapSubscription = _notificationService.onMessageOpenedApp.listen(
      _handleNotificationTap,
      onError: (Object error) {
        _log.warning('Notification tap stream error: $error');
      },
    );

    _log.info('NotificationHandler initialized');
  }

  /// Stops listening and releases resources.
  void dispose() {
    _foregroundSubscription?.cancel();
    _tapSubscription?.cancel();
    _foregroundSubscription = null;
    _tapSubscription = null;
    _log.fine('NotificationHandler disposed');
  }

  // ---------------------------------------------------------------------------
  // Routing logic
  // ---------------------------------------------------------------------------

  void _handleForegroundMessage(NotificationPayload payload) {
    _log.fine('Foreground message received: ${payload.type}');
    // Foreground messages are already displayed by NotificationService.
    // Additional in-app UI (banners, badges) can be triggered here.
  }

  void _handleNotificationTap(NotificationPayload payload) {
    _log.info('Notification tapped: ${payload.type}');

    final route = _routeForType(payload.type, payload.data);
    if (route != null) {
      onNavigate(route.path, route.arguments);
    } else {
      _log.warning('No route defined for notification type: ${payload.type}');
    }
  }

  /// Maps a notification type to a screen route.
  ///
  /// Returns `null` if no route is configured for the given type.
  _NotificationRoute? _routeForType(
      String type, Map<String, dynamic> data) {
    switch (type) {
      case NotificationTopics.pestAlert:
        return _NotificationRoute(
          path: '/alerts/pest',
          arguments: {
            'alertId': data['alert_id'],
            'fieldId': data['field_id'],
          },
        );

      case NotificationTopics.irrigationReminder:
        return _NotificationRoute(
          path: '/irrigation/schedule',
          arguments: {
            'fieldId': data['field_id'],
            'scheduleId': data['schedule_id'],
          },
        );

      case NotificationTopics.weatherWarning:
        return _NotificationRoute(
          path: '/weather/warning',
          arguments: {
            'warningId': data['warning_id'],
            'farmId': data['farm_id'],
          },
        );

      case NotificationTopics.taskAssigned:
        return _NotificationRoute(
          path: '/tasks/detail',
          arguments: {
            'taskId': data['task_id'],
            'farmId': data['farm_id'],
          },
        );

      default:
        return null;
    }
  }
}

/// Internal route descriptor for notification-driven navigation.
class _NotificationRoute {
  const _NotificationRoute({
    required this.path,
    this.arguments = const {},
  });

  /// The route path (e.g., `/alerts/pest`).
  final String path;

  /// Arguments to pass to the destination screen.
  final Map<String, dynamic> arguments;
}
