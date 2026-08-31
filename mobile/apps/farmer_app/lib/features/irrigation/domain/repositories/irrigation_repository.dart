import '../entities/irrigation_alert_entity.dart';
import '../entities/irrigation_schedule_entity.dart';
import '../entities/irrigation_zone_entity.dart';

abstract class IrrigationRepository {
  Future<List<IrrigationZone>> getIrrigationZones(String fieldId);
  Future<IrrigationZone> getZoneById(String zoneId);
  Future<List<IrrigationSchedule>> getSchedules(String zoneId);
  Future<IrrigationSchedule> updateSchedule(IrrigationSchedule schedule);
  Future<void> deleteSchedule(String scheduleId);
  Future<List<IrrigationAlert>> getAlerts({String? zoneId});
  Future<void> markAlertRead(String alertId);
}
