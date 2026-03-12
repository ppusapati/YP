import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../domain/usecases/get_drone_flights_usecase.dart';
import '../../domain/usecases/get_drone_layers_usecase.dart';
import 'drone_event.dart';
import 'drone_state.dart';

class DroneBloc extends Bloc<DroneEvent, DroneState> {
  DroneBloc({
    required GetDroneLayersUseCase getDroneLayers,
    required GetDroneFlightsUseCase getDroneFlights,
  })  : _getDroneLayers = getDroneLayers,
        _getDroneFlights = getDroneFlights,
        super(const DroneInitial()) {
    on<LoadDroneLayers>(_onLoadDroneLayers);
    on<LoadFlights>(_onLoadFlights);
    on<SelectLayer>(_onSelectLayer);
    on<ToggleLayer>(_onToggleLayer);
    on<SelectFlight>(_onSelectFlight);
  }

  final GetDroneLayersUseCase _getDroneLayers;
  final GetDroneFlightsUseCase _getDroneFlights;
  static final _log = Logger('DroneBloc');

  Future<void> _onLoadDroneLayers(
    LoadDroneLayers event,
    Emitter<DroneState> emit,
  ) async {
    emit(const DroneLoading());
    try {
      final layers = await _getDroneLayers(fieldId: event.fieldId);
      final flights = await _getDroneFlights(fieldId: event.fieldId);
      emit(DroneLayersLoaded(
        layers: layers,
        flights: flights,
      ));
    } catch (e, s) {
      _log.severe('Failed to load drone layers', e, s);
      emit(DroneError(e.toString()));
    }
  }

  Future<void> _onLoadFlights(
    LoadFlights event,
    Emitter<DroneState> emit,
  ) async {
    try {
      final flights = await _getDroneFlights(fieldId: event.fieldId);
      final currentState = state;
      if (currentState is DroneLayersLoaded) {
        emit(currentState.copyWith(flights: flights));
      }
    } catch (e, s) {
      _log.severe('Failed to load flights', e, s);
    }
  }

  void _onSelectLayer(SelectLayer event, Emitter<DroneState> emit) {
    final currentState = state;
    if (currentState is! DroneLayersLoaded) return;
    emit(currentState.copyWith(selectedLayer: () => event.layer));
  }

  void _onToggleLayer(ToggleLayer event, Emitter<DroneState> emit) {
    final currentState = state;
    if (currentState is! DroneLayersLoaded) return;

    final types = Set<dynamic>.from(currentState.activeLayerTypes);
    if (types.contains(event.layerType)) {
      types.remove(event.layerType);
    } else {
      types.add(event.layerType);
    }
    emit(currentState.copyWith(activeLayerTypes: types.cast()));
  }

  Future<void> _onSelectFlight(
    SelectFlight event,
    Emitter<DroneState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DroneLayersLoaded) return;

    emit(currentState.copyWith(
      selectedFlight: () => event.flight,
      layers: event.flight.layers,
    ));
  }
}
