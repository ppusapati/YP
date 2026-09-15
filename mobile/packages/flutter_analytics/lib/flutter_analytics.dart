/// Product analytics for the YieldPoint apps.
///
/// Provider-agnostic, consent-gated and offline-buffered — in that order of
/// importance. The apps depend on this package; this package depends on no
/// analytics vendor, so the choice of one stays a configuration decision
/// rather than a rewrite.
library flutter_analytics;

export 'src/analytics.dart';
export 'src/analytics_event.dart';
export 'src/analytics_provider.dart';
export 'src/screen_view_observer.dart';
