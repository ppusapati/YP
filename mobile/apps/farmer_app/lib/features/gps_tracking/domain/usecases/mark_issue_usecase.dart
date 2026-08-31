import 'package:latlong2/latlong.dart';

import '../entities/crop_issue_entity.dart';
import '../repositories/gps_tracking_repository.dart';

class MarkIssueUseCase {
  const MarkIssueUseCase(this._repository);

  final GPSTrackingRepository _repository;

  Future<CropIssue> call({
    required String trackId,
    required LatLng location,
    required CropIssueType type,
    required String description,
    required CropIssueSeverity severity,
    List<String> photos = const [],
  }) async {
    return _repository.markIssue(
      trackId: trackId,
      location: location,
      type: type,
      description: description,
      severity: severity,
      photos: photos,
    );
  }
}
