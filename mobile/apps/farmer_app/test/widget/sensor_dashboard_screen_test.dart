import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/sensors/domain/entities/sensor_entity.dart';
import 'package:farmer_app/features/sensors/presentation/bloc/sensor_bloc.dart';
import 'package:farmer_app/features/sensors/presentation/bloc/sensor_event.dart';
import 'package:farmer_app/features/sensors/presentation/bloc/sensor_state.dart';
import 'package:farmer_app/features/sensors/presentation/screens/sensor_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSensorBloc extends MockBloc<SensorEvent, SensorState>
    implements SensorBloc {}

void main() {
  late MockSensorBloc mockSensorBloc;

  const testLocation = SensorLocation(
    latitude: -1.286,
    longitude: 36.817,
    fieldId: 'field-1',
    fieldName: 'North Field',
  );

  const testSensors = [
    Sensor(
      id: 'sensor-1',
      name: 'Temp Sensor A',
      type: SensorType.temperature,
      location: testLocation,
      status: SensorStatus.online,
      lastReading: 28.5,
      batteryLevel: 85,
    ),
    Sensor(
      id: 'sensor-2',
      name: 'Humidity Sensor B',
      type: SensorType.humidity,
      location: testLocation,
      status: SensorStatus.online,
      lastReading: 65.0,
      batteryLevel: 42,
    ),
    Sensor(
      id: 'sensor-3',
      name: 'Moisture Sensor C',
      type: SensorType.soilMoisture,
      location: testLocation,
      status: SensorStatus.offline,
      lastReading: 30.0,
      batteryLevel: 10,
    ),
  ];

  setUp(() {
    mockSensorBloc = MockSensorBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<SensorBloc>.value(
        value: mockSensorBloc,
        child: const SensorDashboardScreen(),
      ),
    );
  }

  group('SensorDashboardScreen', () {
    testWidgets('displays sensor grid when sensors loaded', (tester) async {
      when(() => mockSensorBloc.state)
          .thenReturn(const SensorsLoaded(sensors: testSensors));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Temp Sensor A'), findsOneWidget);
      expect(find.text('Humidity Sensor B'), findsOneWidget);
      expect(find.text('Moisture Sensor C'), findsOneWidget);
    });

    testWidgets('displays sensor readings values', (tester) async {
      when(() => mockSensorBloc.state)
          .thenReturn(const SensorsLoaded(sensors: testSensors));

      await tester.pumpWidget(buildSubject());

      expect(find.text('28.5'), findsOneWidget);
      expect(find.text('65.0'), findsOneWidget);
      expect(find.text('30.0'), findsOneWidget);
    });

    testWidgets('displays loading indicator when loading', (tester) async {
      when(() => mockSensorBloc.state)
          .thenReturn(const SensorLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays summary bar with correct counts', (tester) async {
      when(() => mockSensorBloc.state)
          .thenReturn(const SensorsLoaded(sensors: testSensors));

      await tester.pumpWidget(buildSubject());

      // Summary bar shows total, online, offline, low battery counts
      expect(find.text('3'), findsOneWidget); // Total
      expect(find.text('2'), findsOneWidget); // Online
      expect(find.text('1'), findsAtLeastNWidgets(1)); // Offline or Low Batt
    });

    testWidgets('displays "Sensor Monitoring" in app bar', (tester) async {
      when(() => mockSensorBloc.state)
          .thenReturn(const SensorsLoaded(sensors: testSensors));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Sensor Monitoring'), findsOneWidget);
    });

    testWidgets('displays error view with retry button', (tester) async {
      when(() => mockSensorBloc.state)
          .thenReturn(const SensorError(message: 'Connection lost'));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Failed to load sensors'), findsOneWidget);
      expect(find.text('Connection lost'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button dispatches LoadSensors event', (tester) async {
      when(() => mockSensorBloc.state)
          .thenReturn(const SensorError(message: 'Error'));

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockSensorBloc.add(const LoadSensors())).called(1);
    });

    testWidgets('displays empty state when no sensors', (tester) async {
      when(() => mockSensorBloc.state)
          .thenReturn(const SensorsLoaded(sensors: []));

      await tester.pumpWidget(buildSubject());

      expect(find.text('No sensors found'), findsOneWidget);
    });

    testWidgets('displays filter chips for sensor types', (tester) async {
      when(() => mockSensorBloc.state)
          .thenReturn(const SensorsLoaded(sensors: testSensors));

      await tester.pumpWidget(buildSubject());

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Temp'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Moisture'), findsOneWidget);
    });

    testWidgets('displays GridView for sensor cards', (tester) async {
      when(() => mockSensorBloc.state)
          .thenReturn(const SensorsLoaded(sensors: testSensors));

      await tester.pumpWidget(buildSubject());

      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
