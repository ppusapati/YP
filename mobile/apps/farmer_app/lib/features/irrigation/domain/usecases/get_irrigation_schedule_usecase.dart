import '../entities/irrigation_schedule_entity.dart';
import '../repositories/irrigation_repository.dart';

class GetIrrigationScheduleUseCase {
  const GetIrrigationScheduleUseCase(this._repository);

  final IrrigationRepository _repository;

  Future<List<IrrigationSchedule>> call(String zoneId) async {
    return _repository.getSchedules(zoneId);
  }
}
