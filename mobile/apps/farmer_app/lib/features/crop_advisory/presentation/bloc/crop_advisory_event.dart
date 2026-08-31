import 'package:equatable/equatable.dart';

import '../../domain/entities/advisory_entity.dart';

sealed class CropAdvisoryEvent extends Equatable {
  const CropAdvisoryEvent();

  @override
  List<Object?> get props => [];
}

final class LoadAdvisories extends CropAdvisoryEvent {
  const LoadAdvisories({this.farmId});
  final String? farmId;

  @override
  List<Object?> get props => [farmId];
}

final class CreateAdvisory extends CropAdvisoryEvent {
  const CreateAdvisory({required this.advisory});
  final AdvisoryEntity advisory;

  @override
  List<Object?> get props => [advisory];
}
