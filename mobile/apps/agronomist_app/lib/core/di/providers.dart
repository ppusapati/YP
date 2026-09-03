import 'package:flutter_auth/flutter_auth.dart';
import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

// Farm
import '../../features/farm/data/datasources/farm_remote_datasource.dart';
import '../../features/farm/data/datasources/farm_local_datasource.dart';
import '../../features/farm/data/repositories/farm_repository_impl.dart';
import '../../features/farm/domain/repositories/farm_repository.dart';
import '../../features/farm/domain/usecases/get_farms_usecase.dart';
import '../../features/farm/domain/usecases/create_farm_usecase.dart';
import '../../features/farm/domain/usecases/update_farm_usecase.dart';

// Field Inspection
import '../../features/field_inspection/data/datasources/field_inspection_remote_datasource.dart';
import '../../features/field_inspection/data/datasources/field_inspection_local_datasource.dart';
import '../../features/field_inspection/data/repositories/field_inspection_repository_impl.dart';
import '../../features/field_inspection/domain/repositories/field_inspection_repository.dart';
import '../../features/field_inspection/domain/usecases/get_inspections_usecase.dart';
import '../../features/field_inspection/domain/usecases/create_inspection_usecase.dart';
import '../../features/field_inspection/domain/usecases/submit_inspection_usecase.dart';

// Crop Advisory
import '../../features/crop_advisory/data/datasources/crop_advisory_remote_datasource.dart';
import '../../features/crop_advisory/data/datasources/crop_advisory_local_datasource.dart';
import '../../features/crop_advisory/data/repositories/crop_advisory_repository_impl.dart';
import '../../features/crop_advisory/domain/repositories/crop_advisory_repository.dart';
import '../../features/crop_advisory/domain/usecases/get_advisories_usecase.dart';
import '../../features/crop_advisory/domain/usecases/create_advisory_usecase.dart';

// Soil Analysis
import '../../features/soil_analysis/data/datasources/soil_analysis_remote_datasource.dart';
import '../../features/soil_analysis/data/datasources/soil_analysis_local_datasource.dart';
import '../../features/soil_analysis/data/repositories/soil_analysis_repository_impl.dart';
import '../../features/soil_analysis/domain/repositories/soil_analysis_repository.dart';
import '../../features/soil_analysis/domain/usecases/get_soil_analyses_usecase.dart';
import '../../features/soil_analysis/domain/usecases/create_soil_analysis_usecase.dart';

// Satellite Monitoring
import '../../features/satellite_monitoring/data/datasources/satellite_remote_datasource.dart';
import '../../features/satellite_monitoring/data/datasources/satellite_local_datasource.dart';
import '../../features/satellite_monitoring/data/repositories/satellite_repository_impl.dart';
import '../../features/satellite_monitoring/domain/repositories/satellite_repository.dart';
import '../../features/satellite_monitoring/domain/usecases/get_satellite_tiles_usecase.dart';
import '../../features/satellite_monitoring/domain/usecases/get_stress_alerts_usecase.dart';
import '../../features/satellite_monitoring/domain/usecases/get_field_summary_usecase.dart';

// Plant Diagnosis
import '../../features/plant_diagnosis/data/datasources/diagnosis_remote_datasource.dart';
import '../../features/plant_diagnosis/data/datasources/diagnosis_local_datasource.dart';
import '../../features/plant_diagnosis/data/repositories/diagnosis_repository_impl.dart';
import '../../features/plant_diagnosis/domain/repositories/diagnosis_repository.dart';
import '../../features/plant_diagnosis/domain/usecases/submit_diagnosis_usecase.dart';
import '../../features/plant_diagnosis/domain/usecases/get_diagnoses_usecase.dart';

// Pest Risk
import '../../features/pest_risk/data/datasources/pest_risk_remote_datasource.dart';
import '../../features/pest_risk/data/repositories/pest_risk_repository_impl.dart';
import '../../features/pest_risk/domain/repositories/pest_risk_repository.dart';
import '../../features/pest_risk/domain/usecases/predict_pest_risk_usecase.dart';
import '../../features/pest_risk/domain/usecases/get_pest_alerts_usecase.dart';

// Irrigation
import '../../features/irrigation/data/datasources/irrigation_remote_datasource.dart';
import '../../features/irrigation/data/datasources/irrigation_local_datasource.dart';
import '../../features/irrigation/data/repositories/irrigation_repository_impl.dart';
import '../../features/irrigation/domain/repositories/irrigation_repository.dart';
import '../../features/irrigation/domain/usecases/get_irrigation_plan_usecase.dart';
import '../../features/irrigation/domain/usecases/update_irrigation_schedule_usecase.dart';

// Sensors
import '../../features/sensors/data/datasources/sensor_remote_datasource.dart';
import '../../features/sensors/data/repositories/sensor_repository_impl.dart';
import '../../features/sensors/domain/repositories/sensor_repository.dart';
import '../../features/sensors/domain/usecases/get_sensor_readings_usecase.dart';

