import 'package:equatable/equatable.dart';

/// Status of a marketplace listing.
enum ListingStatus {
  draft,
  active,
  soldOut,
  expired,
  cancelled;

  String get label => switch (this) {
        draft => 'Draft',
        active => 'Active',
        soldOut => 'Sold Out',
        expired => 'Expired',
        cancelled => 'Cancelled',
      };

  /// Map proto enum int value to [ListingStatus].
  static ListingStatus fromProtoValue(int value) => switch (value) {
        1 => draft,
        2 => active,
        3 => soldOut,
        4 => expired,
        5 => cancelled,
        _ => draft,
      };

  /// Proto enum int value.
  int get protoValue => switch (this) {
        draft => 1,
        active => 2,
        soldOut => 3,
        expired => 4,
        cancelled => 5,
      };
}

/// A produce listing posted by a farmer on the marketplace.
class Listing extends Equatable {
  const Listing({
    required this.id,
    required this.farmId,
    required this.productName,
    required this.productType,
    required this.description,
    required this.quantityAvailable,
    required this.quantityUnit,
    required this.pricePerUnitPaise,
    required this.currency,
    required this.status,
    this.cropId,
    this.minOrderQuantity,
    this.qualityGrade,
    this.location,
    this.region,
    this.imageUrls = const [],
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String farmId;
  final String productName;
  final String productType;
  final String description;
  final double quantityAvailable;
  final String quantityUnit;
  final int pricePerUnitPaise;
  final String currency;
  final ListingStatus status;
  final String? cropId;
  final double? minOrderQuantity;
  final String? qualityGrade;
  final String? location;
  final String? region;
  final List<String> imageUrls;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Price formatted as rupees (paise to rupees).
  String get formattedPrice {
    final rupees = pricePerUnitPaise / 100;
    if (currency == 'INR') {
      return '₹${rupees.toStringAsFixed(2)}/$quantityUnit';
    }
    return '${rupees.toStringAsFixed(2)} $currency/$quantityUnit';
  }

  @override
  List<Object?> get props => [
        id,
        farmId,
        productName,
        productType,
        description,
        quantityAvailable,
        quantityUnit,
        pricePerUnitPaise,
        currency,
        status,
        cropId,
        minOrderQuantity,
        qualityGrade,
        location,
        region,
        imageUrls,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
