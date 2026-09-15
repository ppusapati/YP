import 'package:logging/logging.dart';

import 'analytics_event.dart';

/// Where events actually go.
///
/// The core depends on this interface and on nothing else, so Firebase,
/// PostHog or a first-party endpoint plug in without the apps taking a
/// dependency on any of them. That matters more than usual here: the choice of
/// analytics vendor is a data-residency decision, and Indian agricultural data
/// is subject to rules that may rule out whichever one is convenient today.
abstract class AnalyticsProvider {
  /// Name, for logs and for the registry.
  String get name;

  /// Called once before any events are sent.
  Future<void> initialize();

  /// Sends a batch.
  ///
  /// A batch rather than one event at a time, because the buffer flushes what
  /// accumulated while the phone was out of signal, and that can be hundreds.
  ///
  /// Throwing means "not delivered": the caller keeps the batch and retries.
  /// Returning normally means the events are the provider's problem now.
  Future<void> send(List<AnalyticsEvent> events);

  /// Associates subsequent events with a user.
  ///
  /// [userId] is an opaque id, never an email or a phone number.
  Future<void> identify(String userId, {Map<String, Object?> traits = const {}});

  /// Forgets the current user, on sign-out.
  Future<void> reset();
}

/// Accepts everything and does nothing.
///
/// The default, so an app with no analytics vendor configured still runs every
/// call path — consent, buffering, flushing — rather than taking a different
/// branch in production from the one under test.
class NoopAnalyticsProvider implements AnalyticsProvider {
  const NoopAnalyticsProvider();

  @override
  String get name => 'noop';

  @override
  Future<void> initialize() async {}

  @override
  Future<void> send(List<AnalyticsEvent> events) async {}

  @override
  Future<void> identify(String userId,
      {Map<String, Object?> traits = const {}}) async {}

  @override
  Future<void> reset() async {}
}

/// Logs events instead of sending them.
///
/// For development, and for answering "is anything being recorded at all?"
/// without standing up a vendor account.
class LoggingAnalyticsProvider implements AnalyticsProvider {
  LoggingAnalyticsProvider({Logger? logger})
      : _log = logger ?? Logger('Analytics');

  final Logger _log;

  @override
  String get name => 'logging';

  @override
  Future<void> initialize() async => _log.info('analytics: logging provider');

  @override
  Future<void> send(List<AnalyticsEvent> events) async {
    for (final event in events) {
      _log.info('analytics: ${event.name} ${event.properties}');
    }
  }

  @override
  Future<void> identify(String userId,
      {Map<String, Object?> traits = const {}}) async {
    _log.info('analytics: identify $userId');
  }

  @override
  Future<void> reset() async => _log.info('analytics: reset');
}
