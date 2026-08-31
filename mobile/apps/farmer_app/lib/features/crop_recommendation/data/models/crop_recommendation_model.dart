import '../../domain/entities/crop_recommendation_entity.dart';

class CropRecommendationModel extends CropRecommendation {
  const CropRecommendationModel({
    required super.cropName,
    required super.plantingWindowStart,
    required super.plantingWindowEnd,
    required super.soilSuitabilityScore,
    required super.expectedYield,
    required super.unit,
    super.reasons,
  });

  factory CropRecommendationModel.fromJson(Map<String, dynamic> json) {
    return CropRecommendationModel(
      cropName: json['crop_name'] as String,
      plantingWindowStart:
          DateTime.parse(json['planting_window_start'] as String),
      plantingWindowEnd:
          DateTime.parse(json['planting_window_end'] as String),
      soilSuitabilityScore:
          (json['soil_suitability_score'] as num).toDouble(),
      expectedYield: (json['expected_yield'] as num).toDouble(),
      unit: json['unit'] as String,
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop_name': cropName,
      'planting_window_start': plantingWindowStart.toIso8601String(),
      'planting_window_end': plantingWindowEnd.toIso8601String(),
      'soil_suitability_score': soilSuitabilityScore,
      'expected_yield': expectedYield,
      'unit': unit,
      'reasons': reasons,
    };
  }
}
