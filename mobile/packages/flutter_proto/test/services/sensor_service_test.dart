import 'package:fixnum/fixnum.dart';
import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName = 'yieldpoint.sensor.v1.SensorService';

  group('SensorServiceClient', () {
    group('getReading', () {
      test('sends correct request and parses response', () async {
        final response = SensorReading(
          sensorId: 'sensor-1',
          type: SensorType.TEMPERATURE,
          value: 25.5,
          unit: 'celsius',
          timestamp: Int64(1700000000),
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetReading');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SensorServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final reading = await client.getReading(sensorId: 'sensor-1');
        expect(reading.sensorId, 'sensor-1');
        expect(reading.type, SensorType.TEMPERATURE);
        expect(reading.value, 25.5);
        expect(reading.unit, 'celsius');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = SensorServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getReading(sensorId: 'sensor-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.method, 'method',
                  '$serviceName/GetReading')),
        );
      });

      test('applies interceptors to request headers', () async {
        final response = SensorReading(sensorId: 'sensor-1');
        final mockClient = MockClient((request) async {
          expect(
              request.headers['Authorization'], 'Bearer sensor-token');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SensorServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer sensor-token';
              return headers;
            },
          ],
        );

        await client.getReading(sensorId: 'sensor-1');
      });
    });

    group('listReadings', () {
      test('sends correct request and returns list', () async {
        final response = SensorReading(
          sensorId: 'sensor-1',
          type: SensorType.SOIL_MOISTURE,
          value: 0.42,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListReadings');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SensorServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final readings = await client.listReadings(
          sensorId: 'sensor-1',
          type: SensorType.SOIL_MOISTURE,
        );
        expect(readings, isNotEmpty);
        expect(readings.first.value, 0.42);
      });
    });

    group('recordReading', () {
      test('sends reading and returns recorded reading', () async {
        final response = SensorReading(
          sensorId: 'sensor-1',
          type: SensorType.HUMIDITY,
          value: 65.0,
          unit: 'percent',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/RecordReading');
          final sent = SensorReading.fromBuffer(request.bodyBytes);
          expect(sent.sensorId, 'sensor-1');
          expect(sent.value, 65.0);
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SensorServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final reading = await client.recordReading(SensorReading(
          sensorId: 'sensor-1',
          type: SensorType.HUMIDITY,
          value: 65.0,
        ));
        expect(reading.unit, 'percent');
      });
    });

    group('getDashboard', () {
      test('sends correct request and returns dashboard', () async {
        final response = SensorDashboard(
          sensorId: 'sensor-1',
          stats: SensorStats(min: 10.0, max: 35.0, mean: 22.5),
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetDashboard');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = SensorServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final dashboard = await client.getDashboard('sensor-1');
        expect(dashboard.sensorId, 'sensor-1');
        expect(dashboard.stats.min, 10.0);
        expect(dashboard.stats.max, 35.0);
        expect(dashboard.stats.mean, 22.5);
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 404);
        });

        final client = SensorServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getDashboard('sensor-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 404)),
        );
      });
    });

    group('streamReadings', () {
      test('streams sensor readings from server', () async {
        final reading1 = SensorReading(
          sensorId: 'sensor-1',
          type: SensorType.TEMPERATURE,
          value: 22.0,
        );
        final reading2 = SensorReading(
          sensorId: 'sensor-1',
          type: SensorType.TEMPERATURE,
          value: 23.0,
        );

        final mockClient = MockClient.streaming((request, sink) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/StreamReadings');
          expect(request.headers['Connect-Content-Encoding'], 'identity');
          sink.add(reading1.writeToBuffer());
          sink.add(reading2.writeToBuffer());
          sink.close();
        });

        final client = SensorServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final readings =
            await client.streamReadings('sensor-1').toList();
        expect(readings, hasLength(2));
        expect(readings[0].value, 22.0);
        expect(readings[1].value, 23.0);
      });
    });

    group('streamReadingsByType', () {
      test('streams filtered readings from server', () async {
        final reading = SensorReading(
          sensorId: 'sensor-1',
          type: SensorType.SOIL_PH,
          value: 6.8,
        );

        final mockClient = MockClient.streaming((request, sink) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/StreamReadingsByType');
          sink.add(reading.writeToBuffer());
          sink.close();
        });

        final client = SensorServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final readings = await client
            .streamReadingsByType(
              sensorId: 'sensor-1',
              type: SensorType.SOIL_PH,
            )
            .toList();
        expect(readings, hasLength(1));
        expect(readings.first.type, SensorType.SOIL_PH);
        expect(readings.first.value, 6.8);
      });
    });
  });
}
