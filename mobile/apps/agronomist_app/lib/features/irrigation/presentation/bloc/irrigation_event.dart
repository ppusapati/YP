import 'package:equatable/equatable.dart';

sealed class IrrigationEvent extends Equatable {
  const IrrigationEvent();
  @override
  List<Object?> get props => [];
}

final class LoadIrrigationZones extends IrrigationEvent {
  const LoadIrrigationZones({required this.fieldId});
  final String fieldId;
  @override
  List<Object?> get props => [fieldId];
}
