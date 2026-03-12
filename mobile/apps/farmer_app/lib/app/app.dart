import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ui_core/src/theme/app_theme.dart';

import '../core/di/providers.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme_provider.dart';
import '../features/alerts/presentation/bloc/alert_bloc.dart';
import '../features/crop_recommendation/presentation/bloc/crop_recommendation_bloc.dart';
import '../features/drone/presentation/bloc/drone_bloc.dart';
import '../features/gps_tracking/presentation/bloc/gps_tracking_bloc.dart';

/// The root widget of the YieldPoint Farmer app.
class FarmerApp extends ConsumerWidget {
  const FarmerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

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
      ],
      child: MaterialApp.router(
        title: 'YieldPoint Farmer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
