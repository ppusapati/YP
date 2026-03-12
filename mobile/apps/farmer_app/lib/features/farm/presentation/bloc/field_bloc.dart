import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/farm_repository.dart';
import 'field_event.dart';
import 'field_state.dart';

/// BLoC for managing field CRUD operations within a farm.
class FieldBloc extends Bloc<FieldEvent, FieldState> {
  FieldBloc({required FarmRepository farmRepository})
      : _farmRepository = farmRepository,
        super(const FieldInitial()) {
    on<LoadFields>(_onLoadFields);
    on<CreateField>(_onCreateField);
    on<UpdateField>(_onUpdateField);
    on<DeleteField>(_onDeleteField);
    on<SelectField>(_onSelectField);
  }

  final FarmRepository _farmRepository;

  Future<void> _onLoadFields(
    LoadFields event,
    Emitter<FieldState> emit,
  ) async {
    emit(const FieldLoading());
    try {
      final fields = await _farmRepository.getFieldsByFarmId(event.farmId);
      emit(FieldsLoaded(fields: fields));
    } catch (e) {
      emit(FieldError(message: e.toString()));
    }
  }

  Future<void> _onCreateField(
    CreateField event,
    Emitter<FieldState> emit,
  ) async {
    emit(const FieldLoading());
    try {
      final field = await _farmRepository.createField(event.field);
      emit(FieldCreated(field: field));
    } catch (e) {
      emit(FieldError(message: e.toString()));
    }
  }

  Future<void> _onUpdateField(
    UpdateField event,
    Emitter<FieldState> emit,
  ) async {
    emit(const FieldLoading());
    try {
      final field = await _farmRepository.updateField(event.field);
      emit(FieldUpdated(field: field));
    } catch (e) {
      emit(FieldError(message: e.toString()));
    }
  }

  Future<void> _onDeleteField(
    DeleteField event,
    Emitter<FieldState> emit,
  ) async {
    emit(const FieldLoading());
    try {
      await _farmRepository.deleteField(event.fieldId);
      emit(const FieldDeleted());
      // Reload fields after deletion.
      final fields = await _farmRepository.getFieldsByFarmId(event.farmId);
      emit(FieldsLoaded(fields: fields));
    } catch (e) {
      emit(FieldError(message: e.toString()));
    }
  }

  Future<void> _onSelectField(
    SelectField event,
    Emitter<FieldState> emit,
  ) async {
    final currentState = state;
    if (currentState is FieldsLoaded) {
      emit(currentState.copyWith(selectedFieldId: event.fieldId));
    }
  }
}
