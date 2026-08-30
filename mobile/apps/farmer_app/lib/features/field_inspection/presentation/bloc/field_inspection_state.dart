import 'package:equatable/equatable.dart';

import '../../domain/entities/inspection_entity.dart';

sealed class FieldInspectionState extends Equatable {
  const FieldInspectionState();

  @override
  List<Object?> get props => [];
}

final class FieldInspectionInitial extends FieldInspectionState {
  const FieldInspectionInitial();
}

final class FieldInspectionLoading extends FieldInspectionState {
  const FieldInspectionLoading();
}

final class InspectionsLoaded extends FieldInspectionState {
  const InspectionsLoaded({required this.inspections});
  final List<InspectionEntity> inspections;

  @override
  List<Object?> get props => [inspections];
}

final class InspectionCreated extends FieldInspectionState {
  const InspectionCreated({required this.inspection});
  final InspectionEntity inspection;

  @override
  List<Object?> get props => [inspection];
}

final class InspectionSubmitted extends FieldInspectionState {
  const InspectionSubmitted({required this.inspection});
  final InspectionEntity inspection;

  @override
  List<Object?> get props => [inspection];
}

final class FieldInspectionError extends FieldInspectionState {
  const FieldInspectionError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
