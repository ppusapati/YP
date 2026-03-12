import 'package:latlong2/latlong.dart';

import '../../domain/entities/pest_risk_entity.dart';

/// Data transfer model for [PestRiskZone], handles JSON serialization.
class PestRiskZoneModel extends PestRiskZone {
  const PestRiskZoneModel({
    required super.id,
    required super.fieldId,
    required super.riskLevel,
    required super.pestType,
    required super.polygon,
    required super.alertDate,
    required super.description,
  });

  factory PestRiskZoneModel.fromJson(Map<String, dynamic> json) {
    return PestRiskZoneModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      riskLevel: _parseRiskLevel(json['risk_level'] as String),
      pestType: json['pest_type'] as String,
      polygon: (json['polygon'] as List<dynamic>)
          .map((point) => LatLng(
                (point['lat'] as num).toDouble(),
                (point['lng'] as num).toDouble(),
              ))
          .toList(),
      alertDate: DateTime.parse(json['alert_date'] as String),
      description: json['description'] as String,
    );
  }

  factory PestRiskZoneModel.fromEntity(PestRiskZone entity) {
    return PestRiskZoneModel(
      id: entity.id,
      fieldId: entity.fieldId,
      riskLevel: entity.riskLevel,
      pestType: entity.pestType,
      polygon: entity.polygon,
      alertDate: entity.alertDate,
      description: entity.description,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'field_id': fieldId,
        'risk_level': riskLevel.name,
        'pest_type': pestType,
        'polygon': polygon
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
        'alert_date': alertDate.toIso8601String(),
        'description': description,
      };

  static RiskLevel _parseRiskLevel(String value) => switch (value) {
        'low' => RiskLevel.low,
        'moderate' => RiskLevel.moderate,
        'high' => RiskLevel.high,
        'critical' => RiskLevel.critical,
        _ => RiskLevel.low,
      };
}

/// Data transfer model for [PestAlert], handles JSON serialization.
class PestAlertModel extends PestAlert {
  const PestAlertModel({
    required super.id,
    required super.zoneId,
    required super.fieldId,
    required super.pestType,
    required super.riskLevel,
    required super.title,
    required super.message,
    required super.recommendations,
    required super.createdAt,
    super.isRead,
  });

  factory PestAlertModel.fromJson(Map<String, dynamic> json) {
    return PestAlertModel(
      id: json['id'] as String,
      zoneId: json['zone_id'] as String,
      fieldId: json['field_id'] as String,
      pestType: json['pest_type'] as String,
      riskLevel: PestRiskZoneModel._parseRiskLevel(
        json['risk_level'] as String,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  factory PestAlertModel.fromEntity(PestAlert entity) {
    return PestAlertModel(
      id: entity.id,
      zoneId: entity.zoneId,
      fieldId: entity.fieldId,
      pestType: entity.pestType,
      riskLevel: entity.riskLevel,
      title: entity.title,
      message: entity.message,
      recommendations: entity.recommendations,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'zone_id': zoneId,
        'field_id': fieldId,
        'pest_type': pestType,
        'risk_level': riskLevel.name,
        'title': title,
        'message': message,
        'recommendations': recommendations,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
      };
}
