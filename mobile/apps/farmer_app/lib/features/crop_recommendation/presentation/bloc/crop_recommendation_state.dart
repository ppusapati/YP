import 'package:equatable/equatable.dart';

import '../../domain/entities/crop_recommendation_entity.dart';

sealed class CropRecommendationState extends Equatable {
  const CropRecommendationState();

  @override
  List<Object?> get props => [];
}

final class CropRecInitial extends CropRecommendationState {
  const CropRecInitial();
}

final class CropRecLoading extends CropRecommendationState {
  const CropRecLoading();
}

final class RecommendationsLoaded extends CropRecommendationState {
  const RecommendationsLoaded({
    required this.recommendations,
    required this.fieldId,
  });

  final List<CropRecommendation> recommendations;
  final String fieldId;

  @override
  List<Object?> get props => [recommendations, fieldId];
}

final class CropRecError extends CropRecommendationState {
  const CropRecError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
