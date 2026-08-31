import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_sensor_dashboard_usecase.dart';
import '../../domain/usecases/get_sensor_readings_usecase.dart';
import '../../domain/usecases/get_sensors_usecase.dart';
import '../../domain/repositories/sensor_repository.dart';
import 'sensor_event.dart';
import 'sensor_state.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  SensorBloc({
    required GetSensorsUseCase getSensors,
    required GetSensorReadingsUseCase getSensorReadings,
    required GetSensorDashboardUseCase getSensorDashboard,
    required SensorRepository repository,
  })  : _getSensors = getSensors,
        _getSensorReadings = getSensorReadings,
        _repository = repository,
        super(const SensorInitial()) {
    on<LoadSensors>(_onLoadSensors);
    on<LoadReadings>(_onLoadReadings);
    on<RefreshSensor>(_onRefreshSensor);
    on<SelectSensor>(_onSelectSensor);
    on<FilterByType>(_onFilterByType);
  }

  final GetSensorsUseCase _getSensors;
  final GetSensorReadingsUseCase _getSensorReadings;
  final SensorRepository _repository;

  Future<void> _onLoadSensors(
    LoadSensors event,
    Emitter<SensorState> emit,
  ) async {
    emit(const SensorLoading());
    try {
      final sensors = await _getSensors();
      emit(SensorsLoaded(sensors: sensors));
    } catch (e) {
      emit(SensorError(message: e.toString()));
    }
  }

  Future<void> _onLoadReadings(
    LoadReadings event,
    Emitter<SensorState> emit,
  ) async {
    emit(const SensorLoading());
    try {
      final sensor = await _repository.getSensorById(event.sensorId);
      final readings = await _getSensorReadings(
        sensorId: event.sensorId,
        from: event.from,
        to: event.to,
      );
      emit(SensorReadingsLoaded(sensor: sensor, readings: readings));
    } catch (e) {
      emit(SensorError(message: e.toString()));
    }
  }

  Future<void> _onRefreshSensor(
    RefreshSensor event,
    Emitter<SensorState> emit,
  ) async {
    try {
      await _repository.refreshSensor(event.sensorId);
      final sensor = await _repository.getSensorById(event.sensorId);
      final readings = await _getSensorReadings(sensorId: event.sensorId);
      emit(SensorReadingsLoaded(sensor: sensor, readings: readings));
    } catch (e) {
      emit(SensorError(message: e.toString()));
    }
  }

  Future<void> _onSelectSensor(
    SelectSensor event,
    Emitter<SensorState> emit,
  ) async {
    final currentState = state;
    if (currentState is SensorsLoaded) {
      emit(currentState.copyWith(selectedSensorId: event.sensorId));
    }
  }

  Future<void> _onFilterByType(
    FilterByType event,
    Emitter<SensorState> emit,
  ) async {
    emit(const SensorLoading());
    try {
      final sensors = await _getSensors(type: event.type);
      emit(SensorsLoaded(sensors: sensors, filterType: event.type));
    } catch (e) {
      emit(SensorError(message: e.toString()));
    }
  }
}
