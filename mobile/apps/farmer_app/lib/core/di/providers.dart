import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_auth/flutter_auth.dart';
import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
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

// Farm
import '../../features/farm/data/datasources/farm_local_datasource.dart';
import '../../features/farm/data/datasources/farm_remote_datasource.dart';
import '../../features/farm/data/repositories/farm_repository_impl.dart';
import '../../features/farm/domain/repositories/farm_repository.dart';
import '../../features/farm/domain/usecases/create_farm_usecase.dart';
import '../../features/farm/domain/usecases/create_field_usecase.dart';
import '../../features/farm/domain/usecases/get_farms_usecase.dart';
import '../../features/farm/domain/usecases/update_farm_usecase.dart';

// AI Diagnosis
import '../../features/ai_diagnosis/data/datasources/diagnosis_local_datasource.dart';
import '../../features/ai_diagnosis/data/datasources/diagnosis_remote_datasource.dart';
import '../../features/ai_diagnosis/data/repositories/diagnosis_repository_impl.dart';
import '../../features/ai_diagnosis/domain/repositories/diagnosis_repository.dart';
import '../../features/ai_diagnosis/domain/usecases/diagnose_plant_usecase.dart';
import '../../features/ai_diagnosis/domain/usecases/get_diagnosis_history_usecase.dart';

// Satellite
import '../../features/satellite/data/datasources/satellite_local_datasource.dart';
import '../../features/satellite/data/datasources/satellite_remote_datasource.dart';
import '../../features/satellite/data/repositories/satellite_repository_impl.dart';
import '../../features/satellite/domain/repositories/satellite_repository.dart';
import '../../features/satellite/domain/usecases/get_crop_health_usecase.dart';
import '../../features/satellite/domain/usecases/get_ndvi_history_usecase.dart';
import '../../features/satellite/domain/usecases/get_satellite_tiles_usecase.dart';

// Sensors
import '../../features/sensors/data/datasources/sensor_local_datasource.dart';
import '../../features/sensors/data/datasources/sensor_remote_datasource.dart';
import '../../features/sensors/data/repositories/sensor_repository_impl.dart';
import '../../features/sensors/domain/repositories/sensor_repository.dart';
import '../../features/sensors/domain/usecases/get_sensor_dashboard_usecase.dart';
import '../../features/sensors/domain/usecases/get_sensor_readings_usecase.dart';
import '../../features/sensors/domain/usecases/get_sensors_usecase.dart';

// Soil
import '../../features/soil/data/datasources/soil_local_datasource.dart';
import '../../features/soil/data/datasources/soil_remote_datasource.dart';
import '../../features/soil/data/repositories/soil_repository_impl.dart';
import '../../features/soil/domain/repositories/soil_repository.dart';
import '../../features/soil/domain/usecases/get_soil_analysis_usecase.dart';
import '../../features/soil/domain/usecases/get_soil_history_usecase.dart';

// Irrigation
import '../../features/irrigation/data/datasources/irrigation_local_datasource.dart';
import '../../features/irrigation/data/datasources/irrigation_remote_datasource.dart';
import '../../features/irrigation/data/repositories/irrigation_repository_impl.dart';
import '../../features/irrigation/domain/repositories/irrigation_repository.dart';
import '../../features/irrigation/domain/usecases/get_irrigation_alerts_usecase.dart';
import '../../features/irrigation/domain/usecases/get_irrigation_schedule_usecase.dart';
import '../../features/irrigation/domain/usecases/get_irrigation_zones_usecase.dart';
import '../../features/irrigation/domain/usecases/update_irrigation_schedule_usecase.dart';

// Pest Risk
import '../../features/pest_risk/data/datasources/pest_local_datasource.dart';
import '../../features/pest_risk/data/datasources/pest_remote_datasource.dart';
import '../../features/pest_risk/data/repositories/pest_repository_impl.dart';
import '../../features/pest_risk/domain/repositories/pest_repository.dart';
import '../../features/pest_risk/domain/usecases/get_pest_alerts_usecase.dart';
import '../../features/pest_risk/domain/usecases/get_pest_risk_zones_usecase.dart';

// Tasks
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/datasources/task_remote_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/complete_task_usecase.dart';
import '../../features/tasks/domain/usecases/create_task_usecase.dart';
import '../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../features/tasks/domain/usecases/update_task_usecase.dart';

