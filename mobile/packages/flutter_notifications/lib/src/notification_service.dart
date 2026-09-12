import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

/// Supported notification topics for the YieldPoint platform.
abstract final class NotificationTopics {
  /// Pest detection or scouting alerts.
  static const String pestAlert = 'pest_alert';

  /// Scheduled irrigation reminders.
  static const String irrigationReminder = 'irrigation_reminder';

  /// Severe or adverse weather warnings.
  static const String weatherWarning = 'weather_warning';

  /// A task has been assigned to the current user.
  static const String taskAssigned = 'task_assigned';

  /// All available topics.
  static const List<String> all = [
    pestAlert,
    irrigationReminder,
    weatherWarning,
    taskAssigned,
  ];
}

/// Represents a decoded push notification payload.
class NotificationPayload {
  const NotificationPayload({
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
  });

  /// The notification type / topic (e.g., [NotificationTopics.pestAlert]).
  final String type;

  /// The display title.
  final String title;

  /// The display body text.
  final String body;

  /// Additional key-value data attached to the notification.
  final Map<String, dynamic> data;

  /// Constructs a [NotificationPayload] from a raw notification data map.
  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      type: map['type'] as String? ?? 'unknown',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'title': title,
        'body': body,
        'data': data,
      };

  @override
  String toString() => 'NotificationPayload(type: $type, title: $title)';
}

/// Service for managing push notifications in the YieldPoint app.
///
/// Handles initialisation of the local notification plugin, permission
/// requests, foreground message display, and notification tap routing.
///
/// Usage:
/// ```dart
/// final service = NotificationService();
/// await service.initialize();
/// final granted = await service.requestPermission();
///
/// service.onMessage.listen((payload) {
///   print('Foreground notification: ${payload.title}');
/// });
///
/// service.onMessageOpenedApp.listen((payload) {
///   print('User tapped: ${payload.title}');
///   // Navigate to the relevant screen
/// });
///
/// await service.subscribeToTopic(NotificationTopics.pestAlert);
/// ```
class NotificationService {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  static final _log = Logger('NotificationService');

  final StreamController<NotificationPayload> _onMessageController =
      StreamController<NotificationPayload>.broadcast();
  final StreamController<NotificationPayload> _onMessageOpenedController =
      StreamController<NotificationPayload>.broadcast();

  final Set<String> _subscribedTopics = {};

  bool _isInitialized = false;

  /// Stream of notifications received while the app is in the foreground.
  Stream<NotificationPayload> get onMessage => _onMessageController.stream;

  /// Stream of notifications that the user tapped to open the app.
  Stream<NotificationPayload> get onMessageOpenedApp =>
      _onMessageOpenedController.stream;

  /// The set of topics the user is currently subscribed to.
  Set<String> get subscribedTopics => Set.unmodifiable(_subscribedTopics);

  /// Whether the service has been initialised.
  bool get isInitialized => _isInitialized;

  /// Initialises the notification service.
  ///
  /// Sets up the local notifications plugin with platform-specific
  /// settings and registers callback handlers.
  Future<void> initialize() async {
    if (_isInitialized) {
      _log.warning('NotificationService already initialized');
      return;
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    _log.info('NotificationService initialized');
  }

  /// Requests notification permissions from the user.
  ///
  /// Returns `true` if permission was granted, `false` otherwise.
  Future<bool> requestPermission() async {
    _assertInitialized();

    // Request Android 13+ permissions.
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      _log.info('Android notification permission: $granted');
      return granted ?? false;
    }

    // Request iOS permissions.
    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      _log.info('iOS notification permission: $granted');
      return granted ?? false;
    }

    return false;
  }

  /// Displays a local notification in the foreground.
  ///
  /// Call this when a push message arrives while the app is active.
  Future<void> showNotification(NotificationPayload payload) async {
    _assertInitialized();

    final androidDetails = AndroidNotificationDetails(
      _channelIdForType(payload.type),
      _channelNameForType(payload.type),
      channelDescription: 'YieldPoint ${payload.type} notifications',
      importance: _importanceForType(payload.type),
      priority: _priorityForType(payload.type),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      payload.hashCode,
      payload.title,
      payload.body,
      details,
      payload: payload.type,
    );

    _onMessageController.add(payload);
    _log.fine('Showed notification: ${payload.type} — ${payload.title}');
  }

  /// Subscribes to a notification topic.
  ///
  /// Supported topics are defined in [NotificationTopics].
  Future<void> subscribeToTopic(String topic) async {
    if (!NotificationTopics.all.contains(topic)) {
      _log.warning('Unknown topic: $topic');
      return;
    }

    _subscribedTopics.add(topic);
    _log.info('Subscribed to topic: $topic');

    // In a full implementation this would register with the push
    // notification backend (e.g., APNs topic registration or a
    // custom server endpoint).
  }

  /// Unsubscribes from a notification topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    _subscribedTopics.remove(topic);
    _log.info('Unsubscribed from topic: $topic');

    // In a full implementation this would deregister with the push
    // notification backend.
  }

  /// Cancels all displayed notifications.
  Future<void> cancelAll() async {
    _assertInitialized();
    await _plugin.cancelAll();
    _log.fine('All notifications cancelled');
  }

  /// Releases resources.
  void dispose() {
    _onMessageController.close();
    _onMessageOpenedController.close();
    _log.fine('NotificationService disposed');
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _onNotificationTapped(NotificationResponse response) {
    _log.fine('Notification tapped: ${response.payload}');

    final payload = NotificationPayload(
      type: response.payload ?? 'unknown',
      title: '',
      body: '',
    );

    _onMessageOpenedController.add(payload);
  }

  void _assertInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'NotificationService has not been initialized. '
        'Call initialize() first.',
      );
    }
  }

  String _channelIdForType(String type) => 'yp_$type';

  String _channelNameForType(String type) {
    switch (type) {
      case NotificationTopics.pestAlert:
        return 'Pest Alerts';
      case NotificationTopics.irrigationReminder:
        return 'Irrigation Reminders';
      case NotificationTopics.weatherWarning:
        return 'Weather Warnings';
      case NotificationTopics.taskAssigned:
        return 'Task Assignments';
      default:
        return 'YieldPoint';
    }
  }

  Importance _importanceForType(String type) {
    switch (type) {
      case NotificationTopics.pestAlert:
      case NotificationTopics.weatherWarning:
        return Importance.high;
      case NotificationTopics.taskAssigned:
        return Importance.defaultImportance;
      case NotificationTopics.irrigationReminder:
        return Importance.low;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _priorityForType(String type) {
    switch (type) {
      case NotificationTopics.pestAlert:
      case NotificationTopics.weatherWarning:
        return Priority.high;
      default:
        return Priority.defaultPriority;
    }
  }
}
