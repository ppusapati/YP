import 'package:farmer_app/features/satellite/domain/entities/satellite_entity.dart';
import 'package:farmer_app/features/satellite/domain/repositories/satellite_repository.dart';
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
    SatelliteTile(
      id: 'tile-3',
      fieldId: 'field-1',
      layerType: SatelliteLayerType.ndvi,
      tileUrl: 'https://tiles.example.com/ndvi/tile-3.png',
      captureDate: tileDate.subtract(const Duration(days: 10)),
      cloudCoverPercent: 22.0,
    ),
  ];

  final from = DateTime(2024, 1, 1);
  final to = DateTime(2024, 6, 30);

  final testNdviHistory = [
    NdviDataPoint(
      date: DateTime(2024, 2, 1),
      meanNdvi: 0.55,
      minNdvi: 0.30,
      maxNdvi: 0.75,
    ),
    NdviDataPoint(
      date: DateTime(2024, 3, 1),
      meanNdvi: 0.62,
      minNdvi: 0.38,
      maxNdvi: 0.80,
    ),
    NdviDataPoint(
      date: DateTime(2024, 4, 1),
      meanNdvi: 0.71,
      minNdvi: 0.45,
      maxNdvi: 0.88,
    ),
    NdviDataPoint(
      date: DateTime(2024, 5, 1),
      meanNdvi: 0.68,
      minNdvi: 0.42,
      maxNdvi: 0.85,
    ),
  ];

  setUp(() {
    mockRepository = MockSatelliteRepository();
  });

  group('SatelliteRepository', () {
    group('getSatelliteTiles', () {
      test('fetches all tiles for a field', () async {
        when(() => mockRepository.getSatelliteTiles(
              fieldId: 'field-1',
              layerType: null,
              from: null,
              to: null,
            )).thenAnswer((_) async => testTiles);

        final result = await mockRepository.getSatelliteTiles(
          fieldId: 'field-1',
        );

        expect(result.length, 3);
        expect(result[0].layerType, SatelliteLayerType.ndvi);
        expect(result[1].layerType, SatelliteLayerType.rgb);
      });

      test('fetches tiles filtered by layer type', () async {
        final ndviTiles =
            testTiles.where((t) => t.layerType == SatelliteLayerType.ndvi).toList();
        when(() => mockRepository.getSatelliteTiles(
              fieldId: 'field-1',
              layerType: SatelliteLayerType.ndvi,
              from: null,
              to: null,
            )).thenAnswer((_) async => ndviTiles);

        final result = await mockRepository.getSatelliteTiles(
          fieldId: 'field-1',
          layerType: SatelliteLayerType.ndvi,
        );

        expect(result.length, 2);
        expect(result.every((t) => t.layerType == SatelliteLayerType.ndvi), true);
      });

      test('fetches tiles within date range', () async {
        final recentTiles = [testTiles.first];
        when(() => mockRepository.getSatelliteTiles(
              fieldId: 'field-1',
              layerType: null,
              from: tileDate.subtract(const Duration(days: 1)),
              to: tileDate.add(const Duration(days: 1)),
            )).thenAnswer((_) async => recentTiles);

        final result = await mockRepository.getSatelliteTiles(
          fieldId: 'field-1',
          from: tileDate.subtract(const Duration(days: 1)),
          to: tileDate.add(const Duration(days: 1)),
        );

        expect(result.length, 1);
        expect(result.first.id, 'tile-1');
      });

      test('returns empty list when no tiles available', () async {
        when(() => mockRepository.getSatelliteTiles(
              fieldId: 'field-999',
              layerType: null,
              from: null,
              to: null,
            )).thenAnswer((_) async => []);

        final result = await mockRepository.getSatelliteTiles(
          fieldId: 'field-999',
        );

        expect(result, isEmpty);
      });

      test('throws on network failure', () async {
        when(() => mockRepository.getSatelliteTiles(
              fieldId: 'field-1',
              layerType: null,
              from: null,
              to: null,
            )).thenThrow(Exception('Network error'));

        expect(
          () => mockRepository.getSatelliteTiles(fieldId: 'field-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getNdviHistory', () {
      test('fetches NDVI history for a field', () async {
        when(() => mockRepository.getNdviHistory(
              fieldId: 'field-1',
              from: from,
              to: to,
            )).thenAnswer((_) async => testNdviHistory);

        final result = await mockRepository.getNdviHistory(
          fieldId: 'field-1',
          from: from,
          to: to,
        );

        expect(result.length, 4);
        expect(result[0].meanNdvi, 0.55);
        expect(result[2].meanNdvi, 0.71);
      });

      test('returns data points sorted by date', () async {
        when(() => mockRepository.getNdviHistory(
              fieldId: 'field-1',
              from: from,
              to: to,
            )).thenAnswer((_) async => testNdviHistory);

        final result = await mockRepository.getNdviHistory(
          fieldId: 'field-1',
          from: from,
          to: to,
        );

        for (var i = 0; i < result.length - 1; i++) {
          expect(result[i].date.isBefore(result[i + 1].date), true);
        }
      });

      test('returns empty list when no NDVI data available', () async {
        when(() => mockRepository.getNdviHistory(
              fieldId: 'field-999',
              from: from,
              to: to,
            )).thenAnswer((_) async => []);

        final result = await mockRepository.getNdviHistory(
          fieldId: 'field-999',
          from: from,
          to: to,
        );

        expect(result, isEmpty);
      });

      test('all data points have valid NDVI ranges', () async {
        when(() => mockRepository.getNdviHistory(
              fieldId: 'field-1',
              from: from,
              to: to,
            )).thenAnswer((_) async => testNdviHistory);

        final result = await mockRepository.getNdviHistory(
          fieldId: 'field-1',
          from: from,
          to: to,
        );

        for (final point in result) {
          expect(point.minNdvi, lessThanOrEqualTo(point.meanNdvi));
          expect(point.meanNdvi, lessThanOrEqualTo(point.maxNdvi));
          expect(point.minNdvi, greaterThanOrEqualTo(-1.0));
          expect(point.maxNdvi, lessThanOrEqualTo(1.0));
        }
      });
    });
  });
}