// Yield Analysis
import '../../features/yield_analysis/data/datasources/yield_analysis_remote_datasource.dart';
import '../../features/yield_analysis/data/repositories/yield_analysis_repository_impl.dart';
import '../../features/yield_analysis/domain/repositories/yield_analysis_repository.dart';
import '../../features/yield_analysis/domain/usecases/get_yield_forecast_usecase.dart';
import '../../features/yield_analysis/domain/usecases/get_yield_history_usecase.dart';

// Traceability
import '../../features/traceability/data/datasources/traceability_remote_datasource.dart';
import '../../features/traceability/data/datasources/traceability_local_datasource.dart';
import '../../features/traceability/data/repositories/traceability_repository_impl.dart';
import '../../features/traceability/domain/repositories/traceability_repository.dart';
import '../../features/traceability/domain/usecases/get_trace_records_usecase.dart';
import '../../features/traceability/domain/usecases/create_trace_record_usecase.dart';

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

/// HTTP client for REST-style calls (auth endpoints).
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(() => client.close());
  return client;
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
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ═══════════════════════════════════════════════════════════════════════
// Farm feature
// ═══════════════════════════════════════════════════════════════════════

final farmRemoteDataSourceProvider = Provider<FarmRemoteDataSource>((ref) {
  return FarmRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final farmLocalDataSourceProvider = Provider<FarmLocalDataSource>((ref) {
  return FarmLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
});

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return FarmRepositoryImpl(
    remoteDataSource: ref.watch(farmRemoteDataSourceProvider),
    localDataSource: ref.watch(farmLocalDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
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

// ═══════════════════════════════════════════════════════════════════════
// Field Inspection feature
// ═══════════════════════════════════════════════════════════════════════

final fieldInspectionRemoteDataSourceProvider =
    Provider<FieldInspectionRemoteDataSource>((ref) {
  return FieldInspectionRemoteDataSourceImpl(ref.watch(connectClientProvider));
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
  return GetInspectionsUseCase(ref.watch(fieldInspectionRepositoryProvider));
});

final createInspectionUseCaseProvider =
    Provider<CreateInspectionUseCase>((ref) {
  return CreateInspectionUseCase(ref.watch(fieldInspectionRepositoryProvider));
});

final submitInspectionUseCaseProvider =
    Provider<SubmitInspectionUseCase>((ref) {
  return SubmitInspectionUseCase(ref.watch(fieldInspectionRepositoryProvider));
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
  return CropAdvisoryLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
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
// Soil Analysis feature
// ═══════════════════════════════════════════════════════════════════════

final soilAnalysisRemoteDataSourceProvider =
    Provider<SoilAnalysisRemoteDataSource>((ref) {
  return SoilAnalysisRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final soilAnalysisLocalDataSourceProvider =
    Provider<SoilAnalysisLocalDataSource>((ref) {
  return SoilAnalysisLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
});

final soilAnalysisRepositoryProvider =
    Provider<SoilAnalysisRepository>((ref) {
  return SoilAnalysisRepositoryImpl(
    remoteDataSource: ref.watch(soilAnalysisRemoteDataSourceProvider),
    localDataSource: ref.watch(soilAnalysisLocalDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

final getSoilAnalysesUseCaseProvider =
    Provider<GetSoilAnalysesUseCase>((ref) {
  return GetSoilAnalysesUseCase(ref.watch(soilAnalysisRepositoryProvider));
});

final createSoilAnalysisUseCaseProvider =
    Provider<CreateSoilAnalysisUseCase>((ref) {
  return CreateSoilAnalysisUseCase(ref.watch(soilAnalysisRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Satellite Monitoring feature
// ═══════════════════════════════════════════════════════════════════════

final satelliteRemoteDataSourceProvider =
    Provider<SatelliteRemoteDataSource>((ref) {
  return SatelliteRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final satelliteLocalDataSourceProvider =
    Provider<SatelliteLocalDataSource>((ref) {
  return SatelliteLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
});

final satelliteRepositoryProvider = Provider<SatelliteRepository>((ref) {
  return SatelliteRepositoryImpl(
    remoteDataSource: ref.watch(satelliteRemoteDataSourceProvider),
    localDataSource: ref.watch(satelliteLocalDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

final getSatelliteTilesUseCaseProvider =
    Provider<GetSatelliteTilesUseCase>((ref) {
  return GetSatelliteTilesUseCase(ref.watch(satelliteRepositoryProvider));
});

final getStressAlertsUseCaseProvider =
    Provider<GetStressAlertsUseCase>((ref) {
  return GetStressAlertsUseCase(ref.watch(satelliteRepositoryProvider));
});

final getFieldSummaryUseCaseProvider =
    Provider<GetFieldSummaryUseCase>((ref) {
  return GetFieldSummaryUseCase(ref.watch(satelliteRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Plant Diagnosis feature
// ═══════════════════════════════════════════════════════════════════════

final diagnosisRemoteDataSourceProvider =
    Provider<DiagnosisRemoteDataSource>((ref) {
  return DiagnosisRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final diagnosisLocalDataSourceProvider =
    Provider<DiagnosisLocalDataSource>((ref) {
  return DiagnosisLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
});

final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  return DiagnosisRepositoryImpl(
    remoteDataSource: ref.watch(diagnosisRemoteDataSourceProvider),
    localDataSource: ref.watch(diagnosisLocalDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

final submitDiagnosisUseCaseProvider =
    Provider<SubmitDiagnosisUseCase>((ref) {
  return SubmitDiagnosisUseCase(ref.watch(diagnosisRepositoryProvider));
});

final getDiagnosesUseCaseProvider =
    Provider<GetDiagnosesUseCase>((ref) {
  return GetDiagnosesUseCase(ref.watch(diagnosisRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Pest Risk feature
// ═══════════════════════════════════════════════════════════════════════

final pestRiskRemoteDataSourceProvider =
    Provider<PestRiskRemoteDataSource>((ref) {
  return PestRiskRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final pestRiskRepositoryProvider = Provider<PestRiskRepository>((ref) {
  return PestRiskRepositoryImpl(
    remoteDataSource: ref.watch(pestRiskRemoteDataSourceProvider),
  );
});

final predictPestRiskUseCaseProvider =
    Provider<PredictPestRiskUseCase>((ref) {
  return PredictPestRiskUseCase(ref.watch(pestRiskRepositoryProvider));
});

final getPestAlertsUseCaseProvider =
    Provider<GetPestAlertsUseCase>((ref) {
  return GetPestAlertsUseCase(ref.watch(pestRiskRepositoryProvider));
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
  return IrrigationLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
});

final irrigationRepositoryProvider = Provider<IrrigationRepository>((ref) {
  return IrrigationRepositoryImpl(
    remoteDataSource: ref.watch(irrigationRemoteDataSourceProvider),
    localDataSource: ref.watch(irrigationLocalDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

final getIrrigationPlanUseCaseProvider =
    Provider<GetIrrigationPlanUseCase>((ref) {
  return GetIrrigationPlanUseCase(ref.watch(irrigationRepositoryProvider));
});

final updateIrrigationScheduleUseCaseProvider =
    Provider<UpdateIrrigationScheduleUseCase>((ref) {
  return UpdateIrrigationScheduleUseCase(
      ref.watch(irrigationRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Sensors feature
// ═══════════════════════════════════════════════════════════════════════

final sensorRemoteDataSourceProvider =
    Provider<SensorRemoteDataSource>((ref) {
  return SensorRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return SensorRepositoryImpl(
    remoteDataSource: ref.watch(sensorRemoteDataSourceProvider),
  );
});

final getSensorReadingsUseCaseProvider =
    Provider<GetSensorReadingsUseCase>((ref) {
  return GetSensorReadingsUseCase(ref.watch(sensorRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Yield Analysis feature
// ═══════════════════════════════════════════════════════════════════════

final yieldAnalysisRemoteDataSourceProvider =
    Provider<YieldAnalysisRemoteDataSource>((ref) {
  return YieldAnalysisRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final yieldAnalysisRepositoryProvider =
    Provider<YieldAnalysisRepository>((ref) {
  return YieldAnalysisRepositoryImpl(
    remoteDataSource: ref.watch(yieldAnalysisRemoteDataSourceProvider),
  );
});

final getYieldForecastUseCaseProvider =
    Provider<GetYieldForecastUseCase>((ref) {
  return GetYieldForecastUseCase(ref.watch(yieldAnalysisRepositoryProvider));
});

final getYieldHistoryUseCaseProvider =
    Provider<GetYieldHistoryUseCase>((ref) {
  return GetYieldHistoryUseCase(ref.watch(yieldAnalysisRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════════
// Traceability feature
// ═══════════════════════════════════════════════════════════════════════

final traceabilityRemoteDataSourceProvider =
    Provider<TraceabilityRemoteDataSource>((ref) {
  return TraceabilityRemoteDataSourceImpl(ref.watch(connectClientProvider));
});

final traceabilityLocalDataSourceProvider =
    Provider<TraceabilityLocalDataSource>((ref) {
  return TraceabilityLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
});

final traceabilityRepositoryProvider =
    Provider<TraceabilityRepository>((ref) {
  return TraceabilityRepositoryImpl(
    remoteDataSource: ref.watch(traceabilityRemoteDataSourceProvider),
    localDataSource: ref.watch(traceabilityLocalDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

final getTraceRecordsUseCaseProvider =
    Provider<GetTraceRecordsUseCase>((ref) {
  return GetTraceRecordsUseCase(ref.watch(traceabilityRepositoryProvider));
});

final createTraceRecordUseCaseProvider =
    Provider<CreateTraceRecordUseCase>((ref) {
  return CreateTraceRecordUseCase(ref.watch(traceabilityRepositoryProvider));
});
