import 'package:bloc/bloc.dart';

import '../../domain/usecases/get_field_summary_usecase.dart';
import '../../domain/usecases/get_satellite_tiles_usecase.dart';
import '../../domain/usecases/get_stress_alerts_usecase.dart';
import 'satellite_event.dart';
import 'satellite_state.dart';

class SatelliteBloc extends Bloc<SatelliteEvent, SatelliteState> {
  SatelliteBloc({
    required GetSatelliteTilesUseCase getSatelliteTiles,
    required GetStressAlertsUseCase getStressAlerts,
    required GetFieldSummaryUseCase getFieldSummary,
  })  : _getSatelliteTiles = getSatelliteTiles,
        _getStressAlerts = getStressAlerts,
        _getFieldSummary = getFieldSummary,
        super(const SatelliteInitial()) {
    on<LoadSatelliteTiles>(_onLoadTiles);
    on<LoadStressAlerts>(_onLoadStressAlerts);
    on<LoadFieldSummary>(_onLoadFieldSummary);
  }

  final GetSatelliteTilesUseCase _getSatelliteTiles;
  final GetStressAlertsUseCase _getStressAlerts;
  final GetFieldSummaryUseCase _getFieldSummary;

  Future<void> _onLoadTiles(
      LoadSatelliteTiles event, Emitter<SatelliteState> emit) async {
    emit(const SatelliteLoading());
    try {
      final tiles = await _getSatelliteTiles(event.fieldId);
      emit(SatelliteTilesLoaded(tiles: tiles));
    } catch (e) {
      emit(SatelliteError(message: e.toString()));
    }
  }

  Future<void> _onLoadStressAlerts(
      LoadStressAlerts event, Emitter<SatelliteState> emit) async {
    emit(const SatelliteLoading());
    try {
      final alerts = await _getStressAlerts(event.farmId);
      emit(StressAlertsLoaded(alerts: alerts));
    } catch (e) {
      emit(SatelliteError(message: e.toString()));
    }
  }

  Future<void> _onLoadFieldSummary(
      LoadFieldSummary event, Emitter<SatelliteState> emit) async {
    emit(const SatelliteLoading());
    try {
      final summary = await _getFieldSummary(event.farmId, event.fieldId);
      emit(FieldSummaryLoaded(summary: summary));
    } catch (e) {
      emit(SatelliteError(message: e.toString()));
    }
  }
}
