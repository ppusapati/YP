import '../generated/irrigation.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for irrigation management.
///
/// Provides operations for irrigation zones, scheduling,
/// and water management.
class IrrigationServiceClient extends BaseService {
  IrrigationServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'agriculture.irrigation.v1.IrrigationService';

  /// Creates a new irrigation zone.
  Future<CreateZoneResponse> createZone(IrrigationZone zone) async {
    final request = CreateZoneRequest(zone: zone);
    final bytes = await callUnary('CreateZone', request);
    return CreateZoneResponse.fromBuffer(bytes);
  }

  /// Lists irrigation zones for a field.
  Future<ListZonesResponse> listZones(String fieldId) async {
    final request = ListZonesRequest(fieldId: fieldId);
    final bytes = await callUnary('ListZones', request);
    return ListZonesResponse.fromBuffer(bytes);
  }

  /// Creates an irrigation schedule.
  Future<CreateScheduleResponse> createSchedule(
      IrrigationSchedule schedule) async {
    final request = CreateScheduleRequest(schedule: schedule);
    final bytes = await callUnary('CreateSchedule', request);
    return CreateScheduleResponse.fromBuffer(bytes);
  }

  /// Retrieves an irrigation schedule by ID.
  Future<GetScheduleResponse> getSchedule(String id) async {
    final request = GetScheduleRequest(id: id);
    final bytes = await callUnary('GetSchedule', request);
    return GetScheduleResponse.fromBuffer(bytes);
  }

  /// Lists irrigation schedules.
  Future<ListSchedulesResponse> listSchedules({
    String? fieldId,
    String? farmId,
    String? zoneId,
    int pageSize = 20,
  }) async {
    final request = ListSchedulesRequest(
      fieldId: fieldId,
      farmId: farmId,
      zoneId: zoneId,
      pageSize: pageSize,
    );
    final bytes = await callUnary('ListSchedules', request);
    return ListSchedulesResponse.fromBuffer(bytes);
  }

  /// Updates an existing irrigation schedule.
  Future<UpdateScheduleResponse> updateSchedule(
      IrrigationSchedule schedule) async {
    final request = UpdateScheduleRequest(schedule: schedule);
    final bytes = await callUnary('UpdateSchedule', request);
    return UpdateScheduleResponse.fromBuffer(bytes);
  }

  /// Deletes an irrigation schedule by ID.
  Future<void> deleteSchedule(String id) async {
    final request = DeleteScheduleRequest(id: id);
    await callUnary('DeleteSchedule', request);
  }
}
