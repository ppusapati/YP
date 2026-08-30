import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName =
      'yieldpoint.satellite.tile.v1.SatelliteTileService';

  group('TileServiceClient', () {
    group('generateTileset', () {
      test('sends correct request and parses response', () async {
        final response = Tileset(
          id: 'tileset-1',
          processingJobId: 'job-1',
          farmId: 'farm-1',
          layer: 'ndvi',
          format: 'png',
          minZoom: 10,
          maxZoom: 18,
          tileCount: 256,
          status: 'GENERATING',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GenerateTileset');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          final sent = Tileset.fromBuffer(request.bodyBytes);
          expect(sent.processingJobId, 'job-1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = TileServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final tileset = await client.generateTileset(Tileset(
          processingJobId: 'job-1',
          farmId: 'farm-1',
          layer: 'ndvi',
          format: 'png',
        ));
        expect(tileset.id, 'tileset-1');
        expect(tileset.status, 'GENERATING');
        expect(tileset.minZoom, 10);
        expect(tileset.maxZoom, 18);
        expect(tileset.tileCount, 256);
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = TileServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.generateTileset(Tileset(farmId: 'farm-1')),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.method, 'method',
                  '$serviceName/GenerateTileset')),
        );
      });

      test('applies interceptors to request headers', () async {
        final response = Tileset(id: 'tileset-1');
        final mockClient = MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer tile-token');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = TileServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer tile-token';
              return headers;
            },
          ],
        );

        await client.generateTileset(Tileset(farmId: 'farm-1'));
      });
    });

    group('getTileset', () {
      test('sends correct request and returns tileset', () async {
        final response = Tileset(
          id: 'tileset-1',
          layer: 'rgb',
          status: 'READY',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetTileset');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = TileServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final tileset = await client.getTileset('tileset-1');
        expect(tileset.id, 'tileset-1');
        expect(tileset.layer, 'rgb');
        expect(tileset.status, 'READY');
      });
    });

    group('listTilesets', () {
      test('sends correct request and returns list', () async {
        final response = Tileset(id: 'tileset-1', status: 'READY');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListTilesets');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = TileServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final tilesets = await client.listTilesets();
        expect(tilesets, isNotEmpty);
        expect(tilesets.first.status, 'READY');
      });
    });

    group('getTile', () {
      test('sends correct request and returns tile data', () async {
        final response = TileData(
          tilesetId: 'tileset-1',
          z: 14,
          x: 8192,
          y: 5461,
          data: [0, 1, 2, 3, 4, 5],
          contentType: 'image/png',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetTile');
          final sent = TileRequest.fromBuffer(request.bodyBytes);
          expect(sent.tilesetId, 'tileset-1');
          expect(sent.z, 14);
          expect(sent.x, 8192);
          expect(sent.y, 5461);
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = TileServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final tile = await client.getTile(TileRequest(
          tilesetId: 'tileset-1',
          z: 14,
          x: 8192,
          y: 5461,
        ));
        expect(tile.tilesetId, 'tileset-1');
        expect(tile.z, 14);
        expect(tile.contentType, 'image/png');
        expect(tile.data, [0, 1, 2, 3, 4, 5]);
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 404);
        });

        final client = TileServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getTile(TileRequest(tilesetId: 'ts', z: 1)),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 404)),
        );
      });
    });

    group('deleteTileset', () {
      test('sends delete request with correct URL', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/DeleteTileset');
          final sent = Tileset.fromBuffer(request.bodyBytes);
          expect(sent.id, 'tileset-1');
          return http.Response.bytes(Tileset().writeToBuffer(), 200);
        });

        final client = TileServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        await client.deleteTileset('tileset-1');
      });
    });
  });
}
