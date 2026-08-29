import '../entities/irrigation_zone_entity.dart';
import '../entities/irrigation_schedule_entity.dart';

abstract class IrrigationRepository {
  Future<List<IrrigationZoneEntity>> getZones(String fieldId);
  Future<IrrigationZoneEntity> getZoneById(String zoneId);
  Future<IrrigationScheduleEntity> updateSchedule(IrrigationScheduleEntity schedule);
  Future<List<IrrigationScheduleEntity>> getSchedules(String zoneId);
}
