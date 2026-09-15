import 'dart:convert';

/// Something a person did, or something the app did on their behalf.
class AnalyticsEvent {
  AnalyticsEvent({
    required this.name,
    Map<String, Object?> properties = const {},
    DateTime? occurredAt,
  })  : properties = Map.unmodifiable(properties),
        occurredAt = occurredAt ?? DateTime.now().toUtc();

  /// `snake_case`, past tense: `diagnosis_submitted`, `boundary_walked`.
  final String name;

  final Map<String, Object?> properties;

  /// When it happened, not when it was sent.
  ///
  /// The two differ by however long the phone was out of signal, which in this
  /// product is routinely hours. Without this, every event a farmer generated
  /// in a field would carry the timestamp of their drive home, and any
  /// question about when work happens in the day would be answered wrongly.
  final DateTime occurredAt;

  Map<String, dynamic> toJson() => {
        'name': name,
        'properties': properties,
        'occurred_at': occurredAt.toIso8601String(),
      };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      name: json['name'] as String,
      properties:
          (json['properties'] as Map?)?.cast<String, Object?>() ?? const {},
      occurredAt: DateTime.parse(json['occurred_at'] as String).toUtc(),
    );
  }

  /// Encoded for the offline buffer.
  String encode() => jsonEncode(toJson());

  static AnalyticsEvent decode(String raw) =>
      AnalyticsEvent.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  @override
  String toString() => 'AnalyticsEvent($name, $properties)';
}

/// A screen the user opened.
class ScreenView {
  ScreenView({required this.name, DateTime? occurredAt})
      : occurredAt = occurredAt ?? DateTime.now().toUtc();

  /// The route name, e.g. `/diagnosis`, with path parameters left out.
  final String name;
  final DateTime occurredAt;

  AnalyticsEvent toEvent() => AnalyticsEvent(
        name: 'screen_viewed',
        properties: {'screen': name},
        occurredAt: occurredAt,
      );
}

/// What the user has agreed to.
///
/// Analytics is off until someone says otherwise. That is the requirement
/// under the DPDP Act and the GDPR, and it is also the only defensible default
/// for an app whose users did not choose to be measured.
enum AnalyticsConsent {
  /// No decision yet. Events are dropped, not buffered: holding data from
  /// someone who has not agreed, in the hope they will, is the thing consent
  /// rules exist to prevent.
  unknown,

  /// Agreed. Events are collected and sent.
  granted,

  /// Declined. Events are dropped and the buffer is emptied.
  denied,
}
