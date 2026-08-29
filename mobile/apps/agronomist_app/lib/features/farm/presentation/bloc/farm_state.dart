import 'package:equatable/equatable.dart';

import '../../domain/entities/farm_entity.dart';

sealed class FarmState extends Equatable {
  const FarmState();

  @override
  List<Object?> get props => [];
}

final class FarmInitial extends FarmState {
  const FarmInitial();
}

final class FarmLoading extends FarmState {
  const FarmLoading();
}

final class FarmsLoaded extends FarmState {
  const FarmsLoaded({required this.farms});

  final List<FarmEntity> farms;

  @override
  List<Object?> get props => [farms];
}

final class FarmLoaded extends FarmState {
  const FarmLoaded({required this.farm});

  final FarmEntity farm;

  @override
  List<Object?> get props => [farm];
}

final class FarmCreated extends FarmState {
  const FarmCreated({required this.farm});

  final FarmEntity farm;

  @override
  List<Object?> get props => [farm];
}

final class FarmUpdated extends FarmState {
  const FarmUpdated({required this.farm});

  final FarmEntity farm;

  @override
  List<Object?> get props => [farm];
}

final class FarmDeleted extends FarmState {
  const FarmDeleted();
}

final class FarmError extends FarmState {
  const FarmError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
