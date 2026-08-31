import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_irrigation_alerts_usecase.dart';
import '../../domain/usecases/get_irrigation_schedule_usecase.dart';
import '../../domain/usecases/get_irrigation_zones_usecase.dart';
import '../../domain/usecases/update_irrigation_schedule_usecase.dart';
import 'irrigation_event.dart';
import 'irrigation_state.dart';

class IrrigationBloc extends Bloc<IrrigationEvent, IrrigationState> {
  IrrigationBloc({
    required GetIrrigationZonesUseCase getZones,
    required GetIrrigationScheduleUseCase getSchedule,
    required UpdateIrrigationScheduleUseCase updateSchedule,
    required GetIrrigationAlertsUseCase getAlerts,
  })  : _getZones = getZones,
        _getSchedule = getSchedule,
        _updateSchedule = updateSchedule,
        _getAlerts = getAlerts,
        super(const IrrigationInitial()) {
    on<LoadZones>(_onLoadZones);
    on<LoadSchedule>(_onLoadSchedule);
    on<UpdateSchedule>(_onUpdateSchedule);
    on<LoadAlerts>(_onLoadAlerts);
  }

  final GetIrrigationZonesUseCase _getZones;
  final GetIrrigationScheduleUseCase _getSchedule;
  final UpdateIrrigationScheduleUseCase _updateSchedule;
  final GetIrrigationAlertsUseCase _getAlerts;

  Future<void> _onLoadZones(
    LoadZones event,
    Emitter<IrrigationState> emit,
  ) async {
    emit(const IrrigationLoading());
    try {
      final zones = await _getZones(event.fieldId);
      emit(ZonesLoaded(zones: zones));
    } catch (e) {
      emit(IrrigationError(message: e.toString()));
    }
  }

  Future<void> _onLoadSchedule(
    LoadSchedule event,
    Emitter<IrrigationState> emit,
  ) async {
    emit(const IrrigationLoading());
    try {
      final schedules = await _getSchedule(event.zoneId);
      emit(ScheduleLoaded(zoneId: event.zoneId, schedules: schedules));
    } catch (e) {
      emit(IrrigationError(message: e.toString()));
    }
  }

  Future<void> _onUpdateSchedule(
    UpdateSchedule event,
    Emitter<IrrigationState> emit,
  ) async {
    emit(const IrrigationLoading());
    try {
      await _updateSchedule(event.schedule);
      final schedules = await _getSchedule(event.schedule.zoneId);
      emit(ScheduleLoaded(
          zoneId: event.schedule.zoneId, schedules: schedules));
    } catch (e) {
      emit(IrrigationError(message: e.toString()));
    }
  }

  Future<void> _onLoadAlerts(
    LoadAlerts event,
    Emitter<IrrigationState> emit,
  ) async {
    emit(const IrrigationLoading());
    try {
      final alerts = await _getAlerts(zoneId: event.zoneId);
      emit(AlertsLoaded(alerts: alerts));
    } catch (e) {
      emit(IrrigationError(message: e.toString()));
    }
  }
}
