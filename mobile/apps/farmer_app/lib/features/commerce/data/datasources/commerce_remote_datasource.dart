import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../models/listing_model.dart';
import '../models/order_model.dart';

/// Remote data source for the commerce / marketplace service via ConnectRPC.
///
/// Because no proto-generated Dart types exist for the commerce service yet,
/// this datasource uses ConnectRPC's JSON mode with manual serialisation
/// instead of protobuf binary encoding.
abstract class CommerceRemoteDataSource {
  Future<List<ListingModel>> listListings({
    String? farmId,
    String? cropId,
    String? productType,
    String? region,
    String? search,
    int pageSize = 20,
    int pageOffset = 0,
  });

  Future<ListingModel> getListing(String listingId);

  Future<ListingModel> createListing(Map<String, dynamic> fields);

  Future<OrderModel> placeOrder(Map<String, dynamic> fields);

  Future<OrderModel> getOrder(String orderId);

  Future<List<OrderModel>> listOrders({
    String? buyerId,
    String? sellerId,
    int? statusValue,
    int pageSize = 20,
    int pageOffset = 0,
  });
}

class CommerceRemoteDataSourceImpl implements CommerceRemoteDataSource {
  CommerceRemoteDataSourceImpl({required ConnectClient client})
      : _client = client;

  final ConnectClient _client;
  static final _log = Logger('CommerceRemoteDataSource');

  static const _basePath = '/agriculture.commerce.v1.CommerceService';

  /// JSON-mode headers to override the default proto content type.
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  /// Perform a unary ConnectRPC call using JSON encoding.
  Future<Map<String, dynamic>> _callJson(
    String method,
    Map<String, dynamic> request,
  ) async {
    final body = Uint8List.fromList(utf8.encode(jsonEncode(request)));
    final response = await _client.unary(
      '$_basePath/$method',
      body: body,
      headers: _jsonHeaders,
    );
    if (!response.isSuccess) {
      throw ConnectException(
        code: 'internal',
        message: '$_basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    final decoded = jsonDecode(utf8.decode(response.body));
    return decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
  }

  // ---------------------------------------------------------------------------
  // Listings
  // ---------------------------------------------------------------------------

  @override
  Future<List<ListingModel>> listListings({
    String? farmId,
    String? cropId,
    String? productType,
    String? region,
    String? search,
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    try {
      final body = <String, dynamic>{
        if (farmId != null && farmId.isNotEmpty) 'farmId': farmId,
        if (cropId != null && cropId.isNotEmpty) 'cropId': cropId,
        if (productType != null && productType.isNotEmpty)
          'productType': productType,
        if (region != null && region.isNotEmpty) 'region': region,
        if (search != null && search.isNotEmpty) 'search': search,
        'pageSize': pageSize,
        'pageOffset': pageOffset,
      };
      final json = await _callJson('ListListings', body);
      final listings = json['listings'] as List<dynamic>? ?? [];
      return listings
          .map((e) => ListingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ConnectException catch (e) {
      _log.severe('Failed to list listings: $e');
      rethrow;
    }
  }

  @override
  Future<ListingModel> getListing(String listingId) async {
    try {
      final json = await _callJson('GetListing', {'id': listingId});
      return ListingModel.fromJson(
        json['listing'] as Map<String, dynamic>? ?? json,
      );
    } on ConnectException catch (e) {
      _log.severe('Failed to get listing $listingId: $e');
      rethrow;
    }
  }

  @override
  Future<ListingModel> createListing(Map<String, dynamic> fields) async {
    try {
      final json = await _callJson('CreateListing', fields);
      return ListingModel.fromJson(
        json['listing'] as Map<String, dynamic>? ?? json,
      );
    } on ConnectException catch (e) {
      _log.severe('Failed to create listing: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------

  @override
  Future<OrderModel> placeOrder(Map<String, dynamic> fields) async {
    try {
      final json = await _callJson('PlaceOrder', fields);
      return OrderModel.fromJson(
        json['order'] as Map<String, dynamic>? ?? json,
      );
    } on ConnectException catch (e) {
      _log.severe('Failed to place order: $e');
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrder(String orderId) async {
    try {
      final json = await _callJson('GetOrder', {'id': orderId});
      return OrderModel.fromJson(
        json['order'] as Map<String, dynamic>? ?? json,
      );
    } on ConnectException catch (e) {
      _log.severe('Failed to get order $orderId: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> listOrders({
    String? buyerId,
    String? sellerId,
    int? statusValue,
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    try {
      final body = <String, dynamic>{
        if (buyerId != null && buyerId.isNotEmpty) 'buyerId': buyerId,
        if (sellerId != null && sellerId.isNotEmpty) 'sellerId': sellerId,
        if (statusValue != null) 'status': statusValue,
        'pageSize': pageSize,
        'pageOffset': pageOffset,
      };
      final json = await _callJson('ListOrders', body);
      final orders = json['orders'] as List<dynamic>? ?? [];
      return orders
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ConnectException catch (e) {
      _log.severe('Failed to list orders: $e');
      rethrow;
    }
  }
}
