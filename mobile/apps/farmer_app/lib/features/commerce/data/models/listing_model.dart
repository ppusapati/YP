import '../../domain/entities/listing_entity.dart';

/// Data transfer model for [Listing].
class ListingModel extends Listing {
  const ListingModel({
    required super.id,
    required super.farmId,
    required super.productName,
    required super.productType,
    required super.description,
    required super.quantityAvailable,
    required super.quantityUnit,
    required super.pricePerUnitPaise,
    required super.currency,
    required super.status,
    super.cropId,
    super.minOrderQuantity,
    super.qualityGrade,
    super.location,
    super.region,
    super.imageUrls,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  /// Deserialise from ConnectRPC JSON response map.
  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      productType: json['productType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      quantityAvailable:
          (json['quantityAvailable'] as num?)?.toDouble() ?? 0,
      quantityUnit: json['quantityUnit'] as String? ?? 'kg',
      pricePerUnitPaise: _parseInt(json['pricePerUnitPaise']),
      currency: json['currency'] as String? ?? 'INR',
      status: ListingStatus.fromProtoValue(
        _parseStatusInt(json['status']),
      ),
      cropId: json['cropId'] as String?,
      minOrderQuantity:
          (json['minOrderQuantity'] as num?)?.toDouble(),
      qualityGrade: json['qualityGrade'] as String?,
      location: json['location'] as String?,
      region: json['region'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdBy: json['createdBy'] as String?,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  factory ListingModel.fromEntity(Listing entity) {
    return ListingModel(
      id: entity.id,
      farmId: entity.farmId,
      productName: entity.productName,
      productType: entity.productType,
      description: entity.description,
      quantityAvailable: entity.quantityAvailable,
      quantityUnit: entity.quantityUnit,
      pricePerUnitPaise: entity.pricePerUnitPaise,
      currency: entity.currency,
      status: entity.status,
      cropId: entity.cropId,
      minOrderQuantity: entity.minOrderQuantity,
      qualityGrade: entity.qualityGrade,
      location: entity.location,
      region: entity.region,
      imageUrls: entity.imageUrls,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmId': farmId,
        'productName': productName,
        'productType': productType,
        'description': description,
        'quantityAvailable': quantityAvailable,
        'quantityUnit': quantityUnit,
        'pricePerUnitPaise': pricePerUnitPaise.toString(),
        'currency': currency,
        'status': status.protoValue,
        if (cropId != null) 'cropId': cropId,
        if (minOrderQuantity != null) 'minOrderQuantity': minOrderQuantity,
        if (qualityGrade != null) 'qualityGrade': qualityGrade,
        if (location != null) 'location': location,
        if (region != null) 'region': region,
        if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
        if (createdBy != null) 'createdBy': createdBy,
      };

  // ---------------------------------------------------------------------------
  // Parsing helpers
  // ---------------------------------------------------------------------------

  /// Proto int64 fields arrive as strings in JSON; parse robustly.
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Status can be an int or a string enum name.
  static int _parseStatusInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      // Try parsing as int first.
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      // Could be the proto enum string name; map to int.
      return switch (value) {
        'LISTING_STATUS_DRAFT' => 1,
        'LISTING_STATUS_ACTIVE' => 2,
        'LISTING_STATUS_SOLD_OUT' => 3,
        'LISTING_STATUS_EXPIRED' => 4,
        'LISTING_STATUS_CANCELLED' => 5,
        _ => 0,
      };
    }
    return 0;
  }

  /// Parse a Protobuf Timestamp JSON value. ConnectRPC JSON encodes
  /// google.protobuf.Timestamp as an RFC 3339 string.
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    // Some servers return seconds/nanos map.
    if (value is Map) {
      final seconds = (value['seconds'] as num?)?.toInt() ?? 0;
      final nanos = (value['nanos'] as num?)?.toInt() ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanos ~/ 1000000,
      );
    }
    return null;
  }
}
