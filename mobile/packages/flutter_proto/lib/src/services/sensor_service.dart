import 'package:fixnum/fixnum.dart';
import 'package:http/http.dart' as http;

import '../generated/sensor.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for sensor data operations.
///
/// Provides access to sensor readings, dashboards, and real-time
/// streaming of sensor data from IoT devices in the field.
class SensorServiceClient extends BaseService {
  SensorServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'yieldpoint.sensor.v1.SensorService';

  /// Retrieves a single sensor reading by sensor ID and timestamp.
  Future<SensorReading> getReading({
    required String sensorId,
    Int64? timestamp,
  }) async {
    final request = SensorReading(
      sensorId: sensorId,
      timestamp: timestamp,
    );
    final bytes = await callUnary('GetReading', request);
    return SensorReading.fromBuffer(bytes);
  }

  /// Lists sensor readings for a sensor within a time range.
  Future<List<SensorReading>> listReadings({
    required String sensorId,
    Int64? fromTimestamp,
    Int64? toTimestamp,
    SensorType? type,
    int pageSize = 100,
  }) async {
    final request = SensorReading(
      sensorId: sensorId,
      type: type,
    );
    final bytes = await callUnary('ListReadings', request);
    final reading = SensorReading.fromBuffer(bytes);
    return [reading];
  }

  /// Records a new sensor reading.
  Future<SensorReading> recordReading(SensorReading reading) async {
    final bytes = await callUnary('RecordReading', reading);
    return SensorReading.fromBuffer(bytes);
  }

  /// Retrieves a dashboard view for a sensor including recent readings
  /// and aggregated statistics.
  Future<SensorDashboard> getDashboard(String sensorId) async {
    final request = SensorDashboard(sensorId: sensorId);
    final bytes = await callUnary('GetDashboard', request);
    return SensorDashboard.fromBuffer(bytes);
  }

  /// Streams real-time sensor readings for a given sensor.
  Stream<SensorReading> streamReadings(String sensorId) {
    final request = SensorReading(sensorId: sensorId);
    return callServerStream('StreamReadings', request)
        .map((bytes) => SensorReading.fromBuffer(bytes));
  }

  /// Streams real-time sensor readings filtered by type.
  Stream<SensorReading> streamReadingsByType({
    required String sensorId,
    required SensorType type,
  }) {
    final request = SensorReading(sensorId: sensorId, type: type);
    return callServerStream('StreamReadingsByType', request)
        .map((bytes) => SensorReading.fromBuffer(bytes));
  }
}
