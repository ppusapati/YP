import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// Risk severity levels for pest infestations.
enum RiskLevel {
  low,
  moderate,
  high,
  critical;

  String get label => switch (this) {
        low => 'Low',
        moderate => 'Moderate',
        high => 'High',
        critical => 'Critical',
      };
}

/// Represents a geographic zone with an associated pest risk assessment.
class PestRiskZone extends Equatable {
  const PestRiskZone({
    required this.id,
    required this.fieldId,
    required this.riskLevel,
    required this.pestType,
    required this.polygon,
    required this.alertDate,
    required this.description,
  });

  /// Unique identifier for this risk zone.
  final String id;

  /// The field this risk zone belongs to.
  final String fieldId;

  /// Assessed risk severity.
  final RiskLevel riskLevel;

  /// The type of pest identified or predicted (e.g., "Fall Armyworm").
  final String pestType;

  /// Ordered list of coordinates forming the zone polygon boundary.
  final List<LatLng> polygon;

  /// When the alert was generated.
  final DateTime alertDate;

  /// Human-readable description of the risk assessment.
  final String description;

  @override
  List<Object?> get props => [
        id,
        fieldId,
        riskLevel,
        pestType,
        polygon,
        alertDate,
        description,
      ];
}

/// A pest alert with actionable recommendations.
class PestAlert extends Equatable {
  const PestAlert({
    required this.id,
    required this.zoneId,
    required this.fieldId,
    required this.pestType,
    required this.riskLevel,
    required this.title,
    required this.message,
    required this.recommendations,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String zoneId;
  final String fieldId;
  final String pestType;
  final RiskLevel riskLevel;
  final String title;
  final String message;
  final List<String> recommendations;
  final DateTime createdAt;
  final bool isRead;

  PestAlert copyWith({bool? isRead}) => PestAlert(
        id: id,
        zoneId: zoneId,
        fieldId: fieldId,
        pestType: pestType,
        riskLevel: riskLevel,
        title: title,
        message: message,
        recommendations: recommendations,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );

  @override
  List<Object?> get props => [
        id,
        zoneId,
        fieldId,
        pestType,
        riskLevel,
        title,
        message,
        recommendations,
        createdAt,
        isRead,
      ];
}
