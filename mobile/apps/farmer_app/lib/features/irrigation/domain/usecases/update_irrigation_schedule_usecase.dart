import '../entities/irrigation_schedule_entity.dart';
import '../repositories/irrigation_repository.dart';

class UpdateIrrigationScheduleUseCase {
  const UpdateIrrigationScheduleUseCase(this._repository);

  final IrrigationRepository _repository;

  Future<IrrigationSchedule> call(IrrigationSchedule schedule) async {
    return _repository.updateSchedule(schedule);
  }
}
