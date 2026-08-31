import 'package:fixnum/fixnum.dart';
import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName =
      'yieldpoint.satellite.vegetation.v1.VegetationIndexService';

  group('VegetationIndexServiceClient', () {
    group('computeIndices', () {
      test('sends correct request and parses response', () async {
        final response = VegetationIndex(
          id: 'vi-1',
          farmId: 'farm-1',
          fieldId: 'field-1',
          indexType: 'NDVI',
          meanValue: 0.72,
          minValue: 0.45,
          maxValue: 0.91,
          stdDeviation: 0.12,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ComputeIndices');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = VegetationIndexServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final vi = await client.computeIndices(VegetationIndex(
          fieldId: 'field-1',
          indexType: 'NDVI',
        ));
        expect(vi.id, 'vi-1');
        expect(vi.meanValue, 0.72);
        expect(vi.minValue, 0.45);
        expect(vi.maxValue, 0.91);
        expect(vi.stdDeviation, 0.12);
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = VegetationIndexServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client
              .computeIndices(VegetationIndex(fieldId: 'field-1')),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.method, 'method',
                  '$serviceName/ComputeIndices')),
        );
      });

      test('applies interceptors to request headers', () async {
        final response = VegetationIndex(id: 'vi-1');
        final mockClient = MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer vi-token');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = VegetationIndexServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer vi-token';
              return headers;
            },
          ],
        );

        await client
            .computeIndices(VegetationIndex(fieldId: 'field-1'));
      });
    });

    group('getVegetationIndex', () {
      test('sends correct request and returns index', () async {
        final response = VegetationIndex(
          id: 'vi-1',
          indexType: 'EVI',
          meanValue: 0.65,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetVegetationIndex');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = VegetationIndexServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final vi = await client.getVegetationIndex('vi-1');
        expect(vi.id, 'vi-1');
        expect(vi.indexType, 'EVI');
        expect(vi.meanValue, 0.65);
      });
    });

    group('listVegetationIndices', () {
      test('sends correct request and returns list', () async {
        final response = VegetationIndex(id: 'vi-1', indexType: 'NDVI');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListVegetationIndices');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = VegetationIndexServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final indices = await client.listVegetationIndices();
        expect(indices, isNotEmpty);
        expect(indices.first.indexType, 'NDVI');
      });
    });

    group('getNDVITimeSeries', () {
      test('sends correct request and returns time series', () async {
        final response = NDVITimeSeriesEntry(
          date: Int64(1700000000),
          ndviMean: 0.75,
          ndviMin: 0.50,
          ndviMax: 0.90,
          cloudCoverPct: 10.0,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetNDVITimeSeries');
          final sent = VegetationIndex.fromBuffer(request.bodyBytes);
          expect(sent.farmId, 'farm-1');
          expect(sent.fieldId, 'field-1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = VegetationIndexServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final series =
            await client.getNDVITimeSeries('farm-1', 'field-1');
        expect(series, isNotEmpty);
        expect(series.first.ndviMean, 0.75);
        expect(series.first.ndviMin, 0.50);
        expect(series.first.ndviMax, 0.90);
        expect(series.first.cloudCoverPct, 10.0);
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 503);
        });

        final client = VegetationIndexServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getNDVITimeSeries('farm-1', 'field-1'),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('getFieldHealth', () {
      test('sends correct request and returns field health', () async {
        final response = FieldHealth(
          farmId: 'farm-1',
          fieldId: 'field-1',
          currentNdvi: 0.78,
          ndviTrend: 'improving',
          healthScore: 0.85,
          healthCategory: 'good',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetFieldHealth');
          final sent = FieldHealth.fromBuffer(request.bodyBytes);
          expect(sent.farmId, 'farm-1');
          expect(sent.fieldId, 'field-1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = VegetationIndexServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final health =
            await client.getFieldHealth('farm-1', 'field-1');
        expect(health.currentNdvi, 0.78);
        expect(health.ndviTrend, 'improving');
        expect(health.healthScore, 0.85);
        expect(health.healthCategory, 'good');
      });
    });
  });
}
