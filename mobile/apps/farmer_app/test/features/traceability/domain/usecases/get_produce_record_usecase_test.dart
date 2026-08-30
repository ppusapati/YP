import 'package:farmer_app/features/traceability/domain/entities/produce_record_entity.dart';
import 'package:farmer_app/features/traceability/domain/repositories/traceability_repository.dart';
import 'package:farmer_app/features/traceability/domain/usecases/get_produce_record_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockTraceabilityRepository extends Mock
    implements TraceabilityRepository {}

void main() {
  late MockTraceabilityRepository mockRepository;
  late GetProduceRecordUseCase useCase;

  final testRecord = ProduceRecord(
    id: 'record-1',
    farmId: 'farm-1',
    farmName: 'Sunrise Farm',
    cropVariety: 'Hass Avocado',
    harvestDate: DateTime(2024, 5, 20),
    treatments: [
      Treatment(
        id: 'treat-1',
        name: 'Copper Fungicide',
        type: 'pesticide',
        date: DateTime(2024, 4, 15),
        dosage: '2 ml/L',
      ),
    ],
    farmLocation: const LatLng(-1.286, 36.817),
    certifications: [
      Certification(
        name: 'GlobalGAP',
        issuer: 'GlobalGAP',
        validUntil: DateTime(2025, 12, 31),
      ),
    ],
    batchId: 'BATCH-2024-001',
  );

  setUp(() {
    mockRepository = MockTraceabilityRepository();
    useCase = GetProduceRecordUseCase(mockRepository);
  });

  group('GetProduceRecordUseCase', () {
    test('returns produce record from repository', () async {
      when(() => mockRepository.getProduceRecord('record-1'))
          .thenAnswer((_) async => testRecord);

      final result = await useCase('record-1');

      expect(result, testRecord);
      expect(result.cropVariety, 'Hass Avocado');
      expect(result.batchId, 'BATCH-2024-001');
      expect(result.treatments.length, 1);
      verify(() => mockRepository.getProduceRecord('record-1')).called(1);
    });

    test('propagates exception when record not found', () async {
      when(() => mockRepository.getProduceRecord('record-999'))
          .thenThrow(Exception('Not found'));

      expect(
        () => useCase('record-999'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
