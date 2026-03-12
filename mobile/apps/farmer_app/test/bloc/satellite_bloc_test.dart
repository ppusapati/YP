import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/satellite/domain/entities/satellite_entity.dart';
import 'package:farmer_app/features/satellite/domain/repositories/satellite_repository.dart';
import 'package:farmer_app/features/satellite/presentation/bloc/satellite_bloc.dart';
import 'package:farmer_app/features/satellite/presentation/bloc/satellite_event.dart';
import 'package:farmer_app/features/satellite/presentation/bloc/satellite_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSatelliteRepository extends Mock implements SatelliteRepository {}

void main() {
  late MockSatelliteRepository mockRepository;

  final tileDate = DateTime(2024, 6, 15);
  final testTiles = [
    SatelliteTile(
      id: 'tile-1',
      fieldId: 'field-1',
      layerType: SatelliteLayerType.ndvi,
      tileUrl: 'https://tiles.example.com/ndvi/tile-1.png',
      captureDate: tileDate,
      cloudCoverPercent: 12.5,
    ),
    SatelliteTile(
      id: 'tile-2',
      fieldId: 'field-1',
      layerType: SatelliteLayerType.rgb,
      tileUrl: 'https://tiles.example.com/rgb/tile-2.png',
      captureDate: tileDate.subtract(const Duration(days: 5)),
      cloudCoverPercent: 5.0,
    ),
  ];

  final from = DateTime(2024, 1, 1);
  final to = DateTime(2024, 6, 30);
  final testNdviData = [
    NdviDataPoint(
      date: DateTime(2024, 3, 15),
      meanNdvi: 0.65,
      minNdvi: 0.40,
      maxNdvi: 0.82,
    ),
    NdviDataPoint(
      date: DateTime(2024, 4, 15),
      meanNdvi: 0.72,
      minNdvi: 0.50,
      maxNdvi: 0.88,
    ),
  ];

  setUp(() {
    mockRepository = MockSatelliteRepository();
  });

  group('SatelliteBloc', () {
    blocTest<SatelliteBloc, SatelliteState>(
      'emits [SatelliteLoading, SatelliteTilesLoaded] when LoadSatelliteTiles succeeds',
      build: () {
        when(() => mockRepository.getSatelliteTiles(
              fieldId: 'field-1',
              layerType: null,
            )).thenAnswer((_) async => testTiles);
        return SatelliteBloc(repository: mockRepository);
      },
      act: (bloc) =>
          bloc.add(const LoadSatelliteTiles(fieldId: 'field-1')),
      expect: () => [
        const SatelliteLoading(),
        SatelliteTilesLoaded(tiles: testTiles),
      ],
    );

    blocTest<SatelliteBloc, SatelliteState>(
      'emits [SatelliteLoading, SatelliteError] when LoadSatelliteTiles fails',
      build: () {
        when(() => mockRepository.getSatelliteTiles(
              fieldId: 'field-1',
              layerType: null,
            )).thenThrow(Exception('Tile fetch failed'));
        return SatelliteBloc(repository: mockRepository);
      },
      act: (bloc) =>
          bloc.add(const LoadSatelliteTiles(fieldId: 'field-1')),
      expect: () => [
        const SatelliteLoading(),
        isA<SatelliteError>().having(
          (e) => e.message,
          'message',
          contains('Tile fetch failed'),
        ),
      ],
    );

    blocTest<SatelliteBloc, SatelliteState>(
      'emits [SatelliteLoading, NdviDataLoaded] when LoadNdviData succeeds',
      build: () {
        when(() => mockRepository.getNdviHistory(
              fieldId: 'field-1',
              from: from,
              to: to,
            )).thenAnswer((_) async => testNdviData);
        return SatelliteBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(LoadNdviData(
        fieldId: 'field-1',
        from: from,
        to: to,
      )),
      expect: () => [
        const SatelliteLoading(),
        NdviDataLoaded(dataPoints: testNdviData, from: from, to: to),
      ],
    );

    blocTest<SatelliteBloc, SatelliteState>(
      'emits [SatelliteLoading, SatelliteError] when LoadNdviData fails',
      build: () {
        when(() => mockRepository.getNdviHistory(
              fieldId: 'field-1',
              from: from,
              to: to,
            )).thenThrow(Exception('NDVI data unavailable'));
        return SatelliteBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(LoadNdviData(
        fieldId: 'field-1',
        from: from,
        to: to,
      )),
      expect: () => [
        const SatelliteLoading(),
        isA<SatelliteError>(),
      ],
    );

    blocTest<SatelliteBloc, SatelliteState>(
      'emits SatelliteDateRangeSelected on SelectDateRange',
      build: () => SatelliteBloc(repository: mockRepository),
      act: (bloc) => bloc.add(SelectDateRange(from: from, to: to)),
      expect: () => [
        SatelliteDateRangeSelected(from: from, to: to),
      ],
    );

    blocTest<SatelliteBloc, SatelliteState>(
      'loads tiles filtered by layer type',
      build: () {
        when(() => mockRepository.getSatelliteTiles(
              fieldId: 'field-1',
              layerType: SatelliteLayerType.ndvi,
            )).thenAnswer((_) async => [testTiles.first]);
        return SatelliteBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadSatelliteTiles(
        fieldId: 'field-1',
        layerType: SatelliteLayerType.ndvi,
      )),
      expect: () => [
        const SatelliteLoading(),
        SatelliteTilesLoaded(tiles: [testTiles.first]),
      ],
    );

    test('initial state is SatelliteInitial', () {
      final bloc = SatelliteBloc(repository: mockRepository);
      expect(bloc.state, const SatelliteInitial());
      bloc.close();
    });
  });
}
