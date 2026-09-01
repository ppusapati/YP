import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName = 'agriculture.pest.v1.PestPredictionService';

  group('PestPredictionServiceClient', () {
    group('predictPestRisk', () {
      test('sends correct request and parses response', () async {
        final response = PestRiskZone(
          id: 'pred-1',
          fieldId: 'field-1',
          riskLevel: PestRiskLevel.HIGH,
          pestType: 'aphids',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/PredictPestRisk');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = PestPredictionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final prediction = await client.predictPestRisk('field-1');
        expect(prediction.id, 'pred-1');
        expect(prediction.fieldId, 'field-1');
        expect(prediction.riskLevel, PestRiskLevel.HIGH);
        expect(prediction.pestType, 'aphids');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = PestPredictionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.predictPestRisk('field-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.method, 'method',
                  '$serviceName/PredictPestRisk')),
        );
      });

      test('applies interceptors to request headers', () async {
        final response = PestRiskZone(id: 'pred-1');
        final mockClient = MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer pest-token');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = PestPredictionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer pest-token';
              return headers;
            },
          ],
        );

        await client.predictPestRisk('field-1');
      });
    });

    group('getPrediction', () {
      test('sends correct request and returns prediction', () async {
        final response = PestRiskZone(
          id: 'pred-1',
          riskLevel: PestRiskLevel.MODERATE,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetPrediction');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = PestPredictionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final prediction = await client.getPrediction('pred-1');
        expect(prediction.id, 'pred-1');
        expect(prediction.riskLevel, PestRiskLevel.MODERATE);
      });
    });

    group('listPredictions', () {
      test('sends correct request and returns list', () async {
        final response = PestRiskZone(
          id: 'pred-1',
          fieldId: 'field-1',
          riskLevel: PestRiskLevel.LOW,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListPredictions');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = PestPredictionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final predictions = await client.listPredictions('field-1');
        expect(predictions, isNotEmpty);
        expect(predictions.first.riskLevel, PestRiskLevel.LOW);
      });
    });

    group('reportObservation', () {
      test('sends observation and returns result', () async {
        final response = PestRiskZone(
          id: 'obs-1',
          fieldId: 'field-1',
          pestType: 'whitefly',
          riskLevel: PestRiskLevel.CRITICAL,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ReportObservation');
          final sent = PestRiskZone.fromBuffer(request.bodyBytes);
          expect(sent.fieldId, 'field-1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = PestPredictionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final obs = await client.reportObservation(
            PestRiskZone(fieldId: 'field-1', pestType: 'whitefly'));
        expect(obs.id, 'obs-1');
        expect(obs.riskLevel, PestRiskLevel.CRITICAL);
      });
    });

    group('getTreatmentPlan', () {
      test('sends correct request and returns treatment plan', () async {
        final response = PestRiskZone(
          id: 'pred-1',
          pestType: 'aphids',
          riskLevel: PestRiskLevel.HIGH,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetTreatmentPlan');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = PestPredictionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final plan = await client.getTreatmentPlan('pred-1');
        expect(plan.id, 'pred-1');
        expect(plan.pestType, 'aphids');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 404);
        });

        final client = PestPredictionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getTreatmentPlan('pred-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 404)),
        );
      });
    });

    group('getRiskMap', () {
      test('sends correct request and returns risk zones', () async {
        final response = PestRiskZone(
          fieldId: 'farm-1',
          riskLevel: PestRiskLevel.MODERATE,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetRiskMap');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = PestPredictionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final zones = await client.getRiskMap('farm-1');
        expect(zones, isNotEmpty);
      });
    });

    group('acknowledgeAlert', () {
      test('sends acknowledge request with correct URL', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/AcknowledgeAlert');
          final sent = PestRiskZone.fromBuffer(request.bodyBytes);
          expect(sent.id, 'alert-1');
          return http.Response.bytes(
              PestRiskZone().writeToBuffer(), 200);
        });

        final client = PestPredictionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        await client.acknowledgeAlert('alert-1');
      });
    });
  });
}
