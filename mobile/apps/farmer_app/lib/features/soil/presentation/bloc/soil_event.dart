import 'package:equatable/equatable.dart';

sealed class SoilEvent extends Equatable {
  const SoilEvent();

  @override
  List<Object?> get props => [];
}

final class LoadSoilAnalysis extends SoilEvent {
  const LoadSoilAnalysis({required this.fieldId});

  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}

final class LoadSoilHistory extends SoilEvent {
  const LoadSoilHistory({
    required this.fieldId,
    this.from,
    this.to,
  });

  final String fieldId;
  final DateTime? from;
  final DateTime? to;

  @override
  List<Object?> get props => [fieldId, from, to];
}

final class SelectField extends SoilEvent {
  const SelectField({required this.fieldId});

  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}
