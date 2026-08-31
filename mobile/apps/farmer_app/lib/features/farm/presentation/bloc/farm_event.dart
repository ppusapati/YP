import 'package:equatable/equatable.dart';

import '../../domain/entities/farm_entity.dart';

sealed class FarmEvent extends Equatable {
  const FarmEvent();

  @override
  List<Object?> get props => [];
}

final class LoadFarms extends FarmEvent {
  const LoadFarms({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

final class LoadFarmById extends FarmEvent {
  const LoadFarmById({required this.farmId});

  final String farmId;

  @override
  List<Object?> get props => [farmId];
}

final class CreateFarm extends FarmEvent {
  const CreateFarm({required this.farm});

  final FarmEntity farm;

  @override
  List<Object?> get props => [farm];
}

final class UpdateFarm extends FarmEvent {
  const UpdateFarm({required this.farm});

  final FarmEntity farm;

  @override
  List<Object?> get props => [farm];
}

final class DeleteFarm extends FarmEvent {
  const DeleteFarm({required this.farmId});

  final String farmId;

  @override
  List<Object?> get props => [farmId];
}

final class SelectFarm extends FarmEvent {
  const SelectFarm({required this.farmId});

  final String farmId;

  @override
  List<Object?> get props => [farmId];
}
