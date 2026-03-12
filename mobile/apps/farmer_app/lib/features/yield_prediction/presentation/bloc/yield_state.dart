import 'package:equatable/equatable.dart';

import '../../domain/entities/yield_prediction_entity.dart';

sealed class YieldState extends Equatable {
  const YieldState();

  @override
  List<Object?> get props => [];
}

final class YieldInitial extends YieldState {
  const YieldInitial();
}

final class YieldLoading extends YieldState {
  const YieldLoading();
}

final class PredictionsLoaded extends YieldState {
  const PredictionsLoaded({
    required this.predictions,
    this.selectedFieldId,
    this.selectedCropType,
  });

  final List<YieldPrediction> predictions;
  final String? selectedFieldId;
  final String? selectedCropType;

  double get totalExpectedYield =>
      predictions.fold(0, (sum, p) => sum + p.expectedYield);

  int get harvestSoonCount =>
      predictions.where((p) => p.isHarvestSoon).length;

  List<String> get uniqueCropTypes =>
      predictions.map((p) => p.cropType).toSet().toList()..sort();

  @override
  List<Object?> get props => [predictions, selectedFieldId, selectedCropType];
}

final class YieldHistoryLoaded extends YieldState {
  const YieldHistoryLoaded({
    required this.fieldId,
    required this.history,
  });

  final String fieldId;
  final List<YieldPrediction> history;

  @override
  List<Object?> get props => [fieldId, history];
}

final class YieldError extends YieldState {
  const YieldError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
