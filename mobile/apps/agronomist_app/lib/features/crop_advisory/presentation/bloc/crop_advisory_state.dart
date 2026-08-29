import 'package:equatable/equatable.dart';

import '../../domain/entities/advisory_entity.dart';

sealed class CropAdvisoryState extends Equatable {
  const CropAdvisoryState();

  @override
  List<Object?> get props => [];
}

final class CropAdvisoryInitial extends CropAdvisoryState {
  const CropAdvisoryInitial();
}

final class CropAdvisoryLoading extends CropAdvisoryState {
  const CropAdvisoryLoading();
}

final class AdvisoriesLoaded extends CropAdvisoryState {
  const AdvisoriesLoaded({required this.advisories});
  final List<AdvisoryEntity> advisories;

  @override
  List<Object?> get props => [advisories];
}

final class AdvisoryCreated extends CropAdvisoryState {
  const AdvisoryCreated({required this.advisory});
  final AdvisoryEntity advisory;

  @override
  List<Object?> get props => [advisory];
}

final class CropAdvisoryError extends CropAdvisoryState {
  const CropAdvisoryError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
