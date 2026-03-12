import '../entities/crop_health_entity.dart';
import '../entities/satellite_entity.dart';

/// Abstract repository interface for satellite monitoring operations.
abstract class SatelliteRepository {
  /// Retrieves satellite tiles for a field within a date range.
  Future<List<SatelliteTile>> getSatelliteTiles({
    required String fieldId,
    SatelliteLayerType? layerType,
    DateTime? from,
    DateTime? to,
  });

  /// Retrieves NDVI history data for a field.
  Future<List<NdviDataPoint>> getNdviHistory({
    required String fieldId,
    required DateTime from,
    required DateTime to,
  });

  /// Retrieves crop health time-series data for a field.
  Future<CropHealthEntity> getCropHealth({
    required String fieldId,
  });

  /// Retrieves crop health data for all fields in a farm.
  Future<List<CropHealthEntity>> getCropHealthByFarm({
    required String farmId,
  });
}
