import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/main_screen.dart';
import '../../features/alerts/presentation/bloc/alert_bloc.dart';
import '../../features/alerts/presentation/bloc/alert_event.dart';
import '../../features/alerts/presentation/screens/alert_detail_screen.dart';
import '../../features/alerts/presentation/screens/alert_list_screen.dart';
import '../../features/crop_recommendation/presentation/screens/crop_recommendation_screen.dart';
import '../../features/drone/presentation/screens/drone_viewer_screen.dart';
import '../../features/gps_tracking/presentation/screens/track_detail_screen.dart';
import '../../features/gps_tracking/presentation/screens/track_history_screen.dart';
import '../../features/gps_tracking/presentation/screens/tracking_screen.dart';

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
              child: _PlaceholderScreen(title: 'Farms'),
            ),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Create Farm'),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => _PlaceholderScreen(
                  title: 'Farm ${state.pathParameters['id']}',
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => _PlaceholderScreen(
                      title: 'Edit Farm ${state.pathParameters['id']}',
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/satellite',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen(title: 'Satellite'),
            ),
            routes: [
              GoRoute(
                path: 'health',
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Crop Health'),
              ),
            ],
          ),
          GoRoute(
            path: '/diagnosis',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen(title: 'Diagnosis'),
            ),
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Diagnosis History'),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => _PlaceholderScreen(
                  title: 'Diagnosis ${state.pathParameters['id']}',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/tasks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen(title: 'Tasks'),
            ),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Create Task'),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => _PlaceholderScreen(
                  title: 'Task ${state.pathParameters['id']}',
                ),
              ),
            ],
          ),
        ],
      ),

      // ─── Full-screen routes (no bottom nav) ──────────────────────

      // Sensors
      GoRoute(
        path: '/sensors',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Sensors'),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => _PlaceholderScreen(
              title: 'Sensor ${state.pathParameters['id']}',
            ),
          ),
        ],
      ),

      // Irrigation
      GoRoute(
        path: '/irrigation',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Irrigation'),
        routes: [
          GoRoute(
            path: 'schedule',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Irrigation Schedule'),
          ),
          GoRoute(
            path: 'zone/:id',
            builder: (context, state) => _PlaceholderScreen(
              title: 'Zone ${state.pathParameters['id']}',
            ),
          ),
        ],
      ),

      // Soil
      GoRoute(
        path: '/soil',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Soil'),
        routes: [
          GoRoute(
            path: ':fieldId',
            builder: (context, state) => _PlaceholderScreen(
              title: 'Soil ${state.pathParameters['fieldId']}',
            ),
          ),
        ],
      ),

      // Yield
      GoRoute(
        path: '/yield',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Yield Prediction'),
        routes: [
          GoRoute(
            path: ':fieldId',
            builder: (context, state) => _PlaceholderScreen(
              title: 'Yield ${state.pathParameters['fieldId']}',
            ),
          ),
        ],
      ),

      // Pest Risk
      GoRoute(
        path: '/pest-risk',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Pest Risk'),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => _PlaceholderScreen(
              title: 'Pest Risk ${state.pathParameters['id']}',
            ),
          ),
        ],
      ),

      // Observations
      GoRoute(
        path: '/observations',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Observations'),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'New Observation'),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => _PlaceholderScreen(
              title: 'Observation ${state.pathParameters['id']}',
            ),
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
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Traceability'),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => _PlaceholderScreen(
              title: 'Trace ${state.pathParameters['id']}',
            ),
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

/// Placeholder screen for routes not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
