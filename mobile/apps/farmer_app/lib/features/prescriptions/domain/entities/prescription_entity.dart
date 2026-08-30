import 'package:equatable/equatable.dart';

/// Type of prescription map.
enum PrescriptionType {
  fertilizer,
  irrigation,
  seeding,
  liming;

  String get displayName => switch (this) {
        fertilizer => 'Fertilizer',
        irrigation => 'Irrigation',
        seeding => 'Seeding',
        liming => 'Liming',
      };
}

/// Summary data for a single management zone.
class ZoneSummary extends Equatable {
  final String zone;
  final int cellCount;
  final double areaHectares;
  final double minRate;
  final double meanRate;
  final double maxRate;
  final double totalAmount;

  const ZoneSummary({
    required this.zone,
    this.cellCount = 0,
    required this.areaHectares,
    required this.minRate,
    required this.meanRate,
    required this.maxRate,
    required this.totalAmount,
  });

  @override
  List<Object?> get props =>
      [zone, cellCount, areaHectares, minRate, meanRate, maxRate, totalAmount];
}

/// A single prescription map (e.g. fertilizer rates for a field).
class PrescriptionMap extends Equatable {
  final String id;
  final PrescriptionType prescriptionType;
  final String unit;
  final double avgRate;
  final double totalAmount;
  final List<double> rates;
  final List<ZoneSummary> zones;

  const PrescriptionMap({
    required this.id,
    required this.prescriptionType,
    required this.unit,
    required this.avgRate,
    required this.totalAmount,
    this.rates = const [],
    this.zones = const [],
  });

  @override
  List<Object?> get props =>
      [id, prescriptionType, unit, avgRate, totalAmount, rates, zones];
}

/// A bundle of prescriptions generated for a field.
class PrescriptionBundle extends Equatable {
  final String id;
  final String fieldId;
  final String fieldName;
  final String cropType;
  final double targetYield;
  final DateTime createdAt;
  final double? estimatedCostSavings;
  final double? estimatedYieldGain;
  final List<PrescriptionMap> prescriptions;

  const PrescriptionBundle({
    required this.id,
    required this.fieldId,
    required this.fieldName,
    required this.cropType,
    required this.targetYield,
    required this.createdAt,
    this.estimatedCostSavings,
    this.estimatedYieldGain,
    this.prescriptions = const [],
  });

  @override
  List<Object?> get props => [
        id,
        fieldId,
        fieldName,
        cropType,
        targetYield,
        createdAt,
        estimatedCostSavings,
        estimatedYieldGain,
        prescriptions,
      ];
}
