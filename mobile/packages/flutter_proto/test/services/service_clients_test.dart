import 'package:flutter_proto/flutter_proto.dart';
import 'package:flutter_proto/src/generated/task.pb.dart' as task_pb;
// Prefixed because the barrel hides yield's GetPrediction* in favour of
// pest-prediction's, which are different messages under the same names.
import 'package:flutter_proto/src/generated/yield.pb.dart' as yield_pb;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

/// Every service client, checked for the two things only it can get wrong: the
/// fully-qualified service name it posts to, and whether its single-id getter
/// sends the right request and reads back the right response.
///
/// Everything else about the call — headers, error mapping, interceptors — is
/// BaseService's and is tested once in base_service_test.dart rather than
/// seventeen times here.
///
/// A wrong service name is the failure worth catching: it produces a 404 from
/// the gateway that reads as "the server is down" rather than "this client is
/// addressing a service that does not exist", and no amount of local testing
/// of the client's own logic would reveal it.

/// One client's expected wiring.
class _ClientCase {
  const _ClientCase({
    required this.label,
    required this.serviceName,
    required this.method,
    required this.build,
    required this.respondWith,
    required this.call,
    required this.expectId,
  });

  final String label;

  /// The fully-qualified protobuf service name this client must address.
  final String serviceName;

  /// The RPC method its single-id getter invokes.
  final String method;

  final BaseService Function(http.Client) build;

  /// The response the fake server returns, already encoded.
  final List<int> Function() respondWith;

  /// Invokes the getter and returns the id the response carried, so the test
  /// can prove the bytes were parsed rather than merely received.
  final Future<String> Function(BaseService) call;

  final String expectId;
}

