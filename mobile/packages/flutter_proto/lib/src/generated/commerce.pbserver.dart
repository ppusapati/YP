// This is a generated file - do not edit.
//
// Generated from commerce.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'commerce.pb.dart' as $1;
import 'commerce.pbjson.dart';

export 'commerce.pb.dart';

abstract class CommerceServiceBase extends $pb.GeneratedService {
  $async.Future<$1.CreateListingResponse> createListing(
      $pb.ServerContext ctx, $1.CreateListingRequest request);
  $async.Future<$1.GetListingResponse> getListing(
      $pb.ServerContext ctx, $1.GetListingRequest request);
  $async.Future<$1.ListListingsResponse> listListings(
      $pb.ServerContext ctx, $1.ListListingsRequest request);
  $async.Future<$1.UpdateListingResponse> updateListing(
      $pb.ServerContext ctx, $1.UpdateListingRequest request);
  $async.Future<$1.ActivateListingResponse> activateListing(
      $pb.ServerContext ctx, $1.ActivateListingRequest request);
  $async.Future<$1.CancelListingResponse> cancelListing(
      $pb.ServerContext ctx, $1.CancelListingRequest request);
  $async.Future<$1.PlaceOrderResponse> placeOrder(
      $pb.ServerContext ctx, $1.PlaceOrderRequest request);
  $async.Future<$1.GetOrderResponse> getOrder(
      $pb.ServerContext ctx, $1.GetOrderRequest request);
  $async.Future<$1.ListOrdersResponse> listOrders(
      $pb.ServerContext ctx, $1.ListOrdersRequest request);
  $async.Future<$1.UpdateOrderStatusResponse> updateOrderStatus(
      $pb.ServerContext ctx, $1.UpdateOrderStatusRequest request);
  $async.Future<$1.UpdatePaymentStatusResponse> updatePaymentStatus(
      $pb.ServerContext ctx, $1.UpdatePaymentStatusRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateListing':
        return $1.CreateListingRequest();
      case 'GetListing':
        return $1.GetListingRequest();
      case 'ListListings':
        return $1.ListListingsRequest();
      case 'UpdateListing':
        return $1.UpdateListingRequest();
      case 'ActivateListing':
        return $1.ActivateListingRequest();
      case 'CancelListing':
        return $1.CancelListingRequest();
      case 'PlaceOrder':
        return $1.PlaceOrderRequest();
      case 'GetOrder':
        return $1.GetOrderRequest();
      case 'ListOrders':
        return $1.ListOrdersRequest();
      case 'UpdateOrderStatus':
        return $1.UpdateOrderStatusRequest();
      case 'UpdatePaymentStatus':
        return $1.UpdatePaymentStatusRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateListing':
        return createListing(ctx, request as $1.CreateListingRequest);
      case 'GetListing':
        return getListing(ctx, request as $1.GetListingRequest);
      case 'ListListings':
        return listListings(ctx, request as $1.ListListingsRequest);
      case 'UpdateListing':
        return updateListing(ctx, request as $1.UpdateListingRequest);
      case 'ActivateListing':
        return activateListing(ctx, request as $1.ActivateListingRequest);
      case 'CancelListing':
        return cancelListing(ctx, request as $1.CancelListingRequest);
      case 'PlaceOrder':
        return placeOrder(ctx, request as $1.PlaceOrderRequest);
      case 'GetOrder':
        return getOrder(ctx, request as $1.GetOrderRequest);
      case 'ListOrders':
        return listOrders(ctx, request as $1.ListOrdersRequest);
      case 'UpdateOrderStatus':
        return updateOrderStatus(ctx, request as $1.UpdateOrderStatusRequest);
      case 'UpdatePaymentStatus':
        return updatePaymentStatus(
            ctx, request as $1.UpdatePaymentStatusRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CommerceServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => CommerceServiceBase$messageJson;
}
