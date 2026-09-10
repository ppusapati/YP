import 'package:logging/logging.dart';

import '../../domain/entities/listing_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/commerce_repository.dart';
import '../datasources/commerce_remote_datasource.dart';

/// Concrete [CommerceRepository] backed by the commerce ConnectRPC service.
class CommerceRepositoryImpl implements CommerceRepository {
  CommerceRepositoryImpl({
    required CommerceRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final CommerceRemoteDataSource _remote;
  static final _log = Logger('CommerceRepositoryImpl');

  // ---------------------------------------------------------------------------
  // Listings
  // ---------------------------------------------------------------------------

  @override
  Future<List<Listing>> listListings({
    String? farmId,
    String? cropId,
    String? productType,
    String? region,
    String? search,
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    try {
      return await _remote.listListings(
        farmId: farmId,
        cropId: cropId,
        productType: productType,
        region: region,
        search: search,
        pageSize: pageSize,
        pageOffset: pageOffset,
      );
    } catch (e, stack) {
      _log.severe('listListings failed', e, stack);
      rethrow;
    }
  }

  @override
  Future<Listing> getListing(String listingId) async {
    try {
      return await _remote.getListing(listingId);
    } catch (e, stack) {
      _log.severe('getListing failed', e, stack);
      rethrow;
    }
  }

  @override
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
  }) async {
    try {
      final fields = <String, dynamic>{
        'farmId': farmId,
        'productName': productName,
        'productType': productType,
        'description': description,
        'quantityAvailable': quantityAvailable,
        'quantityUnit': quantityUnit,
        'pricePerUnitPaise': pricePerUnitPaise.toString(),
        'currency': currency,
        if (cropId != null) 'cropId': cropId,
        if (minOrderQuantity != null) 'minOrderQuantity': minOrderQuantity,
        if (qualityGrade != null) 'qualityGrade': qualityGrade,
        if (location != null) 'location': location,
        if (region != null) 'region': region,
      };
      return await _remote.createListing(fields);
    } catch (e, stack) {
      _log.severe('createListing failed', e, stack);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------

  @override
  Future<Order> placeOrder({
    required String listingId,
    required double quantity,
    String? deliveryMethod,
    String? deliveryAddress,
    String? deliveryNotes,
    String? notes,
  }) async {
    try {
      final fields = <String, dynamic>{
        'listingId': listingId,
        'quantity': quantity,
        if (deliveryMethod != null) 'deliveryMethod': deliveryMethod,
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
        if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
        if (notes != null) 'notes': notes,
      };
      return await _remote.placeOrder(fields);
    } catch (e, stack) {
      _log.severe('placeOrder failed', e, stack);
      rethrow;
    }
  }

  @override
  Future<Order> getOrder(String orderId) async {
    try {
      return await _remote.getOrder(orderId);
    } catch (e, stack) {
      _log.severe('getOrder failed', e, stack);
      rethrow;
    }
  }

  @override
  Future<List<Order>> listOrders({
    String? buyerId,
    String? sellerId,
    OrderStatus? status,
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    try {
      return await _remote.listOrders(
        buyerId: buyerId,
        sellerId: sellerId,
        statusValue: status?.protoValue,
        pageSize: pageSize,
        pageOffset: pageOffset,
      );
    } catch (e, stack) {
      _log.severe('listOrders failed', e, stack);
      rethrow;
    }
  }
}