// Observations
import '../../features/observations/data/datasources/observation_local_datasource.dart';
import '../../features/observations/data/datasources/observation_remote_datasource.dart';
import '../../features/observations/data/repositories/observation_repository_impl.dart';
import '../../features/observations/domain/repositories/observation_repository.dart';
import '../../features/observations/domain/usecases/create_observation_usecase.dart';
import '../../features/observations/domain/usecases/get_observations_usecase.dart';

// Traceability
import '../../features/traceability/data/datasources/traceability_local_datasource.dart';
import '../../features/traceability/data/datasources/traceability_remote_datasource.dart';
import '../../features/traceability/data/repositories/traceability_repository_impl.dart';
import '../../features/traceability/domain/repositories/traceability_repository.dart';
import '../../features/traceability/domain/usecases/get_farm_history_usecase.dart';
import '../../features/traceability/domain/usecases/get_produce_record_usecase.dart';
import '../../features/traceability/domain/usecases/scan_qr_code_usecase.dart';

// Yield Prediction
import '../../features/yield_prediction/data/datasources/yield_local_datasource.dart';
import '../../features/yield_prediction/data/datasources/yield_remote_datasource.dart';
import '../../features/yield_prediction/data/repositories/yield_repository_impl.dart';
import '../../features/yield_prediction/domain/repositories/yield_repository.dart';
import '../../features/yield_prediction/domain/usecases/get_yield_history_usecase.dart';
import '../../features/yield_prediction/domain/usecases/get_yield_predictions_usecase.dart';

// Field Inspection
import '../../features/field_inspection/data/datasources/field_inspection_local_datasource.dart';
import '../../features/field_inspection/data/datasources/field_inspection_remote_datasource.dart';
import '../../features/field_inspection/data/repositories/field_inspection_repository_impl.dart';
import '../../features/field_inspection/domain/repositories/field_inspection_repository.dart';
import '../../features/field_inspection/domain/usecases/create_inspection_usecase.dart';
import '../../features/field_inspection/domain/usecases/get_inspections_usecase.dart';
import '../../features/field_inspection/domain/usecases/submit_inspection_usecase.dart';

// Crop Advisory
import '../../features/crop_advisory/data/datasources/crop_advisory_local_datasource.dart';
import '../../features/crop_advisory/data/datasources/crop_advisory_remote_datasource.dart';
import '../../features/crop_advisory/data/repositories/crop_advisory_repository_impl.dart';
import '../../features/crop_advisory/domain/repositories/crop_advisory_repository.dart';
import '../../features/crop_advisory/domain/usecases/create_advisory_usecase.dart';
import '../../features/crop_advisory/domain/usecases/get_advisories_usecase.dart';

// Analytics
import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/domain/usecases/get_field_analytics_usecase.dart';

// Prescriptions
import '../../features/prescriptions/data/datasources/prescription_remote_datasource.dart';
import '../../features/prescriptions/data/repositories/prescription_repository_impl.dart';
import '../../features/prescriptions/domain/repositories/prescription_repository.dart';
import '../../features/prescriptions/domain/usecases/generate_prescription_usecase.dart';
import '../../features/prescriptions/domain/usecases/get_prescriptions_usecase.dart';

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

/// Secure token storage and lifecycle management.
final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService();
});

/// Authentication repository for login, logout, and token refresh.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(apiConfigProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  final httpClient = ref.watch(httpClientProvider);
  return AuthRepository(
    baseUrl: config.origin,
    tokenService: tokenService,
    httpClient: httpClient,
  );
});

/// ConnectRPC client with auth, connectivity, and logging interceptors.
final connectClientProvider = Provider<ConnectClient>((ref) {
  final config = ref.watch(apiConfigProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  final client = ConnectClient(config: config);

  final connectivityInterceptor = ConnectivityInterceptor(
    connectivityService: connectivityService,
  );
  client.addRequestInterceptor(connectivityInterceptor.interceptRequest);

  final authInterceptor = AuthInterceptor(
    tokenReader: () => tokenService.getAccessToken(),
    tokenRefresher: () async {
      final token = await authRepository.refreshToken();
      return token.accessToken;
    },
  );
  client.addAuthInterceptor(authInterceptor);

  final loggingInterceptor = LoggingInterceptor();
  client.addRequestInterceptor(loggingInterceptor.interceptRequest);
  client.addResponseInterceptor(loggingInterceptor.interceptResponse);

  ref.onDispose(() {
    connectivityInterceptor.dispose();
    client.close();
  });
  return client;
});

/// Authentication BLoC for login/logout/token-refresh lifecycle.
final authBlocProvider = Provider<AuthBloc>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final bloc = AuthBloc(authRepository: authRepository);
  ref.onDispose(() => bloc.close());
  return bloc;
});

