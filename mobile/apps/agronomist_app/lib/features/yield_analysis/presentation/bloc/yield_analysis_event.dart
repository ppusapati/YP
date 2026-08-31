import 'package:equatable/equatable.dart';

sealed class YieldAnalysisEvent extends Equatable {
  const YieldAnalysisEvent();
  @override
  List<Object?> get props => [];
}

final class LoadYieldForecast extends YieldAnalysisEvent {
  const LoadYieldForecast({required this.fieldId});
  final String fieldId;
  @override
  List<Object?> get props => [fieldId];
}
