import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/satellite_repository.dart';
import 'satellite_event.dart';
import 'satellite_state.dart';

/// BLoC for satellite monitoring: tiles, NDVI data, and crop health.
class SatelliteBloc extends Bloc<SatelliteEvent, SatelliteState> {
  SatelliteBloc({required SatelliteRepository repository})
      : _repository = repository,
        super(const SatelliteInitial()) {
    on<LoadSatelliteTiles>(_onLoadTiles);
    on<LoadNdviData>(_onLoadNdvi);
    on<LoadCropHealth>(_onLoadCropHealth);
    on<SelectDateRange>(_onSelectDateRange);
  }

  final SatelliteRepository _repository;

  Future<void> _onLoadTiles(
    LoadSatelliteTiles event,
    Emitter<SatelliteState> emit,
  ) async {
    emit(const SatelliteLoading());
    try {
      final tiles = await _repository.getSatelliteTiles(
        fieldId: event.fieldId,
        layerType: event.layerType,
      );
      emit(SatelliteTilesLoaded(tiles: tiles));
    } catch (e) {
      emit(SatelliteError(message: e.toString()));
    }
  }

  Future<void> _onLoadNdvi(
    LoadNdviData event,
    Emitter<SatelliteState> emit,
  ) async {
    emit(const SatelliteLoading());
    try {
      final data = await _repository.getNdviHistory(
        fieldId: event.fieldId,
        from: event.from,
        to: event.to,
      );
      emit(NdviDataLoaded(dataPoints: data, from: event.from, to: event.to));
    } catch (e) {
      emit(SatelliteError(message: e.toString()));
    }
  }

  Future<void> _onLoadCropHealth(
    LoadCropHealth event,
    Emitter<SatelliteState> emit,
  ) async {
    emit(const SatelliteLoading());
    try {
      final cropHealth = await _repository.getCropHealth(
        fieldId: event.fieldId,
      );
      emit(CropHealthLoaded(cropHealth: cropHealth));
    } catch (e) {
      emit(SatelliteError(message: e.toString()));
    }
  }

  Future<void> _onSelectDateRange(
    SelectDateRange event,
    Emitter<SatelliteState> emit,
  ) async {
    emit(SatelliteDateRangeSelected(from: event.from, to: event.to));
  }
}
