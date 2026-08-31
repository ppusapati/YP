import 'package:equatable/equatable.dart';

import '../../domain/entities/inspection_entity.dart';

sealed class FieldInspectionEvent extends Equatable {
  const FieldInspectionEvent();

  @override
  List<Object?> get props => [];
}

final class LoadInspections extends FieldInspectionEvent {
  const LoadInspections({this.farmId});
  final String? farmId;

  @override
  List<Object?> get props => [farmId];
}

final class CreateInspection extends FieldInspectionEvent {
  const CreateInspection({required this.inspection});
  final InspectionEntity inspection;

  @override
  List<Object?> get props => [inspection];
}

final class SubmitInspection extends FieldInspectionEvent {
  const SubmitInspection({required this.inspectionId});
  final String inspectionId;

  @override
  List<Object?> get props => [inspectionId];
}
