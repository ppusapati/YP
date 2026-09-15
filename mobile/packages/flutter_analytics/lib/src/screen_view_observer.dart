import 'package:flutter/widgets.dart';

import 'analytics.dart';

/// Records a screen view for every route the user opens.
///
/// A `NavigatorObserver` rather than a call in each screen's `initState`,
/// because the second is a line sixty screens have to remember and the ones
/// that forget are invisible — they simply never appear in the numbers, which
/// reads as a feature nobody uses.
///
/// Wire it into the router:
/// ```dart
/// GoRouter(observers: [ScreenViewObserver(analytics)], ...)
/// ```
class ScreenViewObserver extends NavigatorObserver {
  ScreenViewObserver(this._analytics);

  final Analytics _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _record(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // The screen being returned to is the one now on screen.
    if (previousRoute != null) _record(previousRoute);
    super.didPop(route, previousRoute);
  }

  void _record(Route<dynamic> route) {
    final name = screenNameOf(route);
    if (name == null) return;
    _analytics.trackScreen(name);
  }

  /// The route's name with path parameters stripped.
  ///
  /// `/farms/018f2c.../fields/018f3a...` becomes `/farms/:id/fields/:id`.
  /// Without this every farm is its own screen in the numbers, the list is
  /// unreadable, and each row carries an identifier that has no business in a
  /// third-party analytics account.
  @visibleForTesting
  static String? screenNameOf(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return null;

    return name
        .split('/')
        .map((segment) => _looksLikeAnId(segment) ? ':id' : segment)
        .join('/');
  }

  static bool _looksLikeAnId(String segment) {
    if (segment.length < 8) return false;
    // ULIDs and UUIDs, which is what every id in this platform is. A short
    // word like `fields` is left alone; anything long and made only of
    // identifier characters is not a route name someone wrote by hand.
    return RegExp(r'^[0-9a-zA-Z_-]+$').hasMatch(segment) &&
        RegExp(r'[0-9]').hasMatch(segment);
  }
}
