import '../../domain/entities/yield_factor_entity.dart';
import '../../domain/entities/yield_prediction_entity.dart';

class YieldFactorModel extends YieldFactor {
  const YieldFactorModel({
    required super.name,
    required super.impact,
    required super.value,
  });

  factory YieldFactorModel.fromJson(Map<String, dynamic> json) {
    return YieldFactorModel(
      name: json['name'] as String,
      impact: (json['impact'] as num).toDouble(),
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'impact': impact,
        'value': value,
      };
}

class YieldPredictionModel extends YieldPrediction {
  const YieldPredictionModel({
    required super.id,
    required super.fieldId,
    required super.cropType,
    required super.expectedYield,
    required super.unit,
    required super.harvestDate,
    required super.confidenceLevel,
    required super.factors,
    super.fieldName,
    super.previousYield,
  });

  factory YieldPredictionModel.fromJson(Map<String, dynamic> json) {
    return YieldPredictionModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      cropType: json['crop_type'] as String,
      expectedYield: (json['expected_yield'] as num).toDouble(),
      unit: json['unit'] as String,
      harvestDate: DateTime.parse(json['harvest_date'] as String),
      confidenceLevel: (json['confidence_level'] as num).toDouble(),
      factors: (json['factors'] as List<dynamic>?)
              ?.map((e) =>
                  YieldFactorModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      fieldName: json['field_name'] as String?,
      previousYield: (json['previous_yield'] as num?)?.toDouble(),
    );
  }

  factory YieldPredictionModel.fromEntity(YieldPrediction entity) {
    return YieldPredictionModel(
      id: entity.id,
      fieldId: entity.fieldId,
      cropType: entity.cropType,
      expectedYield: entity.expectedYield,
      unit: entity.unit,
      harvestDate: entity.harvestDate,
      confidenceLevel: entity.confidenceLevel,
      factors: entity.factors,
      fieldName: entity.fieldName,
      previousYield: entity.previousYield,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'crop_type': cropType,
      'expected_yield': expectedYield,
      'unit': unit,
      'harvest_date': harvestDate.toIso8601String(),
      'confidence_level': confidenceLevel,
      'factors': factors
          .map((f) => {
                'name': f.name,
                'impact': f.impact,
                'value': f.value,
              })
          .toList(),
      'field_name': fieldName,
      'previous_yield': previousYield,
    };
  }
}
