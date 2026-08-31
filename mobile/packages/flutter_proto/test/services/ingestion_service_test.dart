import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName =
      'yieldpoint.satellite.ingestion.v1.SatelliteIngestionService';

  group('IngestionServiceClient', () {
    group('requestIngestion', () {
      test('sends correct request and parses response', () async {
        final response = IngestionTask(
          id: 'task-1',
          farmId: 'farm-1',
          provider: 'sentinel-2',
          status: 'PENDING',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/RequestIngestion');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          final sent = IngestionTask.fromBuffer(request.bodyBytes);
          expect(sent.farmId, 'farm-1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IngestionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final task = await client.requestIngestion(
            IngestionTask(farmId: 'farm-1', provider: 'sentinel-2'));
        expect(task.id, 'task-1');
        expect(task.status, 'PENDING');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = IngestionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.requestIngestion(IngestionTask(farmId: 'farm-1')),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.method, 'method',
                  '$serviceName/RequestIngestion')),
        );
      });

      test('applies interceptors to request headers', () async {
        final response = IngestionTask(id: 'task-1');
        final mockClient = MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer ing-token');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IngestionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer ing-token';
              return headers;
            },
          ],
        );

        await client.requestIngestion(IngestionTask(farmId: 'farm-1'));
      });
    });

    group('getIngestionTask', () {
      test('sends correct request and returns task', () async {
        final response = IngestionTask(
          id: 'task-1',
          farmId: 'farm-1',
          status: 'COMPLETED',
          provider: 'sentinel-2',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetIngestionTask');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IngestionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final task = await client.getIngestionTask('task-1');
        expect(task.id, 'task-1');
        expect(task.status, 'COMPLETED');
      });
    });

    group('listIngestionTasks', () {
      test('sends correct request and returns list', () async {
        final response = IngestionTask(id: 'task-1', status: 'RUNNING');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListIngestionTasks');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IngestionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final tasks = await client.listIngestionTasks();
        expect(tasks, isNotEmpty);
        expect(tasks.first.status, 'RUNNING');
      });
    });

    group('cancelIngestion', () {
      test('sends cancel request with correct URL', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/CancelIngestion');
          final sent = IngestionTask.fromBuffer(request.bodyBytes);
          expect(sent.id, 'task-1');
          return http.Response.bytes(
              IngestionTask().writeToBuffer(), 200);
        });

        final client = IngestionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        await client.cancelIngestion('task-1');
      });
    });

    group('retryIngestion', () {
      test('sends retry request and returns task', () async {
        final response =
            IngestionTask(id: 'task-1', status: 'RETRYING');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/RetryIngestion');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IngestionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final task = await client.retryIngestion('task-1');
        expect(task.status, 'RETRYING');
      });
    });

    group('getIngestionStats', () {
      test('sends correct request and returns stats', () async {
        final response = IngestionStats(
          totalTasks: 100,
          completedTasks: 80,
          failedTasks: 5,
          pendingTasks: 15,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetIngestionStats');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = IngestionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final stats = await client.getIngestionStats();
        expect(stats.totalTasks, 100);
        expect(stats.completedTasks, 80);
        expect(stats.failedTasks, 5);
        expect(stats.pendingTasks, 15);
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 503);
        });

        final client = IngestionServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.getIngestionStats(),
          throwsA(isA<ServiceException>()),
        );
      });
    });
  });
}
