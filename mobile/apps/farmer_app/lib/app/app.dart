import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';

import '../core/auth/role_provider.dart';
import '../core/di/providers.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme_provider.dart';
import '../features/alerts/presentation/bloc/alert_bloc.dart';
import '../features/ai_diagnosis/presentation/bloc/diagnosis_bloc.dart';
import '../features/crop_advisory/presentation/bloc/crop_advisory_bloc.dart';
import '../features/crop_recommendation/presentation/bloc/crop_recommendation_bloc.dart';
import '../features/drone/presentation/bloc/drone_bloc.dart';
import '../features/farm/presentation/bloc/farm_bloc.dart';
import '../features/farm/presentation/bloc/field_bloc.dart';
import '../features/field_inspection/presentation/bloc/field_inspection_bloc.dart';
import '../features/gps_tracking/presentation/bloc/gps_tracking_bloc.dart';
import '../features/irrigation/presentation/bloc/irrigation_bloc.dart';
import '../features/observations/presentation/bloc/observation_bloc.dart';
import '../features/pest_risk/presentation/bloc/pest_bloc.dart';
import '../features/satellite/presentation/bloc/satellite_bloc.dart';
import '../features/sensors/presentation/bloc/sensor_bloc.dart';
import '../features/soil/presentation/bloc/soil_bloc.dart';
import '../features/tasks/presentation/bloc/task_bloc.dart';
import '../features/traceability/presentation/bloc/traceability_bloc.dart';
import '../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../features/prescriptions/presentation/bloc/prescription_bloc.dart';
import '../features/yield_prediction/presentation/bloc/yield_bloc.dart';

/// The root widget of the unified YieldPoint app.
class FarmerApp extends ConsumerWidget {
  const FarmerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    final role = ref.watch(userRoleProvider);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AlertBloc(
            getAlerts: ref.read(getAlertsUseCaseProvider),
            markAlertRead: ref.read(markAlertReadUseCaseProvider),
            getUnreadCount: ref.read(getUnreadCountUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => GPSTrackingBloc(
            startTracking: ref.read(startTrackingUseCaseProvider),
            stopTracking: ref.read(stopTrackingUseCaseProvider),
            markIssue: ref.read(markIssueUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => DroneBloc(
            getDroneLayers: ref.read(getDroneLayersUseCaseProvider),
            getDroneFlights: ref.read(getDroneFlightsUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => CropRecommendationBloc(
            getRecommendations: ref.read(getRecommendationsUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => FarmBloc(
            farmRepository: ref.read(farmRepositoryProvider),
          ),
        ),
        BlocProvider(
          create: (context) => FieldBloc(
            farmRepository: ref.read(farmRepositoryProvider),
          ),
        ),
        BlocProvider(
          create: (context) => DiagnosisBloc(
            repository: ref.read(diagnosisRepositoryProvider),
          ),
        ),
        BlocProvider(
          create: (context) => SatelliteBloc(
            repository: ref.read(satelliteRepositoryProvider),
          ),
        ),
        BlocProvider(
          create: (context) => SensorBloc(
            getSensors: ref.read(getSensorsUseCaseProvider),
            getSensorReadings: ref.read(getSensorReadingsUseCaseProvider),
            getSensorDashboard: ref.read(getSensorDashboardUseCaseProvider),
            repository: ref.read(sensorRepositoryProvider),
          ),
        ),
        BlocProvider(
          create: (context) => SoilBloc(
            getSoilAnalysis: ref.read(getSoilAnalysisUseCaseProvider),
            getSoilHistory: ref.read(getSoilHistoryUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => IrrigationBloc(
            getZones: ref.read(getIrrigationZonesUseCaseProvider),
            getSchedule: ref.read(getIrrigationScheduleUseCaseProvider),
            updateSchedule:
                ref.read(updateIrrigationScheduleUseCaseProvider),
            getAlerts: ref.read(getIrrigationAlertsUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => PestBloc(
            getPestRiskZones: ref.read(getPestRiskZonesUseCaseProvider),
            getPestAlerts: ref.read(getPestAlertsUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => TaskBloc(
            getTasks: ref.read(getTasksUseCaseProvider),
            createTask: ref.read(createTaskUseCaseProvider),
            updateTask: ref.read(updateTaskUseCaseProvider),
            completeTask: ref.read(completeTaskUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => ObservationBloc(
            getObservations: ref.read(getObservationsUseCaseProvider),
            createObservation: ref.read(createObservationUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => TraceabilityBloc(
            scanQrCode: ref.read(scanQrCodeUseCaseProvider),
            getProduceRecord: ref.read(getProduceRecordUseCaseProvider),
            getFarmHistory: ref.read(getFarmHistoryUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => YieldBloc(
            getPredictions: ref.read(getYieldPredictionsUseCaseProvider),
            getHistory: ref.read(getYieldHistoryUseCaseProvider),
          ),
        ),
        // ── Analytics & Prescriptions blocs ───────────────────────────
        BlocProvider(
          create: (context) => AnalyticsBloc(
            getFieldAnalytics: ref.read(getFieldAnalyticsUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => PrescriptionBloc(
            getPrescriptions: ref.read(getPrescriptionsUseCaseProvider),
            generatePrescription:
                ref.read(generatePrescriptionUseCaseProvider),
          ),
        ),
        // ── Agronomist-specific blocs ────────────────────────────────
        BlocProvider(
          create: (context) => FieldInspectionBloc(
            getInspections: ref.read(getInspectionsUseCaseProvider),
            createInspection: ref.read(createInspectionUseCaseProvider),
            submitInspection: ref.read(submitInspectionUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => CropAdvisoryBloc(
            getAdvisories: ref.read(getAdvisoriesUseCaseProvider),
            createAdvisory: ref.read(createAdvisoryUseCaseProvider),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: role.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
