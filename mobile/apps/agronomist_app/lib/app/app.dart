import 'package:flutter/material.dart';
import 'package:flutter_auth/flutter_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';

import '../core/di/providers.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme_provider.dart';
import '../features/farm/presentation/bloc/farm_bloc.dart';
import '../features/field_inspection/presentation/bloc/field_inspection_bloc.dart';
import '../features/crop_advisory/presentation/bloc/crop_advisory_bloc.dart';
import '../features/soil_analysis/presentation/bloc/soil_analysis_bloc.dart';
import '../features/satellite_monitoring/presentation/bloc/satellite_bloc.dart';
import '../features/plant_diagnosis/presentation/bloc/diagnosis_bloc.dart';
import '../features/pest_risk/presentation/bloc/pest_risk_bloc.dart';
import '../features/irrigation/presentation/bloc/irrigation_bloc.dart';
import '../features/sensors/presentation/bloc/sensor_bloc.dart';
import '../features/yield_analysis/presentation/bloc/yield_analysis_bloc.dart';
import '../features/traceability/presentation/bloc/traceability_bloc.dart';

/// The root widget of the YieldPoint Agronomist app.
class AgronomistApp extends ConsumerWidget {
  const AgronomistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: ref.read(authBlocProvider)..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => FarmBloc(
            getFarms: ref.read(getFarmsUseCaseProvider),
            createFarm: ref.read(createFarmUseCaseProvider),
            updateFarm: ref.read(updateFarmUseCaseProvider),
          ),
        ),
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
        BlocProvider(
          create: (context) => SoilAnalysisBloc(
            getSoilAnalyses: ref.read(getSoilAnalysesUseCaseProvider),
            createSoilAnalysis: ref.read(createSoilAnalysisUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => SatelliteBloc(
            getSatelliteTiles: ref.read(getSatelliteTilesUseCaseProvider),
            getStressAlerts: ref.read(getStressAlertsUseCaseProvider),
            getFieldSummary: ref.read(getFieldSummaryUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => DiagnosisBloc(
            submitDiagnosis: ref.read(submitDiagnosisUseCaseProvider),
            getDiagnoses: ref.read(getDiagnosesUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => PestRiskBloc(
            predictPestRisk: ref.read(predictPestRiskUseCaseProvider),
            getPestAlerts: ref.read(getPestAlertsUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => IrrigationBloc(
            getIrrigationPlan: ref.read(getIrrigationPlanUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => SensorBloc(
            getSensorReadings: ref.read(getSensorReadingsUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => YieldAnalysisBloc(
            getYieldForecast: ref.read(getYieldForecastUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => TraceabilityBloc(
            getTraceRecords: ref.read(getTraceRecordsUseCaseProvider),
            createTraceRecord: ref.read(createTraceRecordUseCaseProvider),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'YieldPoint Agronomist',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
