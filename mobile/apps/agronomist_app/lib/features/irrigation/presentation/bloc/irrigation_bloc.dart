import 'package:bloc/bloc.dart';

import '../../domain/usecases/get_irrigation_plan_usecase.dart';
import 'irrigation_event.dart';
import 'irrigation_state.dart';

class IrrigationBloc extends Bloc<IrrigationEvent, IrrigationState> {
  IrrigationBloc({required GetIrrigationPlanUseCase getIrrigationPlan})
      : _getIrrigationPlan = getIrrigationPlan,
        super(const IrrigationInitial()) {
    on<LoadIrrigationZones>(_onLoadZones);
  }

  final GetIrrigationPlanUseCase _getIrrigationPlan;

  Future<void> _onLoadZones(
      LoadIrrigationZones event, Emitter<IrrigationState> emit) async {
    emit(const IrrigationLoading());
    try {
      final zones = await _getIrrigationPlan(event.fieldId);
      emit(IrrigationZonesLoaded(zones: zones));
    } catch (e) {
      emit(IrrigationError(message: e.toString()));
    }
  }
}
