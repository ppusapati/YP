import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/field_analytics_entity.dart';
import '../../domain/usecases/get_field_analytics_usecase.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({
    required GetFieldAnalyticsUseCase getFieldAnalytics,
  })  : _getFieldAnalytics = getFieldAnalytics,
        super(const AnalyticsInitial()) {
    on<LoadAnalyticsList>(_onLoadAnalyticsList);
    on<LoadFieldAnalytics>(_onLoadFieldAnalytics);
  }

  final GetFieldAnalyticsUseCase _getFieldAnalytics;

  Future<void> _onLoadAnalyticsList(
      LoadAnalyticsList event, Emitter<AnalyticsState> emit) async {
    emit(const AnalyticsLoading());
    try {
      final analytics = await _getFieldAnalytics(farmId: event.farmId);
      emit(AnalyticsListLoaded(fieldAnalytics: analytics));
    } catch (e) {
      emit(AnalyticsError(message: e.toString()));
    }
  }

  Future<void> _onLoadFieldAnalytics(
      LoadFieldAnalytics event, Emitter<AnalyticsState> emit) async {
    emit(const AnalyticsLoading());
    try {
      final analytics =
          await _getFieldAnalytics.getFieldDetail(event.fieldId);
      emit(FieldAnalyticsLoaded(fieldAnalytics: analytics));
    } catch (e) {
      emit(AnalyticsError(message: e.toString()));
    }
  }
}
