import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/main_screen.dart';

// Feature screens
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/farm/presentation/screens/farm_list_screen.dart';
import '../../features/farm/presentation/screens/farm_detail_screen.dart';
import '../../features/field_inspection/presentation/screens/field_inspection_list_screen.dart';
import '../../features/field_inspection/presentation/screens/inspection_form_screen.dart';
import '../../features/crop_advisory/presentation/screens/crop_advisory_screen.dart';
import '../../features/soil_analysis/presentation/screens/soil_analysis_screen.dart';
import '../../features/soil_analysis/presentation/screens/soil_sample_form_screen.dart';
import '../../features/satellite_monitoring/presentation/screens/satellite_monitoring_screen.dart';
import '../../features/satellite_monitoring/presentation/screens/stress_alerts_screen.dart';
import '../../features/satellite_monitoring/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/plant_diagnosis/presentation/screens/diagnosis_screen.dart';
import '../../features/plant_diagnosis/presentation/screens/diagnosis_result_screen.dart';
import '../../features/plant_diagnosis/presentation/screens/diagnosis_history_screen.dart';
import '../../features/pest_risk/presentation/screens/pest_risk_screen.dart';
import '../../features/pest_risk/presentation/screens/pest_alert_list_screen.dart';
import '../../features/irrigation/presentation/screens/irrigation_screen.dart';
import '../../features/sensors/presentation/screens/sensor_list_screen.dart';
import '../../features/yield_analysis/presentation/screens/yield_forecast_screen.dart';
import '../../features/yield_analysis/presentation/screens/crop_performance_screen.dart';
import '../../features/traceability/presentation/screens/traceability_screen.dart';
import '../../features/traceability/presentation/screens/record_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

/// GoRouter configuration provider.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      // ─── Shell route with bottom navigation ──────────────────────
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/fields',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FarmListScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => FarmDetailScreen(
                  farmId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/advisory',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CropAdvisoryScreen(),
            ),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PestAlertListScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // ─── Full-screen routes (no bottom nav) ──────────────────────

      // Farms
      GoRoute(
        path: '/farms',
        builder: (context, state) => const FarmListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => FarmDetailScreen(
              farmId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      // Soil Analysis
      GoRoute(
        path: '/soil-analysis/:fieldId',
        builder: (context, state) => SoilAnalysisScreen(
          fieldId: state.pathParameters['fieldId']!,
        ),
        routes: [
          GoRoute(
            path: 'new-sample',
            builder: (context, state) => SoilSampleFormScreen(
              fieldId: state.pathParameters['fieldId']!,
            ),
          ),
        ],
      ),

      // Satellite Monitoring
      GoRoute(
        path: '/satellite/:fieldId',
        builder: (context, state) => SatelliteMonitoringScreen(
          fieldId: state.pathParameters['fieldId']!,
        ),
        routes: [
          GoRoute(
            path: 'alerts',
            builder: (context, state) => StressAlertsScreen(
              farmId: state.pathParameters['fieldId']!,
            ),
          ),
          GoRoute(
            path: 'analytics',
            builder: (context, state) => AnalyticsDashboardScreen(
              farmId: state.pathParameters['fieldId']!,
              fieldId: state.pathParameters['fieldId']!,
            ),
          ),
        ],
      ),

      // Sensors
      GoRoute(
        path: '/sensors/:fieldId',
        builder: (context, state) => SensorListScreen(
          fieldId: state.pathParameters['fieldId']!,
        ),
      ),

      // Plant Diagnosis
      GoRoute(
        path: '/diagnosis/new',
        builder: (context, state) => const DiagnosisScreen(),
      ),
      GoRoute(
        path: '/diagnosis/history',
        builder: (context, state) => const DiagnosisHistoryScreen(),
      ),
      GoRoute(
        path: '/diagnosis/:id',
        builder: (context, state) => DiagnosisResultScreen(
          diagnosisId: state.pathParameters['id']!,
        ),
      ),

      // Pest Risk
      GoRoute(
        path: '/pest-risk/:fieldId',
        builder: (context, state) => PestRiskScreen(
          fieldId: state.pathParameters['fieldId']!,
        ),
      ),

      // Irrigation
      GoRoute(
        path: '/irrigation/:fieldId',
        builder: (context, state) => IrrigationScreen(
          fieldId: state.pathParameters['fieldId']!,
        ),
      ),

      // Yield Forecast
      GoRoute(
        path: '/yield-forecast/:fieldId',
        builder: (context, state) => YieldForecastScreen(
          fieldId: state.pathParameters['fieldId']!,
        ),
      ),

      // Crop Performance
      GoRoute(
        path: '/crop-performance/:fieldId',
        builder: (context, state) => CropPerformanceScreen(
          fieldId: state.pathParameters['fieldId']!,
        ),
      ),

      // Traceability
      GoRoute(
        path: '/traceability',
        builder: (context, state) => const TraceabilityScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => RecordDetailScreen(
              recordId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      // Field Inspections
      GoRoute(
        path: '/inspections',
        builder: (context, state) => const FieldInspectionListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const InspectionFormScreen(),
          ),
        ],
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const _NotificationsScreen(),
      ),
    ],
  );
});

/// Simple notifications screen — kept inline since it has no dedicated feature.
class _NotificationsScreen extends StatelessWidget {
  const _NotificationsScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none,
                size: 80,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 24),
            Text('No notifications', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Alerts and updates will appear here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
