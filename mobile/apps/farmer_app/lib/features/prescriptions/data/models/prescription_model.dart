import '../../domain/entities/prescription_entity.dart';

/// Data model for PrescriptionBundle with JSON serialization.
class PrescriptionBundleModel {
  final String id;
  final String fieldId;
  final String fieldName;
  final String cropType;
  final double targetYield;
  final DateTime createdAt;
  final double? estimatedCostSavings;
  final double? estimatedYieldGain;
  final List<PrescriptionMapModel> prescriptions;

  const PrescriptionBundleModel({
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

  factory PrescriptionBundleModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionBundleModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      fieldName: json['field_name'] as String? ?? '',
      cropType: json['crop_type'] as String? ?? '',
      targetYield: (json['target_yield'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      estimatedCostSavings:
          (json['estimated_cost_savings'] as num?)?.toDouble(),
      estimatedYieldGain:
          (json['estimated_yield_gain'] as num?)?.toDouble(),
      prescriptions: (json['prescriptions'] as List<dynamic>?)
              ?.map((e) => PrescriptionMapModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'field_name': fieldName,
      'crop_type': cropType,
      'target_yield': targetYield,
      'created_at': createdAt.toIso8601String(),
      if (estimatedCostSavings != null)
        'estimated_cost_savings': estimatedCostSavings,
      if (estimatedYieldGain != null)
        'estimated_yield_gain': estimatedYieldGain,
      'prescriptions': prescriptions.map((e) => e.toJson()).toList(),
    };
  }

  PrescriptionBundle toEntity() {
    return PrescriptionBundle(
      id: id,
      fieldId: fieldId,
      fieldName: fieldName,
      cropType: cropType,
      targetYield: targetYield,
      createdAt: createdAt,
      estimatedCostSavings: estimatedCostSavings,
      estimatedYieldGain: estimatedYieldGain,
      prescriptions: prescriptions.map((e) => e.toEntity()).toList(),
    );
  }

  factory PrescriptionBundleModel.fromEntity(PrescriptionBundle entity) {
    return PrescriptionBundleModel(
      id: entity.id,
      fieldId: entity.fieldId,
      fieldName: entity.fieldName,
      cropType: entity.cropType,
      targetYield: entity.targetYield,
      createdAt: entity.createdAt,
      estimatedCostSavings: entity.estimatedCostSavings,
      estimatedYieldGain: entity.estimatedYieldGain,
      prescriptions: entity.prescriptions
          .map((e) => PrescriptionMapModel.fromEntity(e))
          .toList(),
    );
  }
}

class PrescriptionMapModel {
  final String id;
  final String prescriptionType;
  final String unit;
  final double avgRate;
  final double totalAmount;
  final List<double> rates;
  final List<ZoneSummaryModel> zones;

  const PrescriptionMapModel({
    required this.id,
    required this.prescriptionType,
    required this.unit,
    required this.avgRate,
    required this.totalAmount,
    this.rates = const [],
    this.zones = const [],
  });

  factory PrescriptionMapModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionMapModel(
      id: json['id'] as String,
      prescriptionType: json['prescription_type'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      avgRate: (json['avg_rate'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      rates: (json['rates'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      zones: (json['zones'] as List<dynamic>?)
              ?.map((e) =>
                  ZoneSummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescription_type': prescriptionType,
      'unit': unit,
      'avg_rate': avgRate,
      'total_amount': totalAmount,
      'rates': rates,
      'zones': zones.map((e) => e.toJson()).toList(),
    };
  }

  PrescriptionMap toEntity() {
    return PrescriptionMap(
      id: id,
      prescriptionType: PrescriptionType.values.firstWhere(
        (e) => e.name == prescriptionType,
        orElse: () => PrescriptionType.fertilizer,
      ),
      unit: unit,
      avgRate: avgRate,
      totalAmount: totalAmount,
      rates: rates,
      zones: zones.map((e) => e.toEntity()).toList(),
    );
  }

  factory PrescriptionMapModel.fromEntity(PrescriptionMap entity) {
    return PrescriptionMapModel(
      id: entity.id,
      prescriptionType: entity.prescriptionType.name,
      unit: entity.unit,
      avgRate: entity.avgRate,
      totalAmount: entity.totalAmount,
      rates: entity.rates,
      zones: entity.zones
          .map((e) => ZoneSummaryModel.fromEntity(e))
          .toList(),
    );
  }
}

class ZoneSummaryModel {
  final String zone;
  final int cellCount;
  final double areaHectares;
  final double minRate;
  final double meanRate;
  final double maxRate;
  final double totalAmount;

  const ZoneSummaryModel({
    required this.zone,
    this.cellCount = 0,
    required this.areaHectares,
    required this.minRate,
    required this.meanRate,
    required this.maxRate,
    required this.totalAmount,
  });

  factory ZoneSummaryModel.fromJson(Map<String, dynamic> json) {
    return ZoneSummaryModel(
      zone: json['zone'] as String,
      cellCount: json['cell_count'] as int? ?? 0,
      areaHectares: (json['area_hectares'] as num).toDouble(),
      minRate: (json['min_rate'] as num).toDouble(),
      meanRate: (json['mean_rate'] as num).toDouble(),
      maxRate: (json['max_rate'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zone': zone,
      'cell_count': cellCount,
      'area_hectares': areaHectares,
      'min_rate': minRate,
      'mean_rate': meanRate,
      'max_rate': maxRate,
      'total_amount': totalAmount,
    };
  }

  ZoneSummary toEntity() {
    return ZoneSummary(
      zone: zone,
      cellCount: cellCount,
      areaHectares: areaHectares,
      minRate: minRate,
      meanRate: meanRate,
      maxRate: maxRate,
      totalAmount: totalAmount,
    );
  }

  factory ZoneSummaryModel.fromEntity(ZoneSummary entity) {
    return ZoneSummaryModel(
      zone: entity.zone,
      cellCount: entity.cellCount,
      areaHectares: entity.areaHectares,
      minRate: entity.minRate,
      meanRate: entity.meanRate,
      maxRate: entity.maxRate,
      totalAmount: entity.totalAmount,
    );
  }
}
