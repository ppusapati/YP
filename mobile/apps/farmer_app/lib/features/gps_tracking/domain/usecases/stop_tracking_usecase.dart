import '../entities/gps_track_entity.dart';
import '../repositories/gps_tracking_repository.dart';

class StopTrackingUseCase {
  const StopTrackingUseCase(this._repository);

  final GPSTrackingRepository _repository;

  Future<GPSTrack> call(String trackId) async {
    return _repository.stopTracking(trackId);
  }
}
