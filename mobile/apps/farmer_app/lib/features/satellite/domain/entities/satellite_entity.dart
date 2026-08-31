import 'package:equatable/equatable.dart';

enum SatelliteLayerType {
  rgb,
  ndvi,
  ndwi,
  evi,
  falseColor;

  String get displayName => switch (this) {
        rgb => 'RGB',
        ndvi => 'NDVI',
        ndwi => 'NDWI',
        evi => 'EVI',
        falseColor => 'False Color',
      };
}

class SatelliteTile extends Equatable {
  final String id;
  final String fieldId;
  final SatelliteLayerType layerType;
  final String tileUrl;
  final DateTime captureDate;
  final double cloudCoverPercent;

  const SatelliteTile({
    required this.id,
    required this.fieldId,
    required this.layerType,
    required this.tileUrl,
    required this.captureDate,
    required this.cloudCoverPercent,
  });

  @override
  List<Object?> get props =>
      [id, fieldId, layerType, tileUrl, captureDate, cloudCoverPercent];
}

class NdviDataPoint extends Equatable {
  final DateTime date;
  final double meanNdvi;
  final double minNdvi;
  final double maxNdvi;

  const NdviDataPoint({
    required this.date,
    required this.meanNdvi,
    required this.minNdvi,
    required this.maxNdvi,
  });

  @override
  List<Object?> get props => [date, meanNdvi, minNdvi, maxNdvi];
}
