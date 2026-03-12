import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_soil_analysis_usecase.dart';
import '../../domain/usecases/get_soil_history_usecase.dart';
import 'soil_event.dart';
import 'soil_state.dart';

class SoilBloc extends Bloc<SoilEvent, SoilState> {
  SoilBloc({
    required GetSoilAnalysisUseCase getSoilAnalysis,
    required GetSoilHistoryUseCase getSoilHistory,
  })  : _getSoilAnalysis = getSoilAnalysis,
        _getSoilHistory = getSoilHistory,
        super(const SoilInitial()) {
    on<LoadSoilAnalysis>(_onLoadSoilAnalysis);
    on<LoadSoilHistory>(_onLoadSoilHistory);
    on<SelectField>(_onSelectField);
  }

  final GetSoilAnalysisUseCase _getSoilAnalysis;
  final GetSoilHistoryUseCase _getSoilHistory;

  Future<void> _onLoadSoilAnalysis(
    LoadSoilAnalysis event,
    Emitter<SoilState> emit,
  ) async {
    emit(const SoilLoading());
    try {
      final analysis = await _getSoilAnalysis(event.fieldId);
      emit(SoilAnalysisLoaded(
        analysis: analysis,
        selectedFieldId: event.fieldId,
      ));
    } catch (e) {
      emit(SoilError(message: e.toString()));
    }
  }

  Future<void> _onLoadSoilHistory(
    LoadSoilHistory event,
    Emitter<SoilState> emit,
  ) async {
    emit(const SoilLoading());
    try {
      final history = await _getSoilHistory(
        event.fieldId,
        from: event.from,
        to: event.to,
      );
      emit(SoilHistoryLoaded(fieldId: event.fieldId, history: history));
    } catch (e) {
      emit(SoilError(message: e.toString()));
    }
  }

  Future<void> _onSelectField(
    SelectField event,
    Emitter<SoilState> emit,
  ) async {
    emit(const SoilLoading());
    try {
      final analysis = await _getSoilAnalysis(event.fieldId);
      emit(SoilAnalysisLoaded(
        analysis: analysis,
        selectedFieldId: event.fieldId,
      ));
    } catch (e) {
      emit(SoilError(message: e.toString()));
    }
  }
}
