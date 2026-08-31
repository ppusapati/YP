import '../../domain/entities/drone_layer_entity.dart';
import '../../domain/repositories/drone_repository.dart';
import '../datasources/drone_remote_datasource.dart';

class DroneRepositoryImpl implements DroneRepository {
  DroneRepositoryImpl({
    required DroneRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final DroneRemoteDataSource _remoteDataSource;

  @override
  Future<List<DroneLayer>> getDroneLayers({
    required String fieldId,
    DroneLayerType? layerType,
  }) async {
    return _remoteDataSource.getDroneLayers(
      fieldId: fieldId,
      layerType: layerType?.name,
    );
  }

  @override
  Future<List<DroneFlight>> getDroneFlights({required String fieldId}) async {
    return _remoteDataSource.getDroneFlights(fieldId: fieldId);
  }

  @override
  Future<List<DroneLayer>> getLayersForFlight(String flightId) async {
    return _remoteDataSource.getLayersForFlight(flightId);
  }
}
