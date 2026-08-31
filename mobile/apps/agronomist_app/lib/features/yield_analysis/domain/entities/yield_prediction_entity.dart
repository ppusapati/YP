import 'package:equatable/equatable.dart';

class YieldPredictionEntity extends Equatable {
  final String id;
  final String fieldId;
  final String cropName;
  final double predictedYield;
  final String unit;
  final double confidence;
  final DateTime harvestDate;
  final DateTime predictedAt;

  const YieldPredictionEntity({
    required this.id, required this.fieldId, required this.cropName,
    required this.predictedYield, this.unit = 'tonnes/ha',
    required this.confidence, required this.harvestDate, required this.predictedAt,
  });

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';

  @override
  List<Object?> get props => [id, fieldId, cropName, predictedYield, unit, confidence, harvestDate, predictedAt];
}
