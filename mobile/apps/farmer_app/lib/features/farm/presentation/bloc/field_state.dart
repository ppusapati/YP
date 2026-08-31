import 'package:equatable/equatable.dart';

import '../../domain/entities/field_entity.dart';

sealed class FieldState extends Equatable {
  const FieldState();

  @override
  List<Object?> get props => [];
}

final class FieldInitial extends FieldState {
  const FieldInitial();
}

final class FieldLoading extends FieldState {
  const FieldLoading();
}

final class FieldsLoaded extends FieldState {
  const FieldsLoaded({
    required this.fields,
    this.selectedFieldId,
  });

  final List<FieldEntity> fields;
  final String? selectedFieldId;

  FieldEntity? get selectedField {
    if (selectedFieldId == null) return null;
    try {
      return fields.firstWhere((f) => f.id == selectedFieldId);
    } catch (_) {
      return null;
    }
  }

  FieldsLoaded copyWith({
    List<FieldEntity>? fields,
    String? selectedFieldId,
  }) {
    return FieldsLoaded(
      fields: fields ?? this.fields,
      selectedFieldId: selectedFieldId ?? this.selectedFieldId,
    );
  }

  @override
  List<Object?> get props => [fields, selectedFieldId];
}

final class FieldCreated extends FieldState {
  const FieldCreated({required this.field});

  final FieldEntity field;

  @override
  List<Object?> get props => [field];
}

final class FieldUpdated extends FieldState {
  const FieldUpdated({required this.field});

  final FieldEntity field;

  @override
  List<Object?> get props => [field];
}

final class FieldDeleted extends FieldState {
  const FieldDeleted();
}

final class FieldError extends FieldState {
  const FieldError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
