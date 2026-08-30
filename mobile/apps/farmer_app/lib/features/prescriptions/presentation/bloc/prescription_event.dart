part of 'prescription_bloc.dart';

sealed class PrescriptionEvent extends Equatable {
  const PrescriptionEvent();

  @override
  List<Object?> get props => [];
}

final class LoadPrescriptions extends PrescriptionEvent {
  const LoadPrescriptions({this.prescriptionType});
  final PrescriptionType? prescriptionType;

  @override
  List<Object?> get props => [prescriptionType];
}

final class LoadPrescriptionDetail extends PrescriptionEvent {
  const LoadPrescriptionDetail({required this.prescriptionId});
  final String prescriptionId;

  @override
  List<Object?> get props => [prescriptionId];
}

final class GeneratePrescription extends PrescriptionEvent {
  const GeneratePrescription({
    required this.fieldId,
    required this.cropType,
    required this.targetYield,
    this.soilData,
  });

  final String fieldId;
  final String cropType;
  final double targetYield;
  final List<List<double>>? soilData;

  @override
  List<Object?> get props => [fieldId, cropType, targetYield, soilData];
}
