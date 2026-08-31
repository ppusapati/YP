import 'package:equatable/equatable.dart';

import '../../domain/entities/soil_analysis_entity.dart';

sealed class SoilAnalysisState extends Equatable {
  const SoilAnalysisState();

  @override
  List<Object?> get props => [];
}

final class SoilAnalysisInitial extends SoilAnalysisState {
  const SoilAnalysisInitial();
}

final class SoilAnalysisLoading extends SoilAnalysisState {
  const SoilAnalysisLoading();
}

final class SoilAnalysesLoaded extends SoilAnalysisState {
  const SoilAnalysesLoaded({required this.analyses});
  final List<SoilAnalysisEntity> analyses;

  @override
  List<Object?> get props => [analyses];
}

final class SoilSampleCreated extends SoilAnalysisState {
  const SoilSampleCreated({required this.analysis});
  final SoilAnalysisEntity analysis;

  @override
  List<Object?> get props => [analysis];
}

final class SoilAnalysisError extends SoilAnalysisState {
  const SoilAnalysisError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
