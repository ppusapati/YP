import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../domain/usecases/get_recommendations_usecase.dart';
import 'crop_recommendation_event.dart';
import 'crop_recommendation_state.dart';

class CropRecommendationBloc
    extends Bloc<CropRecommendationEvent, CropRecommendationState> {
  CropRecommendationBloc({
    required GetRecommendationsUseCase getRecommendations,
  })  : _getRecommendations = getRecommendations,
        super(const CropRecInitial()) {
    on<LoadRecommendations>(_onLoadRecommendations);
    on<SelectField>(_onSelectField);
  }

  final GetRecommendationsUseCase _getRecommendations;
  static final _log = Logger('CropRecommendationBloc');

  Future<void> _onLoadRecommendations(
    LoadRecommendations event,
    Emitter<CropRecommendationState> emit,
  ) async {
    emit(const CropRecLoading());
    try {
      final recs = await _getRecommendations(fieldId: event.fieldId);
      // Sort by suitability score descending.
      recs.sort(
          (a, b) => b.soilSuitabilityScore.compareTo(a.soilSuitabilityScore));
      emit(RecommendationsLoaded(
        recommendations: recs,
        fieldId: event.fieldId,
      ));
    } catch (e, s) {
      _log.severe('Failed to load recommendations', e, s);
      emit(CropRecError(e.toString()));
    }
  }

  Future<void> _onSelectField(
    SelectField event,
    Emitter<CropRecommendationState> emit,
  ) async {
    add(LoadRecommendations(fieldId: event.fieldId));
  }
}
