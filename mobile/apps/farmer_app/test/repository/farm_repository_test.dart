import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:farmer_app/features/farm/data/datasources/farm_local_datasource.dart';
import 'package:farmer_app/features/farm/data/datasources/farm_remote_datasource.dart';
import 'package:farmer_app/features/farm/data/models/farm_model.dart';
import 'package:farmer_app/features/farm/data/repositories/farm_repository_impl.dart';
import 'package:farmer_app/features/farm/domain/entities/farm_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockFarmRemoteDataSource extends Mock implements FarmRemoteDataSource {}

class MockFarmLocalDataSource extends Mock implements FarmLocalDataSource {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockFarmRemoteDataSource mockRemote;
  late MockFarmLocalDataSource mockLocal;
  late MockConnectivity mockConnectivity;
  late FarmRepositoryImpl repository;

  final now = DateTime(2024, 1, 15);
  final testFarmModel = FarmModel(
    id: 'farm-1',
    name: 'Test Farm',
    ownerId: 'user-1',
    boundaries: const [
      LatLng(-1.286, 36.817),
      LatLng(-1.287, 36.818),
    ],
    totalAreaHectares: 50.0,
    createdAt: now,
    updatedAt: now,
  );

  final testFarmModel2 = FarmModel(
    id: 'farm-2',
    name: 'Second Farm',
    ownerId: 'user-1',
    boundaries: const [
      LatLng(-1.3, 36.82),
    ],
    totalAreaHectares: 100.0,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockRemote = MockFarmRemoteDataSource();
    mockLocal = MockFarmLocalDataSource();
    mockConnectivity = MockConnectivity();
    repository = FarmRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      connectivity: mockConnectivity,
    );
  });

  setUpAll(() {
    registerFallbackValue(testFarmModel);
    registerFallbackValue(<FarmModel>[]);
  });

  void setOnline() {
    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
  }

  void setOffline() {
    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);
  }

  group('FarmRepositoryImpl', () {
    group('getFarms', () {
      test('returns farms from remote when online', () async {
        setOnline();
        when(() => mockRemote.getFarms('user-1'))
            .thenAnswer((_) async => [testFarmModel, testFarmModel2]);
        when(() => mockLocal.cacheFarms(any()))
            .thenAnswer((_) async {});

        final result = await repository.getFarms('user-1');

        expect(result, isA<List<FarmEntity>>());
        expect(result.length, 2);
        expect(result[0].id, 'farm-1');
        expect(result[1].id, 'farm-2');
        verify(() => mockRemote.getFarms('user-1')).called(1);
      });

      test('caches farms locally after remote fetch', () async {
        setOnline();
        when(() => mockRemote.getFarms('user-1'))
            .thenAnswer((_) async => [testFarmModel]);
        when(() => mockLocal.cacheFarms(any()))
            .thenAnswer((_) async {});

        await repository.getFarms('user-1');

        verify(() => mockLocal.cacheFarms(any())).called(1);
      });

      test('returns cached farms when offline', () async {
        setOffline();
        when(() => mockLocal.getFarms('user-1'))
            .thenAnswer((_) async => [testFarmModel]);

        final result = await repository.getFarms('user-1');

        expect(result.length, 1);
        expect(result[0].name, 'Test Farm');
        verify(() => mockLocal.getFarms('user-1')).called(1);
        verifyNever(() => mockRemote.getFarms(any()));
      });

      test('falls back to cache when remote fails while online', () async {
        setOnline();
        when(() => mockRemote.getFarms('user-1'))
            .thenThrow(Exception('Server error'));
        when(() => mockLocal.getFarms('user-1'))
            .thenAnswer((_) async => [testFarmModel]);

        final result = await repository.getFarms('user-1');

        expect(result.length, 1);
        expect(result[0].id, 'farm-1');
      });
    });

    group('createFarm', () {
      test('creates farm via remote and caches result', () async {
        final farmEntity = testFarmModel.toEntity();
        when(() => mockRemote.createFarm(any()))
            .thenAnswer((_) async => testFarmModel);
        when(() => mockLocal.cacheFarm(any()))
            .thenAnswer((_) async {});

        final result = await repository.createFarm(farmEntity);

        expect(result.id, 'farm-1');
        expect(result.name, 'Test Farm');
        verify(() => mockRemote.createFarm(any())).called(1);
        verify(() => mockLocal.cacheFarm(any())).called(1);
      });

      test('throws when remote create fails', () async {
        final farmEntity = testFarmModel.toEntity();
        when(() => mockRemote.createFarm(any()))
            .thenThrow(Exception('Create failed'));

        expect(
          () => repository.createFarm(farmEntity),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateFarm', () {
      test('updates farm via remote and caches result', () async {
        final farmEntity = testFarmModel.toEntity().copyWith(name: 'Updated');
        final updatedModel = FarmModel(
          id: 'farm-1',
          name: 'Updated',
          ownerId: 'user-1',
          boundaries: testFarmModel.boundaries,
          totalAreaHectares: 50.0,
          createdAt: now,
          updatedAt: now,
        );
        when(() => mockRemote.updateFarm(any()))
            .thenAnswer((_) async => updatedModel);
        when(() => mockLocal.cacheFarm(any()))
            .thenAnswer((_) async {});

        final result = await repository.updateFarm(farmEntity);

        expect(result.name, 'Updated');
        verify(() => mockRemote.updateFarm(any())).called(1);
        verify(() => mockLocal.cacheFarm(any())).called(1);
      });
    });

    group('deleteFarm', () {
      test('deletes from both remote and local', () async {
        when(() => mockRemote.deleteFarm('farm-1'))
            .thenAnswer((_) async {});
        when(() => mockLocal.deleteFarm('farm-1'))
            .thenAnswer((_) async {});

        await repository.deleteFarm('farm-1');

        verify(() => mockRemote.deleteFarm('farm-1')).called(1);
        verify(() => mockLocal.deleteFarm('farm-1')).called(1);
      });
    });

    group('getFarmById', () {
      test('returns farm from remote when online', () async {
        setOnline();
        when(() => mockRemote.getFarmById('farm-1'))
            .thenAnswer((_) async => testFarmModel);
        when(() => mockLocal.cacheFarm(any()))
            .thenAnswer((_) async {});

        final result = await repository.getFarmById('farm-1');

        expect(result.id, 'farm-1');
        verify(() => mockRemote.getFarmById('farm-1')).called(1);
      });

      test('returns cached farm when offline', () async {
        setOffline();
        when(() => mockLocal.getFarmById('farm-1'))
            .thenAnswer((_) async => testFarmModel);

        final result = await repository.getFarmById('farm-1');

        expect(result.id, 'farm-1');
        verifyNever(() => mockRemote.getFarmById(any()));
      });

      test('throws FarmNotFoundException when not in cache offline', () async {
        setOffline();
        when(() => mockLocal.getFarmById('farm-999'))
            .thenAnswer((_) async => null);

        expect(
          () => repository.getFarmById('farm-999'),
          throwsA(isA<FarmNotFoundException>()),
        );
      });
    });
  });
}
