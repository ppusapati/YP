import 'package:equatable/equatable.dart';

import '../../domain/entities/diagnosis_entity.dart';

sealed class DiagnosisState extends Equatable {
  const DiagnosisState();

  @override
  List<Object?> get props => [];
}

final class DiagnosisInitial extends DiagnosisState {
  const DiagnosisInitial();
}

final class DiagnosisLoading extends DiagnosisState {
  const DiagnosisLoading();
}

final class DiagnosesLoaded extends DiagnosisState {
  const DiagnosesLoaded({required this.diagnoses});
  final List<DiagnosisEntity> diagnoses;

  @override
  List<Object?> get props => [diagnoses];
}

final class DiagnosisLoaded extends DiagnosisState {
  const DiagnosisLoaded({required this.diagnosis});
  final DiagnosisEntity diagnosis;

  @override
  List<Object?> get props => [diagnosis];
}

final class DiagnosisSubmitted extends DiagnosisState {
  const DiagnosisSubmitted({required this.diagnosis});
  final DiagnosisEntity diagnosis;

  @override
  List<Object?> get props => [diagnosis];
}

final class DiagnosisError extends DiagnosisState {
  const DiagnosisError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
