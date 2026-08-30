import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName = 'yieldpoint.traceability.v1.TraceabilityService';

  group('TraceabilityServiceClient', () {
    group('getRecord', () {
      test('sends correct request and parses response', () async {
        final response = ProduceRecord(
          id: 'rec-1',
          farmId: 'farm-1',
          cropVariety: 'Hass Avocado',
          certifications: ['GlobalGAP', 'Organic'],
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetRecord');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = TraceabilityServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final record = await client.getRecord('rec-1');
        expect(record.id, 'rec-1');
        expect(record.farmId, 'farm-1');
        expect(record.cropVariety, 'Hass Avocado');
        expect(record.certifications, contains('GlobalGAP'));
        expect(record.certifications, contains('Organic'));
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 404);
        });

        final client = TraceabilityServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getRecord('rec-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.method, 'method',
                  '$serviceName/GetRecord')),
        );
      });

      test('applies interceptors to request headers', () async {
        final response = ProduceRecord(id: 'rec-1');
        final mockClient = MockClient((request) async {
          expect(
              request.headers['Authorization'], 'Bearer trace-token');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = TraceabilityServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer trace-token';
              return headers;
            },
          ],
        );

        await client.getRecord('rec-1');
      });
    });

    group('listRecords', () {
      test('sends correct request and returns list', () async {
        final response = ProduceRecord(
          id: 'rec-1',
          farmId: 'farm-1',
          cropVariety: 'Fuerte Avocado',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListRecords');
          final sent = ProduceRecord.fromBuffer(request.bodyBytes);
          expect(sent.farmId, 'farm-1');
          expect(sent.cropVariety, 'avocado');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = TraceabilityServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final records = await client.listRecords(
          farmId: 'farm-1',
          cropVariety: 'avocado',
        );
        expect(records, isNotEmpty);
        expect(records.first.cropVariety, 'Fuerte Avocado');
      });
    });

    group('createRecord', () {
      test('sends record and returns created record', () async {
        final response = ProduceRecord(
          id: 'rec-new',
          farmId: 'farm-1',
          cropVariety: 'Kent Mango',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/CreateRecord');
          final sent = ProduceRecord.fromBuffer(request.bodyBytes);
          expect(sent.farmId, 'farm-1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = TraceabilityServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final record = await client.createRecord(
            ProduceRecord(farmId: 'farm-1', cropVariety: 'Kent Mango'));
        expect(record.id, 'rec-new');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 400);
        });

        final client = TraceabilityServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client
              .createRecord(ProduceRecord(farmId: 'farm-1')),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('updateRecord', () {
      test('sends updated record and returns result', () async {
        final response = ProduceRecord(
          id: 'rec-1',
          cropVariety: 'Updated Variety',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/UpdateRecord');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = TraceabilityServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final record = await client.updateRecord(
            ProduceRecord(id: 'rec-1', cropVariety: 'Updated Variety'));
        expect(record.cropVariety, 'Updated Variety');
      });
    });

    group('deleteRecord', () {
      test('sends delete request with correct URL', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/DeleteRecord');
          final sent = ProduceRecord.fromBuffer(request.bodyBytes);
          expect(sent.id, 'rec-1');
          return http.Response.bytes(
              ProduceRecord().writeToBuffer(), 200);
        });

        final client = TraceabilityServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        await client.deleteRecord('rec-1');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 403);
        });

        final client = TraceabilityServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.deleteRecord('rec-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 403)),
        );
      });
    });

    group('addCertification', () {
      test('sends certification and returns updated record', () async {
        final response = ProduceRecord(
          id: 'rec-1',
          certifications: ['GlobalGAP', 'Organic'],
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/AddCertification');
          final sent = ProduceRecord.fromBuffer(request.bodyBytes);
          expect(sent.id, 'rec-1');
          expect(sent.certifications, contains('Organic'));
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = TraceabilityServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final record = await client.addCertification(
          recordId: 'rec-1',
          certification: 'Organic',
        );
        expect(record.certifications, hasLength(2));
      });
    });

    group('addTreatment', () {
      test('sends treatment and returns updated record', () async {
        final response = ProduceRecord(
          id: 'rec-1',
          treatments: ['pesticide_spray', 'fungicide_application'],
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/AddTreatment');
          final sent = ProduceRecord.fromBuffer(request.bodyBytes);
          expect(sent.id, 'rec-1');
          expect(sent.treatments, contains('fungicide_application'));
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = TraceabilityServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final record = await client.addTreatment(
          recordId: 'rec-1',
          treatment: 'fungicide_application',
        );
        expect(record.treatments, hasLength(2));
      });
    });
  });
}
