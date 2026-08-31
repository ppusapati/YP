import 'package:farmer_app/features/irrigation/domain/entities/irrigation_schedule_entity.dart';
import 'package:farmer_app/features/irrigation/domain/repositories/irrigation_repository.dart';
import 'package:farmer_app/features/irrigation/domain/usecases/update_irrigation_schedule_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIrrigationRepository extends Mock implements IrrigationRepository {}

void main() {
  late MockIrrigationRepository mockRepository;
  late UpdateIrrigationScheduleUseCase useCase;

  final testSchedule = IrrigationSchedule(
    id: 'sched-1',
    zoneId: 'zone-1',
    startTime: DateTime(2024, 6, 15, 6, 0),
    duration: const Duration(hours: 2),
    waterVolume: 500.0,
    status: ScheduleStatus.pending,
  );

  final updatedSchedule = IrrigationSchedule(
    id: 'sched-1',
    zoneId: 'zone-1',
    startTime: DateTime(2024, 6, 15, 7, 0),
    duration: const Duration(hours: 3),
    waterVolume: 750.0,
    status: ScheduleStatus.active,
  );

  setUp(() {
    mockRepository = MockIrrigationRepository();
    useCase = UpdateIrrigationScheduleUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(testSchedule);
  });

  group('UpdateIrrigationScheduleUseCase', () {
    test('returns updated schedule from repository', () async {
      when(() => mockRepository.updateSchedule(any()))
          .thenAnswer((_) async => updatedSchedule);

      final result = await useCase(testSchedule);

      expect(result.id, 'sched-1');
      expect(result.status, ScheduleStatus.active);
      expect(result.waterVolume, 750.0);
      expect(result.duration, const Duration(hours: 3));
      verify(() => mockRepository.updateSchedule(any())).called(1);
    });

    test('propagates exception when update fails', () async {
      when(() => mockRepository.updateSchedule(any()))
          .thenThrow(Exception('Schedule conflict'));

      expect(
        () => useCase(testSchedule),
        throwsA(isA<Exception>()),
      );
    });

    test('schedule computes endTime correctly', () {
      expect(
        testSchedule.endTime,
        DateTime(2024, 6, 15, 8, 0),
      );
    });

    test('schedule formats duration correctly', () {
      expect(testSchedule.durationFormatted, '2h 0m');

      final shortSchedule = testSchedule.copyWith(
        duration: const Duration(minutes: 45),
      );
      expect(shortSchedule.durationFormatted, '45m');
    });
  });
}
