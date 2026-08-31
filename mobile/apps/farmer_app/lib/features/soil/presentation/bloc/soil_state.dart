import 'package:equatable/equatable.dart';

import '../../domain/entities/soil_analysis_entity.dart';

sealed class SoilState extends Equatable {
  const SoilState();

  @override
  List<Object?> get props => [];
}

final class SoilInitial extends SoilState {
  const SoilInitial();
}

final class SoilLoading extends SoilState {
  const SoilLoading();
}

final class SoilAnalysisLoaded extends SoilState {
  const SoilAnalysisLoaded({
    required this.analysis,
    this.selectedFieldId,
  });

  final SoilAnalysis analysis;
  final String? selectedFieldId;

  @override
  List<Object?> get props => [analysis, selectedFieldId];
}

final class SoilHistoryLoaded extends SoilState {
  const SoilHistoryLoaded({
    required this.fieldId,
    required this.history,
  });

  final String fieldId;
  final List<SoilAnalysis> history;

  @override
  List<Object?> get props => [fieldId, history];
}

final class SoilError extends SoilState {
  const SoilError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
