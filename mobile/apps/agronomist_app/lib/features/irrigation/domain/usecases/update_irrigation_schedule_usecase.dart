import '../entities/irrigation_schedule_entity.dart';
import '../repositories/irrigation_repository.dart';

class UpdateIrrigationScheduleUseCase {
  final IrrigationRepository _repository;
  const UpdateIrrigationScheduleUseCase(this._repository);

  Future<IrrigationScheduleEntity> call(IrrigationScheduleEntity schedule) {
    return _repository.updateSchedule(schedule);
  }
}
