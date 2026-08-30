part of 'analytics_bloc.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadAnalyticsList extends AnalyticsEvent {
  const LoadAnalyticsList({this.farmId});
  final String? farmId;

  @override
  List<Object?> get props => [farmId];
}

final class LoadFieldAnalytics extends AnalyticsEvent {
  const LoadFieldAnalytics({required this.fieldId});
  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}
