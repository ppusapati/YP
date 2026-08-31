import 'package:bloc/bloc.dart';

import '../../domain/usecases/get_yield_forecast_usecase.dart';
import 'yield_analysis_event.dart';
import 'yield_analysis_state.dart';

class YieldAnalysisBloc extends Bloc<YieldAnalysisEvent, YieldAnalysisState> {
  YieldAnalysisBloc({required GetYieldForecastUseCase getYieldForecast})
      : _getYieldForecast = getYieldForecast,
        super(const YieldAnalysisInitial()) {
    on<LoadYieldForecast>(_onLoad);
  }

  final GetYieldForecastUseCase _getYieldForecast;

  Future<void> _onLoad(LoadYieldForecast event, Emitter<YieldAnalysisState> emit) async {
    emit(const YieldAnalysisLoading());
    try {
      final predictions = await _getYieldForecast(event.fieldId);
      emit(YieldForecastLoaded(predictions: predictions));
    } catch (e) {
      emit(YieldAnalysisError(message: e.toString()));
    }
  }
}
