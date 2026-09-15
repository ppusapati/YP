import 'package:drift/native.dart';
import 'package:farmer_app/features/ai_diagnosis/data/datasources/diagnosis_local_datasource.dart';
import 'package:farmer_app/features/farm/data/datasources/farm_local_datasource.dart';
import 'package:farmer_app/features/satellite/data/datasources/satellite_local_datasource.dart';
import 'package:farmer_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Does the real app start?
///
/// Nothing else in the suite answers this. Widget tests build one screen with
/// its bloc handed to them; the thing that breaks in production is the wiring
/// underneath — twenty-five blocs resolved out of a Riverpod graph, three
/// Drift schemas opened and migrated, a router with sixty routes. A provider
/// that throws at read time, a migration that fails on a fresh install, a bloc
/// whose dependency was renamed: each of those passes every unit test in the
/// repository and gives a white screen on a real phone.
///
/// Run on a device or emulator:
///   flutter test integration_test/app_boot_test.dart
///
/// These do not run under `flutter test` on its own: they need a real binding,
/// which is what `integration_test` provides and what the CI mobile job has to
/// give them an emulator for.

/// In-memory databases, so a run cannot inherit state from the one before it
/// or leave any behind. The schemas are the real ones — a migration that
/// fails on a fresh install fails here too.
Future<app.AppDatabases> _memoryDatabases() async {
  return app.AppDatabases(
    farm: FarmDatabase(NativeDatabase.memory()),
    diagnosis: DiagnosisDatabase(NativeDatabase.memory()),
    satellite: SatelliteDatabase(NativeDatabase.memory()),
  );
}

Future<void> _startApp(WidgetTester tester) async {
  // A clean slate: the app reads its saved session and settings from here, and
  // whatever the last test left would otherwise decide which screen opens.
  SharedPreferences.setMockInitialValues({});

  await app.bootstrap(
    // WorkManager cannot register a periodic task in a test harness, and the
    // notification prompt blocks waiting for a tap nobody will give it.
    enableBackgroundSync: false,
    enableNotifications: false,
    databases: _memoryDatabases,
  );

  await tester.pumpAndSettle(const Duration(seconds: 10));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('app boot', () {
    testWidgets('starts and renders a first screen', (tester) async {
      await _startApp(tester);

      expect(
        find.byType(MaterialApp),
        findsOneWidget,
        reason: 'the app never got as far as building its root widget',
      );
      expect(
        tester.takeException(),
        isNull,
        reason: 'startup threw; on a phone this is the white screen',
      );
    });

    testWidgets('resolves every provider the root widget reads',
        (tester) async {
      // A Riverpod provider that throws does so at first read, which is during
      // this build. Pumping the real root is the only thing that exercises all
      // of them together.
      await _startApp(tester);

      expect(find.byType(Scaffold), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders no error widget anywhere in the tree',
        (tester) async {
      // A build failure inside a subtree shows a red box rather than throwing
      // out of pumpAndSettle, so it passes the check above while being just as
      // broken.
      await _startApp(tester);

      expect(
        find.byType(ErrorWidget),
        findsNothing,
        reason: 'a subtree failed to build',
      );
    });

    testWidgets('survives a resize without throwing', (tester) async {
      // Rotation and the keyboard both do this, and an overflow in a screen
      // that only ever ran at one size is a common way a phone build differs
      // from a developer's.
      await _startApp(tester);

      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.binding.setSurfaceSize(const Size(640, 360));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
  });
}
