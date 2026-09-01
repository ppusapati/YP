import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName = 'agriculture.farm.v1.FarmService';

  group('FarmServiceClient', () {
    group('getFarm', () {
      test('sends correct request and parses response', () async {
        final responseFarm = Farm(id: 'farm-1', name: 'Test Farm');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetFarm');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          return http.Response.bytes(responseFarm.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final farm = await client.getFarm('farm-1');
        expect(farm.id, 'farm-1');
        expect(farm.name, 'Test Farm');
      });

      test('throws ServiceException on non-200 status', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getFarm('farm-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.method, 'method',
                  '$serviceName/GetFarm')),
        );
      });

      test('applies interceptors to request headers', () async {
        final responseFarm = Farm(id: 'farm-1');
        final mockClient = MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer test-token');
          return http.Response.bytes(responseFarm.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer test-token';
              return headers;
            },
          ],
        );

        await client.getFarm('farm-1');
      });
    });

    group('listFarms', () {
      test('sends correct request and returns response', () async {
        final responseFarm = Farm(ownerId: 'owner-1', name: 'Farm A');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListFarms');
          expect(request.headers['Content-Type'], 'application/proto');
          return http.Response.bytes(responseFarm.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final response = await client.listFarms(ownerId: 'owner-1');
        expect(response.farms, isNotEmpty);
        expect(response.farms.first.ownerId, 'owner-1');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('not found', 404);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.listFarms(ownerId: 'owner-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 404)),
        );
      });
    });

    group('createFarm', () {
      test('sends farm and returns created farm', () async {
        final responseFarm =
            Farm(id: 'new-farm', name: 'New Farm', ownerId: 'owner-1');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/CreateFarm');
          final sentFarm = Farm.fromBuffer(request.bodyBytes);
          expect(sentFarm.name, 'New Farm');
          return http.Response.bytes(responseFarm.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final farm =
            await client.createFarm(Farm(name: 'New Farm', ownerId: 'owner-1'));
        expect(farm.id, 'new-farm');
        expect(farm.name, 'New Farm');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 400);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.createFarm(Farm(name: 'Test')),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 400)),
        );
      });
    });

    group('updateFarm', () {
      test('sends updated farm and returns result', () async {
        final responseFarm = Farm(id: 'farm-1', name: 'Updated Farm');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/UpdateFarm');
          return http.Response.bytes(responseFarm.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final farm = await client
            .updateFarm(Farm(id: 'farm-1', name: 'Updated Farm'));
        expect(farm.name, 'Updated Farm');
      });
    });

    group('deleteFarm', () {
      test('sends delete request with correct URL', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/DeleteFarm');
          final sentFarm = Farm.fromBuffer(request.bodyBytes);
          expect(sentFarm.id, 'farm-1');
          return http.Response.bytes(Farm().writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        await client.deleteFarm('farm-1');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 403);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.deleteFarm('farm-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 403)),
        );
      });
    });

    group('getField', () {
      test('sends correct request and parses response', () async {
        final responseField =
            Field(id: 'field-1', farmId: 'farm-1', name: 'North Field');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetField');
          return http.Response.bytes(responseField.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final field = await client.getField('field-1');
        expect(field.id, 'field-1');
        expect(field.name, 'North Field');
      });
    });

    group('listFields', () {
      test('sends correct request and returns list', () async {
        final responseField = Field(farmId: 'farm-1', name: 'Field A');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListFields');
          return http.Response.bytes(responseField.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final fields = await client.listFields('farm-1');
        expect(fields, isNotEmpty);
        expect(fields.first.farmId, 'farm-1');
      });
    });

    group('createField', () {
      test('sends field and returns created field', () async {
        final responseField =
            Field(id: 'field-new', farmId: 'farm-1', name: 'New Field');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/CreateField');
          return http.Response.bytes(responseField.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final field = await client.createField(
            Field(farmId: 'farm-1', name: 'New Field'));
        expect(field.id, 'field-new');
      });
    });

    group('updateField', () {
      test('sends updated field and returns result', () async {
        final responseField = Field(id: 'field-1', name: 'Updated Field');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/UpdateField');
          return http.Response.bytes(responseField.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final field = await client
            .updateField(Field(id: 'field-1', name: 'Updated Field'));
        expect(field.name, 'Updated Field');
      });
    });

    group('deleteField', () {
      test('sends delete request with correct URL', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/DeleteField');
          final sentField = Field.fromBuffer(request.bodyBytes);
          expect(sentField.id, 'field-1');
          return http.Response.bytes(Field().writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        await client.deleteField('field-1');
      });
    });
  });
}
