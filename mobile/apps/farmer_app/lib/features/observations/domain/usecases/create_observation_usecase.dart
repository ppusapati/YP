import '../entities/observation_entity.dart';
import '../repositories/observation_repository.dart';

/// Creates a new field observation, uploading photos first.
class CreateObservationUseCase {
  const CreateObservationUseCase(this._repository);

  final ObservationRepository _repository;

  /// Creates the observation. Any local photo paths are uploaded first and
  /// replaced with remote URLs.
  Future<FieldObservation> call(FieldObservation observation) async {
    // Upload any local photos.
    final uploadedUrls = <String>[];
    for (final photo in observation.photos) {
      if (photo.startsWith('http')) {
        uploadedUrls.add(photo);
      } else {
        final url = await _repository.uploadPhoto(photo);
        uploadedUrls.add(url);
      }
    }

    final withUrls = observation.copyWith(photos: uploadedUrls);
    return _repository.createObservation(withUrls);
  }
}
