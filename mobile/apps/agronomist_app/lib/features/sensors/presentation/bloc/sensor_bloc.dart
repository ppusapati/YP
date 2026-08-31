import 'package:bloc/bloc.dart';

import '../../domain/usecases/get_sensor_readings_usecase.dart';
import 'sensor_event.dart';
import 'sensor_state.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  SensorBloc({required GetSensorReadingsUseCase getSensorReadings})
      : _getSensorReadings = getSensorReadings,
        super(const SensorInitial()) {
    on<LoadSensorReadings>(_onLoad);
  }

  final GetSensorReadingsUseCase _getSensorReadings;

  Future<void> _onLoad(LoadSensorReadings event, Emitter<SensorState> emit) async {
    emit(const SensorLoading());
    try {
      final readings = await _getSensorReadings(event.fieldId);
      emit(SensorReadingsLoaded(readings: readings));
    } catch (e) {
      emit(SensorError(message: e.toString()));
    }
  }
}
