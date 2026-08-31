import 'package:farmer_app/features/observations/domain/entities/observation_entity.dart';
import 'package:farmer_app/features/observations/domain/repositories/observation_repository.dart';
import 'package:farmer_app/features/observations/domain/usecases/create_observation_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockObservationRepository extends Mock
    implements ObservationRepository {}

void main() {
  late MockObservationRepository mockRepository;
  late CreateObservationUseCase useCase;

  final observationWithLocalPhotos = FieldObservation(
    id: '',
    fieldId: 'field-1',
    location: const LatLng(-1.286, 36.817),
    photos: const ['/tmp/photo1.jpg', '/tmp/photo2.jpg'],
    notes: 'Found pest damage on lower leaves.',
    timestamp: DateTime(2024, 6, 15, 10, 30),
    category: ObservationCategory.pest,
  );

  final observationWithRemotePhotos = FieldObservation(
    id: '',
    fieldId: 'field-1',
    location: const LatLng(-1.286, 36.817),
    photos: const [
      'https://photos.example.com/uploaded1.jpg',
      'https://photos.example.com/uploaded2.jpg',
    ],
    notes: 'Found pest damage on lower leaves.',
    timestamp: DateTime(2024, 6, 15, 10, 30),
    category: ObservationCategory.pest,
  );

  final createdObservation = FieldObservation(
    id: 'obs-new-1',
    fieldId: 'field-1',
    location: const LatLng(-1.286, 36.817),
    photos: const [
      'https://photos.example.com/uploaded1.jpg',
      'https://photos.example.com/uploaded2.jpg',
    ],
    notes: 'Found pest damage on lower leaves.',
    timestamp: DateTime(2024, 6, 15, 10, 30),
    category: ObservationCategory.pest,
  );

  final observationMixed = FieldObservation(
    id: '',
    fieldId: 'field-1',
    location: const LatLng(-1.286, 36.817),
    photos: const [
      'https://already-uploaded.com/photo.jpg',
      '/tmp/local_photo.jpg',
    ],
    notes: 'Mixed photos test.',
    timestamp: DateTime(2024, 6, 15, 10, 30),
    category: ObservationCategory.growth,
  );

  setUp(() {
    mockRepository = MockObservationRepository();
    useCase = CreateObservationUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(observationWithLocalPhotos);
  });

  group('CreateObservationUseCase', () {
    test('uploads local photos and creates observation', () async {
      when(() => mockRepository.uploadPhoto('/tmp/photo1.jpg'))
          .thenAnswer((_) async => 'https://photos.example.com/uploaded1.jpg');
      when(() => mockRepository.uploadPhoto('/tmp/photo2.jpg'))
          .thenAnswer((_) async => 'https://photos.example.com/uploaded2.jpg');
      when(() => mockRepository.createObservation(any()))
          .thenAnswer((_) async => createdObservation);

      final result = await useCase(observationWithLocalPhotos);

      expect(result.id, 'obs-new-1');
      verify(() => mockRepository.uploadPhoto('/tmp/photo1.jpg')).called(1);
      verify(() => mockRepository.uploadPhoto('/tmp/photo2.jpg')).called(1);
      verify(() => mockRepository.createObservation(any())).called(1);
    });

    test('skips upload for http photos', () async {
      when(() => mockRepository.createObservation(any()))
          .thenAnswer((_) async => createdObservation);

      await useCase(observationWithRemotePhotos);

      verifyNever(() => mockRepository.uploadPhoto(any()));
      verify(() => mockRepository.createObservation(any())).called(1);
    });

    test('handles mix of local and remote photos', () async {
      when(() => mockRepository.uploadPhoto('/tmp/local_photo.jpg'))
          .thenAnswer(
              (_) async => 'https://photos.example.com/local_uploaded.jpg');
      when(() => mockRepository.createObservation(any()))
          .thenAnswer((_) async => createdObservation);

      await useCase(observationMixed);

      verify(() => mockRepository.uploadPhoto('/tmp/local_photo.jpg'))
          .called(1);
      verifyNever(
          () => mockRepository.uploadPhoto('https://already-uploaded.com/photo.jpg'));
    });

    test('creates observation with no photos', () async {
      final noPhotoObs = observationWithLocalPhotos.copyWith(photos: []);
      when(() => mockRepository.createObservation(any()))
          .thenAnswer((_) async => createdObservation);

      await useCase(noPhotoObs);

      verifyNever(() => mockRepository.uploadPhoto(any()));
      verify(() => mockRepository.createObservation(any())).called(1);
    });

    test('propagates exception when upload fails', () async {
      when(() => mockRepository.uploadPhoto(any()))
          .thenThrow(Exception('Upload failed'));

      expect(
        () => useCase(observationWithLocalPhotos),
        throwsA(isA<Exception>()),
      );
    });

    test('propagates exception when create fails', () async {
      when(() => mockRepository.uploadPhoto(any()))
          .thenAnswer((_) async => 'https://uploaded.com/photo.jpg');
      when(() => mockRepository.createObservation(any()))
          .thenThrow(Exception('Server error'));

      expect(
        () => useCase(observationWithLocalPhotos),
        throwsA(isA<Exception>()),
      );
    });
  });
}
