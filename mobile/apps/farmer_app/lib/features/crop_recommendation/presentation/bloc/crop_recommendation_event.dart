import 'package:equatable/equatable.dart';

sealed class CropRecommendationEvent extends Equatable {
  const CropRecommendationEvent();

  @override
  List<Object?> get props => [];
}

final class LoadRecommendations extends CropRecommendationEvent {
  const LoadRecommendations({required this.fieldId});
  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}

final class SelectField extends CropRecommendationEvent {
  const SelectField(this.fieldId);
  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}
