import 'package:bloc/bloc.dart';

import '../../domain/usecases/get_diagnoses_usecase.dart';
import '../../domain/usecases/submit_diagnosis_usecase.dart';
import 'diagnosis_event.dart';
import 'diagnosis_state.dart';

class DiagnosisBloc extends Bloc<DiagnosisEvent, DiagnosisState> {
  DiagnosisBloc({
    required SubmitDiagnosisUseCase submitDiagnosis,
    required GetDiagnosesUseCase getDiagnoses,
  })  : _submitDiagnosis = submitDiagnosis,
        _getDiagnoses = getDiagnoses,
        super(const DiagnosisInitial()) {
    on<SubmitDiagnosis>(_onSubmitDiagnosis);
    on<LoadDiagnoses>(_onLoadDiagnoses);
    on<LoadDiagnosisById>(_onLoadDiagnosisById);
  }

  final SubmitDiagnosisUseCase _submitDiagnosis;
  final GetDiagnosesUseCase _getDiagnoses;

  Future<void> _onSubmitDiagnosis(
      SubmitDiagnosis event, Emitter<DiagnosisState> emit) async {
    emit(const DiagnosisLoading());
    try {
      final diagnosis = await _submitDiagnosis(event.diagnosis);
      emit(DiagnosisSubmitted(diagnosis: diagnosis));
    } catch (e) {
      emit(DiagnosisError(message: e.toString()));
    }
  }

  Future<void> _onLoadDiagnoses(
      LoadDiagnoses event, Emitter<DiagnosisState> emit) async {
    emit(const DiagnosisLoading());
    try {
      final diagnoses = await _getDiagnoses(fieldId: event.fieldId);
      emit(DiagnosesLoaded(diagnoses: diagnoses));
    } catch (e) {
      emit(DiagnosisError(message: e.toString()));
    }
  }

  Future<void> _onLoadDiagnosisById(
      LoadDiagnosisById event, Emitter<DiagnosisState> emit) async {
    emit(const DiagnosisLoading());
    try {
      final diagnoses = await _getDiagnoses();
      final match = diagnoses.firstWhere((d) => d.id == event.id);
      emit(DiagnosisLoaded(diagnosis: match));
    } catch (e) {
      emit(DiagnosisError(message: e.toString()));
    }
  }
}
