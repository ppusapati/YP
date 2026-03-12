import 'package:latlong2/latlong.dart';

import '../../domain/entities/observation_entity.dart';

/// Data transfer model for [FieldObservation].
class ObservationModel extends FieldObservation {
  const ObservationModel({
    required super.id,
    required super.fieldId,
    required super.location,
    required super.photos,
    required super.notes,
    required super.timestamp,
    required super.category,
    super.weather,
  });

  factory ObservationModel.fromJson(Map<String, dynamic> json) {
    return ObservationModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      location: LatLng(
        (json['location']['lat'] as num).toDouble(),
        (json['location']['lng'] as num).toDouble(),
      ),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notes: json['notes'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      category: _parseCategory(json['category'] as String),
      weather: json['weather'] != null
          ? WeatherConditionModel.fromJson(
              json['weather'] as Map<String, dynamic>)
          : null,
    );
  }

  factory ObservationModel.fromEntity(FieldObservation entity) {
    return ObservationModel(
      id: entity.id,
      fieldId: entity.fieldId,
      location: entity.location,
      photos: entity.photos,
      notes: entity.notes,
      timestamp: entity.timestamp,
      category: entity.category,
      weather: entity.weather,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'field_id': fieldId,
        'location': {
          'lat': location.latitude,
          'lng': location.longitude,
        },
        'photos': photos,
        'notes': notes,
        'timestamp': timestamp.toIso8601String(),
        'category': category.name,
        if (weather != null)
          'weather': WeatherConditionModel.fromEntity(weather!).toJson(),
      };

  static ObservationCategory _parseCategory(String value) => switch (value) {
        'pest' => ObservationCategory.pest,
        'disease' => ObservationCategory.disease,
        'weed' => ObservationCategory.weed,
        'growth' => ObservationCategory.growth,
        'soil' => ObservationCategory.soil,
        'water' => ObservationCategory.water,
        'weather' => ObservationCategory.weather,
        'wildlife' => ObservationCategory.wildlife,
        'equipment' => ObservationCategory.equipment,
        _ => ObservationCategory.other,
      };
}

/// Data transfer model for [WeatherCondition].
class WeatherConditionModel extends WeatherCondition {
  const WeatherConditionModel({
    required super.temperature,
    required super.humidity,
    super.windSpeed,
    super.description,
  });

  factory WeatherConditionModel.fromJson(Map<String, dynamic> json) {
    return WeatherConditionModel(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      windSpeed: (json['wind_speed'] as num?)?.toDouble(),
      description: json['description'] as String?,
    );
  }

  factory WeatherConditionModel.fromEntity(WeatherCondition entity) {
    return WeatherConditionModel(
      temperature: entity.temperature,
      humidity: entity.humidity,
      windSpeed: entity.windSpeed,
      description: entity.description,
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'humidity': humidity,
        if (windSpeed != null) 'wind_speed': windSpeed,
        if (description != null) 'description': description,
      };
}
