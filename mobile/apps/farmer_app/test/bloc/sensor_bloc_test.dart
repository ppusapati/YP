import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/sensors/domain/entities/sensor_entity.dart';
import 'package:farmer_app/features/sensors/domain/entities/sensor_reading_entity.dart';
import 'package:farmer_app/features/sensors/domain/repositories/sensor_repository.dart';
import 'package:farmer_app/features/sensors/domain/usecases/get_sensor_dashboard_usecase.dart';
import 'package:farmer_app/features/sensors/domain/usecases/get_sensor_readings_usecase.dart';
import 'package:farmer_app/features/sensors/domain/usecases/get_sensors_usecase.dart';
import 'package:farmer_app/features/sensors/presentation/bloc/sensor_bloc.dart';
import 'package:farmer_app/features/sensors/presentation/bloc/sensor_event.dart';
import 'package:farmer_app/features/sensors/presentation/bloc/sensor_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSensorRepository extends Mock implements SensorRepository {}

class MockGetSensorsUseCase extends Mock implements GetSensorsUseCase {}

class MockGetSensorReadingsUseCase extends Mock
    implements GetSensorReadingsUseCase {}

class MockGetSensorDashboardUseCase extends Mock
    implements GetSensorDashboardUseCase {}

void main() {
  late MockSensorRepository mockRepository;
  late MockGetSensorsUseCase mockGetSensors;
  late MockGetSensorReadingsUseCase mockGetReadings;
  late MockGetSensorDashboardUseCase mockGetDashboard;

  const testLocation = SensorLocation(
    latitude: -1.286,
    longitude: 36.817,
    fieldId: 'field-1',
    fieldName: 'North Field',
  );

  const testSensor1 = Sensor(
    id: 'sensor-1',
    name: 'Temp Sensor A',
    type: SensorType.temperature,
    location: testLocation,
    status: SensorStatus.online,
    lastReading: 28.5,
    batteryLevel: 85,
  );

  const testSensor2 = Sensor(
    id: 'sensor-2',
    name: 'Humidity Sensor B',
    type: SensorType.humidity,
    location: testLocation,
    status: SensorStatus.online,
    lastReading: 65.0,
    batteryLevel: 42,
  );

  const testSensor3 = Sensor(
    id: 'sensor-3',
    name: 'Moisture Sensor C',
    type: SensorType.soilMoisture,
    location: testLocation,
    status: SensorStatus.offline,
    lastReading: 30.0,
    batteryLevel: 10,
  );

  final testReadings = [
    SensorReading(
      sensorId: 'sensor-1',
      type: SensorType.temperature,
      value: 27.5,
      unit: '\u00B0C',
      timestamp: DateTime(2024, 6, 15, 10, 0),
    ),
    SensorReading(
      sensorId: 'sensor-1',
      type: SensorType.temperature,
      value: 29.0,
      unit: '\u00B0C',
      timestamp: DateTime(2024, 6, 15, 11, 0),
    ),
    SensorReading(
      sensorId: 'sensor-1',
      type: SensorType.temperature,
      value: 31.2,
      unit: '\u00B0C',
      timestamp: DateTime(2024, 6, 15, 12, 0),
    ),
  ];

  setUp(() {
    mockRepository = MockSensorRepository();
    mockGetSensors = MockGetSensorsUseCase();
    mockGetReadings = MockGetSensorReadingsUseCase();
    mockGetDashboard = MockGetSensorDashboardUseCase();
  });

  SensorBloc buildBloc() => SensorBloc(
        getSensors: mockGetSensors,
        getSensorReadings: mockGetReadings,
        getSensorDashboard: mockGetDashboard,
        repository: mockRepository,
      );

  group('SensorBloc', () {
    blocTest<SensorBloc, SensorState>(
      'emits [SensorLoading, SensorsLoaded] when LoadSensors succeeds',
      build: () {
        when(() => mockGetSensors(type: null))
            .thenAnswer((_) async => [testSensor1, testSensor2, testSensor3]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadSensors()),
      expect: () => [
        const SensorLoading(),
        const SensorsLoaded(
          sensors: [testSensor1, testSensor2, testSensor3],
        ),
      ],
    );

    blocTest<SensorBloc, SensorState>(
      'emits [SensorLoading, SensorError] when LoadSensors fails',
      build: () {
        when(() => mockGetSensors(type: null))
            .thenThrow(Exception('Connection failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadSensors()),
      expect: () => [
        const SensorLoading(),
        isA<SensorError>().having(
          (e) => e.message,
          'message',
          contains('Connection failed'),
        ),
      ],
    );

    blocTest<SensorBloc, SensorState>(
      'emits [SensorLoading, SensorReadingsLoaded] when LoadReadings succeeds',
      build: () {
        when(() => mockRepository.getSensorById('sensor-1'))
            .thenAnswer((_) async => testSensor1);
        when(() => mockGetReadings(
              sensorId: 'sensor-1',
              from: null,
              to: null,
            )).thenAnswer((_) async => testReadings);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadReadings(sensorId: 'sensor-1')),
      expect: () => [
        const SensorLoading(),
        SensorReadingsLoaded(
          sensor: testSensor1,
          readings: testReadings,
        ),
      ],
    );

    blocTest<SensorBloc, SensorState>(
      'loads readings with date range',
      build: () {
        final from = DateTime(2024, 6, 15);
        final to = DateTime(2024, 6, 16);
        when(() => mockRepository.getSensorById('sensor-1'))
            .thenAnswer((_) async => testSensor1);
        when(() => mockGetReadings(
              sensorId: 'sensor-1',
              from: from,
              to: to,
            )).thenAnswer((_) async => testReadings);
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadReadings(
        sensorId: 'sensor-1',
        from: DateTime(2024, 6, 15),
        to: DateTime(2024, 6, 16),
      )),
      expect: () => [
        const SensorLoading(),
        SensorReadingsLoaded(
          sensor: testSensor1,
          readings: testReadings,
        ),
      ],
    );

    blocTest<SensorBloc, SensorState>(
      'emits [SensorLoading, SensorsLoaded] with filter on FilterByType',
      build: () {
        when(() => mockGetSensors(type: SensorType.temperature))
            .thenAnswer((_) async => [testSensor1]);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const FilterByType(type: SensorType.temperature)),
      expect: () => [
        const SensorLoading(),
        const SensorsLoaded(
          sensors: [testSensor1],
          filterType: SensorType.temperature,
        ),
      ],
    );

    blocTest<SensorBloc, SensorState>(
      'clears filter when FilterByType with null type',
      build: () {
        when(() => mockGetSensors(type: null))
            .thenAnswer((_) async => [testSensor1, testSensor2, testSensor3]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const FilterByType()),
      expect: () => [
        const SensorLoading(),
        const SensorsLoaded(
          sensors: [testSensor1, testSensor2, testSensor3],
        ),
      ],
    );

    blocTest<SensorBloc, SensorState>(
      'SelectSensor updates selected sensor in SensorsLoaded state',
      build: () {
        when(() => mockGetSensors(type: null))
            .thenAnswer((_) async => [testSensor1, testSensor2]);
        return buildBloc();
      },
      seed: () => const SensorsLoaded(
        sensors: [testSensor1, testSensor2],
      ),
      act: (bloc) =>
          bloc.add(const SelectSensor(sensorId: 'sensor-1')),
      expect: () => [
        const SensorsLoaded(
          sensors: [testSensor1, testSensor2],
          selectedSensorId: 'sensor-1',
        ),
      ],
    );

    test('initial state is SensorInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const SensorInitial());
      bloc.close();
    });
  });
}
