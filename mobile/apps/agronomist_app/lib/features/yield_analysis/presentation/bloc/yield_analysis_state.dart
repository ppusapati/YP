import 'package:equatable/equatable.dart';

import '../../domain/entities/yield_prediction_entity.dart';

sealed class YieldAnalysisState extends Equatable {
  const YieldAnalysisState();
  @override
  List<Object?> get props => [];
}

final class YieldAnalysisInitial extends YieldAnalysisState { const YieldAnalysisInitial(); }
final class YieldAnalysisLoading extends YieldAnalysisState { const YieldAnalysisLoading(); }

final class YieldForecastLoaded extends YieldAnalysisState {
  const YieldForecastLoaded({required this.predictions});
  final List<YieldPredictionEntity> predictions;
  @override
  List<Object?> get props => [predictions];
}

final class YieldAnalysisError extends YieldAnalysisState {
  const YieldAnalysisError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
