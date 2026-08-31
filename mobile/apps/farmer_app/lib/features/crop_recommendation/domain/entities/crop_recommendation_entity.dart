import 'package:equatable/equatable.dart';

/// Represents a crop recommendation with planting guidance.
class CropRecommendation extends Equatable {
  final String cropName;
  final DateTime plantingWindowStart;
  final DateTime plantingWindowEnd;
  final double soilSuitabilityScore;
  final double expectedYield;
  final String unit;
  final List<String> reasons;

  const CropRecommendation({
    required this.cropName,
    required this.plantingWindowStart,
    required this.plantingWindowEnd,
    required this.soilSuitabilityScore,
    required this.expectedYield,
    required this.unit,
    this.reasons = const [],
  });

  /// Planting window duration in days.
  int get plantingWindowDays =>
      plantingWindowEnd.difference(plantingWindowStart).inDays;

  /// Whether the current date is within the planting window.
  bool get isInPlantingWindow {
    final now = DateTime.now();
    return now.isAfter(plantingWindowStart) && now.isBefore(plantingWindowEnd);
  }

  /// Days until planting window opens, or 0 if already open/past.
  int get daysUntilPlanting {
    final now = DateTime.now();
    if (now.isAfter(plantingWindowStart)) return 0;
    return plantingWindowStart.difference(now).inDays;
  }

  /// Suitability category based on score.
  String get suitabilityLabel {
    if (soilSuitabilityScore >= 0.8) return 'Excellent';
    if (soilSuitabilityScore >= 0.6) return 'Good';
    if (soilSuitabilityScore >= 0.4) return 'Fair';
    return 'Poor';
  }

  CropRecommendation copyWith({
    String? cropName,
    DateTime? plantingWindowStart,
    DateTime? plantingWindowEnd,
    double? soilSuitabilityScore,
    double? expectedYield,
    String? unit,
    List<String>? reasons,
  }) {
    return CropRecommendation(
      cropName: cropName ?? this.cropName,
      plantingWindowStart: plantingWindowStart ?? this.plantingWindowStart,
      plantingWindowEnd: plantingWindowEnd ?? this.plantingWindowEnd,
      soilSuitabilityScore: soilSuitabilityScore ?? this.soilSuitabilityScore,
      expectedYield: expectedYield ?? this.expectedYield,
      unit: unit ?? this.unit,
      reasons: reasons ?? this.reasons,
    );
  }

  @override
  List<Object?> get props => [
        cropName,
        plantingWindowStart,
        plantingWindowEnd,
        soilSuitabilityScore,
        expectedYield,
        unit,
        reasons,
      ];

  @override
  String toString() => 'CropRecommendation(crop: $cropName, '
      'score: ${soilSuitabilityScore.toStringAsFixed(2)})';
}
