import 'dart:async';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_event.dart';
import 'analytics_provider.dart';

/// Product analytics for an app used where there is no signal.
///
/// The thing this gets right that a thin vendor SDK wrapper does not: events
/// raised offline are kept and sent later. A farmer walks a field boundary,
/// photographs a leaf and files an inspection with no bars on the phone, and
/// an analytics layer that drops those would report that nobody uses the app
/// in a field — which is the only place it is used. The buffer is the feature.
///
/// Three rules, in this order:
///
///   1. **Consent first.** Nothing is recorded until consent is granted, and
///      nothing is held while it is undecided. Buffering events from someone
///      who has not agreed, in the hope that they will, is exactly what
///      consent rules exist to stop.
///   2. **Never lose the user's work to analytics.** Every send failure is
///      swallowed and retried later. An app that crashes, blocks or shows an
///      error because a measurement endpoint is down has its priorities
///      backwards.
///   3. **Bounded.** The buffer has a hard cap. A phone offline for a week
///      must not fill its storage with telemetry.
class Analytics {
  Analytics({
    AnalyticsProvider provider = const NoopAnalyticsProvider(),
    SharedPreferences? preferences,
    this.maxBufferedEvents = 500,
    this.batchSize = 50,
    Logger? logger,
  })  : _provider = provider,
        _prefs = preferences,
        _log = logger ?? Logger('Analytics');

  static const _consentKey = 'analytics_consent';
  static const _bufferKey = 'analytics_buffer';

  final AnalyticsProvider _provider;
  final Logger _log;

  /// Where consent and the buffer survive a restart.
  ///
  /// Optional: without it the buffer is in memory only, which is the right
  /// behaviour in a test and a survivable one in an app that has not finished
  /// starting up.
  SharedPreferences? _prefs;

  /// Hard cap on buffered events. Oldest are dropped first — a week-old tap is
  /// worth less than this morning's, and something has to give.
  final int maxBufferedEvents;

  /// How many events go to the provider per call.
  final int batchSize;

  final List<AnalyticsEvent> _buffer = [];
  AnalyticsConsent _consent = AnalyticsConsent.unknown;
  bool _initialized = false;
  Future<void>? _inFlight;
  String? _userId;

  /// The current consent state.
  AnalyticsConsent get consent => _consent;

  /// Whether events are being recorded.
  bool get isEnabled => _consent == AnalyticsConsent.granted;

  /// How many events are waiting to be sent.
  int get bufferedCount => _buffer.length;

  /// Loads stored consent and any buffered events, then initialises the
  /// provider.
  ///
  /// Safe to call twice; the second call does nothing.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _prefs ??= await SharedPreferences.getInstance();
    _consent = _readConsent();
    _buffer.addAll(_readBuffer());

    await _provider.initialize();

    // Whatever survived the last session goes out now, if it may.
    unawaited(flush());
  }

  /// Records the user's decision.
  ///
  /// Granting flushes whatever was collected since consent was granted
  /// previously; denying empties the buffer, because holding events from
  /// someone who has just said no is worse than never collecting them.
  Future<void> setConsent(AnalyticsConsent consent) async {
    _consent = consent;
    await _prefs?.setString(_consentKey, consent.name);

    if (consent == AnalyticsConsent.granted) {
      await flush();
    } else {
      _buffer.clear();
      await _persistBuffer();
      await _provider.reset();
      _userId = null;
    }
  }

  /// Associates subsequent events with a user.
  Future<void> identify(String userId,
      {Map<String, Object?> traits = const {}}) async {
    _userId = userId;
    if (!isEnabled) return;
    await _guard(() => _provider.identify(userId, traits: traits));
  }

  /// Forgets the user, on sign-out.
  Future<void> reset() async {
    _userId = null;
    await _guard(_provider.reset);
  }

  /// Records an event.
  ///
  /// Returns as soon as the event is buffered; delivery happens later and
  /// never blocks the caller. A tap that waits for a network round trip is a
  /// tap the user feels.
  Future<void> track(String name,
      {Map<String, Object?> properties = const {}}) async {
    await record(AnalyticsEvent(name: name, properties: properties));
  }

  /// Records a screen view.
  Future<void> trackScreen(String screenName) async {
    await record(ScreenView(name: screenName).toEvent());
  }

  /// Records a pre-built event, keeping its original timestamp.
  Future<void> record(AnalyticsEvent event) async {
    if (!isEnabled) return;

    _buffer.add(event);

    if (_buffer.length > maxBufferedEvents) {
      final overflow = _buffer.length - maxBufferedEvents;
      _buffer.removeRange(0, overflow);
      _log.fine('analytics buffer full; dropped $overflow oldest events');
    }

    await _persistBuffer();

    if (_buffer.length >= batchSize) {
      unawaited(flush());
    }
  }

  /// Sends everything buffered, oldest first.
  ///
  /// A failure leaves the batch in the buffer for the next attempt, which is
  /// what makes the offline case work: the phone comes back into signal, the
  /// next event or the next start triggers a flush, and the backlog goes.
  ///
  /// Only one flush runs at a time — two concurrent passes would send the
  /// same batch twice — but a caller who asks while one is running waits for
  /// it and then gets a pass of their own. Returning early instead, which is
  /// the obvious way to write this, means a flush triggered by [record]
  /// silently swallows a later explicit `flush()`: the caller is told the
  /// buffer was sent when their events are still in it.
  Future<void> flush() async {
    final running = _inFlight;
    if (running != null) {
      await running;
      // Fall through: whatever arrived during that pass is still ours to send.
    }

    if (!isEnabled || _buffer.isEmpty) return;

    final pass = _flushOnce();
    _inFlight = pass;
    try {
      await pass;
    } finally {
      if (identical(_inFlight, pass)) _inFlight = null;
    }
  }

  Future<void> _flushOnce() async {
    while (_buffer.isNotEmpty) {
      final batch = _buffer.take(batchSize).toList();
      try {
        await _provider.send(batch);
      } catch (e) {
        // Kept, not dropped. This is the ordinary case out of signal, so it is
        // logged at fine rather than as a warning — a log full of "analytics
        // failed" teaches people to ignore the log.
        _log.fine('analytics flush failed, ${_buffer.length} held: $e');
        return;
      }
      _buffer.removeRange(0, batch.length);
      await _persistBuffer();
    }
  }

  /// Re-sends the user id after a provider was replaced or reset externally.
  Future<void> reidentify() async {
    final id = _userId;
    if (id == null || !isEnabled) return;
    await _guard(() => _provider.identify(id));
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  /// Runs a provider call, swallowing whatever it throws.
  ///
  /// Rule 2: measurement must never be able to break the app.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      _log.fine('analytics provider call failed: $e');
    }
  }

  AnalyticsConsent _readConsent() {
    final stored = _prefs?.getString(_consentKey);
    return AnalyticsConsent.values.firstWhere(
      (c) => c.name == stored,
      orElse: () => AnalyticsConsent.unknown,
    );
  }

  List<AnalyticsEvent> _readBuffer() {
    final raw = _prefs?.getStringList(_bufferKey) ?? const [];
    final out = <AnalyticsEvent>[];
    for (final line in raw) {
      try {
        out.add(AnalyticsEvent.decode(line));
      } catch (_) {
        // A row written by an older version of the app. Skipped rather than
        // allowed to throw during startup, which would make a malformed
        // analytics row a failure to launch.
      }
    }
    return out;
  }

  Future<void> _persistBuffer() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setStringList(
      _bufferKey,
      _buffer.map((e) => e.encode()).toList(),
    );
  }
}
