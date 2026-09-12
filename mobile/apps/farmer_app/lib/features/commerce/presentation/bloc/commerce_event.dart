import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entity.dart';

/// Events for the commerce BLoC.
sealed class CommerceEvent extends Equatable {
  const CommerceEvent();

  @override
  List<Object?> get props => [];
}

/// Load marketplace listings, optionally filtered.
class LoadListings extends CommerceEvent {
  const LoadListings({
    this.search,
    this.region,
    this.productType,
  });

  final String? search;
  final String? region;
  final String? productType;

  @override
  List<Object?> get props => [search, region, productType];
}

/// Load a single listing by ID.
class LoadListingDetail extends CommerceEvent {
  const LoadListingDetail(this.listingId);

  final String listingId;

  @override
  List<Object?> get props => [listingId];
}

/// Create a new listing.
class CreateListing extends CommerceEvent {
  const CreateListing({
    required this.farmId,
    required this.productName,
    required this.productType,
    required this.description,
    required this.quantityAvailable,
    required this.quantityUnit,
    required this.pricePerUnitPaise,
    required this.currency,
    this.cropId,
    this.minOrderQuantity,
    this.qualityGrade,
    this.location,
    this.region,
  });

  final String farmId;
  final String productName;
  final String productType;
  final String description;
  final double quantityAvailable;
  final String quantityUnit;
  final int pricePerUnitPaise;
  final String currency;
  final String? cropId;
  final double? minOrderQuantity;
  final String? qualityGrade;
  final String? location;
  final String? region;

  @override
  List<Object?> get props => [
        farmId,
        productName,
        productType,
        description,
        quantityAvailable,
        quantityUnit,
        pricePerUnitPaise,
        currency,
      ];
}

/// Place an order for a listing.
class PlaceOrder extends CommerceEvent {
  const PlaceOrder({
    required this.listingId,
    required this.quantity,
    this.deliveryAddress,
    this.notes,
  });

  final String listingId;
  final double quantity;
  final String? deliveryAddress;
  final String? notes;

  @override
  List<Object?> get props => [listingId, quantity];
}

/// Load orders for the current user.
class LoadOrders extends CommerceEvent {
  const LoadOrders({this.buyerId, this.sellerId, this.status});

  final String? buyerId;
  final String? sellerId;
  final OrderStatus? status;

  @override
  List<Object?> get props => [buyerId, sellerId, status];
}
