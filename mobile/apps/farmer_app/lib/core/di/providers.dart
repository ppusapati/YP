import 'package:connectivity_plus/connectivity_plus.dart';
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
    apiConfig: ref.watch(apiConfigProvider),
    httpClient: ref.watch(httpClientProvider),
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
  return DiagnosisRemoteDataSourceImpl(
    apiConfig: ref.watch(apiConfigProvider),
    httpClient: ref.watch(httpClientProvider),
  );
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
  return SatelliteRemoteDataSourceImpl(
    apiConfig: ref.watch(apiConfigProvider),
    httpClient: ref.watch(httpClientProvider),
  );
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
  return SensorRemoteDataSourceImpl(
    client: ref.watch(httpClientProvider),
    baseUrl: ref.watch(apiBaseUrlProvider),
  );
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
  return SoilRemoteDataSourceImpl(
    client: ref.watch(httpClientProvider),
    baseUrl: ref.watch(apiBaseUrlProvider),
  );
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
  return IrrigationRemoteDataSourceImpl(
    client: ref.watch(httpClientProvider),
    baseUrl: ref.watch(apiBaseUrlProvider),
  );
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
  return YieldRemoteDataSourceImpl(
    client: ref.watch(httpClientProvider),
    baseUrl: ref.watch(apiBaseUrlProvider),
  );
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
