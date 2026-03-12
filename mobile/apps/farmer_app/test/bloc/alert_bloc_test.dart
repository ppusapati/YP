import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/alerts/domain/entities/alert_entity.dart';
import 'package:farmer_app/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:farmer_app/features/alerts/domain/usecases/get_unread_count_usecase.dart';
import 'package:farmer_app/features/alerts/domain/usecases/mark_alert_read_usecase.dart';
import 'package:farmer_app/features/alerts/presentation/bloc/alert_bloc.dart';
import 'package:farmer_app/features/alerts/presentation/bloc/alert_event.dart';
import 'package:farmer_app/features/alerts/presentation/bloc/alert_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAlertsUseCase extends Mock implements GetAlertsUseCase {}

class MockMarkAlertReadUseCase extends Mock implements MarkAlertReadUseCase {}

class MockGetUnreadCountUseCase extends Mock implements GetUnreadCountUseCase {}

void main() {
  late MockGetAlertsUseCase mockGetAlerts;
  late MockMarkAlertReadUseCase mockMarkAlertRead;
  late MockGetUnreadCountUseCase mockGetUnreadCount;

  final testAlert1 = Alert(
    id: 'alert-1',
    type: AlertType.cropStress,
    title: 'Crop Stress Detected',
    message: 'NDVI values below threshold in North Field.',
    severity: AlertSeverity.warning,
    farmId: 'farm-1',
    fieldId: 'field-1',
    timestamp: DateTime(2024, 6, 15, 10, 0),
    read: false,
  );

  final testAlert2 = Alert(
    id: 'alert-2',
    type: AlertType.waterShortage,
    title: 'Water Shortage Alert',
    message: 'Soil moisture critically low in South Field.',
    severity: AlertSeverity.critical,
    farmId: 'farm-1',
    fieldId: 'field-2',
    timestamp: DateTime(2024, 6, 15, 12, 0),
    read: false,
  );

  final testAlert3 = Alert(
    id: 'alert-3',
    type: AlertType.frostWarning,
    title: 'Frost Warning',
    message: 'Temperature expected to drop below 0 tonight.',
    severity: AlertSeverity.info,
    farmId: 'farm-1',
    timestamp: DateTime(2024, 6, 14, 18, 0),
    read: true,
  );

  setUp(() {
    mockGetAlerts = MockGetAlertsUseCase();
    mockMarkAlertRead = MockMarkAlertReadUseCase();
    mockGetUnreadCount = MockGetUnreadCountUseCase();
  });

  AlertBloc buildBloc() => AlertBloc(
        getAlerts: mockGetAlerts,
        markAlertRead: mockMarkAlertRead,
        getUnreadCount: mockGetUnreadCount,
      );

  group('AlertBloc', () {
    blocTest<AlertBloc, AlertState>(
      'emits [AlertLoading, AlertsLoaded] when LoadAlerts succeeds',
      build: () {
        when(() => mockGetAlerts(farmId: 'farm-1'))
            .thenAnswer((_) async => [testAlert1, testAlert2, testAlert3]);
        when(() => mockGetUnreadCount(farmId: 'farm-1'))
            .thenAnswer((_) async => 2);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadAlerts(farmId: 'farm-1')),
      expect: () => [
        const AlertLoading(),
        AlertsLoaded(
          alerts: [testAlert1, testAlert2, testAlert3],
          unreadCount: 2,
        ),
      ],
    );

    blocTest<AlertBloc, AlertState>(
      'emits [AlertLoading, AlertError] when LoadAlerts fails',
      build: () {
        when(() => mockGetAlerts(farmId: any(named: 'farmId')))
            .thenThrow(Exception('Failed to load alerts'));
        when(() => mockGetUnreadCount(farmId: any(named: 'farmId')))
            .thenAnswer((_) async => 0);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadAlerts(farmId: 'farm-1')),
      expect: () => [
        const AlertLoading(),
        isA<AlertError>(),
      ],
    );

    blocTest<AlertBloc, AlertState>(
      'marks alert as read and decrements unread count',
      build: () {
        when(() => mockMarkAlertRead('alert-1'))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => AlertsLoaded(
        alerts: [testAlert1, testAlert2, testAlert3],
        unreadCount: 2,
      ),
      act: (bloc) => bloc.add(const MarkRead('alert-1')),
      expect: () => [
        isA<AlertsLoaded>()
            .having(
              (s) => s.unreadCount,
              'unreadCount',
              1,
            )
            .having(
              (s) => s.alerts.firstWhere((a) => a.id == 'alert-1').read,
              'alert-1.read',
              true,
            ),
      ],
      verify: (_) {
        verify(() => mockMarkAlertRead('alert-1')).called(1);
      },
    );

    blocTest<AlertBloc, AlertState>(
      'updates unread count correctly after marking read',
      build: () {
        when(() => mockMarkAlertRead('alert-2'))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => AlertsLoaded(
        alerts: [testAlert1, testAlert2],
        unreadCount: 2,
      ),
      act: (bloc) => bloc.add(const MarkRead('alert-2')),
      expect: () => [
        isA<AlertsLoaded>().having(
          (s) => s.unreadCount,
          'unreadCount',
          1,
        ),
      ],
    );

    blocTest<AlertBloc, AlertState>(
      'marks all alerts as read and sets unread count to zero',
      build: () {
        when(() => mockMarkAlertRead.markAll(farmId: 'farm-1'))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => AlertsLoaded(
        alerts: [testAlert1, testAlert2],
        unreadCount: 2,
      ),
      act: (bloc) =>
          bloc.add(const MarkAllRead(farmId: 'farm-1')),
      expect: () => [
        isA<AlertsLoaded>()
            .having(
              (s) => s.unreadCount,
              'unreadCount',
              0,
            )
            .having(
              (s) => s.alerts.every((a) => a.read),
              'all read',
              true,
            ),
      ],
    );

    blocTest<AlertBloc, AlertState>(
      'refreshes alerts preserving existing filters',
      build: () {
        when(() => mockGetAlerts(farmId: 'farm-1'))
            .thenAnswer((_) async => [testAlert1, testAlert2, testAlert3]);
        when(() => mockGetUnreadCount(farmId: 'farm-1'))
            .thenAnswer((_) async => 2);
        return buildBloc();
      },
      seed: () => const AlertsLoaded(
        alerts: [],
        unreadCount: 0,
        activeSeverityFilter: AlertSeverity.warning,
      ),
      act: (bloc) =>
          bloc.add(const RefreshAlerts(farmId: 'farm-1')),
      expect: () => [
        isA<AlertsLoaded>()
            .having(
              (s) => s.alerts.length,
              'alerts.length',
              3,
            )
            .having(
              (s) => s.activeSeverityFilter,
              'activeSeverityFilter',
              AlertSeverity.warning,
            ),
      ],
    );

    test('initial state is AlertInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const AlertInitial());
      bloc.close();
    });
  });
}
