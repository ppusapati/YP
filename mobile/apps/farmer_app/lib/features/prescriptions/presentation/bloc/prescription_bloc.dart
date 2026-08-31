import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/prescription_entity.dart';
import '../../domain/usecases/generate_prescription_usecase.dart';
import '../../domain/usecases/get_prescriptions_usecase.dart';

part 'prescription_event.dart';
part 'prescription_state.dart';

class PrescriptionBloc
    extends Bloc<PrescriptionEvent, PrescriptionState> {
  PrescriptionBloc({
    required GetPrescriptionsUseCase getPrescriptions,
    required GeneratePrescriptionUseCase generatePrescription,
  })  : _getPrescriptions = getPrescriptions,
        _generatePrescription = generatePrescription,
        super(const PrescriptionInitial()) {
    on<LoadPrescriptions>(_onLoadPrescriptions);
    on<LoadPrescriptionDetail>(_onLoadPrescriptionDetail);
    on<GeneratePrescription>(_onGeneratePrescription);
  }

  final GetPrescriptionsUseCase _getPrescriptions;
  final GeneratePrescriptionUseCase _generatePrescription;

  Future<void> _onLoadPrescriptions(
      LoadPrescriptions event, Emitter<PrescriptionState> emit) async {
    emit(const PrescriptionLoading());
    try {
      final prescriptions = await _getPrescriptions(
        prescriptionType: event.prescriptionType,
      );
      emit(PrescriptionsLoaded(prescriptions: prescriptions));
    } catch (e) {
      emit(PrescriptionError(message: e.toString()));
    }
  }

  Future<void> _onLoadPrescriptionDetail(
      LoadPrescriptionDetail event,
      Emitter<PrescriptionState> emit) async {
    emit(const PrescriptionLoading());
    try {
      final prescription =
          await _getPrescriptions.getById(event.prescriptionId);
      emit(PrescriptionDetailLoaded(prescription: prescription));
    } catch (e) {
      emit(PrescriptionError(message: e.toString()));
    }
  }

  Future<void> _onGeneratePrescription(
      GeneratePrescription event,
      Emitter<PrescriptionState> emit) async {
    emit(const PrescriptionLoading());
    try {
      final prescription = await _generatePrescription(
        fieldId: event.fieldId,
        cropType: event.cropType,
        targetYield: event.targetYield,
        soilData: event.soilData,
      );
      emit(PrescriptionGenerated(prescription: prescription));
    } catch (e) {
      emit(PrescriptionError(message: e.toString()));
    }
  }
}
