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
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'task.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'task.pbenum.dart';

/// Task represents a farm task assignment.
class Task extends $pb.GeneratedMessage {
  factory Task({
    $core.String? id,
    $core.String? title,
    $core.String? description,
    TaskStatus? status,
    TaskPriority? priority,
    $core.String? assignedTo,
    $core.String? farmId,
    $core.String? fieldId,
    $0.Timestamp? dueDate,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (status != null) result.status = status;
    if (priority != null) result.priority = priority;
    if (assignedTo != null) result.assignedTo = assignedTo;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (dueDate != null) result.dueDate = dueDate;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  Task._();

  factory Task.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Task.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Task',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.task.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aE<TaskStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: TaskStatus.values)
    ..aE<TaskPriority>(5, _omitFieldNames ? '' : 'priority',
        enumValues: TaskPriority.values)
    ..aOS(6, _omitFieldNames ? '' : 'assignedTo')
    ..aOS(7, _omitFieldNames ? '' : 'farmId')
    ..aOS(8, _omitFieldNames ? '' : 'fieldId')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'dueDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Task clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Task copyWith(void Function(Task) updates) =>
      super.copyWith((message) => updates(message as Task)) as Task;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Task create() => Task._();
  @$core.override
  Task createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Task getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Task>(create);
  static Task? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  TaskStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(TaskStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  TaskPriority get priority => $_getN(4);
  @$pb.TagNumber(5)
  set priority(TaskPriority value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPriority() => $_has(4);
  @$pb.TagNumber(5)
  void clearPriority() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get assignedTo => $_getSZ(5);
  @$pb.TagNumber(6)
  set assignedTo($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAssignedTo() => $_has(5);
  @$pb.TagNumber(6)
  void clearAssignedTo() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get farmId => $_getSZ(6);
  @$pb.TagNumber(7)
  set farmId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFarmId() => $_has(6);
  @$pb.TagNumber(7)
  void clearFarmId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get fieldId => $_getSZ(7);
  @$pb.TagNumber(8)
  set fieldId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFieldId() => $_has(7);
  @$pb.TagNumber(8)
  void clearFieldId() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get dueDate => $_getN(8);
  @$pb.TagNumber(9)
  set dueDate($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasDueDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearDueDate() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureDueDate() => $_ensure(8);

  @$pb.TagNumber(10)
  $0.Timestamp get createdAt => $_getN(9);
  @$pb.TagNumber(10)
  set createdAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCreatedAt() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Timestamp get updatedAt => $_getN(10);
  @$pb.TagNumber(11)
  set updatedAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasUpdatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearUpdatedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureUpdatedAt() => $_ensure(10);
}

class GetTaskRequest extends $pb.GeneratedMessage {
  factory GetTaskRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetTaskRequest._();

  factory GetTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTaskRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.task.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTaskRequest copyWith(void Function(GetTaskRequest) updates) =>
      super.copyWith((message) => updates(message as GetTaskRequest))
          as GetTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTaskRequest create() => GetTaskRequest._();
  @$core.override
  GetTaskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTaskRequest>(create);
  static GetTaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetTaskResponse extends $pb.GeneratedMessage {
  factory GetTaskResponse({
    Task? task,
  }) {
    final result = create();
    if (task != null) result.task = task;
    return result;
  }

  GetTaskResponse._();

  factory GetTaskResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTaskResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTaskResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.task.v1'),
      createEmptyInstance: create)
    ..aOM<Task>(1, _omitFieldNames ? '' : 'task', subBuilder: Task.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTaskResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTaskResponse copyWith(void Function(GetTaskResponse) updates) =>
      super.copyWith((message) => updates(message as GetTaskResponse))
          as GetTaskResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTaskResponse create() => GetTaskResponse._();
  @$core.override
  GetTaskResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTaskResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTaskResponse>(create);
  static GetTaskResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Task get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(Task value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  Task ensureTask() => $_ensure(0);
}

class ListTasksRequest extends $pb.GeneratedMessage {
  factory ListTasksRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? assignedTo,
    TaskStatus? status,
    TaskPriority? priority,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (assignedTo != null) result.assignedTo = assignedTo;
    if (status != null) result.status = status;
    if (priority != null) result.priority = priority;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListTasksRequest._();

  factory ListTasksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTasksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTasksRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.task.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'assignedTo')
    ..aE<TaskStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: TaskStatus.values)
    ..aE<TaskPriority>(5, _omitFieldNames ? '' : 'priority',
        enumValues: TaskPriority.values)
    ..aI(6, _omitFieldNames ? '' : 'pageSize')
    ..aOS(7, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTasksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTasksRequest copyWith(void Function(ListTasksRequest) updates) =>
      super.copyWith((message) => updates(message as ListTasksRequest))
          as ListTasksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTasksRequest create() => ListTasksRequest._();
  @$core.override
  ListTasksRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTasksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTasksRequest>(create);
  static ListTasksRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get assignedTo => $_getSZ(2);
  @$pb.TagNumber(3)
  set assignedTo($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAssignedTo() => $_has(2);
  @$pb.TagNumber(3)
  void clearAssignedTo() => $_clearField(3);

  @$pb.TagNumber(4)
  TaskStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(TaskStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  TaskPriority get priority => $_getN(4);
  @$pb.TagNumber(5)
  set priority(TaskPriority value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPriority() => $_has(4);
  @$pb.TagNumber(5)
  void clearPriority() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pageSize => $_getIZ(5);
  @$pb.TagNumber(6)
  set pageSize($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageSize() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get pageToken => $_getSZ(6);
  @$pb.TagNumber(7)
  set pageToken($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPageToken() => $_has(6);
  @$pb.TagNumber(7)
  void clearPageToken() => $_clearField(7);
}

class ListTasksResponse extends $pb.GeneratedMessage {
  factory ListTasksResponse({
    $core.Iterable<Task>? tasks,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (tasks != null) result.tasks.addAll(tasks);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListTasksResponse._();

  factory ListTasksResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTasksResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTasksResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.task.v1'),
      createEmptyInstance: create)
    ..pPM<Task>(1, _omitFieldNames ? '' : 'tasks', subBuilder: Task.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTasksResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTasksResponse copyWith(void Function(ListTasksResponse) updates) =>
      super.copyWith((message) => updates(message as ListTasksResponse))
          as ListTasksResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTasksResponse create() => ListTasksResponse._();
  @$core.override
  ListTasksResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTasksResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTasksResponse>(create);
  static ListTasksResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Task> get tasks => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class CreateTaskRequest extends $pb.GeneratedMessage {
  factory CreateTaskRequest({
    $core.String? title,
    $core.String? description,
    TaskPriority? priority,
    $core.String? assignedTo,
    $core.String? farmId,
    $core.String? fieldId,
    $0.Timestamp? dueDate,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (priority != null) result.priority = priority;
    if (assignedTo != null) result.assignedTo = assignedTo;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (dueDate != null) result.dueDate = dueDate;
    return result;
  }

  CreateTaskRequest._();

  factory CreateTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateTaskRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.task.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aE<TaskPriority>(3, _omitFieldNames ? '' : 'priority',
        enumValues: TaskPriority.values)
    ..aOS(4, _omitFieldNames ? '' : 'assignedTo')
    ..aOS(5, _omitFieldNames ? '' : 'farmId')
    ..aOS(6, _omitFieldNames ? '' : 'fieldId')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'dueDate',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTaskRequest copyWith(void Function(CreateTaskRequest) updates) =>
      super.copyWith((message) => updates(message as CreateTaskRequest))
          as CreateTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTaskRequest create() => CreateTaskRequest._();
  @$core.override
  CreateTaskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateTaskRequest>(create);
  static CreateTaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  TaskPriority get priority => $_getN(2);
  @$pb.TagNumber(3)
  set priority(TaskPriority value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPriority() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriority() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get assignedTo => $_getSZ(3);
  @$pb.TagNumber(4)
  set assignedTo($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAssignedTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearAssignedTo() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get farmId => $_getSZ(4);
  @$pb.TagNumber(5)
  set farmId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFarmId() => $_has(4);
  @$pb.TagNumber(5)
  void clearFarmId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get fieldId => $_getSZ(5);
  @$pb.TagNumber(6)
  set fieldId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFieldId() => $_has(5);
  @$pb.TagNumber(6)
  void clearFieldId() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get dueDate => $_getN(6);
  @$pb.TagNumber(7)
  set dueDate($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDueDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearDueDate() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureDueDate() => $_ensure(6);
}

class CreateTaskResponse extends $pb.GeneratedMessage {
  factory CreateTaskResponse({
    Task? task,
  }) {
    final result = create();
    if (task != null) result.task = task;
    return result;
  }

  CreateTaskResponse._();

  factory CreateTaskResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateTaskResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateTaskResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.task.v1'),
      createEmptyInstance: create)
    ..aOM<Task>(1, _omitFieldNames ? '' : 'task', subBuilder: Task.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTaskResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTaskResponse copyWith(void Function(CreateTaskResponse) updates) =>
      super.copyWith((message) => updates(message as CreateTaskResponse))
          as CreateTaskResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTaskResponse create() => CreateTaskResponse._();
  @$core.override
  CreateTaskResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateTaskResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateTaskResponse>(create);
  static CreateTaskResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Task get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(Task value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  Task ensureTask() => $_ensure(0);
}

class UpdateTaskRequest extends $pb.GeneratedMessage {
  factory UpdateTaskRequest({
    $core.String? id,
    $core.String? title,
    $core.String? description,
    TaskStatus? status,
    TaskPriority? priority,
    $core.String? assignedTo,
    $core.String? fieldId,
    $0.Timestamp? dueDate,
    $1.FieldMask? updateMask,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (status != null) result.status = status;
    if (priority != null) result.priority = priority;
    if (assignedTo != null) result.assignedTo = assignedTo;
    if (fieldId != null) result.fieldId = fieldId;
    if (dueDate != null) result.dueDate = dueDate;
    if (updateMask != null) result.updateMask = updateMask;
    return result;
  }

  UpdateTaskRequest._();

  factory UpdateTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateTaskRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.task.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aE<TaskStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: TaskStatus.values)
    ..aE<TaskPriority>(5, _omitFieldNames ? '' : 'priority',
        enumValues: TaskPriority.values)
    ..aOS(6, _omitFieldNames ? '' : 'assignedTo')
    ..aOS(7, _omitFieldNames ? '' : 'fieldId')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'dueDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$1.FieldMask>(9, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $1.FieldMask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTaskRequest copyWith(void Function(UpdateTaskRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateTaskRequest))
          as UpdateTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateTaskRequest create() => UpdateTaskRequest._();
  @$core.override
  UpdateTaskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateTaskRequest>(create);
  static UpdateTaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  TaskStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(TaskStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  TaskPriority get priority => $_getN(4);
  @$pb.TagNumber(5)
  set priority(TaskPriority value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPriority() => $_has(4);
  @$pb.TagNumber(5)
  void clearPriority() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get assignedTo => $_getSZ(5);
  @$pb.TagNumber(6)
  set assignedTo($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAssignedTo() => $_has(5);
  @$pb.TagNumber(6)
  void clearAssignedTo() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get fieldId => $_getSZ(6);
  @$pb.TagNumber(7)
  set fieldId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFieldId() => $_has(6);
  @$pb.TagNumber(7)
  void clearFieldId() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get dueDate => $_getN(7);
  @$pb.TagNumber(8)
  set dueDate($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasDueDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearDueDate() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureDueDate() => $_ensure(7);

  @$pb.TagNumber(9)
  $1.FieldMask get updateMask => $_getN(8);
  @$pb.TagNumber(9)
  set updateMask($1.FieldMask value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasUpdateMask() => $_has(8);
  @$pb.TagNumber(9)
  void clearUpdateMask() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.FieldMask ensureUpdateMask() => $_ensure(8);
}

class UpdateTaskResponse extends $pb.GeneratedMessage {
  factory UpdateTaskResponse({
    Task? task,
  }) {
    final result = create();
    if (task != null) result.task = task;
    return result;
  }

  UpdateTaskResponse._();

  factory UpdateTaskResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateTaskResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateTaskResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.task.v1'),
      createEmptyInstance: create)
    ..aOM<Task>(1, _omitFieldNames ? '' : 'task', subBuilder: Task.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTaskResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTaskResponse copyWith(void Function(UpdateTaskResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateTaskResponse))
          as UpdateTaskResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateTaskResponse create() => UpdateTaskResponse._();
  @$core.override
  UpdateTaskResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateTaskResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateTaskResponse>(create);
  static UpdateTaskResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Task get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(Task value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  Task ensureTask() => $_ensure(0);
}

class DeleteTaskRequest extends $pb.GeneratedMessage {
  factory DeleteTaskRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteTaskRequest._();

  factory DeleteTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTaskRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.task.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTaskRequest copyWith(void Function(DeleteTaskRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteTaskRequest))
          as DeleteTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTaskRequest create() => DeleteTaskRequest._();
  @$core.override
  DeleteTaskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTaskRequest>(create);
  static DeleteTaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteTaskResponse extends $pb.GeneratedMessage {
  factory DeleteTaskResponse() => create();

  DeleteTaskResponse._();

  factory DeleteTaskResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTaskResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTaskResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.task.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTaskResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTaskResponse copyWith(void Function(DeleteTaskResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteTaskResponse))
          as DeleteTaskResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTaskResponse create() => DeleteTaskResponse._();
  @$core.override
  DeleteTaskResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTaskResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTaskResponse>(create);
  static DeleteTaskResponse? _defaultInstance;
}

/// TaskService provides farm task management operations.
class TaskServiceApi {
  final $pb.RpcClient _client;

  TaskServiceApi(this._client);

  $async.Future<GetTaskResponse> getTask(
          $pb.ClientContext? ctx, GetTaskRequest request) =>
      _client.invoke<GetTaskResponse>(
          ctx, 'TaskService', 'GetTask', request, GetTaskResponse());

  $async.Future<ListTasksResponse> listTasks(
          $pb.ClientContext? ctx, ListTasksRequest request) =>
      _client.invoke<ListTasksResponse>(
          ctx, 'TaskService', 'ListTasks', request, ListTasksResponse());

  $async.Future<CreateTaskResponse> createTask(
          $pb.ClientContext? ctx, CreateTaskRequest request) =>
      _client.invoke<CreateTaskResponse>(
          ctx, 'TaskService', 'CreateTask', request, CreateTaskResponse());

  $async.Future<UpdateTaskResponse> updateTask(
          $pb.ClientContext? ctx, UpdateTaskRequest request) =>
      _client.invoke<UpdateTaskResponse>(
          ctx, 'TaskService', 'UpdateTask', request, UpdateTaskResponse());

  $async.Future<DeleteTaskResponse> deleteTask(
          $pb.ClientContext? ctx, DeleteTaskRequest request) =>
      _client.invoke<DeleteTaskResponse>(
          ctx, 'TaskService', 'DeleteTask', request, DeleteTaskResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
