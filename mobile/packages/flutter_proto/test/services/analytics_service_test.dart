import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName =
      'agriculture.satellite.analytics.v1.SatelliteAnalyticsService';

  group('AnalyticsServiceClient', () {
    group('detectStress', () {
      test('sends correct request and parses response', () async {
        final response = StressAlert(
          id: 'alert-1',
          farmId: 'farm-1',
          fieldId: 'field-1',
          stressType: 'drought',
          severity: 'high',
          confidence: 0.92,
          affectedAreaHectares: 5.5,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/DetectStress');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = AnalyticsServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final alert = await client.detectStress(
            StressAlert(fieldId: 'field-1'));
        expect(alert.id, 'alert-1');
        expect(alert.stressType, 'drought');
        expect(alert.severity, 'high');
        expect(alert.confidence, 0.92);
        expect(alert.affectedAreaHectares, 5.5);
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = AnalyticsServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.detectStress(StressAlert(fieldId: 'field-1')),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.method, 'method',
                  '$serviceName/DetectStress')),
        );
      });

      test('applies interceptors to request headers', () async {
        final response = StressAlert(id: 'alert-1');
        final mockClient = MockClient((request) async {
          expect(
              request.headers['Authorization'], 'Bearer analytics-tk');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = AnalyticsServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer analytics-tk';
              return headers;
            },
          ],
        );

        await client.detectStress(StressAlert(fieldId: 'field-1'));
      });
    });

    group('listStressAlerts', () {
      test('sends correct request and returns list', () async {
        final response = StressAlert(
          id: 'alert-1',
          farmId: 'farm-1',
          stressType: 'nutrient_deficiency',
          severity: 'medium',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListStressAlerts');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = AnalyticsServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final alerts = await client.listStressAlerts('farm-1');
        expect(alerts, isNotEmpty);
        expect(alerts.first.stressType, 'nutrient_deficiency');
      });
    });

    group('getStressAlert', () {
      test('sends correct request and returns alert', () async {
        final response = StressAlert(
          id: 'alert-1',
          farmId: 'farm-1',
          acknowledged: false,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetStressAlert');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = AnalyticsServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final alert = await client.getStressAlert('alert-1');
        expect(alert.id, 'alert-1');
        expect(alert.acknowledged, false);
      });
    });

    group('acknowledgeAlert', () {
      test('sends acknowledge request with correct URL', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/AcknowledgeAlert');
          final sent = StressAlert.fromBuffer(request.bodyBytes);
          expect(sent.id, 'alert-1');
          return http.Response.bytes(
              StressAlert().writeToBuffer(), 200);
        });

        final client = AnalyticsServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        await client.acknowledgeAlert('alert-1');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 404);
        });

        final client = AnalyticsServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.acknowledgeAlert('alert-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 404)),
        );
      });
    });

    group('getFieldAnalyticsSummary', () {
      test('sends correct request and returns summary', () async {
        final response = FieldAnalyticsSummary(
          farmId: 'farm-1',
          fieldId: 'field-1',
          activeStressAlerts: 2,
          healthScore: 0.85,
          ndviTrend: 'improving',
          dominantStressType: 'water_stress',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetFieldAnalyticsSummary');
          final sent =
              FieldAnalyticsSummary.fromBuffer(request.bodyBytes);
          expect(sent.farmId, 'farm-1');
          expect(sent.fieldId, 'field-1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = AnalyticsServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final summary = await client.getFieldAnalyticsSummary(
            'farm-1', 'field-1');
        expect(summary.activeStressAlerts, 2);
        expect(summary.healthScore, 0.85);
        expect(summary.ndviTrend, 'improving');
        expect(summary.dominantStressType, 'water_stress');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 503);
        });

        final client = AnalyticsServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getFieldAnalyticsSummary('farm-1', 'field-1'),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('runTemporalAnalysis', () {
      test('sends correct request and returns result', () async {
        final response = TemporalAnalysisResult(
          farmId: 'farm-1',
          fieldId: 'field-1',
          analysisType: 'ndvi_trend',
          dataPoints: 30,
          summary: 'Steady improvement over the period',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/RunTemporalAnalysis');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = AnalyticsServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final result = await client.runTemporalAnalysis(
            TemporalAnalysisResult(
          farmId: 'farm-1',
          fieldId: 'field-1',
          analysisType: 'ndvi_trend',
        ));
        expect(result.dataPoints, 30);
        expect(result.summary, 'Steady improvement over the period');
      });
    });
  });
}
