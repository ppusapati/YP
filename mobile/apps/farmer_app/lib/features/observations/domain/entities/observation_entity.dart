import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// Category of a field observation.
enum ObservationCategory {
  pest,
  disease,
  weed,
  growth,
  soil,
  water,
  weather,
  wildlife,
  equipment,
  other;

  String get label => switch (this) {
        pest => 'Pest',
        disease => 'Disease',
        weed => 'Weed',
        growth => 'Growth',
        soil => 'Soil',
        water => 'Water',
        weather => 'Weather',
        wildlife => 'Wildlife',
        equipment => 'Equipment',
        other => 'Other',
      };
}

/// Snapshot of weather conditions at the time of observation.
class WeatherCondition extends Equatable {
  const WeatherCondition({
    required this.temperature,
    required this.humidity,
    this.windSpeed,
    this.description,
  });

  /// Temperature in Celsius.
  final double temperature;

  /// Relative humidity percentage.
  final double humidity;

  /// Wind speed in m/s.
  final double? windSpeed;

  /// Brief weather description (e.g., "Partly Cloudy").
  final String? description;

  @override
  List<Object?> get props => [temperature, humidity, windSpeed, description];
}

/// A geo-tagged observation recorded in the field.
class FieldObservation extends Equatable {
  const FieldObservation({
    required this.id,
    required this.fieldId,
    required this.location,
    required this.photos,
    required this.notes,
    required this.timestamp,
    required this.category,
    this.weather,
  });

  final String id;
  final String fieldId;
  final LatLng location;

  /// URLs or local file paths of attached photos.
  final List<String> photos;

  final String notes;
  final DateTime timestamp;
  final ObservationCategory category;
  final WeatherCondition? weather;

  FieldObservation copyWith({
    String? id,
    String? fieldId,
    LatLng? location,
    List<String>? photos,
    String? notes,
    DateTime? timestamp,
    ObservationCategory? category,
    WeatherCondition? weather,
  }) {
    return FieldObservation(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      location: location ?? this.location,
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      weather: weather ?? this.weather,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fieldId,
        location,
        photos,
        notes,
        timestamp,
        category,
        weather,
      ];
}
