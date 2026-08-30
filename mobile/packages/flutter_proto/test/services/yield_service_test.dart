import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName = 'yieldpoint.yield.v1.YieldService';

  group('YieldServiceClient', () {
    group('getYieldPrediction', () {
      test('sends correct request and parses response', () async {
        final response = YieldPrediction(
          fieldId: 'field-1',
          cropType: 'wheat',
          expectedYield: 5.2,
          confidence: 0.89,
          factors: [
            YieldFactor(name: 'soil_quality', impact: 0.3, value: 0.8),
            YieldFactor(name: 'rainfall', impact: 0.5, value: 0.7),
          ],
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetYieldPrediction');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = YieldServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final prediction =
            await client.getYieldPrediction('field-1');
        expect(prediction.fieldId, 'field-1');
        expect(prediction.cropType, 'wheat');
        expect(prediction.expectedYield, 5.2);
        expect(prediction.confidence, 0.89);
        expect(prediction.factors, hasLength(2));
        expect(prediction.factors.first.name, 'soil_quality');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = YieldServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getYieldPrediction('field-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.method, 'method',
                  '$serviceName/GetYieldPrediction')),
        );
      });

      test('applies interceptors to request headers', () async {
        final response = YieldPrediction(fieldId: 'field-1');
        final mockClient = MockClient((request) async {
          expect(
              request.headers['Authorization'], 'Bearer yield-token');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = YieldServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer yield-token';
              return headers;
            },
          ],
        );

        await client.getYieldPrediction('field-1');
      });
    });

    group('listYieldPredictions', () {
      test('sends correct request and returns list', () async {
        final response = YieldPrediction(
          fieldId: 'field-1',
          cropType: 'corn',
          expectedYield: 8.5,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListYieldPredictions');
          final sent = YieldPrediction.fromBuffer(request.bodyBytes);
          expect(sent.fieldId, 'field-1');
          expect(sent.cropType, 'corn');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = YieldServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final predictions = await client.listYieldPredictions(
          fieldId: 'field-1',
          cropType: 'corn',
        );
        expect(predictions, isNotEmpty);
        expect(predictions.first.expectedYield, 8.5);
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 503);
        });

        final client = YieldServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.listYieldPredictions(fieldId: 'field-1'),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('getSoilAnalysis', () {
      test('sends correct request and returns analysis', () async {
        final response = SoilAnalysis(
          fieldId: 'field-1',
          pH: 6.5,
          nitrogen: 40.0,
          phosphorus: 25.0,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetSoilAnalysis');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = YieldServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final analysis = await client.getSoilAnalysis('field-1');
        expect(analysis.fieldId, 'field-1');
        expect(analysis.pH, 6.5);
      });
    });

    group('submitSoilAnalysis', () {
      test('sends analysis and returns result', () async {
        final response = SoilAnalysis(
          fieldId: 'field-1',
          pH: 7.0,
          texture: 'sandy_loam',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/SubmitSoilAnalysis');
          final sent = SoilAnalysis.fromBuffer(request.bodyBytes);
          expect(sent.fieldId, 'field-1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = YieldServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final analysis = await client.submitSoilAnalysis(
            SoilAnalysis(fieldId: 'field-1', pH: 7.0));
        expect(analysis.texture, 'sandy_loam');
      });
    });

    group('getCropRecommendations', () {
      test('sends correct request and returns recommendations',
          () async {
        final response = CropRecommendation(
          cropName: 'Sorghum',
          plantingWindow: 'March-April',
          soilSuitability: 0.85,
          expectedYield: 4.2,
          reasons: ['drought_tolerant', 'good_soil_match'],
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetCropRecommendations');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = YieldServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final recs =
            await client.getCropRecommendations('field-1');
        expect(recs, isNotEmpty);
        expect(recs.first.cropName, 'Sorghum');
        expect(recs.first.plantingWindow, 'March-April');
        expect(recs.first.soilSuitability, 0.85);
        expect(recs.first.reasons, contains('drought_tolerant'));
      });
    });

    group('streamYieldUpdates', () {
      test('streams yield prediction data from server', () async {
        final pred = YieldPrediction(
          fieldId: 'field-1',
          expectedYield: 5.3,
          confidence: 0.85,
        );

        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/StreamYieldUpdates');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(
              request.headers['Connect-Content-Encoding'], 'identity');
          return http.Response.bytes(pred.writeToBuffer(), 200);
        });

        final client = YieldServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final updates =
            await client.streamYieldUpdates('field-1').toList();
        expect(updates, hasLength(1));
        expect(updates.first.expectedYield, 5.3);
        expect(updates.first.confidence, 0.85);
      });
    });
  });
}
