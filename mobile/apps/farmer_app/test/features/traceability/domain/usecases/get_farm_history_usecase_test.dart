import 'package:farmer_app/features/traceability/domain/entities/produce_record_entity.dart';
import 'package:farmer_app/features/traceability/domain/repositories/traceability_repository.dart';
import 'package:farmer_app/features/traceability/domain/usecases/get_farm_history_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockTraceabilityRepository extends Mock
    implements TraceabilityRepository {}

void main() {
  late MockTraceabilityRepository mockRepository;
  late GetFarmHistoryUseCase useCase;

  final testRecords = [
    ProduceRecord(
      id: 'record-1',
      farmId: 'farm-1',
      farmName: 'Sunrise Farm',
      cropVariety: 'Hass Avocado',
      harvestDate: DateTime(2024, 5, 20),
      treatments: const [],
      farmLocation: const LatLng(-1.286, 36.817),
      certifications: const [],
      batchId: 'BATCH-2024-001',
    ),
    ProduceRecord(
      id: 'record-2',
      farmId: 'farm-1',
      farmName: 'Sunrise Farm',
      cropVariety: 'Fuerte Avocado',
      harvestDate: DateTime(2024, 4, 10),
      treatments: const [],
      farmLocation: const LatLng(-1.286, 36.817),
      certifications: const [],
      batchId: 'BATCH-2024-002',
    ),
  ];

  setUp(() {
    mockRepository = MockTraceabilityRepository();
    useCase = GetFarmHistoryUseCase(mockRepository);
  });

  group('GetFarmHistoryUseCase', () {
    test('returns farm history from repository', () async {
      when(() => mockRepository.getFarmHistory('farm-1'))
          .thenAnswer((_) async => testRecords);

      final result = await useCase('farm-1');

      expect(result, testRecords);
      expect(result.length, 2);
      expect(result[0].cropVariety, 'Hass Avocado');
      expect(result[1].cropVariety, 'Fuerte Avocado');
      verify(() => mockRepository.getFarmHistory('farm-1')).called(1);
    });

    test('returns empty list when farm has no records', () async {
      when(() => mockRepository.getFarmHistory('farm-new'))
          .thenAnswer((_) async => []);

      final result = await useCase('farm-new');

      expect(result, isEmpty);
    });

    test('propagates exception from repository', () async {
      when(() => mockRepository.getFarmHistory('farm-1'))
          .thenThrow(Exception('Service unavailable'));

      expect(
        () => useCase('farm-1'),
        throwsA(isA<Exception>()),
      );
    });

    test('delegates to repository getFarmHistory method', () async {
      when(() => mockRepository.getFarmHistory(any()))
          .thenAnswer((_) async => testRecords);

      await useCase('farm-1');

      verify(() => mockRepository.getFarmHistory('farm-1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
