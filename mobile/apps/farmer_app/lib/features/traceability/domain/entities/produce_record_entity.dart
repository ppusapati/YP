import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// A single treatment applied to a crop batch.
class Treatment extends Equatable {
  const Treatment({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    this.dosage,
    this.applicator,
    this.notes,
  });

  final String id;
  final String name;

  /// e.g., "pesticide", "fertilizer", "herbicide", "biological"
  final String type;
  final DateTime date;
  final String? dosage;
  final String? applicator;
  final String? notes;

  @override
  List<Object?> get props => [id, name, type, date, dosage, applicator, notes];
}

/// A certification held by a farm or produce batch.
class Certification extends Equatable {
  const Certification({
    required this.name,
    required this.issuer,
    required this.validUntil,
    this.certificateNumber,
    this.logoUrl,
  });

  final String name;
  final String issuer;
  final DateTime validUntil;
  final String? certificateNumber;
  final String? logoUrl;

  bool get isValid => validUntil.isAfter(DateTime.now());

  @override
  List<Object?> get props =>
      [name, issuer, validUntil, certificateNumber, logoUrl];
}

/// Full traceability record for a produce batch.
class ProduceRecord extends Equatable {
  const ProduceRecord({
    required this.id,
    required this.farmId,
    required this.farmName,
    required this.cropVariety,
    required this.harvestDate,
    required this.treatments,
    required this.farmLocation,
    required this.certifications,
    required this.batchId,
    this.packingDate,
    this.expiryDate,
    this.notes,
  });

  final String id;
  final String farmId;
  final String farmName;
  final String cropVariety;
  final DateTime harvestDate;
  final List<Treatment> treatments;
  final LatLng farmLocation;
  final List<Certification> certifications;
  final String batchId;
  final DateTime? packingDate;
  final DateTime? expiryDate;
  final String? notes;

  @override
  List<Object?> get props => [
        id,
        farmId,
        farmName,
        cropVariety,
        harvestDate,
        treatments,
        farmLocation,
        certifications,
        batchId,
        packingDate,
        expiryDate,
        notes,
      ];
}
