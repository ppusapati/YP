import 'package:farmer_app/features/traceability/domain/entities/produce_record_entity.dart';
import 'package:farmer_app/features/traceability/domain/repositories/traceability_repository.dart';
import 'package:farmer_app/features/traceability/domain/usecases/scan_qr_code_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockTraceabilityRepository extends Mock
    implements TraceabilityRepository {}

void main() {
  late MockTraceabilityRepository mockRepository;
  late ScanQrCodeUseCase useCase;

  final testRecord = ProduceRecord(
    id: 'record-1',
    farmId: 'farm-1',
    farmName: 'Sunrise Farm',
    cropVariety: 'Hass Avocado',
    harvestDate: DateTime(2024, 5, 20),
    treatments: const [],
    farmLocation: const LatLng(-1.286, 36.817),
    certifications: const [],
    batchId: 'BATCH-2024-001',
  );

  setUp(() {
    mockRepository = MockTraceabilityRepository();
    useCase = ScanQrCodeUseCase(mockRepository);
  });

  group('ScanQrCodeUseCase', () {
    test('returns produce record for valid QR data', () async {
      when(() => mockRepository.scanQrCode('YP:BATCH-2024-001'))
          .thenAnswer((_) async => testRecord);

      final result = await useCase('YP:BATCH-2024-001');

      expect(result, testRecord);
      expect(result.batchId, 'BATCH-2024-001');
      verify(() => mockRepository.scanQrCode('YP:BATCH-2024-001')).called(1);
    });

    test('propagates exception for invalid QR data', () async {
      when(() => mockRepository.scanQrCode('invalid'))
          .thenThrow(Exception('Invalid QR format'));

      expect(
        () => useCase('invalid'),
        throwsA(isA<Exception>()),
      );
    });

    test('delegates to repository scanQrCode method', () async {
      when(() => mockRepository.scanQrCode(any()))
          .thenAnswer((_) async => testRecord);

      await useCase('some-qr-data');

      verify(() => mockRepository.scanQrCode('some-qr-data')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
