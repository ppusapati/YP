import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/main_screen.dart';
import '../../features/alerts/presentation/bloc/alert_bloc.dart';
import '../../features/alerts/presentation/bloc/alert_event.dart';
import '../../features/alerts/presentation/screens/alert_detail_screen.dart';
import '../../features/alerts/presentation/screens/alert_list_screen.dart';
import '../../features/ai_diagnosis/presentation/screens/diagnosis_history_screen.dart';
import '../../features/ai_diagnosis/presentation/screens/diagnosis_result_screen.dart';
import '../../features/ai_diagnosis/presentation/screens/diagnosis_screen.dart';
import '../../features/ai_diagnosis/domain/entities/diagnosis_entity.dart';
import '../../features/crop_recommendation/presentation/screens/crop_recommendation_screen.dart';
import '../../features/drone/presentation/screens/drone_viewer_screen.dart';
import '../../features/farm/domain/entities/farm_entity.dart';
import '../../features/farm/presentation/screens/farm_detail_screen.dart';
import '../../features/farm/presentation/screens/farm_editor_screen.dart';
import '../../features/farm/presentation/screens/farm_list_screen.dart';
import '../../features/gps_tracking/presentation/screens/track_detail_screen.dart';
import '../../features/gps_tracking/presentation/screens/track_history_screen.dart';
import '../../features/gps_tracking/presentation/screens/tracking_screen.dart';
import '../../features/irrigation/presentation/screens/irrigation_dashboard_screen.dart';
import '../../features/irrigation/presentation/screens/irrigation_schedule_screen.dart';
import '../../features/irrigation/presentation/screens/irrigation_zone_detail_screen.dart';
import '../../features/observations/domain/entities/observation_entity.dart';
import '../../features/observations/presentation/screens/observation_detail_screen.dart';
import '../../features/observations/presentation/screens/observation_editor_screen.dart';
import '../../features/observations/presentation/screens/observation_list_screen.dart';
import '../../features/pest_risk/domain/entities/pest_risk_entity.dart';
import '../../features/pest_risk/presentation/screens/pest_alert_detail_screen.dart';
import '../../features/pest_risk/presentation/screens/pest_risk_map_screen.dart';
import '../../features/satellite/presentation/screens/crop_health_dashboard_screen.dart';
import '../../features/satellite/presentation/screens/satellite_monitoring_screen.dart';
import '../../features/sensors/presentation/screens/sensor_dashboard_screen.dart';
import '../../features/sensors/presentation/screens/sensor_detail_screen.dart';
import '../../features/soil/presentation/screens/soil_dashboard_screen.dart';
import '../../features/soil/presentation/screens/soil_detail_screen.dart';
import '../../features/tasks/domain/entities/task_entity.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_editor_screen.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';
import '../../features/traceability/domain/entities/produce_record_entity.dart';
import '../../features/traceability/presentation/screens/produce_detail_screen.dart';
import '../../features/traceability/presentation/screens/traceability_screen.dart';
import '../../features/yield_prediction/domain/entities/yield_prediction_entity.dart';
import '../../features/yield_prediction/presentation/screens/yield_dashboard_screen.dart';
import '../../features/yield_prediction/presentation/screens/yield_detail_screen.dart';

