import 'package:flutter/widgets.dart';
import 'package:flutter_analytics/flutter_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A provider that records what it was asked to send, and can be made to fail.
///
/// Failing is the case that matters: it is what being out of signal looks
/// like, which for this product is most of the time.
class _FakeProvider implements AnalyticsProvider {
  bool failSends = false;
  final List<List<AnalyticsEvent>> batches = [];
  final List<String> identified = [];
  int resets = 0;
  int initialisations = 0;

  List<AnalyticsEvent> get sent => batches.expand((b) => b).toList();

  @override
  String get name => 'fake';

  @override
  Future<void> initialize() async => initialisations++;

  @override
  Future<void> send(List<AnalyticsEvent> events) async {
    if (failSends) throw StateError('no network');
    batches.add(List.of(events));
  }

  @override
  Future<void> identify(String userId,
      {Map<String, Object?> traits = const {}}) async {
    identified.add(userId);
  }

  @override
  Future<void> reset() async => resets++;
}

Future<Analytics> _analytics(
  _FakeProvider provider, {
  AnalyticsConsent consent = AnalyticsConsent.granted,
  int maxBufferedEvents = 500,
  int batchSize = 50,
}) async {
  SharedPreferences.setMockInitialValues({});
  final a = Analytics(
    provider: provider,
    preferences: await SharedPreferences.getInstance(),
    maxBufferedEvents: maxBufferedEvents,
    batchSize: batchSize,
  );
  await a.initialize();
  await a.setConsent(consent);
  return a;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('consent', () {
    test('records nothing before consent is given', () async {
      final provider = _FakeProvider();
      final a = await _analytics(provider, consent: AnalyticsConsent.unknown);

      await a.track('diagnosis_submitted');
      await a.flush();

      expect(a.isEnabled, isFalse);
      expect(provider.sent, isEmpty);
      expect(
        a.bufferedCount,
        0,
        reason: 'holding events from someone who has not agreed, in the hope '
            'that they will, is what consent rules exist to prevent',
      );
    });

    test('records nothing after consent is refused', () async {
      final provider = _FakeProvider();
      final a = await _analytics(provider, consent: AnalyticsConsent.denied);

      await a.track('diagnosis_submitted');

      expect(provider.sent, isEmpty);
      expect(a.bufferedCount, 0);
    });

    test('withdrawing consent discards what was already buffered', () async {
      final provider = _FakeProvider()..failSends = true;
      final a = await _analytics(provider);

      await a.track('diagnosis_submitted');
      expect(a.bufferedCount, 1);

      await a.setConsent(AnalyticsConsent.denied);

      expect(a.bufferedCount, 0, reason: 'no means no, retrospectively');
      expect(provider.resets, greaterThan(0));
    });

    test('granting consent flushes what arrives afterwards', () async {
      final provider = _FakeProvider();
      final a = await _analytics(provider);

      await a.track('boundary_walked');
      await a.flush();

      expect(provider.sent.map((e) => e.name), ['boundary_walked']);
    });

    test('consent survives a restart', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final first = Analytics(provider: _FakeProvider(), preferences: prefs);
      await first.initialize();
      await first.setConsent(AnalyticsConsent.granted);

      final second = Analytics(provider: _FakeProvider(), preferences: prefs);
      await second.initialize();

      expect(second.consent, AnalyticsConsent.granted);
    });
  });

  group('offline buffering', () {
    test('keeps events when the provider cannot send', () async {
      final provider = _FakeProvider()..failSends = true;
      final a = await _analytics(provider);

      await a.track('diagnosis_submitted');
      await a.track('boundary_walked');
      await a.flush();

      expect(provider.sent, isEmpty);
      expect(
        a.bufferedCount,
        2,
        reason: 'an analytics layer that drops events offline reports that '
            'nobody uses the app in a field, which is the only place it is used',
      );
    });

    test('sends the backlog once the network returns', () async {
      final provider = _FakeProvider()..failSends = true;
      final a = await _analytics(provider);

      await a.track('diagnosis_submitted');
      await a.track('boundary_walked');
      await a.flush();

      provider.failSends = false;
      await a.flush();

      expect(provider.sent.map((e) => e.name),
          ['diagnosis_submitted', 'boundary_walked']);
      expect(a.bufferedCount, 0);
    });

    test('keeps the order events happened in', () async {
      final provider = _FakeProvider()..failSends = true;
      final a = await _analytics(provider);

      for (var i = 0; i < 5; i++) {
        await a.track('step_$i');
      }
      provider.failSends = false;
      await a.flush();

      expect(
        provider.sent.map((e) => e.name),
        ['step_0', 'step_1', 'step_2', 'step_3', 'step_4'],
      );
    });

    test('the buffer survives a restart', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final offline = _FakeProvider()..failSends = true;
      final first = Analytics(provider: offline, preferences: prefs);
      await first.initialize();
      await first.setConsent(AnalyticsConsent.granted);
      await first.track('inspection_filed');
      await first.flush();
      expect(first.bufferedCount, 1);

      // The app is closed on the way back from the field and opened at home.
      final online = _FakeProvider();
      final second = Analytics(provider: online, preferences: prefs);
      await second.initialize();
      await second.flush();

      expect(online.sent.map((e) => e.name), ['inspection_filed']);
    });

    test('drops the oldest events rather than growing without bound', () async {
      final provider = _FakeProvider()..failSends = true;
      final a = await _analytics(provider, maxBufferedEvents: 3, batchSize: 100);

      for (var i = 0; i < 6; i++) {
        await a.track('step_$i');
      }

      expect(a.bufferedCount, 3);

      provider.failSends = false;
      await a.flush();

      expect(
        provider.sent.map((e) => e.name),
        ['step_3', 'step_4', 'step_5'],
        reason: 'a week-old tap is worth less than this morning\'s',
      );
    });

    test('sends in batches', () async {
      final provider = _FakeProvider()..failSends = true;
      final a = await _analytics(provider, batchSize: 2, maxBufferedEvents: 100);

      for (var i = 0; i < 5; i++) {
        await a.track('step_$i');
      }
      provider.failSends = false;
      await a.flush();

      expect(provider.batches.map((b) => b.length), [2, 2, 1]);
    });
  });

  group('event timestamps', () {
    test('an event carries when it happened, not when it was sent', () async {
      final provider = _FakeProvider()..failSends = true;
      final a = await _analytics(provider);

      final when = DateTime.utc(2026, 3, 14, 6, 15);
      await a.record(AnalyticsEvent(name: 'boundary_walked', occurredAt: when));

      provider.failSends = false;
      await a.flush();

      expect(
        provider.sent.single.occurredAt,
        when,
        reason: 'otherwise every event raised in a field carries the timestamp '
            'of the drive home, and any question about when work happens in '
            'the day is answered wrongly',
      );
    });

    test('an event survives the encode/decode the buffer puts it through',
        () async {
      final event = AnalyticsEvent(
        name: 'diagnosis_submitted',
        properties: {'crop': 'cotton', 'images': 2, 'offline': true},
        occurredAt: DateTime.utc(2026, 3, 14, 6, 15),
      );

      final back = AnalyticsEvent.decode(event.encode());

      expect(back.name, event.name);
      expect(back.properties, event.properties);
      expect(back.occurredAt, event.occurredAt);
    });
  });

  group('failure containment', () {
    test('a provider that throws on identify does not break the caller',
        () async {
      // Rule: measurement must never be able to break the app.
      final provider = _ThrowingProvider();
      final a = await _analytics(_FakeProvider());
      final b = Analytics(provider: provider);

      await expectLater(a.identify('user-1'), completes);
      await expectLater(b.reset(), completes);
    });

    test('a corrupt buffered row is skipped, not thrown at startup', () async {
      // A row written by an older version of the app must not be able to stop
      // the app launching.
      SharedPreferences.setMockInitialValues({
        'analytics_consent': 'granted',
        'analytics_buffer': ['{not json', '{"name":"ok","occurred_at":"2026-03-14T06:15:00Z"}'],
      });

      final provider = _FakeProvider();
      final a = Analytics(
        provider: provider,
        preferences: await SharedPreferences.getInstance(),
      );
      await a.initialize();
      await a.flush();

      expect(provider.sent.map((e) => e.name), ['ok']);
    });
  });

  group('ScreenViewObserver', () {
    Route<dynamic> route(String? name) =>
        PageRouteBuilder<void>(
          settings: RouteSettings(name: name),
          pageBuilder: (_, __, ___) => const SizedBox.shrink(),
        );

    test('replaces identifiers with :id', () {
      // Otherwise every farm is its own screen in the numbers, the list is
      // unreadable, and each row carries an id that has no business in a
      // third-party analytics account.
      expect(
        ScreenViewObserver.screenNameOf(
          route('/farms/01HQ8Z3K9M/fields/01HQ8Z4P2N'),
        ),
        '/farms/:id/fields/:id',
      );
    });

    test('leaves ordinary path segments alone', () {
      expect(
        ScreenViewObserver.screenNameOf(route('/diagnosis/history')),
        '/diagnosis/history',
      );
    });

    test('ignores an unnamed route', () {
      expect(ScreenViewObserver.screenNameOf(route(null)), isNull);
      expect(ScreenViewObserver.screenNameOf(route('')), isNull);
    });
  });
}

class _ThrowingProvider implements AnalyticsProvider {
  @override
  String get name => 'throwing';

  @override
  Future<void> initialize() async => throw StateError('nope');

  @override
  Future<void> send(List<AnalyticsEvent> events) async =>
      throw StateError('nope');

  @override
  Future<void> identify(String userId,
          {Map<String, Object?> traits = const {}}) async =>
      throw StateError('nope');

  @override
  Future<void> reset() async => throw StateError('nope');
}
