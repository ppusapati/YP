// This is a generated file - do not edit.
//
// Generated from assistant.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'assistant.pb.dart' as $1;
import 'assistant.pbjson.dart';

export 'assistant.pb.dart';

abstract class AdvisoryServiceBase extends $pb.GeneratedService {
  $async.Future<$1.AskResponse> ask(
      $pb.ServerContext ctx, $1.AskRequest request);
  $async.Future<$1.GetConversationResponse> getConversation(
      $pb.ServerContext ctx, $1.GetConversationRequest request);
  $async.Future<$1.ListConversationsResponse> listConversations(
      $pb.ServerContext ctx, $1.ListConversationsRequest request);
  $async.Future<$1.ListExchangesResponse> listExchanges(
      $pb.ServerContext ctx, $1.ListExchangesRequest request);
  $async.Future<$1.ReviewExchangeResponse> reviewExchange(
      $pb.ServerContext ctx, $1.ReviewExchangeRequest request);
  $async.Future<$1.GetTenantBudgetResponse> getTenantBudget(
      $pb.ServerContext ctx, $1.GetTenantBudgetRequest request);
  $async.Future<$1.SetTenantBudgetResponse> setTenantBudget(
      $pb.ServerContext ctx, $1.SetTenantBudgetRequest request);
  $async.Future<$1.IngestDocumentResponse> ingestDocument(
      $pb.ServerContext ctx, $1.IngestDocumentRequest request);
  $async.Future<$1.ListDocumentsResponse> listDocuments(
      $pb.ServerContext ctx, $1.ListDocumentsRequest request);
  $async.Future<$1.DeleteDocumentResponse> deleteDocument(
      $pb.ServerContext ctx, $1.DeleteDocumentRequest request);
  $async.Future<$1.SearchReferenceResponse> searchReference(
      $pb.ServerContext ctx, $1.SearchReferenceRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Ask':
        return $1.AskRequest();
      case 'GetConversation':
        return $1.GetConversationRequest();
      case 'ListConversations':
        return $1.ListConversationsRequest();
      case 'ListExchanges':
        return $1.ListExchangesRequest();
      case 'ReviewExchange':
        return $1.ReviewExchangeRequest();
      case 'GetTenantBudget':
        return $1.GetTenantBudgetRequest();
      case 'SetTenantBudget':
        return $1.SetTenantBudgetRequest();
      case 'IngestDocument':
        return $1.IngestDocumentRequest();
      case 'ListDocuments':
        return $1.ListDocumentsRequest();
      case 'DeleteDocument':
        return $1.DeleteDocumentRequest();
      case 'SearchReference':
        return $1.SearchReferenceRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Ask':
        return ask(ctx, request as $1.AskRequest);
      case 'GetConversation':
        return getConversation(ctx, request as $1.GetConversationRequest);
      case 'ListConversations':
        return listConversations(ctx, request as $1.ListConversationsRequest);
      case 'ListExchanges':
        return listExchanges(ctx, request as $1.ListExchangesRequest);
      case 'ReviewExchange':
        return reviewExchange(ctx, request as $1.ReviewExchangeRequest);
      case 'GetTenantBudget':
        return getTenantBudget(ctx, request as $1.GetTenantBudgetRequest);
      case 'SetTenantBudget':
        return setTenantBudget(ctx, request as $1.SetTenantBudgetRequest);
      case 'IngestDocument':
        return ingestDocument(ctx, request as $1.IngestDocumentRequest);
      case 'ListDocuments':
        return listDocuments(ctx, request as $1.ListDocumentsRequest);
      case 'DeleteDocument':
        return deleteDocument(ctx, request as $1.DeleteDocumentRequest);
      case 'SearchReference':
        return searchReference(ctx, request as $1.SearchReferenceRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => AdvisoryServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => AdvisoryServiceBase$messageJson;
}