/// GoRouter configuration provider.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/farms',
    routes: [
      // ─── Shell route with bottom navigation ──────────────────────
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/farms',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FarmListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const FarmEditorScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => FarmDetailScreen(
                  farmId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => FarmEditorScreen(
                      existingFarm: state.extra as FarmEntity?,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/satellite',
            pageBuilder: (context, state) {
              final fieldId =
                  state.uri.queryParameters['fieldId'] ?? 'default';
              return NoTransitionPage(
                child: SatelliteMonitoringScreen(fieldId: fieldId),
              );
            },
            routes: [
              GoRoute(
                path: 'health',
                builder: (context, state) {
                  final fieldId =
                      state.uri.queryParameters['fieldId'] ?? 'default';
                  return CropHealthDashboardScreen(fieldId: fieldId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/diagnosis',
            pageBuilder: (context, state) {
              final fieldId = state.uri.queryParameters['fieldId'];
              return NoTransitionPage(
                child: DiagnosisScreen(fieldId: fieldId),
              );
            },
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) {
                  final fieldId = state.uri.queryParameters['fieldId'];
                  return DiagnosisHistoryScreen(fieldId: fieldId);
                },
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final diagnosis = state.extra as Diagnosis;
                  return DiagnosisResultScreen(diagnosis: diagnosis);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/tasks',
            pageBuilder: (context, state) {
              final farmId = state.uri.queryParameters['farmId'];
              return NoTransitionPage(
                child: TaskListScreen(farmId: farmId),
              );
            },
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  final farmId =
                      state.uri.queryParameters['farmId'] ?? '';
                  return TaskEditorScreen(farmId: farmId);
                },
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final task = state.extra as FarmTask;
                  return TaskDetailScreen(task: task);
                },
              ),
            ],
          ),
        ],
      ),

      // ─── Full-screen routes (no bottom nav) ──────────────────────

      // Sensors
      GoRoute(
        path: '/sensors',
        builder: (context, state) => const SensorDashboardScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => SensorDetailScreen(
              sensorId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      // Irrigation
      GoRoute(
        path: '/irrigation',
        builder: (context, state) {
          final fieldId =
              state.uri.queryParameters['fieldId'] ?? 'default';
          return IrrigationDashboardScreen(fieldId: fieldId);
        },
        routes: [
          GoRoute(
            path: 'schedule',
            builder: (context, state) {
              final zoneId = state.uri.queryParameters['zoneId'];
              return IrrigationScheduleScreen(zoneId: zoneId);
            },
          ),
          GoRoute(
            path: 'zone/:id',
            builder: (context, state) => IrrigationZoneDetailScreen(
              zoneId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      // Soil
      GoRoute(
        path: '/soil',
        builder: (context, state) {
          final fieldId =
              state.uri.queryParameters['fieldId'] ?? 'default';
          return SoilDashboardScreen(fieldId: fieldId);
        },
        routes: [
          GoRoute(
            path: ':fieldId',
            builder: (context, state) => SoilDetailScreen(
              fieldId: state.pathParameters['fieldId']!,
            ),
          ),
        ],
      ),

      // Yield
      GoRoute(
        path: '/yield',
        builder: (context, state) => const YieldDashboardScreen(),
        routes: [
          GoRoute(
            path: ':fieldId',
            builder: (context, state) {
              final prediction = state.extra as YieldPrediction;
              return YieldDetailScreen(prediction: prediction);
            },
          ),
        ],
      ),

      // Pest Risk
      GoRoute(
        path: '/pest-risk',
        builder: (context, state) {
          final fieldId = state.uri.queryParameters['fieldId'];
          return PestRiskMapScreen(fieldId: fieldId);
        },
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final alert = state.extra as PestAlert;
              return PestAlertDetailScreen(alert: alert);
            },
          ),
        ],
      ),

      // Observations
      GoRoute(
        path: '/observations',
        builder: (context, state) {
          final fieldId = state.uri.queryParameters['fieldId'];
          return ObservationListScreen(fieldId: fieldId);
        },
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) {
              final fieldId =
                  state.uri.queryParameters['fieldId'] ?? '';
              return ObservationEditorScreen(fieldId: fieldId);
            },
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final observation = state.extra as FieldObservation;
              return ObservationDetailScreen(observation: observation);
            },
          ),
        ],
      ),

      // GPS Tracking
      GoRoute(
        path: '/tracking',
        builder: (context, state) {
          final fieldId =
              state.uri.queryParameters['fieldId'] ?? 'default';
          return TrackingScreen(fieldId: fieldId);
        },
        routes: [
          GoRoute(
            path: 'history',
            builder: (context, state) => const TrackHistoryScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => TrackDetailScreen(
              trackId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      // Drone
      GoRoute(
        path: '/drone',
        builder: (context, state) {
          final fieldId = state.uri.queryParameters['fieldId'];
          return DroneViewerScreen(fieldId: fieldId);
        },
      ),

      // Crop Recommendations
      GoRoute(
        path: '/crop-recommendations',
        builder: (context, state) {
          final fieldId = state.uri.queryParameters['fieldId'];
          return CropRecommendationScreen(fieldId: fieldId);
        },
      ),

      // Traceability
      GoRoute(
        path: '/traceability',
        builder: (context, state) => const TraceabilityScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final record = state.extra as ProduceRecord;
              return ProduceDetailScreen(record: record);
            },
          ),
        ],
      ),

      // Alerts
      GoRoute(
        path: '/alerts',
        builder: (context, state) {
          context.read<AlertBloc>().add(const LoadAlerts());
          return const AlertListScreen();
        },
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => AlertDetailScreen(
              alertId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
});
