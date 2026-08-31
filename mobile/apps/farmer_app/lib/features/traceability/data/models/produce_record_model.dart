import 'package:latlong2/latlong.dart';

import '../../domain/entities/produce_record_entity.dart';

/// Data transfer model for [Treatment].
class TreatmentModel extends Treatment {
  const TreatmentModel({
    required super.id,
    required super.name,
    required super.type,
    required super.date,
    super.dosage,
    super.applicator,
    super.notes,
  });

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      dosage: json['dosage'] as String?,
      applicator: json['applicator'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'date': date.toIso8601String(),
        if (dosage != null) 'dosage': dosage,
        if (applicator != null) 'applicator': applicator,
        if (notes != null) 'notes': notes,
      };
}

/// Data transfer model for [Certification].
class CertificationModel extends Certification {
  const CertificationModel({
    required super.name,
    required super.issuer,
    required super.validUntil,
    super.certificateNumber,
    super.logoUrl,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      name: json['name'] as String,
      issuer: json['issuer'] as String,
      validUntil: DateTime.parse(json['valid_until'] as String),
      certificateNumber: json['certificate_number'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'issuer': issuer,
        'valid_until': validUntil.toIso8601String(),
        if (certificateNumber != null) 'certificate_number': certificateNumber,
        if (logoUrl != null) 'logo_url': logoUrl,
      };
}

/// Data transfer model for [ProduceRecord].
class ProduceRecordModel extends ProduceRecord {
  const ProduceRecordModel({
    required super.id,
    required super.farmId,
    required super.farmName,
    required super.cropVariety,
    required super.harvestDate,
    required super.treatments,
    required super.farmLocation,
    required super.certifications,
    required super.batchId,
    super.packingDate,
    super.expiryDate,
    super.notes,
  });

  factory ProduceRecordModel.fromJson(Map<String, dynamic> json) {
    return ProduceRecordModel(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      farmName: json['farm_name'] as String,
      cropVariety: json['crop_variety'] as String,
      harvestDate: DateTime.parse(json['harvest_date'] as String),
      treatments: (json['treatments'] as List<dynamic>?)
              ?.map(
                  (t) => TreatmentModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      farmLocation: LatLng(
        (json['farm_location']['lat'] as num).toDouble(),
        (json['farm_location']['lng'] as num).toDouble(),
      ),
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((c) =>
                  CertificationModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      batchId: json['batch_id'] as String,
      packingDate: json['packing_date'] != null
          ? DateTime.parse(json['packing_date'] as String)
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  factory ProduceRecordModel.fromEntity(ProduceRecord entity) {
    return ProduceRecordModel(
      id: entity.id,
      farmId: entity.farmId,
      farmName: entity.farmName,
      cropVariety: entity.cropVariety,
      harvestDate: entity.harvestDate,
      treatments: entity.treatments,
      farmLocation: entity.farmLocation,
      certifications: entity.certifications,
      batchId: entity.batchId,
      packingDate: entity.packingDate,
      expiryDate: entity.expiryDate,
      notes: entity.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'farm_id': farmId,
        'farm_name': farmName,
        'crop_variety': cropVariety,
        'harvest_date': harvestDate.toIso8601String(),
        'treatments': treatments
            .map((t) => t is TreatmentModel
                ? t.toJson()
                : TreatmentModel(
                    id: t.id,
                    name: t.name,
                    type: t.type,
                    date: t.date,
                    dosage: t.dosage,
                    applicator: t.applicator,
                    notes: t.notes,
                  ).toJson())
            .toList(),
        'farm_location': {
          'lat': farmLocation.latitude,
          'lng': farmLocation.longitude,
        },
        'certifications': certifications
            .map((c) => c is CertificationModel
                ? c.toJson()
                : CertificationModel(
                    name: c.name,
                    issuer: c.issuer,
                    validUntil: c.validUntil,
                    certificateNumber: c.certificateNumber,
                    logoUrl: c.logoUrl,
                  ).toJson())
            .toList(),
        'batch_id': batchId,
        if (packingDate != null) 'packing_date': packingDate!.toIso8601String(),
        if (expiryDate != null) 'expiry_date': expiryDate!.toIso8601String(),
        if (notes != null) 'notes': notes,
      };
}
