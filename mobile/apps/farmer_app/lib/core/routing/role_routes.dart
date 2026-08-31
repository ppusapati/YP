import '../auth/user_role.dart';

/// Defines which top-level route paths each role can access.
///
/// Routes not listed here are considered shared and accessible by all roles.
class RoleRoutes {
  RoleRoutes._();

  /// Routes only the farmer role can navigate to.
  static const farmerOnly = <String>{
    '/tracking',
    '/drone',
    '/crop-recommendations',
    '/traceability',
    '/yield',
    '/observations',
  };

  /// Routes only the agronomist role can navigate to.
  static const agronomistOnly = <String>{
    '/dashboard',
    '/inspections',
    '/advisory',
    '/profile',
  };

  /// Routes accessible to both roles.
  static const shared = <String>{
    '/farms',
    '/satellite',
    '/diagnosis',
    '/tasks',
    '/sensors',
    '/irrigation',
    '/soil',
    '/pest-risk',
    '/alerts',
    '/analytics',
    '/prescriptions',
  };

  /// Returns true if the given [path] is accessible by [role].
  static bool canAccess(UserRole role, String path) {
    // Extract the top-level segment (e.g. '/farms/123' -> '/farms').
    final topLevel = '/${path.split('/').where((s) => s.isNotEmpty).firstOrNull ?? ''}';

    switch (role) {
      case UserRole.farmer:
        return !agronomistOnly.contains(topLevel);
      case UserRole.agronomist:
        return !farmerOnly.contains(topLevel);
    }
  }
}
