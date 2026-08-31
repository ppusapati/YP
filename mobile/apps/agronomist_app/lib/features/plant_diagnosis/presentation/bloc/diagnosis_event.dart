import 'package:equatable/equatable.dart';

import '../../domain/entities/diagnosis_entity.dart';

sealed class DiagnosisEvent extends Equatable {
  const DiagnosisEvent();

  @override
  List<Object?> get props => [];
}

final class SubmitDiagnosis extends DiagnosisEvent {
  const SubmitDiagnosis({required this.diagnosis});
  final DiagnosisEntity diagnosis;

  @override
  List<Object?> get props => [diagnosis];
}

final class LoadDiagnoses extends DiagnosisEvent {
  const LoadDiagnoses({this.fieldId});
  final String? fieldId;

  @override
  List<Object?> get props => [fieldId];
}

final class LoadDiagnosisById extends DiagnosisEvent {
  const LoadDiagnosisById({required this.id});
  final String id;

  @override
  List<Object?> get props => [id];
}