/// Connectivity service.
///
/// Eagerly initialised so that [ConnectivityService.onConnectivityChanged]
/// emits events and [ConnectivityService.currentStatus] reflects reality.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

/// HTTP client for REST-style data sources.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(() => client.close());
  return client;
});

/// API base URL string (e.g. `https://api.yieldpoint.io`).
final apiBaseUrlProvider = Provider<String>((ref) {
  final config = ref.watch(apiConfigProvider);
  return config.origin;
});

/// Connectivity instance from connectivity_plus.
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Drift database for the Farm feature. Override in ProviderScope at startup.
final farmDatabaseProvider = Provider<FarmDatabase>((ref) {
  throw UnimplementedError(
    'farmDatabaseProvider must be overridden with actual instance',
  );
});

/// Drift database for the Diagnosis feature. Override in ProviderScope at startup.
final diagnosisDatabaseProvider = Provider<DiagnosisDatabase>((ref) {
  throw UnimplementedError(
    'diagnosisDatabaseProvider must be overridden with actual instance',
  );
});

/// Drift database for the Satellite feature. Override in ProviderScope at startup.
final satelliteDatabaseProvider = Provider<SatelliteDatabase>((ref) {
  throw UnimplementedError(
    'satelliteDatabaseProvider must be overridden with actual instance',
  );
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

// ═══════════════════════════════════════════════════════════════════════
// Farm feature
// ═══════════════════════════════════════════════════════════════════════

final farmRemoteDataSourceProvider = Provider<FarmRemoteDataSource>((ref) {
  return FarmRemoteDataSourceImpl(
    client: ref.watch(connectClientProvider),
  );
});

final farmLocalDataSourceProvider = Provider<FarmLocalDataSource>((ref) {
  return FarmLocalDataSourceImpl(
    database: ref.watch(farmDatabaseProvider),
  );
});

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return FarmRepositoryImpl(
    remoteDataSource: ref.watch(farmRemoteDataSourceProvider),
    localDataSource: ref.watch(farmLocalDataSourceProvider),
    connectivity: ref.watch(connectivityProvider),
  );
});

final getFarmsUseCaseProvider = Provider<GetFarmsUseCase>((ref) {
  return GetFarmsUseCase(ref.watch(farmRepositoryProvider));
});

final createFarmUseCaseProvider = Provider<CreateFarmUseCase>((ref) {
  return CreateFarmUseCase(ref.watch(farmRepositoryProvider));
});

final updateFarmUseCaseProvider = Provider<UpdateFarmUseCase>((ref) {
  return UpdateFarmUseCase(ref.watch(farmRepositoryProvider));
});

