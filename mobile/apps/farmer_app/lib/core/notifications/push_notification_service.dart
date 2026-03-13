import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

/// Push notification service using direct APNs (no Firebase).
///
/// On iOS, the native AppDelegate receives the APNs device token and forwards
/// it to Flutter via a method channel. The backend server uses this token to
/// send pushes directly through APNs.
class PushNotificationService {
  PushNotificationService({
    required FlutterLocalNotificationsPlugin localNotifications,
  }) : _localNotifications = localNotifications;

  final FlutterLocalNotificationsPlugin _localNotifications;
  final _log = Logger('PushNotificationService');
  final _channel = const MethodChannel('com.yieldpoint/apns');

  String? _deviceToken;
  String? get deviceToken => _deviceToken;

  /// Initialize the service and listen for APNs token from native side.
  Future<void> initialize({
    required void Function(String token) onTokenReceived,
  }) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onToken') {
        _deviceToken = call.arguments as String;
        _log.info('APNs device token received');
        onTokenReceived(_deviceToken!);
      }
    });
  }

  /// Show a local notification (for alerts triggered by server push or local logic).
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const androidDetails = AndroidNotificationDetails(
      'yieldpoint_alerts',
      'YieldPoint Alerts',
      channelDescription: 'Alerts for pest risks, irrigation, and field events',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      iOS: iosDetails,
      android: androidDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Cancel a specific notification.
  Future<void> cancel(int id) => _localNotifications.cancel(id);

  /// Cancel all notifications.
  Future<void> cancelAll() => _localNotifications.cancelAll();
}
