import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/alerts/presentation/widgets/alert_badge.dart';

/// Main scaffold with bottom navigation bar.
///
/// This is the shell that wraps all top-level tab routes. The [child]
/// parameter comes from [ShellRoute] and represents the current tab content.
class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YieldPoint'),
        actions: [
          AlertBadge(
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/alerts'),
              tooltip: 'Alerts',
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (index) => _onTabSelected(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.satellite_alt_outlined),
            selectedIcon: Icon(Icons.satellite_alt),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_camera_outlined),
            selectedIcon: Icon(Icons.photo_camera),
            label: 'Diagnosis',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/farms')) return 0;
    if (location.startsWith('/satellite')) return 1;
    if (location.startsWith('/diagnosis')) return 2;
    if (location.startsWith('/tasks')) return 3;
    return 4;
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/farms');
      case 1:
        context.go('/satellite');
      case 2:
        context.go('/diagnosis');
      case 3:
        context.go('/tasks');
      case 4:
        _showMoreMenu(context);
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                _MoreMenuItem(
                  icon: Icons.sensors,
                  label: 'Sensors',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/sensors');
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.water_drop_outlined,
                  label: 'Irrigation',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/irrigation');
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.landscape_outlined,
                  label: 'Soil Analysis',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/soil');
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.bar_chart,
                  label: 'Yield Prediction',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/yield');
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.bug_report_outlined,
                  label: 'Pest Risk',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/pest-risk');
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.visibility_outlined,
                  label: 'Observations',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/observations');
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.route,
                  label: 'GPS Tracking',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/tracking');
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.flight,
                  label: 'Drone Imagery',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/drone');
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.agriculture,
                  label: 'Crop Recommendations',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/crop-recommendations');
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.qr_code,
                  label: 'Traceability',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/traceability');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  const _MoreMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
