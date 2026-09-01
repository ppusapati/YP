import 'package:flutter_proto/src/generated/farm.pb.dart';
import 'package:flutter_proto/src/services/farm_service.dart';
import 'package:flutter_proto/src/services/base_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName = 'agriculture.farm.v1.FarmService';

  group('FarmServiceClient', () {
    group('getFarm', () {
      test('sends correct request and parses response', () async {
        final responseFarm = GetFarmResponse(
          farm: Farm(id: 'farm-1', name: 'Test Farm'),
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(), '$baseUrl/$serviceName/GetFarm');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          return http.Response.bytes(responseFarm.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final result = await client.getFarm('farm-1');
        expect(result.farm.id, 'farm-1');
        expect(result.farm.name, 'Test Farm');
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
              .having((e) => e.method, 'method', '$serviceName/GetFarm')),
        );
      });

      test('applies interceptors to request headers', () async {
        final responseFarm = GetFarmResponse(
          farm: Farm(id: 'farm-1'),
        );
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
        final responseList = ListFarmsResponse(
          farms: [Farm(name: 'Farm A')],
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(), '$baseUrl/$serviceName/ListFarms');
          expect(request.headers['Content-Type'], 'application/proto');
          return http.Response.bytes(responseList.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final response = await client.listFarms();
        expect(response.farms, isNotEmpty);
        expect(response.farms.first.name, 'Farm A');
      });
    });

    group('createFarm', () {
      test('sends request and returns created farm', () async {
        final responseCreate = CreateFarmResponse(
          farm: Farm(id: 'new-farm', name: 'New Farm'),
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(), '$baseUrl/$serviceName/CreateFarm');
          final sentReq = CreateFarmRequest.fromBuffer(request.bodyBytes);
          expect(sentReq.name, 'New Farm');
          return http.Response.bytes(responseCreate.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final result = await client.createFarm(
          CreateFarmRequest(name: 'New Farm'),
        );
        expect(result.farm.id, 'new-farm');
        expect(result.farm.name, 'New Farm');
      });
    });

    group('updateFarm', () {
      test('sends updated farm and returns result', () async {
        final responseUpdate = UpdateFarmResponse(
          farm: Farm(id: 'farm-1', name: 'Updated Farm'),
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(), '$baseUrl/$serviceName/UpdateFarm');
          return http.Response.bytes(responseUpdate.writeToBuffer(), 200);
        });

        final client = FarmServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final result = await client.updateFarm(
          UpdateFarmRequest(id: 'farm-1', name: 'Updated Farm'),
        );
        expect(result.farm.name, 'Updated Farm');
      });
    });

    group('deleteFarm', () {
      test('sends delete request with correct URL', () async {
        final responseDelete = DeleteFarmResponse();
        final mockClient = MockClient((request) async {
          expect(request.url.toString(), '$baseUrl/$serviceName/DeleteFarm');
          final sentReq = DeleteFarmRequest.fromBuffer(request.bodyBytes);
          expect(sentReq.id, 'farm-1');
          return http.Response.bytes(responseDelete.writeToBuffer(), 200);
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
  });
}
