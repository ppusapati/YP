import '../generated/sensor.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for sensor data operations.
///
/// Provides access to sensor management, reading ingestion,
/// history retrieval, and real-time streaming of sensor data
/// from IoT devices in the field.
class SensorServiceClient extends BaseService {
  SensorServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'agriculture.sensor.v1.SensorService';

  /// Retrieves a sensor by ID.
  Future<GetSensorResponse> getSensor(String id) async {
    final request = GetSensorRequest(id: id);
    final bytes = await callUnary('GetSensor', request);
    return GetSensorResponse.fromBuffer(bytes);
  }

  /// Lists sensors with optional filters.
  Future<ListSensorsResponse> listSensors({
    String? fieldId,
    String? farmId,
    SensorType? sensorType,
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    final request = ListSensorsRequest(
      fieldId: fieldId,
      farmId: farmId,
      sensorType: sensorType,
      pageSize: pageSize,
      pageOffset: pageOffset,
    );
    final bytes = await callUnary('ListSensors', request);
    return ListSensorsResponse.fromBuffer(bytes);
  }

  /// Records a new sensor reading.
  Future<IngestReadingResponse> ingestReading(
      IngestReadingRequest request) async {
    final bytes = await callUnary('IngestReading', request);
    return IngestReadingResponse.fromBuffer(bytes);
  }

  /// Retrieves the latest reading for a sensor.
  Future<GetLatestReadingResponse> getLatestReading(String sensorId) async {
    final request = GetLatestReadingRequest(sensorId: sensorId);
    final bytes = await callUnary('GetLatestReading', request);
    return GetLatestReadingResponse.fromBuffer(bytes);
  }

  /// Retrieves reading history for a sensor.
  Future<GetReadingHistoryResponse> getReadingHistory({
    required String sensorId,
    int pageSize = 100,
    int pageOffset = 0,
  }) async {
    final request = GetReadingHistoryRequest(
      sensorId: sensorId,
      pageSize: pageSize,
      pageOffset: pageOffset,
    );
    final bytes = await callUnary('GetReadingHistory', request);
    return GetReadingHistoryResponse.fromBuffer(bytes);
  }

  /// Retrieves sensor network information.
  Future<GetSensorNetworkResponse> getSensorNetwork({
    String? id,
    String? farmId,
  }) async {
    final request = GetSensorNetworkRequest(id: id, farmId: farmId);
    final bytes = await callUnary('GetSensorNetwork', request);
    return GetSensorNetworkResponse.fromBuffer(bytes);
  }

  /// Streams real-time sensor readings for a given sensor.
  Stream<SensorReading> streamReadings(String sensorId) {
    final request = GetLatestReadingRequest(sensorId: sensorId);
    return callServerStream('StreamReadings', request)
        .map((bytes) => SensorReading.fromBuffer(bytes));
  }
}
