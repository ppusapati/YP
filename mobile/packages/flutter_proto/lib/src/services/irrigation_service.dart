import 'package:http/http.dart' as http;

import '../generated/irrigation.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for irrigation management.
///
/// Provides CRUD operations for irrigation zones, scheduling,
/// and alert management.
class IrrigationServiceClient extends BaseService {
  IrrigationServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'yieldpoint.irrigation.v1.IrrigationService';

  /// Retrieves an irrigation zone by ID.
  Future<IrrigationZone> getZone(String zoneId) async {
    final request = IrrigationZone(id: zoneId);
    final bytes = await callUnary('GetZone', request);
    return IrrigationZone.fromBuffer(bytes);
  }

  /// Lists all irrigation zones for a field.
  Future<List<IrrigationZone>> listZones(String fieldId) async {
    final request = IrrigationZone(fieldId: fieldId);
    final bytes = await callUnary('ListZones', request);
    final zone = IrrigationZone.fromBuffer(bytes);
    return [zone];
  }

  /// Creates a new irrigation zone.
  Future<IrrigationZone> createZone(IrrigationZone zone) async {
    final bytes = await callUnary('CreateZone', zone);
    return IrrigationZone.fromBuffer(bytes);
  }

  /// Updates an existing irrigation zone.
  Future<IrrigationZone> updateZone(IrrigationZone zone) async {
    final bytes = await callUnary('UpdateZone', zone);
    return IrrigationZone.fromBuffer(bytes);
  }

  /// Deletes an irrigation zone by ID.
  Future<void> deleteZone(String zoneId) async {
    final request = IrrigationZone(id: zoneId);
    await callUnary('DeleteZone', request);
  }

  /// Retrieves the irrigation schedule for a zone.
  Future<IrrigationSchedule> getSchedule(String zoneId) async {
    final request = IrrigationSchedule(zoneId: zoneId);
    final bytes = await callUnary('GetSchedule', request);
    return IrrigationSchedule.fromBuffer(bytes);
  }

  /// Creates or updates an irrigation schedule for a zone.
  Future<IrrigationSchedule> setSchedule(IrrigationSchedule schedule) async {
    final bytes = await callUnary('SetSchedule', schedule);
    return IrrigationSchedule.fromBuffer(bytes);
  }

  /// Lists active irrigation alerts for a zone.
  Future<List<IrrigationAlert>> listAlerts(String zoneId) async {
    final request = IrrigationAlert(zoneId: zoneId);
    final bytes = await callUnary('ListAlerts', request);
    final alert = IrrigationAlert.fromBuffer(bytes);
    return [alert];
  }

  /// Streams real-time irrigation alerts for a zone.
  Stream<IrrigationAlert> streamAlerts(String zoneId) {
    final request = IrrigationAlert(zoneId: zoneId);
    return callServerStream('StreamAlerts', request)
        .map((bytes) => IrrigationAlert.fromBuffer(bytes));
  }
}
