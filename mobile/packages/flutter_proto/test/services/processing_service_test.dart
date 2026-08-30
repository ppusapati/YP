import 'package:flutter_proto/flutter_proto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const serviceName =
      'yieldpoint.satellite.processing.v1.SatelliteProcessingService';

  group('ProcessingServiceClient', () {
    group('submitProcessingJob', () {
      test('sends correct request and parses response', () async {
        final response = ProcessingJob(
          id: 'job-1',
          ingestionTaskId: 'task-1',
          farmId: 'farm-1',
          status: 'QUEUED',
          applyCloudMasking: true,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/SubmitProcessingJob');
          expect(request.headers['Content-Type'], 'application/proto');
          expect(request.headers['Connect-Protocol-Version'], '1');
          final sent = ProcessingJob.fromBuffer(request.bodyBytes);
          expect(sent.ingestionTaskId, 'task-1');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = ProcessingServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final job = await client.submitProcessingJob(ProcessingJob(
          ingestionTaskId: 'task-1',
          farmId: 'farm-1',
          applyCloudMasking: true,
        ));
        expect(job.id, 'job-1');
        expect(job.status, 'QUEUED');
        expect(job.applyCloudMasking, true);
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 500);
        });

        final client = ProcessingServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.submitProcessingJob(ProcessingJob(farmId: 'f')),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.method, 'method',
                  '$serviceName/SubmitProcessingJob')),
        );
      });

      test('applies interceptors to request headers', () async {
        final response = ProcessingJob(id: 'job-1');
        final mockClient = MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer proc-token');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = ProcessingServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
          interceptors: [
            (headers) async {
              headers['Authorization'] = 'Bearer proc-token';
              return headers;
            },
          ],
        );

        await client
            .submitProcessingJob(ProcessingJob(farmId: 'farm-1'));
      });
    });

    group('getProcessingJob', () {
      test('sends correct request and returns job', () async {
        final response = ProcessingJob(
          id: 'job-1',
          status: 'COMPLETED',
          outputCrs: 'EPSG:4326',
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetProcessingJob');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = ProcessingServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final job = await client.getProcessingJob('job-1');
        expect(job.id, 'job-1');
        expect(job.status, 'COMPLETED');
        expect(job.outputCrs, 'EPSG:4326');
      });
    });

    group('listProcessingJobs', () {
      test('sends correct request and returns list', () async {
        final response =
            ProcessingJob(id: 'job-1', status: 'RUNNING');
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/ListProcessingJobs');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = ProcessingServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final jobs = await client.listProcessingJobs();
        expect(jobs, isNotEmpty);
        expect(jobs.first.status, 'RUNNING');
      });
    });

    group('cancelProcessingJob', () {
      test('sends cancel request with correct URL', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/CancelProcessingJob');
          final sent = ProcessingJob.fromBuffer(request.bodyBytes);
          expect(sent.id, 'job-1');
          return http.Response.bytes(
              ProcessingJob().writeToBuffer(), 200);
        });

        final client = ProcessingServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        await client.cancelProcessingJob('job-1');
      });

      test('throws ServiceException on error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('error', 403);
        });

        final client = ProcessingServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        expect(
          () => client.cancelProcessingJob('job-1'),
          throwsA(isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 403)),
        );
      });
    });

    group('getProcessingStats', () {
      test('sends correct request and returns stats', () async {
        final response = ProcessingStats(
          totalJobs: 50,
          completedJobs: 40,
          failedJobs: 3,
          pendingJobs: 7,
        );
        final mockClient = MockClient((request) async {
          expect(request.url.toString(),
              '$baseUrl/$serviceName/GetProcessingStats');
          return http.Response.bytes(response.writeToBuffer(), 200);
        });

        final client = ProcessingServiceClient(
          baseUrl: baseUrl,
          httpClient: mockClient,
        );

        final stats = await client.getProcessingStats();
        expect(stats.totalJobs, 50);
        expect(stats.completedJobs, 40);
        expect(stats.failedJobs, 3);
        expect(stats.pendingJobs, 7);
      });
    });
  });
}
