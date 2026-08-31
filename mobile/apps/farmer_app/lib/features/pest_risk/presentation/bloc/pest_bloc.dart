import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

import '../../domain/usecases/get_pest_alerts_usecase.dart';
import '../../domain/usecases/get_pest_risk_zones_usecase.dart';
import 'pest_event.dart';
import 'pest_state.dart';

/// BLoC that manages pest risk zone and alert state.
class PestBloc extends Bloc<PestEvent, PestState> {
  PestBloc({
    required GetPestRiskZonesUseCase getPestRiskZones,
    required GetPestAlertsUseCase getPestAlerts,
  })  : _getPestRiskZones = getPestRiskZones,
        _getPestAlerts = getPestAlerts,
        super(const PestInitial()) {
    on<LoadPestRiskZones>(_onLoadPestRiskZones);
    on<LoadPestAlerts>(_onLoadPestAlerts);
    on<FilterByRiskLevel>(_onFilterByRiskLevel);
    on<MarkAlertRead>(_onMarkAlertRead);
  }

  final GetPestRiskZonesUseCase _getPestRiskZones;
  final GetPestAlertsUseCase _getPestAlerts;
  static final _log = Logger('PestBloc');

  Future<void> _onLoadPestRiskZones(
    LoadPestRiskZones event,
    Emitter<PestState> emit,
  ) async {
    emit(const PestLoading());
    try {
      final zones = await _getPestRiskZones(fieldId: event.fieldId);
      emit(PestZonesLoaded(zones: zones));
    } catch (e, stack) {
      _log.severe('Failed to load pest risk zones', e, stack);
      emit(PestError('Unable to load pest risk data. Please try again.'));
    }
  }

  Future<void> _onLoadPestAlerts(
    LoadPestAlerts event,
    Emitter<PestState> emit,
  ) async {
    emit(const PestLoading());
    try {
      final alerts = await _getPestAlerts(fieldId: event.fieldId);
      emit(PestAlertsLoaded(alerts: alerts));
    } catch (e, stack) {
      _log.severe('Failed to load pest alerts', e, stack);
      emit(PestError('Unable to load pest alerts. Please try again.'));
    }
  }

  void _onFilterByRiskLevel(
    FilterByRiskLevel event,
    Emitter<PestState> emit,
  ) {
    final current = state;
    if (current is PestZonesLoaded) {
      if (event.riskLevel == null) {
        emit(PestZonesLoaded(zones: current.zones));
      } else {
        final filtered = current.zones
            .where((z) => z.riskLevel == event.riskLevel)
            .toList();
        emit(PestZonesLoaded(
          zones: current.zones,
          filteredZones: filtered,
          activeFilter: event.riskLevel,
        ));
      }
    }
  }

  Future<void> _onMarkAlertRead(
    MarkAlertRead event,
    Emitter<PestState> emit,
  ) async {
    try {
      await _getPestAlerts.markAsRead(event.alertId);
      final current = state;
      if (current is PestAlertsLoaded) {
        final updated = current.alerts.map((a) {
          if (a.id == event.alertId) return a.copyWith(isRead: true);
          return a;
        }).toList();
        emit(PestAlertsLoaded(alerts: updated));
      }
    } catch (e, stack) {
      _log.warning('Failed to mark alert as read', e, stack);
    }
  }
}
