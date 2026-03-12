import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../domain/usecases/get_alerts_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../domain/usecases/mark_alert_read_usecase.dart';
import 'alert_event.dart';
import 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  AlertBloc({
    required GetAlertsUseCase getAlerts,
    required MarkAlertReadUseCase markAlertRead,
    required GetUnreadCountUseCase getUnreadCount,
  })  : _getAlerts = getAlerts,
        _markAlertRead = markAlertRead,
        _getUnreadCount = getUnreadCount,
        super(const AlertInitial()) {
    on<LoadAlerts>(_onLoadAlerts);
    on<MarkRead>(_onMarkRead);
    on<MarkAllRead>(_onMarkAllRead);
    on<FilterAlerts>(_onFilterAlerts);
    on<RefreshAlerts>(_onRefreshAlerts);
  }

  final GetAlertsUseCase _getAlerts;
  final MarkAlertReadUseCase _markAlertRead;
  final GetUnreadCountUseCase _getUnreadCount;
  static final _log = Logger('AlertBloc');

  Future<void> _onLoadAlerts(LoadAlerts event, Emitter<AlertState> emit) async {
    emit(const AlertLoading());
    try {
      final alerts = await _getAlerts(farmId: event.farmId);
      final unreadCount = await _getUnreadCount(farmId: event.farmId);
      emit(AlertsLoaded(alerts: alerts, unreadCount: unreadCount));
    } catch (e, s) {
      _log.severe('Failed to load alerts', e, s);
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onMarkRead(MarkRead event, Emitter<AlertState> emit) async {
    final currentState = state;
    if (currentState is! AlertsLoaded) return;

    try {
      await _markAlertRead(event.alertId);
      final updatedAlerts = currentState.alerts.map((alert) {
        if (alert.id == event.alertId) {
          return alert.copyWith(read: true);
        }
        return alert;
      }).toList();

      emit(currentState.copyWith(
        alerts: updatedAlerts,
        unreadCount: currentState.unreadCount > 0
            ? currentState.unreadCount - 1
            : 0,
      ));
    } catch (e, s) {
      _log.severe('Failed to mark alert read', e, s);
    }
  }

  Future<void> _onMarkAllRead(
    MarkAllRead event,
    Emitter<AlertState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AlertsLoaded) return;

    try {
      await _markAlertRead.markAll(farmId: event.farmId);
      final updatedAlerts = currentState.alerts
          .map((alert) => alert.copyWith(read: true))
          .toList();
      emit(currentState.copyWith(alerts: updatedAlerts, unreadCount: 0));
    } catch (e, s) {
      _log.severe('Failed to mark all alerts read', e, s);
    }
  }

  void _onFilterAlerts(FilterAlerts event, Emitter<AlertState> emit) {
    final currentState = state;
    if (currentState is! AlertsLoaded) return;

    emit(currentState.copyWith(
      activeSeverityFilter: () => event.severity,
      activeTypeFilter: () => event.type,
    ));
  }

  Future<void> _onRefreshAlerts(
    RefreshAlerts event,
    Emitter<AlertState> emit,
  ) async {
    try {
      final alerts = await _getAlerts(farmId: event.farmId);
      final unreadCount = await _getUnreadCount(farmId: event.farmId);
      final currentState = state;
      emit(AlertsLoaded(
        alerts: alerts,
        unreadCount: unreadCount,
        activeSeverityFilter: currentState is AlertsLoaded
            ? currentState.activeSeverityFilter
            : null,
        activeTypeFilter:
            currentState is AlertsLoaded ? currentState.activeTypeFilter : null,
      ));
    } catch (e, s) {
      _log.severe('Failed to refresh alerts', e, s);
      emit(AlertError(e.toString()));
    }
  }
}
