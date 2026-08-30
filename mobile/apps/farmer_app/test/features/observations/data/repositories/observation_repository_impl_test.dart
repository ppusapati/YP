import 'package:farmer_app/features/observations/data/datasources/observation_local_datasource.dart';
import 'package:farmer_app/features/observations/data/datasources/observation_remote_datasource.dart';
import 'package:farmer_app/features/observations/data/models/observation_model.dart';
import 'package:farmer_app/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:farmer_app/features/observations/domain/entities/observation_entity.dart';
import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockObservationRemoteDataSource extends Mock
    implements ObservationRemoteDataSource {}

class MockObservationLocalDataSource extends Mock
    implements ObservationLocalDataSource {}

void main() {
  late MockObservationRemoteDataSource mockRemote;
  late MockObservationLocalDataSource mockLocal;
  late ObservationRepositoryImpl repository;

  final testModel1 = ObservationModel(
    id: 'obs-1',
    fieldId: 'field-1',
    location: const LatLng(-1.286, 36.817),
    photos: const ['https://photos.example.com/obs1.jpg'],
    notes: 'Pest spotted.',
    timestamp: DateTime(2024, 6, 15, 10, 30),
    category: ObservationCategory.pest,
  );

  final testModel2 = ObservationModel(
    id: 'obs-2',
    fieldId: 'field-2',
    location: const LatLng(-1.290, 36.820),
    photos: const [],
    notes: 'Healthy growth.',
    timestamp: DateTime(2024, 6, 14, 9, 0),
    category: ObservationCategory.growth,
  );

  setUp(() {
    mockRemote = MockObservationRemoteDataSource();
    mockLocal = MockObservationLocalDataSource();
    repository = ObservationRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  setUpAll(() {
    registerFallbackValue(testModel1);
    registerFallbackValue(<ObservationModel>[]);
  });

  group('ObservationRepositoryImpl', () {
    group('getObservations', () {
      test('returns observations from remote and caches them', () async {
        when(() => mockRemote.fetchObservations(fieldId: null))
            .thenAnswer((_) async => [testModel1, testModel2]);
        when(() => mockLocal.cacheObservations(any()))
            .thenAnswer((_) async {});

        final result = await repository.getObservations();

        expect(result.length, 2);
        expect(result[0].id, 'obs-1');
        expect(result[1].id, 'obs-2');
        verify(() => mockRemote.fetchObservations(fieldId: null)).called(1);
        verify(() => mockLocal.cacheObservations(any())).called(1);
      });

      test('returns filtered observations by fieldId from remote', () async {
        when(() => mockRemote.fetchObservations(fieldId: 'field-1'))
            .thenAnswer((_) async => [testModel1]);
        when(() => mockLocal.cacheObservations(any()))
            .thenAnswer((_) async {});

        final result = await repository.getObservations(fieldId: 'field-1');

        expect(result.length, 1);
        expect(result[0].fieldId, 'field-1');
      });

      test('falls back to cache when remote throws ConnectException', () async {
        when(() => mockRemote.fetchObservations(fieldId: null))
            .thenThrow(const ConnectException(code: 'unavailable', message: 'Offline'));
        when(() => mockLocal.getCachedObservations())
            .thenAnswer((_) async => [testModel1, testModel2]);

        final result = await repository.getObservations();

        expect(result.length, 2);
        verify(() => mockLocal.getCachedObservations()).called(1);
      });

      test('filters cached observations by fieldId when offline', () async {
        when(() => mockRemote.fetchObservations(fieldId: 'field-1'))
            .thenThrow(const ConnectException(code: 'unavailable', message: 'Offline'));
        when(() => mockLocal.getCachedObservations())
            .thenAnswer((_) async => [testModel1, testModel2]);

        final result = await repository.getObservations(fieldId: 'field-1');

        expect(result.length, 1);
        expect(result[0].fieldId, 'field-1');
      });

      test('returns empty list when both remote and cache empty', () async {
        when(() => mockRemote.fetchObservations(fieldId: null))
            .thenThrow(const ConnectException(code: 'unavailable', message: 'Offline'));
        when(() => mockLocal.getCachedObservations())
            .thenAnswer((_) async => []);

        final result = await repository.getObservations();

        expect(result, isEmpty);
      });
    });

    group('getFieldObservations', () {
      test('delegates to getObservations with fieldId', () async {
        when(() => mockRemote.fetchObservations(fieldId: 'field-1'))
            .thenAnswer((_) async => [testModel1]);
        when(() => mockLocal.cacheObservations(any()))
            .thenAnswer((_) async {});

        final result = await repository.getFieldObservations('field-1');

        expect(result.length, 1);
        expect(result[0].fieldId, 'field-1');
      });
    });

    group('createObservation', () {
      test('creates observation via remote and caches it', () async {
        when(() => mockRemote.createObservation(any()))
            .thenAnswer((_) async => testModel1);
        when(() => mockLocal.cacheObservation(any()))
            .thenAnswer((_) async {});

        final result = await repository.createObservation(testModel1);

        expect(result.id, 'obs-1');
        verify(() => mockRemote.createObservation(any())).called(1);
        verify(() => mockLocal.cacheObservation(any())).called(1);
      });

      test('throws when remote creation fails', () async {
        when(() => mockRemote.createObservation(any()))
            .thenThrow(const ConnectException(code: 'internal', message: 'Server error'));

        expect(
          () => repository.createObservation(testModel1),
          throwsA(isA<ConnectException>()),
        );
      });
    });

    group('deleteObservation', () {
      test('deletes from both remote and local', () async {
        when(() => mockRemote.deleteObservation('obs-1'))
            .thenAnswer((_) async {});
        when(() => mockLocal.removeObservation('obs-1'))
            .thenAnswer((_) async {});

        await repository.deleteObservation('obs-1');

        verify(() => mockRemote.deleteObservation('obs-1')).called(1);
        verify(() => mockLocal.removeObservation('obs-1')).called(1);
      });
    });

    group('getObservationById', () {
      test('returns observation from remote', () async {
        when(() => mockRemote.fetchObservationById('obs-1'))
            .thenAnswer((_) async => testModel1);

        final result = await repository.getObservationById('obs-1');

        expect(result.id, 'obs-1');
        expect(result.category, ObservationCategory.pest);
      });

      test('throws when observation not found', () async {
        when(() => mockRemote.fetchObservationById('obs-999'))
            .thenThrow(const ConnectException(
          code: 'not_found',
          message: 'Observation not found',
        ));

        expect(
          () => repository.getObservationById('obs-999'),
          throwsA(isA<ConnectException>()),
        );
      });
    });

    group('uploadPhoto', () {
      test('delegates to remote data source', () async {
        when(() => mockRemote.uploadPhoto('/tmp/photo.jpg'))
            .thenAnswer((_) async => 'https://photos.example.com/photo.jpg');

        final result = await repository.uploadPhoto('/tmp/photo.jpg');

        expect(result, 'https://photos.example.com/photo.jpg');
        verify(() => mockRemote.uploadPhoto('/tmp/photo.jpg')).called(1);
      });
    });
  });
}
