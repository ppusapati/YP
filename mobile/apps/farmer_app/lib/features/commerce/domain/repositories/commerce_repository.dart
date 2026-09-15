import '../entities/listing_entity.dart';
import '../entities/order_entity.dart';

/// Contract for commerce / marketplace data access.
abstract class CommerceRepository {
  /// Returns active marketplace listings, optionally filtered.
  Future<List<Listing>> listListings({
    String? farmId,
    String? cropId,
    String? productType,
    String? region,
    String? search,
    int pageSize = 20,
    int pageOffset = 0,
  });

  /// Returns a single listing by [listingId].
  Future<Listing> getListing(String listingId);

  /// Creates a new listing and returns the created entity.
  Future<Listing> createListing({
    required String farmId,
    required String productName,
    required String productType,
    required String description,
    required double quantityAvailable,
    required String quantityUnit,
    required int pricePerUnitPaise,
    required String currency,
    String? cropId,
    double? minOrderQuantity,
    String? qualityGrade,
    String? location,
    String? region,
  });

  /// Places a new order against a listing.
  Future<Order> placeOrder({
    required String listingId,
    required double quantity,
    String? deliveryMethod,
    String? deliveryAddress,
    String? deliveryNotes,
    String? notes,
  });

  /// Returns a single order by [orderId].
  Future<Order> getOrder(String orderId);

  /// Returns orders for the current user (as buyer or seller).
  Future<List<Order>> listOrders({
    String? buyerId,
    String? sellerId,
    OrderStatus? status,
    int pageSize = 20,
    int pageOffset = 0,
  });
}
