import 'package:equatable/equatable.dart';

import '../../domain/entities/soil_analysis_entity.dart';

sealed class SoilAnalysisEvent extends Equatable {
  const SoilAnalysisEvent();

  @override
  List<Object?> get props => [];
}

final class LoadSoilAnalyses extends SoilAnalysisEvent {
  const LoadSoilAnalyses({required this.fieldId});
  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}

final class CreateSoilSample extends SoilAnalysisEvent {
  const CreateSoilSample({required this.analysis});
  final SoilAnalysisEntity analysis;

  @override
  List<Object?> get props => [analysis];
}
