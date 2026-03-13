import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/main_screen.dart';

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
              child: _PlaceholderScreen(title: 'Dashboard'),
            ),
          ),
          GoRoute(
            path: '/fields',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen(title: 'Fields'),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => _PlaceholderScreen(
                  title: 'Field ${state.pathParameters['id']}',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/advisory',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen(title: 'Crop Advisory'),
            ),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen(title: 'Analytics'),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen(title: 'Profile'),
            ),
          ),
        ],
      ),

      // ─── Full-screen routes (no bottom nav) ──────────────────────

      // Farms
      GoRoute(
        path: '/farms',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Farms'),
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

      // Soil Analysis
      GoRoute(
        path: '/soil-analysis/:fieldId',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Soil Analysis ${state.pathParameters['fieldId']}',
        ),
      ),

      // Satellite Monitoring
      GoRoute(
        path: '/satellite/:fieldId',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Satellite ${state.pathParameters['fieldId']}',
        ),
        routes: [
          GoRoute(
            path: 'history',
            builder: (context, state) => _PlaceholderScreen(
              title: 'Satellite History ${state.pathParameters['fieldId']}',
            ),
          ),
        ],
      ),

      // Plant Diagnosis
      GoRoute(
        path: '/diagnosis/new',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'New Diagnosis'),
      ),
      GoRoute(
        path: '/diagnosis/history',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Diagnosis History'),
      ),
      GoRoute(
        path: '/diagnosis/:id',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Diagnosis ${state.pathParameters['id']}',
        ),
      ),

      // Pest Risk
      GoRoute(
        path: '/pest-risk/:fieldId',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Pest Risk ${state.pathParameters['fieldId']}',
        ),
      ),

      // Irrigation
      GoRoute(
        path: '/irrigation/:fieldId',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Irrigation ${state.pathParameters['fieldId']}',
        ),
        routes: [
          GoRoute(
            path: 'schedule',
            builder: (context, state) => _PlaceholderScreen(
              title: 'Irrigation Schedule ${state.pathParameters['fieldId']}',
            ),
          ),
        ],
      ),

      // Yield Forecast
      GoRoute(
        path: '/yield-forecast/:fieldId',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Yield Forecast ${state.pathParameters['fieldId']}',
        ),
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

      // Field Inspections
      GoRoute(
        path: '/inspections',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Field Inspections'),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'New Inspection'),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => _PlaceholderScreen(
              title: 'Inspection ${state.pathParameters['id']}',
            ),
          ),
        ],
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Notifications'),
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
