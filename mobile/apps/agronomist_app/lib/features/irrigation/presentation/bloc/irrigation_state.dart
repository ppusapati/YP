import 'package:equatable/equatable.dart';

import '../../domain/entities/irrigation_zone_entity.dart';

sealed class IrrigationState extends Equatable {
  const IrrigationState();
  @override
  List<Object?> get props => [];
}

final class IrrigationInitial extends IrrigationState {
  const IrrigationInitial();
}

final class IrrigationLoading extends IrrigationState {
  const IrrigationLoading();
}

final class IrrigationZonesLoaded extends IrrigationState {
  const IrrigationZonesLoaded({required this.zones});
  final List<IrrigationZoneEntity> zones;
  @override
  List<Object?> get props => [zones];
}

final class IrrigationError extends IrrigationState {
  const IrrigationError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