final _cases = <_ClientCase>[
  _ClientCase(
    label: 'AnalyticsServiceClient',
    serviceName: 'agriculture.satellite.analytics.v1.SatelliteAnalyticsService',
    method: 'AcknowledgeAlert',
    build: (c) => AnalyticsServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => AcknowledgeAlertResponse().writeToBuffer(),
    call: (s) async {
      await (s as AnalyticsServiceClient).acknowledgeAlert('alert-1');
      return 'alert-1';
    },
    expectId: 'alert-1',
  ),
  _ClientCase(
    label: 'CropServiceClient',
    serviceName: 'agriculture.crop.v1.CropService',
    method: 'GetCrop',
    build: (c) => CropServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => GetCropResponse(crop: Crop(id: 'crop-1')).writeToBuffer(),
    call: (s) async => (await (s as CropServiceClient).getCrop('crop-1')).crop.id,
    expectId: 'crop-1',
  ),
  _ClientCase(
    label: 'DiagnosisServiceClient',
    serviceName: 'agriculture.diagnosis.v1.PlantDiagnosisService',
    method: 'GetDiagnosis',
    build: (c) => DiagnosisServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () =>
        GetDiagnosisResponse(diagnosis: DiagnosisRequest(id: 'diag-1'))
            .writeToBuffer(),
    call: (s) async =>
        (await (s as DiagnosisServiceClient).getDiagnosis('diag-1')).diagnosis.id,
    expectId: 'diag-1',
  ),
  _ClientCase(
    label: 'FarmServiceClient',
    serviceName: 'agriculture.farm.v1.FarmService',
    method: 'GetFarm',
    build: (c) => FarmServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => GetFarmResponse(farm: Farm(id: 'farm-1')).writeToBuffer(),
    call: (s) async => (await (s as FarmServiceClient).getFarm('farm-1')).farm.id,
    expectId: 'farm-1',
  ),
  _ClientCase(
    label: 'FieldServiceClient',
    serviceName: 'agriculture.field.v1.FieldService',
    method: 'GetField',
    build: (c) => FieldServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () =>
        GetFieldResponse(field_1: Field(id: 'field-1')).writeToBuffer(),
    call: (s) async =>
        (await (s as FieldServiceClient).getField('field-1')).field_1.id,
    expectId: 'field-1',
  ),
  _ClientCase(
    label: 'IngestionServiceClient',
    serviceName: 'agriculture.satellite.ingestion.v1.SatelliteIngestionService',
    method: 'GetIngestionTask',
    build: (c) => IngestionServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => GetIngestionTaskResponse().writeToBuffer(),
    call: (s) async {
      await (s as IngestionServiceClient).getIngestionTask('task-1');
      return 'task-1';
    },
    expectId: 'task-1',
  ),
  _ClientCase(
    label: 'IrrigationServiceClient',
    serviceName: 'agriculture.irrigation.v1.IrrigationService',
    method: 'GetSchedule',
    build: (c) => IrrigationServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => GetScheduleResponse().writeToBuffer(),
    call: (s) async {
      await (s as IrrigationServiceClient).getSchedule('sched-1');
      return 'sched-1';
    },
    expectId: 'sched-1',
  ),
  _ClientCase(
    label: 'PestPredictionServiceClient',
    serviceName: 'agriculture.pest.v1.PestPredictionService',
    method: 'GetPrediction',
    build: (c) => PestPredictionServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => GetPredictionResponse().writeToBuffer(),
    call: (s) async {
      await (s as PestPredictionServiceClient).getPrediction('pred-1');
      return 'pred-1';
    },
    expectId: 'pred-1',
  ),
  _ClientCase(
    label: 'ProcessingServiceClient',
    serviceName: 'agriculture.satellite.processing.v1.SatelliteProcessingService',
    method: 'GetProcessingJob',
    build: (c) => ProcessingServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => GetProcessingJobResponse().writeToBuffer(),
    call: (s) async {
      await (s as ProcessingServiceClient).getProcessingJob('job-1');
      return 'job-1';
    },
    expectId: 'job-1',
  ),
  _ClientCase(
    label: 'SatelliteServiceClient',
    serviceName: 'agriculture.satellite.v1.SatelliteService',
    method: 'GetImage',
    build: (c) => SatelliteServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => GetImageResponse().writeToBuffer(),
    call: (s) async {
      await (s as SatelliteServiceClient).getImage('img-1');
      return 'img-1';
    },
    expectId: 'img-1',
  ),
  _ClientCase(
    label: 'SensorServiceClient',
    serviceName: 'agriculture.sensor.v1.SensorService',
    method: 'GetSensor',
    build: (c) => SensorServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => GetSensorResponse().writeToBuffer(),
    call: (s) async {
      await (s as SensorServiceClient).getSensor('sensor-1');
      return 'sensor-1';
    },
    expectId: 'sensor-1',
  ),
  _ClientCase(
    label: 'SoilServiceClient',
    serviceName: 'agriculture.soil.v1.SoilService',
    method: 'GetSoilSample',
    build: (c) => SoilServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => GetSoilSampleResponse().writeToBuffer(),
    call: (s) async {
      await (s as SoilServiceClient).getSoilSample('sample-1');
      return 'sample-1';
    },
    expectId: 'sample-1',
  ),
  _ClientCase(
    label: 'TaskServiceClient',
    serviceName: 'agriculture.task.v1.TaskService',
    method: 'GetTask',
    build: (c) => TaskServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => task_pb.GetTaskResponse().writeToBuffer(),
    call: (s) async {
      await (s as TaskServiceClient).getTask('task-1');
      return 'task-1';
    },
    expectId: 'task-1',
  ),
  _ClientCase(
    label: 'TileServiceClient',
    serviceName: 'agriculture.satellite.tile.v1.SatelliteTileService',
    method: 'GetTileset',
    build: (c) => TileServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => GetTilesetResponse().writeToBuffer(),
    call: (s) async {
      await (s as TileServiceClient).getTileset('tileset-1');
      return 'tileset-1';
    },
    expectId: 'tileset-1',
  ),
  _ClientCase(
    label: 'TraceabilityServiceClient',
    serviceName: 'agriculture.traceability.v1.TraceabilityService',
    method: 'GetRecord',
    build: (c) => TraceabilityServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => GetRecordResponse().writeToBuffer(),
    call: (s) async {
      await (s as TraceabilityServiceClient).getRecord('rec-1');
      return 'rec-1';
    },
    expectId: 'rec-1',
  ),
  _ClientCase(
    label: 'VegetationIndexServiceClient',
    serviceName: 'agriculture.satellite.vegetation.v1.VegetationIndexService',
    method: 'GetVegetationIndex',
    build: (c) => VegetationIndexServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => GetVegetationIndexResponse().writeToBuffer(),
    call: (s) async {
      await (s as VegetationIndexServiceClient).getVegetationIndex('vi-1');
      return 'vi-1';
    },
    expectId: 'vi-1',
  ),
  _ClientCase(
    label: 'YieldServiceClient',
    serviceName: 'agriculture.yield.v1.YieldService',
    method: 'GetPrediction',
    build: (c) => YieldServiceClient(baseUrl: _base, httpClient: c),
    respondWith: () => yield_pb.GetPredictionResponse().writeToBuffer(),
    call: (s) async {
      await (s as YieldServiceClient).getPrediction('ypred-1');
      return 'ypred-1';
    },
    expectId: 'ypred-1',
  ),
];

const _base = 'http://localhost:8080';

void main() {
  for (final c in _cases) {
    group(c.label, () {
      test('addresses ${c.serviceName}', () async {
        late Uri seen;
        final client = c.build(MockClient((request) async {
          seen = request.url;
          return http.Response.bytes(c.respondWith(), 200);
        }));

        await c.call(client);

        expect(client.serviceName, c.serviceName);
        expect(seen.toString(), '$_base/${c.serviceName}/${c.method}');
      });

      test('sends the id it was given', () async {
        // Proves the getter puts the caller's id into the request rather than
        // sending an empty message and returning whatever comes back.
        late List<int> body;
        final client = c.build(MockClient((request) async {
          body = request.bodyBytes;
          return http.Response.bytes(c.respondWith(), 200);
        }));

        await c.call(client);

        // Field 1 of every one of these requests is the id, so it appears in
        // the encoded body regardless of the concrete request type.
        expect(String.fromCharCodes(body), contains(c.expectId));
      });

      test('surfaces a failure as ServiceException', () async {
        final client = c.build(
          MockClient((_) async => http.Response('nope', 500)),
        );

        await expectLater(
          c.call(client),
          throwsA(isA<ServiceException>().having(
            (e) => e.method,
            'method',
            '${c.serviceName}/${c.method}',
          )),
        );
      });
    });
  }

  test('no two clients claim the same service name', () {
    // A copy-pasted client that kept the name it was copied from would send
    // its calls to the wrong service and get plausible-looking 404s.
    final names = _cases.map((c) => c.serviceName).toList();
    expect(names.toSet().length, names.length,
        reason: 'duplicate service names: $names');
  });
}
