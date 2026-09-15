// This is a generated file - do not edit.
//
// Generated from task.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'task.pb.dart' as $2;
import 'task.pbjson.dart';

export 'task.pb.dart';

abstract class TaskServiceBase extends $pb.GeneratedService {
  $async.Future<$2.GetTaskResponse> getTask(
      $pb.ServerContext ctx, $2.GetTaskRequest request);
  $async.Future<$2.ListTasksResponse> listTasks(
      $pb.ServerContext ctx, $2.ListTasksRequest request);
  $async.Future<$2.CreateTaskResponse> createTask(
      $pb.ServerContext ctx, $2.CreateTaskRequest request);
  $async.Future<$2.UpdateTaskResponse> updateTask(
      $pb.ServerContext ctx, $2.UpdateTaskRequest request);
  $async.Future<$2.DeleteTaskResponse> deleteTask(
      $pb.ServerContext ctx, $2.DeleteTaskRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetTask':
        return $2.GetTaskRequest();
      case 'ListTasks':
        return $2.ListTasksRequest();
      case 'CreateTask':
        return $2.CreateTaskRequest();
      case 'UpdateTask':
        return $2.UpdateTaskRequest();
      case 'DeleteTask':
        return $2.DeleteTaskRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetTask':
        return getTask(ctx, request as $2.GetTaskRequest);
      case 'ListTasks':
        return listTasks(ctx, request as $2.ListTasksRequest);
      case 'CreateTask':
        return createTask(ctx, request as $2.CreateTaskRequest);
      case 'UpdateTask':
        return updateTask(ctx, request as $2.UpdateTaskRequest);
      case 'DeleteTask':
        return deleteTask(ctx, request as $2.DeleteTaskRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => TaskServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => TaskServiceBase$messageJson;
}
