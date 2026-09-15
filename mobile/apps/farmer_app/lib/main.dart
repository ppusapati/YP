import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'app/app.dart';
import 'core/di/providers.dart';
import 'features/farm/data/datasources/farm_local_datasource.dart';
import 'features/ai_diagnosis/data/datasources/diagnosis_local_datasource.dart';
import 'features/satellite/data/datasources/satellite_local_datasource.dart';

/// Background task dispatcher for WorkManager.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'syncData':
        // Perform background data synchronization.
        Logger('BackgroundSync').info('Executing background sync task');
        return true;
      case 'uploadPendingPhotos':
        Logger('BackgroundSync').info('Uploading pending photos');
        return true;
      default:
        return true;
    }
  });
}

/// Background notification response handler.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  Logger('Notifications').info('Background notification tapped: ${response.id}');
}

Future<void> main() => bootstrap();

/// Starts the app.
///
/// Split out of `main` so an integration test can start the real app without
/// the parts of startup that need a shipped device: WorkManager will not
/// register a periodic task under `flutter test`, notification permission
/// prompts block, and the on-disk databases carry state between runs. Each is
/// switchable, and every default is the production one — a test that turns a
/// piece off is saying so out loud, and nothing is silently different in the
/// build that ships.
///
/// [databases] defaults to opening the real SQLite files; a test passes
/// in-memory ones so runs cannot contaminate each other.
Future<void> bootstrap({
  bool enableBackgroundSync = true,
  bool enableNotifications = true,
  Future<AppDatabases> Function() databases = openApplicationDatabases,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Configure logging ───────────────────────────────────────────
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    debugPrint('[${record.level.name}] ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      debugPrint('  Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrint('  Stack: ${record.stackTrace}');
    }
  });

  // ─── System UI overlay style ─────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ─── Preferred orientations ──────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ─── Initialize push notifications (direct APNs) ─────────────────
  if (enableNotifications) {
    await _initNotifications();
  }

  // ─── Initialize SharedPreferences ────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();

  // ─── Initialize WorkManager ──────────────────────────────────────
  if (enableBackgroundSync) {
    await _initBackgroundSync();
  }

  // ─── Log environment ─────────────────────────────────────────────
  Logger('App').info(
    'API target: '
    '${const bool.fromEnvironment('API_USE_TLS', defaultValue: true) ? "https" : "http"}://'
    '${const String.fromEnvironment('API_BASE_URL', defaultValue: 'api.yieldpoint.io')}'
    ':${const int.fromEnvironment('API_PORT', defaultValue: 443)}',
  );

  final dbs = await databases();

  // ─── Run app ─────────────────────────────────────────────────────
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        farmDatabaseProvider.overrideWithValue(dbs.farm),
        diagnosisDatabaseProvider.overrideWithValue(dbs.diagnosis),
        satelliteDatabaseProvider.overrideWithValue(dbs.satellite),
      ],
      child: const FarmerApp(),
    ),
  );
}

/// The three Drift databases the app runs on.
class AppDatabases {
  const AppDatabases({
    required this.farm,
    required this.diagnosis,
    required this.satellite,
  });

  final FarmDatabase farm;
  final DiagnosisDatabase diagnosis;
  final SatelliteDatabase satellite;
}

/// Opens the on-disk databases in the application documents directory.
Future<AppDatabases> openApplicationDatabases() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return AppDatabases(
    farm: FarmDatabase(
      NativeDatabase.createInBackground(
        File(p.join(dbFolder.path, 'farm.sqlite')),
      ),
    ),
    diagnosis: DiagnosisDatabase(
      NativeDatabase.createInBackground(
        File(p.join(dbFolder.path, 'diagnosis.sqlite')),
      ),
    ),
    satellite: SatelliteDatabase(
      NativeDatabase.createInBackground(
        File(p.join(dbFolder.path, 'satellite.sqlite')),
      ),
    ),
  );
}

Future<void> _initNotifications() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(
    iOS: initializationSettingsIOS,
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  // Request notification permissions on iOS.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);
}

Future<void> _initBackgroundSync() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Register periodic background sync task.
  await Workmanager().registerPeriodicTask(
    'syncData',
    'syncData',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
}
