import '../../domain/entities/field_analytics_entity.dart';

/// Data model for FieldAnalytics with JSON serialization.
class FieldAnalyticsModel {
  final String fieldId;
  final String fieldName;
  final double meanYield;
  final double peakYield;
  final String yieldTrend;
  final double avgStressDays;
  final double avgNdvi;
  final int seasonsAnalyzed;
  final List<YieldTrendModel> yieldTrends;
  final List<SeasonComparisonModel> seasonComparisons;
  final RotationScoreModel? rotationScore;

  const FieldAnalyticsModel({
    required this.fieldId,
    required this.fieldName,
    required this.meanYield,
    required this.peakYield,
    required this.yieldTrend,
    required this.avgStressDays,
    required this.avgNdvi,
    required this.seasonsAnalyzed,
    this.yieldTrends = const [],
    this.seasonComparisons = const [],
    this.rotationScore,
  });

  factory FieldAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return FieldAnalyticsModel(
      fieldId: json['field_id'] as String,
      fieldName: json['field_name'] as String? ?? '',
      meanYield: (json['mean_yield'] as num).toDouble(),
      peakYield: (json['peak_yield'] as num).toDouble(),
      yieldTrend: json['yield_trend'] as String? ?? 'stable',
      avgStressDays: (json['avg_stress_days'] as num).toDouble(),
      avgNdvi: (json['avg_ndvi'] as num).toDouble(),
      seasonsAnalyzed: json['seasons_analyzed'] as int? ?? 0,
      yieldTrends: (json['yield_trends'] as List<dynamic>?)
              ?.map(
                  (e) => YieldTrendModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      seasonComparisons: (json['season_comparisons'] as List<dynamic>?)
              ?.map((e) =>
                  SeasonComparisonModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rotationScore: json['rotation_score'] != null
          ? RotationScoreModel.fromJson(
              json['rotation_score'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field_id': fieldId,
      'field_name': fieldName,
      'mean_yield': meanYield,
      'peak_yield': peakYield,
      'yield_trend': yieldTrend,
      'avg_stress_days': avgStressDays,
      'avg_ndvi': avgNdvi,
      'seasons_analyzed': seasonsAnalyzed,
      'yield_trends': yieldTrends.map((e) => e.toJson()).toList(),
      'season_comparisons':
          seasonComparisons.map((e) => e.toJson()).toList(),
      if (rotationScore != null) 'rotation_score': rotationScore!.toJson(),
    };
  }

  FieldAnalytics toEntity() {
    return FieldAnalytics(
      fieldId: fieldId,
      fieldName: fieldName,
      meanYield: meanYield,
      peakYield: peakYield,
      yieldTrend: YieldTrendDirection.values.firstWhere(
        (e) => e.name == yieldTrend,
        orElse: () => YieldTrendDirection.stable,
      ),
      avgStressDays: avgStressDays,
      avgNdvi: avgNdvi,
      seasonsAnalyzed: seasonsAnalyzed,
      yieldTrends: yieldTrends.map((e) => e.toEntity()).toList(),
      seasonComparisons:
          seasonComparisons.map((e) => e.toEntity()).toList(),
      rotationScore: rotationScore?.toEntity(),
    );
  }

  factory FieldAnalyticsModel.fromEntity(FieldAnalytics entity) {
    return FieldAnalyticsModel(
      fieldId: entity.fieldId,
      fieldName: entity.fieldName,
      meanYield: entity.meanYield,
      peakYield: entity.peakYield,
      yieldTrend: entity.yieldTrend.name,
      avgStressDays: entity.avgStressDays,
      avgNdvi: entity.avgNdvi,
      seasonsAnalyzed: entity.seasonsAnalyzed,
      yieldTrends: entity.yieldTrends
          .map((e) => YieldTrendModel.fromEntity(e))
          .toList(),
      seasonComparisons: entity.seasonComparisons
          .map((e) => SeasonComparisonModel.fromEntity(e))
          .toList(),
      rotationScore: entity.rotationScore != null
          ? RotationScoreModel.fromEntity(entity.rotationScore!)
          : null,
    );
  }
}

class YieldTrendModel {
  final String season;
  final String crop;
  final double yieldValue;
  final double? ndvi;

  const YieldTrendModel({
    required this.season,
    required this.crop,
    required this.yieldValue,
    this.ndvi,
  });

  factory YieldTrendModel.fromJson(Map<String, dynamic> json) {
    return YieldTrendModel(
      season: json['season'] as String,
      crop: json['crop'] as String? ?? '',
      yieldValue: (json['yield_value'] as num).toDouble(),
      ndvi: (json['ndvi'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'season': season,
      'crop': crop,
      'yield_value': yieldValue,
      if (ndvi != null) 'ndvi': ndvi,
    };
  }

  YieldTrend toEntity() {
    return YieldTrend(
      season: season,
      crop: crop,
      yieldValue: yieldValue,
      ndvi: ndvi,
    );
  }

  factory YieldTrendModel.fromEntity(YieldTrend entity) {
    return YieldTrendModel(
      season: entity.season,
      crop: entity.crop,
      yieldValue: entity.yieldValue,
      ndvi: entity.ndvi,
    );
  }
}

class SeasonComparisonModel {
  final String season;
  final String crop;
  final double yieldValue;
  final double yieldVsMeanPct;
  final int stressDays;
  final double stressVsMeanPct;
  final double ndviPeak;
  final double ndviVsMeanPct;
  final List<String> notableEvents;

  const SeasonComparisonModel({
    required this.season,
    required this.crop,
    required this.yieldValue,
    required this.yieldVsMeanPct,
    required this.stressDays,
    required this.stressVsMeanPct,
    required this.ndviPeak,
    required this.ndviVsMeanPct,
    this.notableEvents = const [],
  });

  factory SeasonComparisonModel.fromJson(Map<String, dynamic> json) {
    return SeasonComparisonModel(
      season: json['season'] as String,
      crop: json['crop'] as String? ?? '',
      yieldValue: (json['yield_value'] as num).toDouble(),
      yieldVsMeanPct: (json['yield_vs_mean_pct'] as num).toDouble(),
      stressDays: json['stress_days'] as int? ?? 0,
      stressVsMeanPct: (json['stress_vs_mean_pct'] as num?)?.toDouble() ?? 0,
      ndviPeak: (json['ndvi_peak'] as num).toDouble(),
      ndviVsMeanPct: (json['ndvi_vs_mean_pct'] as num?)?.toDouble() ?? 0,
      notableEvents: (json['notable_events'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'season': season,
      'crop': crop,
      'yield_value': yieldValue,
      'yield_vs_mean_pct': yieldVsMeanPct,
      'stress_days': stressDays,
      'stress_vs_mean_pct': stressVsMeanPct,
      'ndvi_peak': ndviPeak,
      'ndvi_vs_mean_pct': ndviVsMeanPct,
      'notable_events': notableEvents,
    };
  }

  SeasonComparison toEntity() {
    return SeasonComparison(
      season: season,
      crop: crop,
      yieldValue: yieldValue,
      yieldVsMeanPct: yieldVsMeanPct,
      stressDays: stressDays,
      stressVsMeanPct: stressVsMeanPct,
      ndviPeak: ndviPeak,
      ndviVsMeanPct: ndviVsMeanPct,
      notableEvents: notableEvents,
    );
  }

  factory SeasonComparisonModel.fromEntity(SeasonComparison entity) {
    return SeasonComparisonModel(
      season: entity.season,
      crop: entity.crop,
      yieldValue: entity.yieldValue,
      yieldVsMeanPct: entity.yieldVsMeanPct,
      stressDays: entity.stressDays,
      stressVsMeanPct: entity.stressVsMeanPct,
      ndviPeak: entity.ndviPeak,
      ndviVsMeanPct: entity.ndviVsMeanPct,
      notableEvents: entity.notableEvents,
    );
  }
}

class RotationScoreModel {
  final double effectivenessScore;
  final double diversityIndex;
  final int rotationLength;
  final String soilHealthImpact;
  final List<String> rotationPattern;
  final List<String> recommendations;

  const RotationScoreModel({
    required this.effectivenessScore,
    required this.diversityIndex,
    required this.rotationLength,
    required this.soilHealthImpact,
    this.rotationPattern = const [],
    this.recommendations = const [],
  });

  factory RotationScoreModel.fromJson(Map<String, dynamic> json) {
    return RotationScoreModel(
      effectivenessScore:
          (json['effectiveness_score'] as num).toDouble(),
      diversityIndex: (json['diversity_index'] as num).toDouble(),
      rotationLength: json['rotation_length'] as int? ?? 0,
      soilHealthImpact: json['soil_health_impact'] as String? ?? '',
      rotationPattern: (json['rotation_pattern'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'effectiveness_score': effectivenessScore,
      'diversity_index': diversityIndex,
      'rotation_length': rotationLength,
      'soil_health_impact': soilHealthImpact,
      'rotation_pattern': rotationPattern,
      'recommendations': recommendations,
    };
  }

  RotationScore toEntity() {
    return RotationScore(
      effectivenessScore: effectivenessScore,
      diversityIndex: diversityIndex,
      rotationLength: rotationLength,
      soilHealthImpact: soilHealthImpact,
      rotationPattern: rotationPattern,
      recommendations: recommendations,
    );
  }

  factory RotationScoreModel.fromEntity(RotationScore entity) {
    return RotationScoreModel(
      effectivenessScore: entity.effectivenessScore,
      diversityIndex: entity.diversityIndex,
      rotationLength: entity.rotationLength,
      soilHealthImpact: entity.soilHealthImpact,
      rotationPattern: entity.rotationPattern,
      recommendations: entity.recommendations,
    );
  }
}
