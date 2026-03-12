import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

// Alerts
import '../../features/alerts/data/datasources/alert_local_datasource.dart';
import '../../features/alerts/data/datasources/alert_remote_datasource.dart';
import '../../features/alerts/data/repositories/alert_repository_impl.dart';
import '../../features/alerts/domain/repositories/alert_repository.dart';
import '../../features/alerts/domain/usecases/get_alerts_usecase.dart';
import '../../features/alerts/domain/usecases/get_unread_count_usecase.dart';
import '../../features/alerts/domain/usecases/mark_alert_read_usecase.dart';

// GPS Tracking
import '../../features/gps_tracking/data/datasources/gps_tracking_local_datasource.dart';
import '../../features/gps_tracking/data/repositories/gps_tracking_repository_impl.dart';
import '../../features/gps_tracking/domain/repositories/gps_tracking_repository.dart';
import '../../features/gps_tracking/domain/usecases/get_tracks_usecase.dart';
import '../../features/gps_tracking/domain/usecases/mark_issue_usecase.dart';
import '../../features/gps_tracking/domain/usecases/start_tracking_usecase.dart';
import '../../features/gps_tracking/domain/usecases/stop_tracking_usecase.dart';

// Drone
import '../../features/drone/data/datasources/drone_remote_datasource.dart';
import '../../features/drone/data/repositories/drone_repository_impl.dart';
import '../../features/drone/domain/repositories/drone_repository.dart';
import '../../features/drone/domain/usecases/get_drone_flights_usecase.dart';
import '../../features/drone/domain/usecases/get_drone_layers_usecase.dart';

// Crop Recommendation
import '../../features/crop_recommendation/data/datasources/crop_recommendation_remote_datasource.dart';
import '../../features/crop_recommendation/data/repositories/crop_recommendation_repository_impl.dart';
import '../../features/crop_recommendation/domain/repositories/crop_recommendation_repository.dart';
import '../../features/crop_recommendation/domain/usecases/get_recommendations_usecase.dart';

// ═══════════════════════════════════════════════════════════════════════
// Infrastructure providers
// ═══════════════════════════════════════════════════════════════════════

/// SharedPreferences instance, override in ProviderScope at startup.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with actual instance',
  );
});

/// API configuration.
final apiConfigProvider = Provider<ApiConfig>((ref) {
  return const ApiConfig(
    baseUrl: AppConfig.apiBaseUrl,
    port: AppConfig.apiPort,
    useTls: AppConfig.apiUseTls,
    timeout: AppConfig.apiTimeout,
    retryCount: AppConfig.apiRetryCount,
  );
});

/// ConnectRPC client.
final connectClientProvider = Provider<ConnectClient>((ref) {
  final config = ref.watch(apiConfigProvider);
  final client = ConnectClient(config: config);
  ref.onDispose(() => client.close());
  return client;
});

/// Connectivity service.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ═══════════════════════════════════════════════════════════════════════
// Alerts feature
// ═══════════════════════════════════════════════════════════════════════

final alertRemoteDataSourceProvider = Provider<AlertRemoteDataSource>((ref) {
  return AlertRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final alertLocalDataSourceProvider = Provider<AlertLocalDataSource>((ref) {
  return AlertLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
});

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepositoryImpl(
    remoteDataSource: ref.watch(alertRemoteDataSourceProvider),
    localDataSource: ref.watch(alertLocalDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

final getAlertsUseCaseProvider = Provider<GetAlertsUseCase>((ref) {
  return GetAlertsUseCase(ref.watch(alertRepositoryProvider));
});

final markAlertReadUseCaseProvider = Provider<MarkAlertReadUseCase>((ref) {
  return MarkAlertReadUseCase(ref.watch(alertRepositoryProvider));
});

final getUnreadCountUseCaseProvider = Provider<GetUnreadCountUseCase>((ref) {
  return GetUnreadCountUseCase(ref.watch(alertRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// GPS Tracking feature
// ═══════════════════════════════════════════════════════════════════════

final gpsTrackingLocalDataSourceProvider =
    Provider<GPSTrackingLocalDataSource>((ref) {
  return GPSTrackingLocalDataSourceImpl(
      ref.watch(sharedPreferencesProvider));
});

final gpsTrackingRepositoryProvider =
    Provider<GPSTrackingRepository>((ref) {
  return GPSTrackingRepositoryImpl(
    localDataSource: ref.watch(gpsTrackingLocalDataSourceProvider),
  );
});

final startTrackingUseCaseProvider = Provider<StartTrackingUseCase>((ref) {
  return StartTrackingUseCase(ref.watch(gpsTrackingRepositoryProvider));
});

final stopTrackingUseCaseProvider = Provider<StopTrackingUseCase>((ref) {
  return StopTrackingUseCase(ref.watch(gpsTrackingRepositoryProvider));
});

final markIssueUseCaseProvider = Provider<MarkIssueUseCase>((ref) {
  return MarkIssueUseCase(ref.watch(gpsTrackingRepositoryProvider));
});

final getTracksUseCaseProvider = Provider<GetTracksUseCase>((ref) {
  return GetTracksUseCase(ref.watch(gpsTrackingRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Drone feature
// ═══════════════════════════════════════════════════════════════════════

final droneRemoteDataSourceProvider =
    Provider<DroneRemoteDataSource>((ref) {
  return DroneRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final droneRepositoryProvider = Provider<DroneRepository>((ref) {
  return DroneRepositoryImpl(
    remoteDataSource: ref.watch(droneRemoteDataSourceProvider),
  );
});

final getDroneLayersUseCaseProvider =
    Provider<GetDroneLayersUseCase>((ref) {
  return GetDroneLayersUseCase(ref.watch(droneRepositoryProvider));
});

final getDroneFlightsUseCaseProvider =
    Provider<GetDroneFlightsUseCase>((ref) {
  return GetDroneFlightsUseCase(ref.watch(droneRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Crop Recommendation feature
// ═══════════════════════════════════════════════════════════════════════

final cropRecommendationRemoteDataSourceProvider =
    Provider<CropRecommendationRemoteDataSource>((ref) {
  return CropRecommendationRemoteDataSourceImpl(
      ref.watch(connectClientProvider));
});

final cropRecommendationRepositoryProvider =
    Provider<CropRecommendationRepository>((ref) {
  return CropRecommendationRepositoryImpl(
    remoteDataSource: ref.watch(cropRecommendationRemoteDataSourceProvider),
  );
});

final getRecommendationsUseCaseProvider =
    Provider<GetRecommendationsUseCase>((ref) {
  return GetRecommendationsUseCase(
      ref.watch(cropRecommendationRepositoryProvider));
});
