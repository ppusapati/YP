import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_yield_history_usecase.dart';
import '../../domain/usecases/get_yield_predictions_usecase.dart';
import 'yield_event.dart';
import 'yield_state.dart';

class YieldBloc extends Bloc<YieldEvent, YieldState> {
  YieldBloc({
    required GetYieldPredictionsUseCase getPredictions,
    required GetYieldHistoryUseCase getHistory,
  })  : _getPredictions = getPredictions,
        _getHistory = getHistory,
        super(const YieldInitial()) {
    on<LoadPredictions>(_onLoadPredictions);
    on<LoadHistory>(_onLoadHistory);
    on<SelectField>(_onSelectField);
    on<SelectCrop>(_onSelectCrop);
  }

  final GetYieldPredictionsUseCase _getPredictions;
  final GetYieldHistoryUseCase _getHistory;

  String? _currentFieldId;
  String? _currentCropType;

  Future<void> _onLoadPredictions(
    LoadPredictions event,
    Emitter<YieldState> emit,
  ) async {
    emit(const YieldLoading());
    try {
      _currentFieldId = event.fieldId;
      _currentCropType = event.cropType;
      final predictions = await _getPredictions(
        fieldId: event.fieldId,
        cropType: event.cropType,
      );
      emit(PredictionsLoaded(
        predictions: predictions,
        selectedFieldId: event.fieldId,
        selectedCropType: event.cropType,
      ));
    } catch (e) {
      emit(YieldError(message: e.toString()));
    }
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<YieldState> emit,
  ) async {
    emit(const YieldLoading());
    try {
      final history = await _getHistory(
        event.fieldId,
        cropType: event.cropType,
      );
      emit(YieldHistoryLoaded(fieldId: event.fieldId, history: history));
    } catch (e) {
      emit(YieldError(message: e.toString()));
    }
  }

  Future<void> _onSelectField(
    SelectField event,
    Emitter<YieldState> emit,
  ) async {
    _currentFieldId = event.fieldId;
    add(LoadPredictions(
      fieldId: event.fieldId,
      cropType: _currentCropType,
    ));
  }

  Future<void> _onSelectCrop(
    SelectCrop event,
    Emitter<YieldState> emit,
  ) async {
    _currentCropType = event.cropType;
    add(LoadPredictions(
      fieldId: _currentFieldId,
      cropType: event.cropType,
    ));
  }
}
