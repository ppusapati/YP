import '../../domain/entities/yield_prediction_entity.dart';

class YieldPredictionModel {
  final String id; final String fieldId; final String cropName;
  final double predictedYield; final String unit; final double confidence;
  final DateTime harvestDate; final DateTime predictedAt;

  const YieldPredictionModel({
    required this.id, required this.fieldId, required this.cropName,
    required this.predictedYield, this.unit = 'tonnes/ha',
    required this.confidence, required this.harvestDate, required this.predictedAt,
  });

  factory YieldPredictionModel.fromJson(Map<String, dynamic> json) {
    return YieldPredictionModel(
      id: json['id'] as String, fieldId: json['field_id'] as String,
      cropName: json['crop_name'] as String,
      predictedYield: (json['predicted_yield'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'tonnes/ha',
      confidence: (json['confidence'] as num).toDouble(),
      harvestDate: DateTime.parse(json['harvest_date'] as String),
      predictedAt: DateTime.parse(json['predicted_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'field_id': fieldId, 'crop_name': cropName,
    'predicted_yield': predictedYield, 'unit': unit, 'confidence': confidence,
    'harvest_date': harvestDate.toIso8601String(), 'predicted_at': predictedAt.toIso8601String(),
  };

  YieldPredictionEntity toEntity() => YieldPredictionEntity(
    id: id, fieldId: fieldId, cropName: cropName,
    predictedYield: predictedYield, unit: unit, confidence: confidence,
    harvestDate: harvestDate, predictedAt: predictedAt,
  );
}
