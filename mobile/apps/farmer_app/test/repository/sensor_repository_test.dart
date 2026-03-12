import 'package:farmer_app/features/sensors/data/datasources/sensor_local_datasource.dart';
import 'package:farmer_app/features/sensors/data/datasources/sensor_remote_datasource.dart';
import 'package:farmer_app/features/sensors/data/models/sensor_model.dart';
import 'package:farmer_app/features/sensors/data/models/sensor_reading_model.dart';
import 'package:farmer_app/features/sensors/data/repositories/sensor_repository_impl.dart';
import 'package:farmer_app/features/sensors/domain/entities/sensor_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSensorRemoteDataSource extends Mock
    implements SensorRemoteDataSource {}

class MockSensorLocalDataSource extends Mock implements SensorLocalDataSource {}

void main() {
  late MockSensorRemoteDataSource mockRemote;
  late MockSensorLocalDataSource mockLocal;
  late SensorRepositoryImpl repository;

  const testLocation = SensorLocationModel(
    latitude: -1.286,
    longitude: 36.817,
    fieldId: 'field-1',
    fieldName: 'North Field',
  );

  const testSensor1 = SensorModel(
    id: 'sensor-1',
    name: 'Temp Sensor A',
    type: SensorType.temperature,
    location: testLocation,
    status: SensorStatus.online,
    lastReading: 28.5,
    batteryLevel: 85,
  );

  const testSensor2 = SensorModel(
    id: 'sensor-2',
    name: 'Humidity Sensor B',
    type: SensorType.humidity,
    location: testLocation,
    status: SensorStatus.online,
    lastReading: 65.0,
    batteryLevel: 42,
  );

  final testReadings = [
    SensorReadingModel(
      sensorId: 'sensor-1',
      type: SensorType.temperature,
      value: 27.5,
      unit: '\u00B0C',
      timestamp: DateTime(2024, 6, 15, 10, 0),
    ),
    SensorReadingModel(
      sensorId: 'sensor-1',
      type: SensorType.temperature,
      value: 29.0,
      unit: '\u00B0C',
      timestamp: DateTime(2024, 6, 15, 11, 0),
    ),
  ];

  setUp(() {
    mockRemote = MockSensorRemoteDataSource();
    mockLocal = MockSensorLocalDataSource();
    repository = SensorRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  setUpAll(() {
    registerFallbackValue(<SensorModel>[]);
    registerFallbackValue(<SensorReadingModel>[]);
  });

  group('SensorRepositoryImpl', () {
    group('getSensors', () {
      test('returns sensors from remote and caches them', () async {
        when(() => mockRemote.getSensors())
            .thenAnswer((_) async => [testSensor1, testSensor2]);
        when(() => mockLocal.cacheSensors(any()))
            .thenAnswer((_) async {});

        final result = await repository.getSensors();

        expect(result.length, 2);
        expect(result[0].id, 'sensor-1');
        expect(result[1].id, 'sensor-2');
        verify(() => mockRemote.getSensors()).called(1);
        verify(() => mockLocal.cacheSensors(any())).called(1);
      });

      test('returns cached sensors when remote fails', () async {
        when(() => mockRemote.getSensors())
            .thenThrow(Exception('Network error'));
        when(() => mockLocal.getCachedSensors())
            .thenAnswer((_) async => [testSensor1]);

        final result = await repository.getSensors();

        expect(result.length, 1);
        expect(result[0].id, 'sensor-1');
        verify(() => mockLocal.getCachedSensors()).called(1);
      });

      test('returns empty list when both remote and cache are empty', () async {
        when(() => mockRemote.getSensors())
            .thenThrow(Exception('Network error'));
        when(() => mockLocal.getCachedSensors())
            .thenAnswer((_) async => []);

        final result = await repository.getSensors();

        expect(result, isEmpty);
      });
    });

    group('getSensorsByType', () {
      test('returns filtered sensors from remote', () async {
        when(() => mockRemote.getSensorsByType('temperature'))
            .thenAnswer((_) async => [testSensor1]);

        final result =
            await repository.getSensorsByType(SensorType.temperature);

        expect(result.length, 1);
        expect(result[0].type, SensorType.temperature);
      });

      test('falls back to cached filtered sensors on remote failure', () async {
        when(() => mockRemote.getSensorsByType('humidity'))
            .thenThrow(Exception('Error'));
        when(() => mockLocal.getCachedSensors())
            .thenAnswer((_) async => [testSensor1, testSensor2]);

        final result =
            await repository.getSensorsByType(SensorType.humidity);

        expect(result.length, 1);
        expect(result[0].type, SensorType.humidity);
      });
    });

    group('getSensorReadings', () {
      test('fetches readings from remote and caches them', () async {
        when(() => mockRemote.getSensorReadings(
              'sensor-1',
              from: null,
              to: null,
            )).thenAnswer((_) async => testReadings);
        when(() => mockLocal.cacheReadings('sensor-1', any()))
            .thenAnswer((_) async {});

        final result = await repository.getSensorReadings('sensor-1');

        expect(result.length, 2);
        expect(result[0].value, 27.5);
        verify(() => mockLocal.cacheReadings('sensor-1', any())).called(1);
      });

      test('fetches readings with date range', () async {
        final from = DateTime(2024, 6, 15);
        final to = DateTime(2024, 6, 16);
        when(() => mockRemote.getSensorReadings(
              'sensor-1',
              from: from,
              to: to,
            )).thenAnswer((_) async => testReadings);
        when(() => mockLocal.cacheReadings('sensor-1', any()))
            .thenAnswer((_) async {});

        final result = await repository.getSensorReadings(
          'sensor-1',
          from: from,
          to: to,
        );

        expect(result.length, 2);
        verify(() => mockRemote.getSensorReadings(
              'sensor-1',
              from: from,
              to: to,
            )).called(1);
      });

      test('returns cached readings when remote fails', () async {
        when(() => mockRemote.getSensorReadings(
              'sensor-1',
              from: null,
              to: null,
            )).thenThrow(Exception('Error'));
        when(() => mockLocal.getCachedReadings('sensor-1'))
            .thenAnswer((_) async => testReadings);

        final result = await repository.getSensorReadings('sensor-1');

        expect(result.length, 2);
        verify(() => mockLocal.getCachedReadings('sensor-1')).called(1);
      });
    });

    group('getSensorById', () {
      test('returns sensor from remote', () async {
        when(() => mockRemote.getSensorById('sensor-1'))
            .thenAnswer((_) async => testSensor1);

        final result = await repository.getSensorById('sensor-1');

        expect(result.id, 'sensor-1');
        expect(result.name, 'Temp Sensor A');
      });

      test('returns cached sensor when remote fails', () async {
        when(() => mockRemote.getSensorById('sensor-1'))
            .thenThrow(Exception('Error'));
        when(() => mockLocal.getCachedSensors())
            .thenAnswer((_) async => [testSensor1, testSensor2]);

        final result = await repository.getSensorById('sensor-1');

        expect(result.id, 'sensor-1');
      });

      test('throws when sensor not found in cache', () async {
        when(() => mockRemote.getSensorById('sensor-999'))
            .thenThrow(Exception('Error'));
        when(() => mockLocal.getCachedSensors())
            .thenAnswer((_) async => [testSensor1]);

        expect(
          () => repository.getSensorById('sensor-999'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getSensorDashboard', () {
      test('returns dashboard from remote', () async {
        when(() => mockRemote.getSensorDashboard())
            .thenAnswer((_) async => {'sensor-1': testSensor1});

        final result = await repository.getSensorDashboard();

        expect(result.length, 1);
        expect(result['sensor-1']?.name, 'Temp Sensor A');
      });

      test('falls back to cached dashboard on remote failure', () async {
        when(() => mockRemote.getSensorDashboard())
            .thenThrow(Exception('Error'));
        when(() => mockLocal.getCachedSensors())
            .thenAnswer((_) async => [testSensor1, testSensor2]);

        final result = await repository.getSensorDashboard();

        expect(result.length, 2);
        expect(result.containsKey('sensor-1'), true);
        expect(result.containsKey('sensor-2'), true);
      });
    });
  });
}
