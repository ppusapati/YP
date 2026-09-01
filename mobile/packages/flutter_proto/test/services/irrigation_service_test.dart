import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName = 'agriculture.irrigation.v1.IrrigationService';

  group('IrrigationServiceClient', () {
    group('getZone', () {
      test('sends correct request and parses response', () async {
        final response = IrrigationZone(
          id: 'zone-1',
          fieldId: 'field-1',
          moistureLevel: 0.65,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetZone');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IrrigationServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final zone = await client.getZone('zone-1');
        expect(zone.id, 'zone-1');
        expect(zone.fieldId, 'field-1');
        expect(zone.moistureLevel, 0.65);
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = IrrigationServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getZone('zone-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.method, 'method',
                  '$serviceName/GetZone')),
        );
      });

      test('applies interceptors to request headers', () async {
        final response = IrrigationZone(id: 'zone-1');
        final mockClient = MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer irr-token');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IrrigationServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer irr-token';
              return headers;
            },
          ],
        );

        await client.getZone('zone-1');
      });
    });

    group('listZones', () {
      test('sends correct request and returns list', () async {
        final response = IrrigationZone(fieldId: 'field-1', id: 'zone-1');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListZones');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IrrigationServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final zones = await client.listZones('field-1');
        expect(zones, isNotEmpty);
        expect(zones.first.id, 'zone-1');
      });
    });

    group('createZone', () {
      test('sends zone and returns created zone', () async {
        final response = IrrigationZone(
          id: 'zone-new',
          fieldId: 'field-1',
          moistureLevel: 0.50,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/CreateZone');
          final sent = IrrigationZone.fromBuffer(request.bodyBytes);
          expect(sent.fieldId, 'field-1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IrrigationServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final zone = await client
            .createZone(IrrigationZone(fieldId: 'field-1'));
        expect(zone.id, 'zone-new');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 400);
        });

        final client = IrrigationServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.createZone(IrrigationZone(fieldId: 'f')),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('getSchedule', () {
      test('sends correct request and returns schedule', () async {
        final response = IrrigationSchedule(
          zoneId: 'zone-1',
          duration: 3600,
          waterVolume: 500.0,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetSchedule');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IrrigationServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final schedule = await client.getSchedule('zone-1');
        expect(schedule.zoneId, 'zone-1');
        expect(schedule.duration, 3600);
        expect(schedule.waterVolume, 500.0);
      });
    });

    group('setSchedule', () {
      test('sends schedule and returns result', () async {
        final response = IrrigationSchedule(
          zoneId: 'zone-1',
          duration: 7200,
          waterVolume: 1000.0,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/SetSchedule');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IrrigationServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final schedule = await client.setSchedule(
            IrrigationSchedule(zoneId: 'zone-1', duration: 7200));
        expect(schedule.waterVolume, 1000.0);
      });
    });

    group('listAlerts', () {
      test('sends correct request and returns alerts', () async {
        final response = IrrigationAlert(
          zoneId: 'zone-1',
          alertType: 'low_moisture',
          severity: 'high',
          message: 'Moisture below threshold',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListAlerts');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IrrigationServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final alerts = await client.listAlerts('zone-1');
        expect(alerts, isNotEmpty);
        expect(alerts.first.alertType, 'low_moisture');
        expect(alerts.first.severity, 'high');
      });
    });

    group('streamAlerts', () {
      test('streams alert data from server and parses first chunk',
          () async {
        final alert = IrrigationAlert(
          zoneId: 'zone-1',
          alertType: 'low_moisture',
          severity: 'high',
        );

        // MockClient wraps send() for StreamedRequest too.
        // The response body bytes arrive as a single chunk.
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/StreamAlerts');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          expect(
              request.headers['Connect-Content-Encoding'], 'identity');
          return http.Response.bytes(alert.writeToBuffer(), 200);
        });

        final client = IrrigationServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final alerts = await client.streamAlerts('zone-1').toList();
        expect(alerts, hasLength(1));
        expect(alerts.first.alertType, 'low_moisture');
        expect(alerts.first.severity, 'high');
      });

      test('throws ServiceException on non-200 stream status',
          () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = IrrigationServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.streamAlerts('zone-1').toList(),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('deleteZone', () {
      test('sends delete request with correct URL', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/DeleteZone');
          final sent = IrrigationZone.fromBuffer(request.bodyBytes);
          expect(sent.id, 'zone-1');
          return http.Response.bytes(
              IrrigationZone().writeToBuffer(), 200);
        });

        final client = IrrigationServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        await client.deleteZone('zone-1');
      });
    });
  });
}
