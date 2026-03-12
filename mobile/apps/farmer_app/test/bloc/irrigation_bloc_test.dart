import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/irrigation/domain/entities/irrigation_alert_entity.dart';
import 'package:farmer_app/features/irrigation/domain/entities/irrigation_schedule_entity.dart';
import 'package:farmer_app/features/irrigation/domain/entities/irrigation_zone_entity.dart';
import 'package:farmer_app/features/irrigation/domain/usecases/get_irrigation_alerts_usecase.dart';
import 'package:farmer_app/features/irrigation/domain/usecases/get_irrigation_schedule_usecase.dart';
import 'package:farmer_app/features/irrigation/domain/usecases/get_irrigation_zones_usecase.dart';
import 'package:farmer_app/features/irrigation/domain/usecases/update_irrigation_schedule_usecase.dart';
import 'package:farmer_app/features/irrigation/presentation/bloc/irrigation_bloc.dart';
import 'package:farmer_app/features/irrigation/presentation/bloc/irrigation_event.dart';
import 'package:farmer_app/features/irrigation/presentation/bloc/irrigation_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetIrrigationZonesUseCase extends Mock
    implements GetIrrigationZonesUseCase {}

class MockGetIrrigationScheduleUseCase extends Mock
    implements GetIrrigationScheduleUseCase {}

class MockUpdateIrrigationScheduleUseCase extends Mock
    implements UpdateIrrigationScheduleUseCase {}

class MockGetIrrigationAlertsUseCase extends Mock
    implements GetIrrigationAlertsUseCase {}

void main() {
  late MockGetIrrigationZonesUseCase mockGetZones;
  late MockGetIrrigationScheduleUseCase mockGetSchedule;
  late MockUpdateIrrigationScheduleUseCase mockUpdateSchedule;
  late MockGetIrrigationAlertsUseCase mockGetAlerts;

  final testZones = [
    const IrrigationZone(
      id: 'zone-1',
      fieldId: 'field-1',
      name: 'Zone Alpha',
      polygon: [
        LatLngPoint(latitude: -1.286, longitude: 36.817),
        LatLngPoint(latitude: -1.287, longitude: 36.818),
      ],
      currentMoisture: 35.0,
      targetMoisture: 60.0,
      status: IrrigationZoneStatus.active,
    ),
    const IrrigationZone(
      id: 'zone-2',
      fieldId: 'field-1',
      name: 'Zone Beta',
      polygon: [
        LatLngPoint(latitude: -1.290, longitude: 36.820),
        LatLngPoint(latitude: -1.291, longitude: 36.821),
      ],
      currentMoisture: 55.0,
      targetMoisture: 60.0,
      status: IrrigationZoneStatus.scheduled,
    ),
  ];

  final testSchedules = [
    IrrigationSchedule(
      id: 'sched-1',
      zoneId: 'zone-1',
      startTime: DateTime(2024, 6, 15, 6, 0),
      duration: const Duration(hours: 2),
      waterVolume: 500.0,
      status: ScheduleStatus.active,
    ),
    IrrigationSchedule(
      id: 'sched-2',
      zoneId: 'zone-1',
      startTime: DateTime(2024, 6, 16, 6, 0),
      duration: const Duration(hours: 1, minutes: 30),
      waterVolume: 375.0,
      status: ScheduleStatus.pending,
    ),
  ];

  final testAlerts = [
    IrrigationAlert(
      id: 'alert-1',
      zoneId: 'zone-1',
      type: AlertType.lowMoisture,
      message: 'Moisture level below threshold in Zone Alpha',
      severity: AlertSeverity.warning,
      timestamp: DateTime(2024, 6, 15, 8, 0),
    ),
    IrrigationAlert(
      id: 'alert-2',
      zoneId: 'zone-2',
      type: AlertType.systemFailure,
      message: 'Pump failure in Zone Beta',
      severity: AlertSeverity.critical,
      timestamp: DateTime(2024, 6, 15, 9, 0),
    ),
  ];

  setUp(() {
    mockGetZones = MockGetIrrigationZonesUseCase();
    mockGetSchedule = MockGetIrrigationScheduleUseCase();
    mockUpdateSchedule = MockUpdateIrrigationScheduleUseCase();
    mockGetAlerts = MockGetIrrigationAlertsUseCase();
  });

  setUpAll(() {
    registerFallbackValue(testSchedules.first);
  });

  IrrigationBloc buildBloc() => IrrigationBloc(
        getZones: mockGetZones,
        getSchedule: mockGetSchedule,
        updateSchedule: mockUpdateSchedule,
        getAlerts: mockGetAlerts,
      );

  group('IrrigationBloc', () {
    blocTest<IrrigationBloc, IrrigationState>(
      'emits [IrrigationLoading, ZonesLoaded] when LoadZones succeeds',
      build: () {
        when(() => mockGetZones('field-1'))
            .thenAnswer((_) async => testZones);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadZones(fieldId: 'field-1')),
      expect: () => [
        const IrrigationLoading(),
        ZonesLoaded(zones: testZones),
      ],
    );

    blocTest<IrrigationBloc, IrrigationState>(
      'emits [IrrigationLoading, IrrigationError] when LoadZones fails',
      build: () {
        when(() => mockGetZones('field-1'))
            .thenThrow(Exception('Failed to load zones'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadZones(fieldId: 'field-1')),
      expect: () => [
        const IrrigationLoading(),
        isA<IrrigationError>(),
      ],
    );

    blocTest<IrrigationBloc, IrrigationState>(
      'emits [IrrigationLoading, ScheduleLoaded] when LoadSchedule succeeds',
      build: () {
        when(() => mockGetSchedule('zone-1'))
            .thenAnswer((_) async => testSchedules);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadSchedule(zoneId: 'zone-1')),
      expect: () => [
        const IrrigationLoading(),
        ScheduleLoaded(zoneId: 'zone-1', schedules: testSchedules),
      ],
    );

    blocTest<IrrigationBloc, IrrigationState>(
      'emits [IrrigationLoading, IrrigationError] when LoadSchedule fails',
      build: () {
        when(() => mockGetSchedule('zone-1'))
            .thenThrow(Exception('Schedule unavailable'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadSchedule(zoneId: 'zone-1')),
      expect: () => [
        const IrrigationLoading(),
        isA<IrrigationError>(),
      ],
    );

    blocTest<IrrigationBloc, IrrigationState>(
      'emits [IrrigationLoading, AlertsLoaded] when LoadAlerts succeeds',
      build: () {
        when(() => mockGetAlerts(zoneId: null))
            .thenAnswer((_) async => testAlerts);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadAlerts()),
      expect: () => [
        const IrrigationLoading(),
        AlertsLoaded(alerts: testAlerts),
      ],
    );

    blocTest<IrrigationBloc, IrrigationState>(
      'loads alerts filtered by zone',
      build: () {
        when(() => mockGetAlerts(zoneId: 'zone-1'))
            .thenAnswer((_) async => [testAlerts.first]);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadAlerts(zoneId: 'zone-1')),
      expect: () => [
        const IrrigationLoading(),
        AlertsLoaded(alerts: [testAlerts.first]),
      ],
    );

    blocTest<IrrigationBloc, IrrigationState>(
      'emits [IrrigationLoading, IrrigationError] when LoadAlerts fails',
      build: () {
        when(() => mockGetAlerts(zoneId: null))
            .thenThrow(Exception('Alerts unavailable'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadAlerts()),
      expect: () => [
        const IrrigationLoading(),
        isA<IrrigationError>(),
      ],
    );

    test('initial state is IrrigationInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const IrrigationInitial());
      bloc.close();
    });
  });
}
