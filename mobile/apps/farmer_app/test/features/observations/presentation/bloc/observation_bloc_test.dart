import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/observations/domain/entities/observation_entity.dart';
import 'package:farmer_app/features/observations/domain/usecases/create_observation_usecase.dart';
import 'package:farmer_app/features/observations/domain/usecases/get_observations_usecase.dart';
import 'package:farmer_app/features/observations/presentation/bloc/observation_bloc.dart';
import 'package:farmer_app/features/observations/presentation/bloc/observation_event.dart';
import 'package:farmer_app/features/observations/presentation/bloc/observation_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockGetObservationsUseCase extends Mock
    implements GetObservationsUseCase {}

class MockCreateObservationUseCase extends Mock
    implements CreateObservationUseCase {}

void main() {
  late MockGetObservationsUseCase mockGetObservations;
  late MockCreateObservationUseCase mockCreateObservation;

  final testObservation1 = FieldObservation(
    id: 'obs-1',
    fieldId: 'field-1',
    location: const LatLng(-1.286, 36.817),
    photos: const ['https://photos.example.com/obs1_1.jpg'],
    notes: 'Spotted fall armyworm larvae on maize leaves.',
    timestamp: DateTime(2024, 6, 15, 10, 30),
    category: ObservationCategory.pest,
    weather: const WeatherCondition(
      temperature: 25.0,
      humidity: 68.0,
      windSpeed: 3.5,
      description: 'Partly Cloudy',
    ),
  );

  final testObservation2 = FieldObservation(
    id: 'obs-2',
    fieldId: 'field-1',
    location: const LatLng(-1.287, 36.818),
    photos: const [
      'https://photos.example.com/obs2_1.jpg',
      'https://photos.example.com/obs2_2.jpg',
    ],
    notes: 'Good vegetative growth, healthy canopy.',
    timestamp: DateTime(2024, 6, 14, 9, 0),
    category: ObservationCategory.growth,
  );

  final testObservation3 = FieldObservation(
    id: 'obs-3',
    fieldId: 'field-2',
    location: const LatLng(-1.290, 36.820),
    photos: const [],
    notes: 'Waterlogging near drain.',
    timestamp: DateTime(2024, 6, 13, 15, 0),
    category: ObservationCategory.water,
  );

  setUp(() {
    mockGetObservations = MockGetObservationsUseCase();
    mockCreateObservation = MockCreateObservationUseCase();
  });

  setUpAll(() {
    registerFallbackValue(testObservation1);
  });

  ObservationBloc buildBloc() => ObservationBloc(
        getObservations: mockGetObservations,
        createObservation: mockCreateObservation,
      );

  group('ObservationBloc', () {
    blocTest<ObservationBloc, ObservationState>(
      'emits [ObservationLoading, ObservationsLoaded] when LoadObservations succeeds',
      build: () {
        when(() => mockGetObservations(fieldId: 'field-1'))
            .thenAnswer(
                (_) async => [testObservation1, testObservation2]);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadObservations(fieldId: 'field-1')),
      expect: () => [
        const ObservationLoading(),
        ObservationsLoaded(
          observations: [testObservation1, testObservation2],
        ),
      ],
      verify: (_) {
        verify(() => mockGetObservations(fieldId: 'field-1')).called(1);
      },
    );

    blocTest<ObservationBloc, ObservationState>(
      'loads all observations when no fieldId provided',
      build: () {
        when(() => mockGetObservations(fieldId: null)).thenAnswer(
            (_) async =>
                [testObservation1, testObservation2, testObservation3]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadObservations()),
      expect: () => [
        const ObservationLoading(),
        ObservationsLoaded(
          observations: [
            testObservation1,
            testObservation2,
            testObservation3,
          ],
        ),
      ],
    );

    blocTest<ObservationBloc, ObservationState>(
      'emits [ObservationLoading, ObservationError] when LoadObservations fails',
      build: () {
        when(() => mockGetObservations(fieldId: any(named: 'fieldId')))
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadObservations(fieldId: 'field-1')),
      expect: () => [
        const ObservationLoading(),
        isA<ObservationError>().having(
          (e) => e.message,
          'message',
          contains('Unable to load observations'),
        ),
      ],
    );

    blocTest<ObservationBloc, ObservationState>(
      'emits [ObservationLoading, ObservationCreated] when CreateObservation succeeds',
      build: () {
        when(() => mockCreateObservation(any()))
            .thenAnswer((_) async => testObservation1);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateObservation(testObservation1)),
      expect: () => [
        const ObservationLoading(),
        ObservationCreated(testObservation1),
      ],
      verify: (_) {
        verify(() => mockCreateObservation(any())).called(1);
      },
    );

    blocTest<ObservationBloc, ObservationState>(
      'emits [ObservationLoading, ObservationError] when CreateObservation fails',
      build: () {
        when(() => mockCreateObservation(any()))
            .thenThrow(Exception('Save failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateObservation(testObservation1)),
      expect: () => [
        const ObservationLoading(),
        isA<ObservationError>().having(
          (e) => e.message,
          'message',
          contains('Unable to save observation'),
        ),
      ],
    );

    blocTest<ObservationBloc, ObservationState>(
      'emits ObservationPhotosUpdated on AddPhoto',
      build: () => buildBloc(),
      act: (bloc) =>
          bloc.add(const AddPhoto('/tmp/photo1.jpg')),
      expect: () => [
        const ObservationPhotosUpdated(['/tmp/photo1.jpg']),
      ],
    );

    blocTest<ObservationBloc, ObservationState>(
      'accumulates photos on multiple AddPhoto events',
      build: () => buildBloc(),
      act: (bloc) {
        bloc.add(const AddPhoto('/tmp/photo1.jpg'));
        bloc.add(const AddPhoto('/tmp/photo2.jpg'));
      },
      expect: () => [
        const ObservationPhotosUpdated(['/tmp/photo1.jpg']),
        const ObservationPhotosUpdated(['/tmp/photo1.jpg', '/tmp/photo2.jpg']),
      ],
    );

    blocTest<ObservationBloc, ObservationState>(
      'emits ObservationPhotosUpdated on RemovePhoto with valid index',
      build: () => buildBloc(),
      act: (bloc) {
        bloc.add(const AddPhoto('/tmp/photo1.jpg'));
        bloc.add(const AddPhoto('/tmp/photo2.jpg'));
        bloc.add(const RemovePhoto(0));
      },
      expect: () => [
        const ObservationPhotosUpdated(['/tmp/photo1.jpg']),
        const ObservationPhotosUpdated(['/tmp/photo1.jpg', '/tmp/photo2.jpg']),
        const ObservationPhotosUpdated(['/tmp/photo2.jpg']),
      ],
    );

    blocTest<ObservationBloc, ObservationState>(
      'does not emit on RemovePhoto with invalid index',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const RemovePhoto(5)),
      expect: () => <ObservationState>[],
    );

    blocTest<ObservationBloc, ObservationState>(
      'DeleteObservation removes item from loaded list',
      build: () => buildBloc(),
      seed: () => ObservationsLoaded(
        observations: [testObservation1, testObservation2],
      ),
      act: (bloc) =>
          bloc.add(const DeleteObservation('obs-1')),
      expect: () => [
        ObservationsLoaded(observations: [testObservation2]),
      ],
    );

    test('initial state is ObservationInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const ObservationInitial());
      bloc.close();
    });
  });
}
