import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName = 'agriculture.soil.v1.SoilService';

  group('SoilServiceClient', () {
    group('getSoilSample', () {
      test('sends correct request and parses response', () async {
        final response = SoilAnalysis(
          fieldId: 'field-1',
          pH: 6.5,
          nitrogen: 40.0,
          texture: 'clay',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetSoilSample');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SoilServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final sample = await client.getSoilSample('field-1');
        expect(sample.fieldId, 'field-1');
        expect(sample.pH, 6.5);
        expect(sample.nitrogen, 40.0);
        expect(sample.texture, 'clay');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = SoilServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getSoilSample('field-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.method, 'method',
                  '$serviceName/GetSoilSample')),
        );
      });

      test('applies interceptors to request headers', () async {
        final response = SoilAnalysis(fieldId: 'field-1');
        final mockClient = MockClient((request) async {
          expect(request.headers['X-Api-Key'], 'soil-key');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SoilServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['X-Api-Key'] = 'soil-key';
              return headers;
            },
          ],
        );

        await client.getSoilSample('field-1');
      });
    });

    group('listSoilSamples', () {
      test('sends correct request and returns list', () async {
        final response = SoilAnalysis(fieldId: 'field-1', pH: 7.0);
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListSoilSamples');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SoilServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final samples = await client.listSoilSamples('field-1');
        expect(samples, isNotEmpty);
        expect(samples.first.pH, 7.0);
      });
    });

    group('createSoilSample', () {
      test('sends sample and returns created sample', () async {
        final response = SoilAnalysis(
          fieldId: 'field-1',
          pH: 6.8,
          organicCarbon: 2.5,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/CreateSoilSample');
          final sent = SoilAnalysis.fromBuffer(request.bodyBytes);
          expect(sent.fieldId, 'field-1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SoilServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final sample = await client
            .createSoilSample(SoilAnalysis(fieldId: 'field-1', pH: 6.8));
        expect(sample.organicCarbon, 2.5);
      });
    });

    group('analyzeSoil', () {
      test('sends correct request and returns analysis', () async {
        final response = SoilAnalysis(
          fieldId: 'field-1',
          pH: 6.2,
          phosphorus: 30.0,
          potassium: 150.0,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/AnalyzeSoil');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SoilServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final analysis = await client.analyzeSoil('field-1');
        expect(analysis.fieldId, 'field-1');
        expect(analysis.phosphorus, 30.0);
        expect(analysis.potassium, 150.0);
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 503);
        });

        final client = SoilServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.analyzeSoil('field-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 503)),
        );
      });
    });

    group('getSoilHealth', () {
      test('sends correct request and returns result', () async {
        final response = SoilAnalysis(fieldId: 'field-1', pH: 7.2);
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetSoilHealth');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SoilServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final health = await client.getSoilHealth('field-1');
        expect(health.fieldId, 'field-1');
      });
    });

    group('getNutrientLevels', () {
      test('sends correct request and returns result', () async {
        final response = SoilAnalysis(
          fieldId: 'field-1',
          nitrogen: 45.0,
          phosphorus: 20.0,
          potassium: 180.0,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetNutrientLevels');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SoilServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final nutrients = await client.getNutrientLevels('field-1');
        expect(nutrients.nitrogen, 45.0);
        expect(nutrients.phosphorus, 20.0);
        expect(nutrients.potassium, 180.0);
      });
    });
  });
}
