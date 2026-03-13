import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ui_core/src/theme/app_theme.dart';

import '../core/di/providers.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme_provider.dart';
import '../features/farm/presentation/bloc/farm_bloc.dart';
import '../features/field_inspection/presentation/bloc/field_inspection_bloc.dart';
import '../features/crop_advisory/presentation/bloc/crop_advisory_bloc.dart';
import '../features/soil_analysis/presentation/bloc/soil_analysis_bloc.dart';
import '../features/satellite/presentation/bloc/satellite_bloc.dart';
import '../features/diagnosis/presentation/bloc/diagnosis_bloc.dart';

/// The root widget of the YieldPoint Agronomist app.
class AgronomistApp extends ConsumerWidget {
  const AgronomistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MultiBlocProvider(
      providers: [
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
            getSatelliteLayers: ref.read(getSatelliteLayersUseCaseProvider),
            getSatelliteHistory: ref.read(getSatelliteHistoryUseCaseProvider),
          ),
        ),
        BlocProvider(
          create: (context) => DiagnosisBloc(
            submitDiagnosis: ref.read(submitDiagnosisUseCaseProvider),
            getDiagnosisHistory: ref.read(getDiagnosisHistoryUseCaseProvider),
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
