import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/traceability/domain/entities/produce_record_entity.dart';
import 'package:farmer_app/features/traceability/domain/usecases/get_farm_history_usecase.dart';
import 'package:farmer_app/features/traceability/domain/usecases/get_produce_record_usecase.dart';
import 'package:farmer_app/features/traceability/domain/usecases/scan_qr_code_usecase.dart';
import 'package:farmer_app/features/traceability/presentation/bloc/traceability_bloc.dart';
import 'package:farmer_app/features/traceability/presentation/bloc/traceability_event.dart';
import 'package:farmer_app/features/traceability/presentation/bloc/traceability_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockScanQrCodeUseCase extends Mock implements ScanQrCodeUseCase {}

class MockGetProduceRecordUseCase extends Mock
    implements GetProduceRecordUseCase {}

class MockGetFarmHistoryUseCase extends Mock implements GetFarmHistoryUseCase {}

void main() {
  late MockScanQrCodeUseCase mockScanQrCode;
  late MockGetProduceRecordUseCase mockGetProduceRecord;
  late MockGetFarmHistoryUseCase mockGetFarmHistory;

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
        certificateNumber: 'GG-2024-001',
      ),
    ],
    batchId: 'BATCH-2024-001',
    packingDate: DateTime(2024, 5, 22),
  );

  final testRecord2 = ProduceRecord(
    id: 'record-2',
    farmId: 'farm-1',
    farmName: 'Sunrise Farm',
    cropVariety: 'Fuerte Avocado',
    harvestDate: DateTime(2024, 4, 10),
    treatments: const [],
    farmLocation: const LatLng(-1.286, 36.817),
    certifications: const [],
    batchId: 'BATCH-2024-002',
  );

  setUp(() {
    mockScanQrCode = MockScanQrCodeUseCase();
    mockGetProduceRecord = MockGetProduceRecordUseCase();
    mockGetFarmHistory = MockGetFarmHistoryUseCase();
  });

  TraceabilityBloc buildBloc() => TraceabilityBloc(
        scanQrCode: mockScanQrCode,
        getProduceRecord: mockGetProduceRecord,
        getFarmHistory: mockGetFarmHistory,
      );

  group('TraceabilityBloc', () {
    blocTest<TraceabilityBloc, TraceabilityState>(
      'emits [Scanning, RecordLoaded] when ScanQRCode succeeds',
      build: () {
        when(() => mockScanQrCode('qr-data-123'))
            .thenAnswer((_) async => testRecord);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ScanQRCode('qr-data-123')),
      expect: () => [
        const Scanning(),
        RecordLoaded(testRecord),
      ],
      verify: (_) {
        verify(() => mockScanQrCode('qr-data-123')).called(1);
      },
    );

    blocTest<TraceabilityBloc, TraceabilityState>(
      'emits [Scanning, TraceabilityError] when ScanQRCode fails',
      build: () {
        when(() => mockScanQrCode('invalid-qr'))
            .thenThrow(Exception('Invalid QR code'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ScanQRCode('invalid-qr')),
      expect: () => [
        const Scanning(),
        isA<TraceabilityError>().having(
          (e) => e.message,
          'message',
          contains('Unable to read QR code'),
        ),
      ],
    );

    blocTest<TraceabilityBloc, TraceabilityState>(
      'emits [TraceabilityLoading, RecordLoaded] when LoadProduceRecord succeeds',
      build: () {
        when(() => mockGetProduceRecord('record-1'))
            .thenAnswer((_) async => testRecord);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadProduceRecord('record-1')),
      expect: () => [
        const TraceabilityLoading(),
        RecordLoaded(testRecord),
      ],
      verify: (_) {
        verify(() => mockGetProduceRecord('record-1')).called(1);
      },
    );

    blocTest<TraceabilityBloc, TraceabilityState>(
      'emits [TraceabilityLoading, TraceabilityError] when LoadProduceRecord fails',
      build: () {
        when(() => mockGetProduceRecord('record-999'))
            .thenThrow(Exception('Not found'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadProduceRecord('record-999')),
      expect: () => [
        const TraceabilityLoading(),
        isA<TraceabilityError>().having(
          (e) => e.message,
          'message',
          contains('Unable to load produce record'),
        ),
      ],
    );

    blocTest<TraceabilityBloc, TraceabilityState>(
      'emits [TraceabilityLoading, FarmHistoryLoaded] when LoadFarmHistory succeeds',
      build: () {
        when(() => mockGetFarmHistory('farm-1'))
            .thenAnswer((_) async => [testRecord, testRecord2]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadFarmHistory('farm-1')),
      expect: () => [
        const TraceabilityLoading(),
        FarmHistoryLoaded([testRecord, testRecord2]),
      ],
      verify: (_) {
        verify(() => mockGetFarmHistory('farm-1')).called(1);
      },
    );

    blocTest<TraceabilityBloc, TraceabilityState>(
      'emits [TraceabilityLoading, TraceabilityError] when LoadFarmHistory fails',
      build: () {
        when(() => mockGetFarmHistory('farm-1'))
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadFarmHistory('farm-1')),
      expect: () => [
        const TraceabilityLoading(),
        isA<TraceabilityError>().having(
          (e) => e.message,
          'message',
          contains('Unable to load farm history'),
        ),
      ],
    );

    blocTest<TraceabilityBloc, TraceabilityState>(
      'emits FarmHistoryLoaded with empty list when farm has no records',
      build: () {
        when(() => mockGetFarmHistory('farm-empty'))
            .thenAnswer((_) async => []);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadFarmHistory('farm-empty')),
      expect: () => [
        const TraceabilityLoading(),
        const FarmHistoryLoaded([]),
      ],
    );

    test('initial state is TraceabilityInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const TraceabilityInitial());
      bloc.close();
    });
  });
}
