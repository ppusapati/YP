import 'package:bloc/bloc.dart';

import '../../domain/usecases/create_inspection_usecase.dart';
import '../../domain/usecases/get_inspections_usecase.dart';
import '../../domain/usecases/submit_inspection_usecase.dart';
import 'field_inspection_event.dart';
import 'field_inspection_state.dart';

class FieldInspectionBloc
    extends Bloc<FieldInspectionEvent, FieldInspectionState> {
  FieldInspectionBloc({
    required GetInspectionsUseCase getInspections,
    required CreateInspectionUseCase createInspection,
    required SubmitInspectionUseCase submitInspection,
  })  : _getInspections = getInspections,
        _createInspection = createInspection,
        _submitInspection = submitInspection,
        super(const FieldInspectionInitial()) {
    on<LoadInspections>(_onLoadInspections);
    on<CreateInspection>(_onCreateInspection);
    on<SubmitInspection>(_onSubmitInspection);
  }

  final GetInspectionsUseCase _getInspections;
  final CreateInspectionUseCase _createInspection;
  final SubmitInspectionUseCase _submitInspection;

  Future<void> _onLoadInspections(
      LoadInspections event, Emitter<FieldInspectionState> emit) async {
    emit(const FieldInspectionLoading());
    try {
      final inspections = await _getInspections(farmId: event.farmId);
      emit(InspectionsLoaded(inspections: inspections));
    } catch (e) {
      emit(FieldInspectionError(message: e.toString()));
    }
  }

  Future<void> _onCreateInspection(
      CreateInspection event, Emitter<FieldInspectionState> emit) async {
    emit(const FieldInspectionLoading());
    try {
      final inspection = await _createInspection(event.inspection);
      emit(InspectionCreated(inspection: inspection));
    } catch (e) {
      emit(FieldInspectionError(message: e.toString()));
    }
  }

  Future<void> _onSubmitInspection(
      SubmitInspection event, Emitter<FieldInspectionState> emit) async {
    emit(const FieldInspectionLoading());
    try {
      final inspection = await _submitInspection(event.inspectionId);
      emit(InspectionSubmitted(inspection: inspection));
    } catch (e) {
      emit(FieldInspectionError(message: e.toString()));
    }
  }
}
