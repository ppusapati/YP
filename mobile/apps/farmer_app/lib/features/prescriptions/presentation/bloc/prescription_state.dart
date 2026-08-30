part of 'prescription_bloc.dart';

sealed class PrescriptionState extends Equatable {
  const PrescriptionState();

  @override
  List<Object?> get props => [];
}

final class PrescriptionInitial extends PrescriptionState {
  const PrescriptionInitial();
}

final class PrescriptionLoading extends PrescriptionState {
  const PrescriptionLoading();
}

final class PrescriptionsLoaded extends PrescriptionState {
  const PrescriptionsLoaded({required this.prescriptions});
  final List<PrescriptionBundle> prescriptions;

  @override
  List<Object?> get props => [prescriptions];
}

final class PrescriptionDetailLoaded extends PrescriptionState {
  const PrescriptionDetailLoaded({required this.prescription});
  final PrescriptionBundle prescription;

  @override
  List<Object?> get props => [prescription];
}

final class PrescriptionGenerated extends PrescriptionState {
  const PrescriptionGenerated({required this.prescription});
  final PrescriptionBundle prescription;

  @override
  List<Object?> get props => [prescription];
}

final class PrescriptionError extends PrescriptionState {
  const PrescriptionError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
