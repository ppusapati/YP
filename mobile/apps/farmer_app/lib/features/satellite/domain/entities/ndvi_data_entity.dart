import 'package:equatable/equatable.dart';

/// Represents NDVI (Normalized Difference Vegetation Index) data for a field.
class NdviDataEntity extends Equatable {
  final String fieldId;
  final List<double> values;
  final DateTime timestamp;
  final double min;
  final double max;
  final double mean;

  const NdviDataEntity({
    required this.fieldId,
    required this.values,
    required this.timestamp,
    required this.min,
    required this.max,
    required this.mean,
  });

  /// Returns a human-readable health classification based on mean NDVI.
  String get healthClassification {
    if (mean >= 0.7) return 'Excellent';
    if (mean >= 0.5) return 'Good';
    if (mean >= 0.3) return 'Moderate';
    if (mean >= 0.1) return 'Poor';
    return 'Critical';
  }

  NdviDataEntity copyWith({
    String? fieldId,
    List<double>? values,
    DateTime? timestamp,
    double? min,
    double? max,
    double? mean,
  }) {
    return NdviDataEntity(
      fieldId: fieldId ?? this.fieldId,
      values: values ?? this.values,
      timestamp: timestamp ?? this.timestamp,
      min: min ?? this.min,
      max: max ?? this.max,
      mean: mean ?? this.mean,
    );
  }

  @override
  List<Object?> get props => [fieldId, values, timestamp, min, max, mean];
}
