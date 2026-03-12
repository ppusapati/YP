import '../entities/gps_track_entity.dart';
import '../repositories/gps_tracking_repository.dart';

class StartTrackingUseCase {
  const StartTrackingUseCase(this._repository);

  final GPSTrackingRepository _repository;

  Future<GPSTrack> call(String fieldId) async {
    return _repository.startTracking(fieldId);
  }
}
