import '../entities/drone_layer_entity.dart';

abstract class DroneRepository {
  Future<List<DroneLayer>> getDroneLayers({
    required String fieldId,
    DroneLayerType? layerType,
  });
  Future<List<DroneFlight>> getDroneFlights({required String fieldId});
  Future<List<DroneLayer>> getLayersForFlight(String flightId);
}
