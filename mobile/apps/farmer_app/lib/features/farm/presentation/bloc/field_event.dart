import 'package:equatable/equatable.dart';

import '../../domain/entities/field_entity.dart';

sealed class FieldEvent extends Equatable {
  const FieldEvent();

  @override
  List<Object?> get props => [];
}

final class LoadFields extends FieldEvent {
  const LoadFields({required this.farmId});

  final String farmId;

  @override
  List<Object?> get props => [farmId];
}

final class CreateField extends FieldEvent {
  const CreateField({required this.field});

  final FieldEntity field;

  @override
  List<Object?> get props => [field];
}

final class UpdateField extends FieldEvent {
  const UpdateField({required this.field});

  final FieldEntity field;

  @override
  List<Object?> get props => [field];
}

final class DeleteField extends FieldEvent {
  const DeleteField({required this.fieldId, required this.farmId});

  final String fieldId;
  final String farmId;

  @override
  List<Object?> get props => [fieldId, farmId];
}

final class SelectField extends FieldEvent {
  const SelectField({required this.fieldId});

  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}
