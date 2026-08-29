import 'package:bloc/bloc.dart';

import '../../domain/usecases/get_pest_alerts_usecase.dart';
import '../../domain/usecases/predict_pest_risk_usecase.dart';
import 'pest_risk_event.dart';
import 'pest_risk_state.dart';

class PestRiskBloc extends Bloc<PestRiskEvent, PestRiskState> {
  PestRiskBloc({
    required PredictPestRiskUseCase predictPestRisk,
    required GetPestAlertsUseCase getPestAlerts,
  })  : _predictPestRisk = predictPestRisk,
        _getPestAlerts = getPestAlerts,
        super(const PestRiskInitial()) {
    on<LoadPestRisks>(_onLoadPestRisks);
    on<LoadPestAlerts>(_onLoadPestAlerts);
  }

  final PredictPestRiskUseCase _predictPestRisk;
  final GetPestAlertsUseCase _getPestAlerts;

  Future<void> _onLoadPestRisks(
      LoadPestRisks event, Emitter<PestRiskState> emit) async {
    emit(const PestRiskLoading());
    try {
      final risks = await _predictPestRisk(event.fieldId);
      emit(PestRisksLoaded(risks: risks));
    } catch (e) {
      emit(PestRiskError(message: e.toString()));
    }
  }

  Future<void> _onLoadPestAlerts(
      LoadPestAlerts event, Emitter<PestRiskState> emit) async {
    emit(const PestRiskLoading());
    try {
      final alerts = await _getPestAlerts();
      emit(PestRisksLoaded(risks: alerts));
    } catch (e) {
      emit(PestRiskError(message: e.toString()));
    }
  }
}
