import 'package:farmer_app/features/traceability/data/datasources/traceability_local_datasource.dart';
import 'package:farmer_app/features/traceability/data/datasources/traceability_remote_datasource.dart';
import 'package:farmer_app/features/traceability/data/models/produce_record_model.dart';
import 'package:farmer_app/features/traceability/data/repositories/traceability_repository_impl.dart';
import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockTraceabilityRemoteDataSource extends Mock
    implements TraceabilityRemoteDataSource {}

class MockTraceabilityLocalDataSource extends Mock
    implements TraceabilityLocalDataSource {}

void main() {
  late MockTraceabilityRemoteDataSource mockRemote;
  late MockTraceabilityLocalDataSource mockLocal;
  late TraceabilityRepositoryImpl repository;

  final testRecordModel = ProduceRecordModel(
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

  final testRecordModel2 = ProduceRecordModel(
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
    mockRemote = MockTraceabilityRemoteDataSource();
    mockLocal = MockTraceabilityLocalDataSource();
    repository = TraceabilityRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  setUpAll(() {
    registerFallbackValue(testRecordModel);
    registerFallbackValue(<ProduceRecordModel>[]);
  });

  group('TraceabilityRepositoryImpl', () {
    group('scanQrCode', () {
      test('scans QR code via remote and caches result', () async {
        when(() => mockRemote.scanQrCode('qr-data'))
            .thenAnswer((_) async => testRecordModel);
        when(() => mockLocal.cacheRecord(any()))
            .thenAnswer((_) async {});

        final result = await repository.scanQrCode('qr-data');

        expect(result.id, 'record-1');
        expect(result.batchId, 'BATCH-2024-001');
        verify(() => mockRemote.scanQrCode('qr-data')).called(1);
        verify(() => mockLocal.cacheRecord(any())).called(1);
      });

      test('throws when remote scan fails', () async {
        when(() => mockRemote.scanQrCode('invalid'))
            .thenThrow(const ConnectException(
          code: 'not_found',
          message: 'QR code not recognized',
        ));

        expect(
          () => repository.scanQrCode('invalid'),
          throwsA(isA<ConnectException>()),
        );
      });
    });

    group('getProduceRecord', () {
      test('returns record from remote and caches it', () async {
        when(() => mockRemote.fetchProduceRecord('record-1'))
            .thenAnswer((_) async => testRecordModel);
        when(() => mockLocal.cacheRecord(any()))
            .thenAnswer((_) async {});

        final result = await repository.getProduceRecord('record-1');

        expect(result.id, 'record-1');
        expect(result.cropVariety, 'Hass Avocado');
        verify(() => mockRemote.fetchProduceRecord('record-1')).called(1);
        verify(() => mockLocal.cacheRecord(any())).called(1);
      });

      test('falls back to cache when remote throws ConnectException', () async {
        when(() => mockRemote.fetchProduceRecord('record-1'))
            .thenThrow(const ConnectException(code: 'unavailable', message: 'Offline'));
        when(() => mockLocal.getCachedRecord('record-1'))
            .thenAnswer((_) async => testRecordModel);

        final result = await repository.getProduceRecord('record-1');

        expect(result.id, 'record-1');
        verify(() => mockLocal.getCachedRecord('record-1')).called(1);
      });

      test('rethrows when remote fails and no cache available', () async {
        when(() => mockRemote.fetchProduceRecord('record-999'))
            .thenThrow(const ConnectException(code: 'unavailable', message: 'Offline'));
        when(() => mockLocal.getCachedRecord('record-999'))
            .thenAnswer((_) async => null);

        expect(
          () => repository.getProduceRecord('record-999'),
          throwsA(isA<ConnectException>()),
        );
      });
    });

    group('getFarmHistory', () {
      test('returns history from remote and caches it', () async {
        when(() => mockRemote.fetchFarmHistory('farm-1'))
            .thenAnswer(
                (_) async => [testRecordModel, testRecordModel2]);
        when(() => mockLocal.cacheFarmHistory('farm-1', any()))
            .thenAnswer((_) async {});

        final result = await repository.getFarmHistory('farm-1');

        expect(result.length, 2);
        expect(result[0].id, 'record-1');
        expect(result[1].id, 'record-2');
        verify(() => mockRemote.fetchFarmHistory('farm-1')).called(1);
        verify(() => mockLocal.cacheFarmHistory('farm-1', any())).called(1);
      });

      test('falls back to cache when remote throws ConnectException', () async {
        when(() => mockRemote.fetchFarmHistory('farm-1'))
            .thenThrow(const ConnectException(code: 'unavailable', message: 'Offline'));
        when(() => mockLocal.getCachedFarmHistory('farm-1'))
            .thenAnswer((_) async => [testRecordModel]);

        final result = await repository.getFarmHistory('farm-1');

        expect(result.length, 1);
        expect(result[0].id, 'record-1');
        verify(() => mockLocal.getCachedFarmHistory('farm-1')).called(1);
      });

      test('returns empty list when both remote and cache fail', () async {
        when(() => mockRemote.fetchFarmHistory('farm-new'))
            .thenThrow(const ConnectException(code: 'unavailable', message: 'Offline'));
        when(() => mockLocal.getCachedFarmHistory('farm-new'))
            .thenAnswer((_) async => []);

        final result = await repository.getFarmHistory('farm-new');

        expect(result, isEmpty);
      });
    });
  });
}
