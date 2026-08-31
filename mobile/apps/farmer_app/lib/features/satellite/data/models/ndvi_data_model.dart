import '../../domain/entities/satellite_entity.dart';

/// Data model for NDVI data points with JSON/protobuf serialization.
class NdviDataModel {
  final DateTime date;
  final double meanNdvi;
  final double minNdvi;
  final double maxNdvi;

  const NdviDataModel({
    required this.date,
    required this.meanNdvi,
    required this.minNdvi,
    required this.maxNdvi,
  });

  factory NdviDataModel.fromJson(Map<String, dynamic> json) {
    return NdviDataModel(
      date: DateTime.parse(json['date'] as String),
      meanNdvi: (json['mean_ndvi'] as num).toDouble(),
      minNdvi: (json['min_ndvi'] as num).toDouble(),
      maxNdvi: (json['max_ndvi'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mean_ndvi': meanNdvi,
      'min_ndvi': minNdvi,
      'max_ndvi': maxNdvi,
    };
  }

  factory NdviDataModel.fromProto(Map<String, dynamic> proto) {
    return NdviDataModel(
      date: proto['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (proto['date'] as num).toInt())
          : DateTime.now(),
      meanNdvi: (proto['mean_ndvi'] as num?)?.toDouble() ?? 0.0,
      minNdvi: (proto['min_ndvi'] as num?)?.toDouble() ?? 0.0,
      maxNdvi: (proto['max_ndvi'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toProto() {
    return {
      'date': date.millisecondsSinceEpoch,
      'mean_ndvi': meanNdvi,
      'min_ndvi': minNdvi,
      'max_ndvi': maxNdvi,
    };
  }

  NdviDataPoint toEntity() {
    return NdviDataPoint(
      date: date,
      meanNdvi: meanNdvi,
      minNdvi: minNdvi,
      maxNdvi: maxNdvi,
    );
  }

  factory NdviDataModel.fromEntity(NdviDataPoint entity) {
    return NdviDataModel(
      date: entity.date,
      meanNdvi: entity.meanNdvi,
      minNdvi: entity.minNdvi,
      maxNdvi: entity.maxNdvi,
    );
  }
}
