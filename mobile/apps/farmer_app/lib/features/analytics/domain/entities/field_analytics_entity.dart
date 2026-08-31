import 'package:equatable/equatable.dart';

/// Trend direction for yield over time.
enum YieldTrendDirection {
  increasing,
  decreasing,
  stable;

  String get displayName => switch (this) {
        increasing => 'Increasing',
        decreasing => 'Decreasing',
        stable => 'Stable',
      };
}

/// A single yield data point in a historical trend.
class YieldTrend extends Equatable {
  final String season;
  final String crop;
  final double yieldValue;
  final double? ndvi;

  const YieldTrend({
    required this.season,
    required this.crop,
    required this.yieldValue,
    this.ndvi,
  });

  @override
  List<Object?> get props => [season, crop, yieldValue, ndvi];
}

/// Comparison data for a single season against historical means.
class SeasonComparison extends Equatable {
  final String season;
  final String crop;
  final double yieldValue;
  final double yieldVsMeanPct;
  final int stressDays;
  final double stressVsMeanPct;
  final double ndviPeak;
  final double ndviVsMeanPct;
  final List<String> notableEvents;

  const SeasonComparison({
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

  @override
  List<Object?> get props => [
        season,
        crop,
        yieldValue,
        yieldVsMeanPct,
        stressDays,
        stressVsMeanPct,
        ndviPeak,
        ndviVsMeanPct,
        notableEvents,
      ];
}

/// Score representing how effective a crop rotation has been.
class RotationScore extends Equatable {
  final double effectivenessScore;
  final double diversityIndex;
  final int rotationLength;
  final String soilHealthImpact;
  final List<String> rotationPattern;
  final List<String> recommendations;

  const RotationScore({
    required this.effectivenessScore,
    required this.diversityIndex,
    required this.rotationLength,
    required this.soilHealthImpact,
    this.rotationPattern = const [],
    this.recommendations = const [],
  });

  @override
  List<Object?> get props => [
        effectivenessScore,
        diversityIndex,
        rotationLength,
        soilHealthImpact,
        rotationPattern,
        recommendations,
      ];
}

/// Aggregated historical analytics for a single field.
class FieldAnalytics extends Equatable {
  final String fieldId;
  final String fieldName;
  final double meanYield;
  final double peakYield;
  final YieldTrendDirection yieldTrend;
  final double avgStressDays;
  final double avgNdvi;
  final int seasonsAnalyzed;
  final List<YieldTrend> yieldTrends;
  final List<SeasonComparison> seasonComparisons;
  final RotationScore? rotationScore;

  const FieldAnalytics({
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

  @override
  List<Object?> get props => [
        fieldId,
        fieldName,
        meanYield,
        peakYield,
        yieldTrend,
        avgStressDays,
        avgNdvi,
        seasonsAnalyzed,
        yieldTrends,
        seasonComparisons,
        rotationScore,
      ];
}
