import 'package:equatable/equatable.dart';

import 'yield_factor_entity.dart';

class YieldPrediction extends Equatable {
  const YieldPrediction({
    required this.id,
    required this.fieldId,
    required this.cropType,
    required this.expectedYield,
    required this.unit,
    required this.harvestDate,
    required this.confidenceLevel,
    required this.factors,
    this.fieldName,
    this.previousYield,
  });

  final String id;
  final String fieldId;
  final String cropType;
  final double expectedYield;
  final String unit;
  final DateTime harvestDate;
  final double confidenceLevel; // 0.0 to 1.0
  final List<YieldFactor> factors;
  final String? fieldName;
  final double? previousYield;

  int get daysToHarvest {
    final now = DateTime.now();
    return harvestDate.difference(now).inDays;
  }

  bool get isHarvestSoon => daysToHarvest <= 14;

  double? get yieldChangePercent {
    if (previousYield == null || previousYield == 0) return null;
    return ((expectedYield - previousYield!) / previousYield!) * 100;
  }

  String get confidenceLabel {
    if (confidenceLevel >= 0.85) return 'High';
    if (confidenceLevel >= 0.65) return 'Medium';
    return 'Low';
  }

  YieldPrediction copyWith({
    String? id,
    String? fieldId,
    String? cropType,
    double? expectedYield,
    String? unit,
    DateTime? harvestDate,
    double? confidenceLevel,
    List<YieldFactor>? factors,
    String? fieldName,
    double? previousYield,
  }) {
    return YieldPrediction(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      cropType: cropType ?? this.cropType,
      expectedYield: expectedYield ?? this.expectedYield,
      unit: unit ?? this.unit,
      harvestDate: harvestDate ?? this.harvestDate,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      factors: factors ?? this.factors,
      fieldName: fieldName ?? this.fieldName,
      previousYield: previousYield ?? this.previousYield,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fieldId,
        cropType,
        expectedYield,
        unit,
        harvestDate,
        confidenceLevel,
        factors,
        fieldName,
        previousYield,
      ];
}
