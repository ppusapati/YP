// This is a generated file - do not edit.
//
// Generated from field.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'field.pb.dart' as $2;
import 'field.pbjson.dart';

export 'field.pb.dart';

abstract class FieldServiceBase extends $pb.GeneratedService {
  $async.Future<$2.CreateFieldResponse> createField(
      $pb.ServerContext ctx, $2.CreateFieldRequest request);
  $async.Future<$2.GetFieldResponse> getField(
      $pb.ServerContext ctx, $2.GetFieldRequest request);
  $async.Future<$2.ListFieldsResponse> listFields(
      $pb.ServerContext ctx, $2.ListFieldsRequest request);
  $async.Future<$2.UpdateFieldResponse> updateField(
      $pb.ServerContext ctx, $2.UpdateFieldRequest request);
  $async.Future<$2.DeleteFieldResponse> deleteField(
      $pb.ServerContext ctx, $2.DeleteFieldRequest request);
  $async.Future<$2.SetFieldBoundaryResponse> setFieldBoundary(
      $pb.ServerContext ctx, $2.SetFieldBoundaryRequest request);
  $async.Future<$2.AssignCropResponse> assignCrop(
      $pb.ServerContext ctx, $2.AssignCropRequest request);
  $async.Future<$2.ListFieldsByFarmResponse> listFieldsByFarm(
      $pb.ServerContext ctx, $2.ListFieldsByFarmRequest request);
  $async.Future<$2.SegmentFieldResponse> segmentField(
      $pb.ServerContext ctx, $2.SegmentFieldRequest request);
  $async.Future<$2.GetFieldSegmentsResponse> getFieldSegments(
      $pb.ServerContext ctx, $2.GetFieldSegmentsRequest request);
  $async.Future<$2.GetCropHistoryResponse> getCropHistory(
      $pb.ServerContext ctx, $2.GetCropHistoryRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateField':
        return $2.CreateFieldRequest();
      case 'GetField':
        return $2.GetFieldRequest();
      case 'ListFields':
        return $2.ListFieldsRequest();
      case 'UpdateField':
        return $2.UpdateFieldRequest();
      case 'DeleteField':
        return $2.DeleteFieldRequest();
      case 'SetFieldBoundary':
        return $2.SetFieldBoundaryRequest();
      case 'AssignCrop':
        return $2.AssignCropRequest();
      case 'ListFieldsByFarm':
        return $2.ListFieldsByFarmRequest();
      case 'SegmentField':
        return $2.SegmentFieldRequest();
      case 'GetFieldSegments':
        return $2.GetFieldSegmentsRequest();
      case 'GetCropHistory':
        return $2.GetCropHistoryRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateField':
        return createField(ctx, request as $2.CreateFieldRequest);
      case 'GetField':
        return getField(ctx, request as $2.GetFieldRequest);
      case 'ListFields':
        return listFields(ctx, request as $2.ListFieldsRequest);
      case 'UpdateField':
        return updateField(ctx, request as $2.UpdateFieldRequest);
      case 'DeleteField':
        return deleteField(ctx, request as $2.DeleteFieldRequest);
      case 'SetFieldBoundary':
        return setFieldBoundary(ctx, request as $2.SetFieldBoundaryRequest);
      case 'AssignCrop':
        return assignCrop(ctx, request as $2.AssignCropRequest);
      case 'ListFieldsByFarm':
        return listFieldsByFarm(ctx, request as $2.ListFieldsByFarmRequest);
      case 'SegmentField':
        return segmentField(ctx, request as $2.SegmentFieldRequest);
      case 'GetFieldSegments':
        return getFieldSegments(ctx, request as $2.GetFieldSegmentsRequest);
      case 'GetCropHistory':
        return getCropHistory(ctx, request as $2.GetCropHistoryRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => FieldServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => FieldServiceBase$messageJson;
}
