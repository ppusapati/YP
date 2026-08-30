import 'package:fixnum/fixnum.dart';
import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName = 'yieldpoint.satellite.v1.SatelliteService';

  group('SatelliteServiceClient', () {
    group('getTilesForField', () {
      test('sends correct request and parses response', () async {
        final response = SatelliteTile(
          id: 'tile-1',
          fieldId: 'field-1',
          tileUrl: 'https://tiles.example.com/tile-1',
          indexType: 'NDVI',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetTilesForField');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SatelliteServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final tiles =
            await client.getTilesForField(fieldId: 'field-1');
        expect(tiles, isNotEmpty);
        expect(tiles.first.id, 'tile-1');
        expect(tiles.first.tileUrl, 'https://tiles.example.com/tile-1');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = SatelliteServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getTilesForField(fieldId: 'field-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.method, 'method',
                  '$serviceName/GetTilesForField')),
        );
      });

      test('applies interceptors to request headers', () async {
        final response = SatelliteTile(id: 'tile-1');
        final mockClient = MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer sat-token');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SatelliteServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer sat-token';
              return headers;
            },
          ],
        );

        await client.getTilesForField(fieldId: 'field-1');
      });
    });

    group('getTile', () {
      test('sends correct request and returns tile', () async {
        final response = SatelliteTile(
          id: 'tile-1',
          fieldId: 'field-1',
          indexType: 'EVI',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetTile');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SatelliteServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final tile = await client.getTile('tile-1');
        expect(tile.id, 'tile-1');
        expect(tile.indexType, 'EVI');
      });
    });

    group('getNDVIData', () {
      test('sends correct request and returns NDVI data', () async {
        final response = NDVIData(
          fieldId: 'field-1',
          resolution: 10.0,
          timestamp: Int64(1700000000),
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetNDVIData');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SatelliteServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final ndvi = await client.getNDVIData(fieldId: 'field-1');
        expect(ndvi.fieldId, 'field-1');
        expect(ndvi.resolution, 10.0);
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 503);
        });

        final client = SatelliteServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getNDVIData(fieldId: 'field-1'),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('getCropHealthTimeSeries', () {
      test('sends correct request and returns time series', () async {
        final response = CropHealthTimeSeries(
          fieldId: 'field-1',
          dataPoints: [
            CropHealthDataPoint(
              timestamp: Int64(1700000000),
              ndviMean: 0.75,
              ndviMin: 0.50,
              ndviMax: 0.90,
            ),
          ],
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetCropHealthTimeSeries');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SatelliteServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final timeSeries = await client.getCropHealthTimeSeries(
            fieldId: 'field-1');
        expect(timeSeries.fieldId, 'field-1');
        expect(timeSeries.dataPoints, hasLength(1));
        expect(timeSeries.dataPoints.first.ndviMean, 0.75);
      });
    });

    group('streamNDVIUpdates', () {
      test('streams NDVI data updates from server', () async {
        final ndvi1 = NDVIData(
          fieldId: 'field-1',
          resolution: 10.0,
        );
        final ndvi2 = NDVIData(
          fieldId: 'field-1',
          resolution: 20.0,
        );

        final mockClient = MockClient.streaming((request, sink) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/StreamNDVIUpdates');
          expect(request.headers['Connect-Content-Encoding'], 'identity');
          sink.add(ndvi1.writeToBuffer());
          sink.add(ndvi2.writeToBuffer());
          sink.close();
        });

        final client = SatelliteServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final updates =
            await client.streamNDVIUpdates('field-1').toList();
        expect(updates, hasLength(2));
        expect(updates[0].resolution, 10.0);
        expect(updates[1].resolution, 20.0);
      });
    });
  });
}
