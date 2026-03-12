import '../entities/gps_track_entity.dart';
import '../repositories/gps_tracking_repository.dart';

class GetTracksUseCase {
  const GetTracksUseCase(this._repository);

  final GPSTrackingRepository _repository;

  Future<List<GPSTrack>> call({String? fieldId}) async {
    return _repository.getTracks(fieldId: fieldId);
  }
}
