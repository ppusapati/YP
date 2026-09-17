// This is a generated file - do not edit.
//
// Generated from finance.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'finance.pb.dart' as $1;
import 'finance.pbjson.dart';

export 'finance.pb.dart';

abstract class FinanceServiceBase extends $pb.GeneratedService {
  $async.Future<$1.QuoteInsuranceResponse> quoteInsurance(
      $pb.ServerContext ctx, $1.QuoteInsuranceRequest request);
  $async.Future<$1.GetQuoteResponse> getQuote(
      $pb.ServerContext ctx, $1.GetQuoteRequest request);
  $async.Future<$1.ListQuotesResponse> listQuotes(
      $pb.ServerContext ctx, $1.ListQuotesRequest request);
  $async.Future<$1.AssessCreditResponse> assessCredit(
      $pb.ServerContext ctx, $1.AssessCreditRequest request);
  $async.Future<$1.GetCreditAssessmentResponse> getCreditAssessment(
      $pb.ServerContext ctx, $1.GetCreditAssessmentRequest request);
  $async.Future<$1.FileClaimResponse> fileClaim(
      $pb.ServerContext ctx, $1.FileClaimRequest request);
  $async.Future<$1.GatherEvidenceResponse> gatherEvidence(
      $pb.ServerContext ctx, $1.GatherEvidenceRequest request);
  $async.Future<$1.GetClaimResponse> getClaim(
      $pb.ServerContext ctx, $1.GetClaimRequest request);
  $async.Future<$1.ListClaimsResponse> listClaims(
      $pb.ServerContext ctx, $1.ListClaimsRequest request);
  $async.Future<$1.UpdateClaimStatusResponse> updateClaimStatus(
      $pb.ServerContext ctx, $1.UpdateClaimStatusRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'QuoteInsurance':
        return $1.QuoteInsuranceRequest();
      case 'GetQuote':
        return $1.GetQuoteRequest();
      case 'ListQuotes':
        return $1.ListQuotesRequest();
      case 'AssessCredit':
        return $1.AssessCreditRequest();
      case 'GetCreditAssessment':
        return $1.GetCreditAssessmentRequest();
      case 'FileClaim':
        return $1.FileClaimRequest();
      case 'GatherEvidence':
        return $1.GatherEvidenceRequest();
      case 'GetClaim':
        return $1.GetClaimRequest();
      case 'ListClaims':
        return $1.ListClaimsRequest();
      case 'UpdateClaimStatus':
        return $1.UpdateClaimStatusRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'QuoteInsurance':
        return quoteInsurance(ctx, request as $1.QuoteInsuranceRequest);
      case 'GetQuote':
        return getQuote(ctx, request as $1.GetQuoteRequest);
      case 'ListQuotes':
        return listQuotes(ctx, request as $1.ListQuotesRequest);
      case 'AssessCredit':
        return assessCredit(ctx, request as $1.AssessCreditRequest);
      case 'GetCreditAssessment':
        return getCreditAssessment(
            ctx, request as $1.GetCreditAssessmentRequest);
      case 'FileClaim':
        return fileClaim(ctx, request as $1.FileClaimRequest);
      case 'GatherEvidence':
        return gatherEvidence(ctx, request as $1.GatherEvidenceRequest);
      case 'GetClaim':
        return getClaim(ctx, request as $1.GetClaimRequest);
      case 'ListClaims':
        return listClaims(ctx, request as $1.ListClaimsRequest);
      case 'UpdateClaimStatus':
        return updateClaimStatus(ctx, request as $1.UpdateClaimStatusRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => FinanceServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => FinanceServiceBase$messageJson;
}
