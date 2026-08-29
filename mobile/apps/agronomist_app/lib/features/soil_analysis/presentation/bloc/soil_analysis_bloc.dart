import 'package:bloc/bloc.dart';

import '../../domain/usecases/create_soil_analysis_usecase.dart';
import '../../domain/usecases/get_soil_analyses_usecase.dart';
import 'soil_analysis_event.dart';
import 'soil_analysis_state.dart';

class SoilAnalysisBloc extends Bloc<SoilAnalysisEvent, SoilAnalysisState> {
  SoilAnalysisBloc({
    required GetSoilAnalysesUseCase getSoilAnalyses,
    required CreateSoilAnalysisUseCase createSoilAnalysis,
  })  : _getSoilAnalyses = getSoilAnalyses,
        _createSoilAnalysis = createSoilAnalysis,
        super(const SoilAnalysisInitial()) {
    on<LoadSoilAnalyses>(_onLoadSoilAnalyses);
    on<CreateSoilSample>(_onCreateSoilSample);
  }

  final GetSoilAnalysesUseCase _getSoilAnalyses;
  final CreateSoilAnalysisUseCase _createSoilAnalysis;

  Future<void> _onLoadSoilAnalyses(
      LoadSoilAnalyses event, Emitter<SoilAnalysisState> emit) async {
    emit(const SoilAnalysisLoading());
    try {
      final analyses = await _getSoilAnalyses(event.fieldId);
      emit(SoilAnalysesLoaded(analyses: analyses));
    } catch (e) {
      emit(SoilAnalysisError(message: e.toString()));
    }
  }

  Future<void> _onCreateSoilSample(
      CreateSoilSample event, Emitter<SoilAnalysisState> emit) async {
    emit(const SoilAnalysisLoading());
    try {
      final analysis = await _createSoilAnalysis(event.analysis);
      emit(SoilSampleCreated(analysis: analysis));
    } catch (e) {
      emit(SoilAnalysisError(message: e.toString()));
    }
  }
}
