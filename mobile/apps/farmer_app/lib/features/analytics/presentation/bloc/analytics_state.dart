part of 'analytics_bloc.dart';

sealed class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

final class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

final class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

final class AnalyticsListLoaded extends AnalyticsState {
  const AnalyticsListLoaded({required this.fieldAnalytics});
  final List<FieldAnalytics> fieldAnalytics;

  @override
  List<Object?> get props => [fieldAnalytics];
}

final class FieldAnalyticsLoaded extends AnalyticsState {
  const FieldAnalyticsLoaded({required this.fieldAnalytics});
  final FieldAnalytics fieldAnalytics;

  @override
  List<Object?> get props => [fieldAnalytics];
}

final class AnalyticsError extends AnalyticsState {
  const AnalyticsError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
