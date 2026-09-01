// This is a generated file - do not edit.
//
// Generated from traceability.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'traceability.pb.dart' as $1;
import 'traceability.pbjson.dart';

export 'traceability.pb.dart';

abstract class TraceabilityServiceBase extends $pb.GeneratedService {
  $async.Future<$1.CreateRecordResponse> createRecord(
      $pb.ServerContext ctx, $1.CreateRecordRequest request);
  $async.Future<$1.GetRecordResponse> getRecord(
      $pb.ServerContext ctx, $1.GetRecordRequest request);
  $async.Future<$1.ListRecordsResponse> listRecords(
      $pb.ServerContext ctx, $1.ListRecordsRequest request);
  $async.Future<$1.AddSupplyChainEventResponse> addSupplyChainEvent(
      $pb.ServerContext ctx, $1.AddSupplyChainEventRequest request);
  $async.Future<$1.GetSupplyChainResponse> getSupplyChain(
      $pb.ServerContext ctx, $1.GetSupplyChainRequest request);
  $async.Future<$1.CreateCertificationResponse> createCertification(
      $pb.ServerContext ctx, $1.CreateCertificationRequest request);
  $async.Future<$1.GetCertificationResponse> getCertification(
      $pb.ServerContext ctx, $1.GetCertificationRequest request);
  $async.Future<$1.ListCertificationsResponse> listCertifications(
      $pb.ServerContext ctx, $1.ListCertificationsRequest request);
  $async.Future<$1.VerifyCertificationResponse> verifyCertification(
      $pb.ServerContext ctx, $1.VerifyCertificationRequest request);
  $async.Future<$1.CreateBatchResponse> createBatch(
      $pb.ServerContext ctx, $1.CreateBatchRequest request);
  $async.Future<$1.GetBatchResponse> getBatch(
      $pb.ServerContext ctx, $1.GetBatchRequest request);
  $async.Future<$1.ListBatchesResponse> listBatches(
      $pb.ServerContext ctx, $1.ListBatchesRequest request);
  $async.Future<$1.GenerateQRCodeResponse> generateQRCode(
      $pb.ServerContext ctx, $1.GenerateQRCodeRequest request);
  $async.Future<$1.VerifyQRCodeResponse> verifyQRCode(
      $pb.ServerContext ctx, $1.VerifyQRCodeRequest request);
  $async.Future<$1.GenerateComplianceReportResponse> generateComplianceReport(
      $pb.ServerContext ctx, $1.GenerateComplianceReportRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateRecord':
        return $1.CreateRecordRequest();
      case 'GetRecord':
        return $1.GetRecordRequest();
      case 'ListRecords':
        return $1.ListRecordsRequest();
      case 'AddSupplyChainEvent':
        return $1.AddSupplyChainEventRequest();
      case 'GetSupplyChain':
        return $1.GetSupplyChainRequest();
      case 'CreateCertification':
        return $1.CreateCertificationRequest();
      case 'GetCertification':
        return $1.GetCertificationRequest();
      case 'ListCertifications':
        return $1.ListCertificationsRequest();
      case 'VerifyCertification':
        return $1.VerifyCertificationRequest();
      case 'CreateBatch':
        return $1.CreateBatchRequest();
      case 'GetBatch':
        return $1.GetBatchRequest();
      case 'ListBatches':
        return $1.ListBatchesRequest();
      case 'GenerateQRCode':
        return $1.GenerateQRCodeRequest();
      case 'VerifyQRCode':
        return $1.VerifyQRCodeRequest();
      case 'GenerateComplianceReport':
        return $1.GenerateComplianceReportRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateRecord':
        return createRecord(ctx, request as $1.CreateRecordRequest);
      case 'GetRecord':
        return getRecord(ctx, request as $1.GetRecordRequest);
      case 'ListRecords':
        return listRecords(ctx, request as $1.ListRecordsRequest);
      case 'AddSupplyChainEvent':
        return addSupplyChainEvent(
            ctx, request as $1.AddSupplyChainEventRequest);
      case 'GetSupplyChain':
        return getSupplyChain(ctx, request as $1.GetSupplyChainRequest);
      case 'CreateCertification':
        return createCertification(
            ctx, request as $1.CreateCertificationRequest);
      case 'GetCertification':
        return getCertification(ctx, request as $1.GetCertificationRequest);
      case 'ListCertifications':
        return listCertifications(ctx, request as $1.ListCertificationsRequest);
      case 'VerifyCertification':
        return verifyCertification(
            ctx, request as $1.VerifyCertificationRequest);
      case 'CreateBatch':
        return createBatch(ctx, request as $1.CreateBatchRequest);
      case 'GetBatch':
        return getBatch(ctx, request as $1.GetBatchRequest);
      case 'ListBatches':
        return listBatches(ctx, request as $1.ListBatchesRequest);
      case 'GenerateQRCode':
        return generateQRCode(ctx, request as $1.GenerateQRCodeRequest);
      case 'VerifyQRCode':
        return verifyQRCode(ctx, request as $1.VerifyQRCodeRequest);
      case 'GenerateComplianceReport':
        return generateComplianceReport(
            ctx, request as $1.GenerateComplianceReportRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      TraceabilityServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => TraceabilityServiceBase$messageJson;
}
