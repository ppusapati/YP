import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/diagnosis_repository.dart';
import 'diagnosis_event.dart';
import 'diagnosis_state.dart';

/// BLoC for AI plant diagnosis: capture, upload, diagnose, and history.
class DiagnosisBloc extends Bloc<DiagnosisEvent, DiagnosisState> {
  DiagnosisBloc({required DiagnosisRepository repository})
      : _repository = repository,
        super(const DiagnosisInitial()) {
    on<CaptureImage>(_onCaptureImage);
    on<SubmitDiagnosis>(_onSubmitDiagnosis);
    on<LoadDiagnosisHistory>(_onLoadHistory);
  }

  final DiagnosisRepository _repository;

  Future<void> _onCaptureImage(
    CaptureImage event,
    Emitter<DiagnosisState> emit,
  ) async {
    // The BLoC signals the UI that the camera is ready; the capture itself is
    // the UI layer's, through image_picker. The resulting path comes back as
    // SubmitDiagnosis, which reads the file and sends the bytes.
    emit(const CameraReady());
  }

  Future<void> _onSubmitDiagnosis(
    SubmitDiagnosis event,
    Emitter<DiagnosisState> emit,
  ) async {
    emit(const Diagnosing());
    try {
      final diagnosis = await _repository.submitDiagnosis(
        fieldId: event.fieldId,
        imagePath: event.imagePath,
      );
      emit(DiagnosisComplete(diagnosis: diagnosis));
    } catch (e) {
      emit(DiagnosisError(message: e.toString()));
    }
  }

  Future<void> _onLoadHistory(
    LoadDiagnosisHistory event,
    Emitter<DiagnosisState> emit,
  ) async {
    emit(const DiagnosisLoading());
    try {
      final diagnoses =
          await _repository.getDiagnosisHistory(fieldId: event.fieldId);
      emit(DiagnosisHistoryLoaded(diagnoses: diagnoses));
    } catch (e) {
      emit(DiagnosisError(message: e.toString()));
    }
  }
}
