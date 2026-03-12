import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Soil nutrient values for the radar chart.
class SoilNutrientData {
  const SoilNutrientData({
    required this.ph,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.organicCarbon,
  });

  /// pH (typically 0-14, normalised to 0-1 for display).
  final double ph;

  /// Nitrogen (kg/ha), normalised 0-1.
  final double nitrogen;

  /// Phosphorus (kg/ha), normalised 0-1.
  final double phosphorus;

  /// Potassium (kg/ha), normalised 0-1.
  final double potassium;

  /// Organic carbon (%), normalised 0-1.
  final double organicCarbon;

  List<double> get values => [ph, nitrogen, phosphorus, potassium, organicCarbon];
}

/// A radar chart displaying soil nutrient levels with an optional overlay
/// indicating the optimal range.
class SoilChart extends StatelessWidget {
  const SoilChart({
    super.key,
    required this.data,
    this.optimalRange,
    this.height = 260,
  });

  /// Current soil nutrient values (each 0.0 – 1.0).
  final SoilNutrientData data;

  /// Optimal nutrient range overlay (each 0.0 – 1.0).
  final SoilNutrientData? optimalRange;

  final double height;

  static const _labels = ['pH', 'N', 'P', 'K', 'OC'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 4,
          ticksTextStyle: AppTypography.chartAxis.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          tickBorderData: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          gridBorderData: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          radarBorderData: BorderSide.none,
          titleTextStyle: AppTypography.labelMedium.copyWith(
            color: colorScheme.onSurface,
          ),
          titlePositionPercentageOffset: 0.18,
          getTitle: (index, angle) => RadarChartTitle(
            text: _labels[index],
          ),
          dataSets: [
            // Optimal range (drawn first, behind)
            if (optimalRange != null)
              RadarDataSet(
                dataEntries: optimalRange!.values
                    .map((v) => RadarEntry(value: v.clamp(0, 1)))
                    .toList(),
                fillColor: AppColors.primaryContainer.withValues(alpha: 0.30),
                borderColor: AppColors.primary.withValues(alpha: 0.4),
                borderWidth: 1.5,
                entryRadius: 0,
              ),
            // Actual values
            RadarDataSet(
              dataEntries: data.values
                  .map((v) => RadarEntry(value: v.clamp(0, 1)))
                  .toList(),
              fillColor: AppColors.accent.withValues(alpha: 0.20),
              borderColor: AppColors.accent,
              borderWidth: 2.5,
              entryRadius: 3,
            ),
          ],
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }
}
