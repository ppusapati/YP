import 'package:equatable/equatable.dart';

enum SoilTexture {
  sandy,
  loamy,
  clay,
  silt,
  sandyLoam,
  clayLoam,
  siltLoam,
}

class SoilAnalysis extends Equatable {
  const SoilAnalysis({
    required this.id,
    required this.fieldId,
    required this.pH,
    required this.organicCarbon,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.texture,
    required this.analysisDate,
    this.fieldName,
  });

  final String id;
  final String fieldId;
  final double pH;
  final double organicCarbon;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final SoilTexture texture;
  final DateTime analysisDate;
  final String? fieldName;

  String get pHClassification {
    if (pH < 5.5) return 'Acidic';
    if (pH < 6.5) return 'Slightly Acidic';
    if (pH < 7.5) return 'Neutral';
    if (pH < 8.5) return 'Slightly Alkaline';
    return 'Alkaline';
  }

  String get fertilityRating {
    final score = _fertilityScore;
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Moderate';
    if (score >= 20) return 'Low';
    return 'Very Low';
  }

  double get _fertilityScore {
    double score = 0;
    // pH scoring: optimal around 6.5
    score += (1.0 - (pH - 6.5).abs() / 3.0).clamp(0.0, 1.0) * 25;
    // Organic carbon scoring: higher is better up to ~3%
    score += (organicCarbon / 3.0).clamp(0.0, 1.0) * 25;
    // NPK scoring
    score += (nitrogen / 300).clamp(0.0, 1.0) * 16.67;
    score += (phosphorus / 50).clamp(0.0, 1.0) * 16.67;
    score += (potassium / 300).clamp(0.0, 1.0) * 16.66;
    return score;
  }

  SoilAnalysis copyWith({
    String? id,
    String? fieldId,
    double? pH,
    double? organicCarbon,
    double? nitrogen,
    double? phosphorus,
    double? potassium,
    SoilTexture? texture,
    DateTime? analysisDate,
    String? fieldName,
  }) {
    return SoilAnalysis(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      pH: pH ?? this.pH,
      organicCarbon: organicCarbon ?? this.organicCarbon,
      nitrogen: nitrogen ?? this.nitrogen,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      texture: texture ?? this.texture,
      analysisDate: analysisDate ?? this.analysisDate,
      fieldName: fieldName ?? this.fieldName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fieldId,
        pH,
        organicCarbon,
        nitrogen,
        phosphorus,
        potassium,
        texture,
        analysisDate,
        fieldName,
      ];
}