final createFieldUseCaseProvider = Provider<CreateFieldUseCase>((ref) {
  return CreateFieldUseCase(ref.watch(farmRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// AI Diagnosis feature
// ═══════════════════════════════════════════════════════════════════════

final diagnosisRemoteDataSourceProvider =
    Provider<DiagnosisRemoteDataSource>((ref) {
  return DiagnosisRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final diagnosisLocalDataSourceProvider =
    Provider<DiagnosisLocalDataSource>((ref) {
  return DiagnosisLocalDataSourceImpl(
    database: ref.watch(diagnosisDatabaseProvider),
  );
});

final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  return DiagnosisRepositoryImpl(
    remoteDataSource: ref.watch(diagnosisRemoteDataSourceProvider),
    localDataSource: ref.watch(diagnosisLocalDataSourceProvider),
    connectivity: ref.watch(connectivityProvider),
  );
});

final diagnosePlantUseCaseProvider = Provider<DiagnosePlantUseCase>((ref) {
  return DiagnosePlantUseCase(ref.watch(diagnosisRepositoryProvider));
});

final getDiagnosisHistoryUseCaseProvider =
    Provider<GetDiagnosisHistoryUseCase>((ref) {
  return GetDiagnosisHistoryUseCase(ref.watch(diagnosisRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Satellite feature
// ═══════════════════════════════════════════════════════════════════════

final satelliteRemoteDataSourceProvider =
    Provider<SatelliteRemoteDataSource>((ref) {
  return SatelliteRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final satelliteLocalDataSourceProvider =
    Provider<SatelliteLocalDataSource>((ref) {
  return SatelliteLocalDataSourceImpl(
    database: ref.watch(satelliteDatabaseProvider),
  );
});

final satelliteRepositoryProvider = Provider<SatelliteRepository>((ref) {
  return SatelliteRepositoryImpl(
    remoteDataSource: ref.watch(satelliteRemoteDataSourceProvider),
    localDataSource: ref.watch(satelliteLocalDataSourceProvider),
    connectivity: ref.watch(connectivityProvider),
  );
});

final getSatelliteTilesUseCaseProvider =
    Provider<GetSatelliteTilesUseCase>((ref) {
  return GetSatelliteTilesUseCase(ref.watch(satelliteRepositoryProvider));
});

final getCropHealthUseCaseProvider =
    Provider<GetCropHealthUseCase>((ref) {
  return GetCropHealthUseCase(ref.watch(satelliteRepositoryProvider));
});

final getNdviHistoryUseCaseProvider =
    Provider<GetNdviHistoryUseCase>((ref) {
  return GetNdviHistoryUseCase(ref.watch(satelliteRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Sensors feature
// ═══════════════════════════════════════════════════════════════════════

final sensorRemoteDataSourceProvider =
    Provider<SensorRemoteDataSource>((ref) {
  return SensorRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final sensorLocalDataSourceProvider =
    Provider<SensorLocalDataSource>((ref) {
  return SensorLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return SensorRepositoryImpl(
    remoteDataSource: ref.watch(sensorRemoteDataSourceProvider),
    localDataSource: ref.watch(sensorLocalDataSourceProvider),
  );
});

final getSensorsUseCaseProvider = Provider<GetSensorsUseCase>((ref) {
  return GetSensorsUseCase(ref.watch(sensorRepositoryProvider));
});

final getSensorReadingsUseCaseProvider =
    Provider<GetSensorReadingsUseCase>((ref) {
  return GetSensorReadingsUseCase(ref.watch(sensorRepositoryProvider));
});

final getSensorDashboardUseCaseProvider =
    Provider<GetSensorDashboardUseCase>((ref) {
  return GetSensorDashboardUseCase(ref.watch(sensorRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Soil feature
// ═══════════════════════════════════════════════════════════════════════

final soilRemoteDataSourceProvider =
    Provider<SoilRemoteDataSource>((ref) {
  return SoilRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final soilLocalDataSourceProvider = Provider<SoilLocalDataSource>((ref) {
  return SoilLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

final soilRepositoryProvider = Provider<SoilRepository>((ref) {
  return SoilRepositoryImpl(
    remoteDataSource: ref.watch(soilRemoteDataSourceProvider),
    localDataSource: ref.watch(soilLocalDataSourceProvider),
  );
});

final getSoilAnalysisUseCaseProvider =
    Provider<GetSoilAnalysisUseCase>((ref) {
  return GetSoilAnalysisUseCase(ref.watch(soilRepositoryProvider));
});

final getSoilHistoryUseCaseProvider =
    Provider<GetSoilHistoryUseCase>((ref) {
  return GetSoilHistoryUseCase(ref.watch(soilRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Irrigation feature
// ═══════════════════════════════════════════════════════════════════════

final irrigationRemoteDataSourceProvider =
    Provider<IrrigationRemoteDataSource>((ref) {
  return IrrigationRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final irrigationLocalDataSourceProvider =
    Provider<IrrigationLocalDataSource>((ref) {
  return IrrigationLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

final irrigationRepositoryProvider = Provider<IrrigationRepository>((ref) {
  return IrrigationRepositoryImpl(
    remoteDataSource: ref.watch(irrigationRemoteDataSourceProvider),
    localDataSource: ref.watch(irrigationLocalDataSourceProvider),
  );
});

final getIrrigationZonesUseCaseProvider =
    Provider<GetIrrigationZonesUseCase>((ref) {
  return GetIrrigationZonesUseCase(ref.watch(irrigationRepositoryProvider));
});

final getIrrigationScheduleUseCaseProvider =
    Provider<GetIrrigationScheduleUseCase>((ref) {
  return GetIrrigationScheduleUseCase(
      ref.watch(irrigationRepositoryProvider));
});

final updateIrrigationScheduleUseCaseProvider =
    Provider<UpdateIrrigationScheduleUseCase>((ref) {
  return UpdateIrrigationScheduleUseCase(
      ref.watch(irrigationRepositoryProvider));
});

final getIrrigationAlertsUseCaseProvider =
    Provider<GetIrrigationAlertsUseCase>((ref) {
  return GetIrrigationAlertsUseCase(
      ref.watch(irrigationRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Pest Risk feature
// ═══════════════════════════════════════════════════════════════════════

final pestRemoteDataSourceProvider =
    Provider<PestRemoteDataSource>((ref) {
  return PestRemoteDataSourceImpl(
    client: ref.watch(connectClientProvider),
  );
});

final pestLocalDataSourceProvider = Provider<PestLocalDataSource>((ref) {
  return PestLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

final pestRepositoryProvider = Provider<PestRepository>((ref) {
  return PestRepositoryImpl(
    remoteDataSource: ref.watch(pestRemoteDataSourceProvider),
    localDataSource: ref.watch(pestLocalDataSourceProvider),
  );
});

final getPestRiskZonesUseCaseProvider =
    Provider<GetPestRiskZonesUseCase>((ref) {
  return GetPestRiskZonesUseCase(ref.watch(pestRepositoryProvider));
});

final getPestAlertsUseCaseProvider =
    Provider<GetPestAlertsUseCase>((ref) {
  return GetPestAlertsUseCase(ref.watch(pestRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Tasks feature
// ═══════════════════════════════════════════════════════════════════════

final taskRemoteDataSourceProvider =
    Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(
    client: ref.watch(connectClientProvider),
  );
});

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    remoteDataSource: ref.watch(taskRemoteDataSourceProvider),
    localDataSource: ref.watch(taskLocalDataSourceProvider),
  );
});

final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>((ref) {
  return CompleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Observations feature
// ═══════════════════════════════════════════════════════════════════════

final observationRemoteDataSourceProvider =
    Provider<ObservationRemoteDataSource>((ref) {
  return ObservationRemoteDataSourceImpl(
    client: ref.watch(connectClientProvider),
  );
});

final observationLocalDataSourceProvider =
    Provider<ObservationLocalDataSource>((ref) {
  return ObservationLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

final observationRepositoryProvider =
    Provider<ObservationRepository>((ref) {
  return ObservationRepositoryImpl(
    remoteDataSource: ref.watch(observationRemoteDataSourceProvider),
    localDataSource: ref.watch(observationLocalDataSourceProvider),
  );
});

final getObservationsUseCaseProvider =
    Provider<GetObservationsUseCase>((ref) {
  return GetObservationsUseCase(ref.watch(observationRepositoryProvider));
});

final createObservationUseCaseProvider =
    Provider<CreateObservationUseCase>((ref) {
  return CreateObservationUseCase(ref.watch(observationRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Traceability feature
// ═══════════════════════════════════════════════════════════════════════

final traceabilityRemoteDataSourceProvider =
    Provider<TraceabilityRemoteDataSource>((ref) {
  return TraceabilityRemoteDataSourceImpl(
    client: ref.watch(connectClientProvider),
  );
});

final traceabilityLocalDataSourceProvider =
    Provider<TraceabilityLocalDataSource>((ref) {
  return TraceabilityLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

final traceabilityRepositoryProvider =
    Provider<TraceabilityRepository>((ref) {
  return TraceabilityRepositoryImpl(
    remoteDataSource: ref.watch(traceabilityRemoteDataSourceProvider),
    localDataSource: ref.watch(traceabilityLocalDataSourceProvider),
  );
});

final scanQrCodeUseCaseProvider = Provider<ScanQrCodeUseCase>((ref) {
  return ScanQrCodeUseCase(ref.watch(traceabilityRepositoryProvider));
});

final getProduceRecordUseCaseProvider =
    Provider<GetProduceRecordUseCase>((ref) {
  return GetProduceRecordUseCase(ref.watch(traceabilityRepositoryProvider));
});

final getFarmHistoryUseCaseProvider =
    Provider<GetFarmHistoryUseCase>((ref) {
  return GetFarmHistoryUseCase(ref.watch(traceabilityRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Yield Prediction feature
// ═══════════════════════════════════════════════════════════════════════

final yieldRemoteDataSourceProvider =
    Provider<YieldRemoteDataSource>((ref) {
  return YieldRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final yieldLocalDataSourceProvider =
    Provider<YieldLocalDataSource>((ref) {
  return YieldLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

final yieldRepositoryProvider = Provider<YieldRepository>((ref) {
  return YieldRepositoryImpl(
    remoteDataSource: ref.watch(yieldRemoteDataSourceProvider),
    localDataSource: ref.watch(yieldLocalDataSourceProvider),
  );
});

final getYieldPredictionsUseCaseProvider =
    Provider<GetYieldPredictionsUseCase>((ref) {
  return GetYieldPredictionsUseCase(ref.watch(yieldRepositoryProvider));
});

final getYieldHistoryUseCaseProvider =
    Provider<GetYieldHistoryUseCase>((ref) {
  return GetYieldHistoryUseCase(ref.watch(yieldRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Field Inspection feature
// ═══════════════════════════════════════════════════════════════════════

final fieldInspectionRemoteDataSourceProvider =
    Provider<FieldInspectionRemoteDataSource>((ref) {
  return FieldInspectionRemoteDataSourceImpl(
      ref.watch(connectClientProvider));
});

final fieldInspectionLocalDataSourceProvider =
    Provider<FieldInspectionLocalDataSource>((ref) {
  return FieldInspectionLocalDataSourceImpl(
      ref.watch(sharedPreferencesProvider));
});

final fieldInspectionRepositoryProvider =
    Provider<FieldInspectionRepository>((ref) {
  return FieldInspectionRepositoryImpl(
    remoteDataSource: ref.watch(fieldInspectionRemoteDataSourceProvider),
    localDataSource: ref.watch(fieldInspectionLocalDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

final getInspectionsUseCaseProvider =
    Provider<GetInspectionsUseCase>((ref) {
  return GetInspectionsUseCase(
      ref.watch(fieldInspectionRepositoryProvider));
});

final createInspectionUseCaseProvider =
    Provider<CreateInspectionUseCase>((ref) {
  return CreateInspectionUseCase(
      ref.watch(fieldInspectionRepositoryProvider));
});

final submitInspectionUseCaseProvider =
    Provider<SubmitInspectionUseCase>((ref) {
  return SubmitInspectionUseCase(
      ref.watch(fieldInspectionRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Crop Advisory feature
// ═══════════════════════════════════════════════════════════════════════

final cropAdvisoryRemoteDataSourceProvider =
    Provider<CropAdvisoryRemoteDataSource>((ref) {
  return CropAdvisoryRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final cropAdvisoryLocalDataSourceProvider =
    Provider<CropAdvisoryLocalDataSource>((ref) {
  return CropAdvisoryLocalDataSourceImpl(
      ref.watch(sharedPreferencesProvider));
});

final cropAdvisoryRepositoryProvider =
    Provider<CropAdvisoryRepository>((ref) {
  return CropAdvisoryRepositoryImpl(
    remoteDataSource: ref.watch(cropAdvisoryRemoteDataSourceProvider),
    localDataSource: ref.watch(cropAdvisoryLocalDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

final getAdvisoriesUseCaseProvider =
    Provider<GetAdvisoriesUseCase>((ref) {
  return GetAdvisoriesUseCase(ref.watch(cropAdvisoryRepositoryProvider));
});

final createAdvisoryUseCaseProvider =
    Provider<CreateAdvisoryUseCase>((ref) {
  return CreateAdvisoryUseCase(ref.watch(cropAdvisoryRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Analytics feature
// ═══════════════════════════════════════════════════════════════════════

final analyticsRemoteDataSourceProvider =
    Provider<AnalyticsRemoteDataSource>((ref) {
  return AnalyticsRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl(
    remoteDataSource: ref.watch(analyticsRemoteDataSourceProvider),
  );
});

final getFieldAnalyticsUseCaseProvider =
    Provider<GetFieldAnalyticsUseCase>((ref) {
  return GetFieldAnalyticsUseCase(ref.watch(analyticsRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Prescriptions feature
// ═══════════════════════════════════════════════════════════════════════

final prescriptionRemoteDataSourceProvider =
    Provider<PrescriptionRemoteDataSource>((ref) {
  return PrescriptionRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final prescriptionRepositoryProvider =
    Provider<PrescriptionRepository>((ref) {
  return PrescriptionRepositoryImpl(
    remoteDataSource: ref.watch(prescriptionRemoteDataSourceProvider),
  );
});

final getPrescriptionsUseCaseProvider =
    Provider<GetPrescriptionsUseCase>((ref) {
  return GetPrescriptionsUseCase(ref.watch(prescriptionRepositoryProvider));
});

final generatePrescriptionUseCaseProvider =
    Provider<GeneratePrescriptionUseCase>((ref) {
  return GeneratePrescriptionUseCase(
      ref.watch(prescriptionRepositoryProvider));
});
