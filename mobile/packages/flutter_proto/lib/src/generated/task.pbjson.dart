// This is a generated file - do not edit.
//
// Generated from task.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'package:protobuf/well_known_types/google/protobuf/field_mask.pbjson.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pbjson.dart'
    as $0;

@$core.Deprecated('Use taskStatusDescriptor instead')
const TaskStatus$json = {
  '1': 'TaskStatus',
  '2': [
    {'1': 'TASK_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'TASK_STATUS_PENDING', '2': 1},
    {'1': 'TASK_STATUS_IN_PROGRESS', '2': 2},
    {'1': 'TASK_STATUS_COMPLETED', '2': 3},
    {'1': 'TASK_STATUS_CANCELLED', '2': 4},
  ],
};

/// Descriptor for `TaskStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List taskStatusDescriptor = $convert.base64Decode(
    'CgpUYXNrU3RhdHVzEhsKF1RBU0tfU1RBVFVTX1VOU1BFQ0lGSUVEEAASFwoTVEFTS19TVEFUVV'
    'NfUEVORElORxABEhsKF1RBU0tfU1RBVFVTX0lOX1BST0dSRVNTEAISGQoVVEFTS19TVEFUVVNf'
    'Q09NUExFVEVEEAMSGQoVVEFTS19TVEFUVVNfQ0FOQ0VMTEVEEAQ=');

@$core.Deprecated('Use taskPriorityDescriptor instead')
const TaskPriority$json = {
  '1': 'TaskPriority',
  '2': [
    {'1': 'TASK_PRIORITY_UNSPECIFIED', '2': 0},
    {'1': 'TASK_PRIORITY_LOW', '2': 1},
    {'1': 'TASK_PRIORITY_MEDIUM', '2': 2},
    {'1': 'TASK_PRIORITY_HIGH', '2': 3},
    {'1': 'TASK_PRIORITY_URGENT', '2': 4},
  ],
};

/// Descriptor for `TaskPriority`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List taskPriorityDescriptor = $convert.base64Decode(
    'CgxUYXNrUHJpb3JpdHkSHQoZVEFTS19QUklPUklUWV9VTlNQRUNJRklFRBAAEhUKEVRBU0tfUF'
    'JJT1JJVFlfTE9XEAESGAoUVEFTS19QUklPUklUWV9NRURJVU0QAhIWChJUQVNLX1BSSU9SSVRZ'
    'X0hJR0gQAxIYChRUQVNLX1BSSU9SSVRZX1VSR0VOVBAE');

@$core.Deprecated('Use taskDescriptor instead')
const Task$json = {
  '1': 'Task',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.task.v1.TaskStatus',
      '10': 'status'
    },
    {
      '1': 'priority',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.task.v1.TaskPriority',
      '10': 'priority'
    },
    {'1': 'assigned_to', '3': 6, '4': 1, '5': 9, '10': 'assignedTo'},
    {'1': 'farm_id', '3': 7, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 8, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'due_date',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'dueDate'
    },
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `Task`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskDescriptor = $convert.base64Decode(
    'CgRUYXNrEg4KAmlkGAEgASgJUgJpZBIUCgV0aXRsZRgCIAEoCVIFdGl0bGUSIAoLZGVzY3JpcH'
    'Rpb24YAyABKAlSC2Rlc2NyaXB0aW9uEjcKBnN0YXR1cxgEIAEoDjIfLmFncmljdWx0dXJlLnRh'
    'c2sudjEuVGFza1N0YXR1c1IGc3RhdHVzEj0KCHByaW9yaXR5GAUgASgOMiEuYWdyaWN1bHR1cm'
    'UudGFzay52MS5UYXNrUHJpb3JpdHlSCHByaW9yaXR5Eh8KC2Fzc2lnbmVkX3RvGAYgASgJUgph'
    'c3NpZ25lZFRvEhcKB2Zhcm1faWQYByABKAlSBmZhcm1JZBIZCghmaWVsZF9pZBgIIAEoCVIHZm'
    'llbGRJZBI1CghkdWVfZGF0ZRgJIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSB2R1'
    'ZURhdGUSOQoKY3JlYXRlZF9hdBgKIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCW'
    'NyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GAsgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFt'
    'cFIJdXBkYXRlZEF0');

@$core.Deprecated('Use getTaskRequestDescriptor instead')
const GetTaskRequest$json = {
  '1': 'GetTaskRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTaskRequestDescriptor =
    $convert.base64Decode('Cg5HZXRUYXNrUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getTaskResponseDescriptor instead')
const GetTaskResponse$json = {
  '1': 'GetTaskResponse',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.task.v1.Task',
      '10': 'task'
    },
  ],
};

/// Descriptor for `GetTaskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTaskResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRUYXNrUmVzcG9uc2USLQoEdGFzaxgBIAEoCzIZLmFncmljdWx0dXJlLnRhc2sudjEuVG'
    'Fza1IEdGFzaw==');

@$core.Deprecated('Use listTasksRequestDescriptor instead')
const ListTasksRequest$json = {
  '1': 'ListTasksRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'assigned_to', '3': 3, '4': 1, '5': 9, '10': 'assignedTo'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.task.v1.TaskStatus',
      '10': 'status'
    },
    {
      '1': 'priority',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.task.v1.TaskPriority',
      '10': 'priority'
    },
    {'1': 'page_size', '3': 6, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 7, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListTasksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTasksRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0VGFza3NSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIZCghmaWVsZF9pZB'
    'gCIAEoCVIHZmllbGRJZBIfCgthc3NpZ25lZF90bxgDIAEoCVIKYXNzaWduZWRUbxI3CgZzdGF0'
    'dXMYBCABKA4yHy5hZ3JpY3VsdHVyZS50YXNrLnYxLlRhc2tTdGF0dXNSBnN0YXR1cxI9Cghwcm'
    'lvcml0eRgFIAEoDjIhLmFncmljdWx0dXJlLnRhc2sudjEuVGFza1ByaW9yaXR5Ughwcmlvcml0'
    'eRIbCglwYWdlX3NpemUYBiABKAVSCHBhZ2VTaXplEh0KCnBhZ2VfdG9rZW4YByABKAlSCXBhZ2'
    'VUb2tlbg==');

@$core.Deprecated('Use listTasksResponseDescriptor instead')
const ListTasksResponse$json = {
  '1': 'ListTasksResponse',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.task.v1.Task',
      '10': 'tasks'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListTasksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTasksResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0VGFza3NSZXNwb25zZRIvCgV0YXNrcxgBIAMoCzIZLmFncmljdWx0dXJlLnRhc2sudj'
    'EuVGFza1IFdGFza3MSJgoPbmV4dF9wYWdlX3Rva2VuGAIgASgJUg1uZXh0UGFnZVRva2VuEh8K'
    'C3RvdGFsX2NvdW50GAMgASgFUgp0b3RhbENvdW50');

@$core.Deprecated('Use createTaskRequestDescriptor instead')
const CreateTaskRequest$json = {
  '1': 'CreateTaskRequest',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'priority',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.task.v1.TaskPriority',
      '10': 'priority'
    },
    {'1': 'assigned_to', '3': 4, '4': 1, '5': 9, '10': 'assignedTo'},
    {'1': 'farm_id', '3': 5, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 6, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'due_date',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'dueDate'
    },
  ],
};

/// Descriptor for `CreateTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTaskRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVUYXNrUmVxdWVzdBIUCgV0aXRsZRgBIAEoCVIFdGl0bGUSIAoLZGVzY3JpcHRpb2'
    '4YAiABKAlSC2Rlc2NyaXB0aW9uEj0KCHByaW9yaXR5GAMgASgOMiEuYWdyaWN1bHR1cmUudGFz'
    'ay52MS5UYXNrUHJpb3JpdHlSCHByaW9yaXR5Eh8KC2Fzc2lnbmVkX3RvGAQgASgJUgphc3NpZ2'
    '5lZFRvEhcKB2Zhcm1faWQYBSABKAlSBmZhcm1JZBIZCghmaWVsZF9pZBgGIAEoCVIHZmllbGRJ'
    'ZBI1CghkdWVfZGF0ZRgHIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSB2R1ZURhdG'
    'U=');

@$core.Deprecated('Use createTaskResponseDescriptor instead')
const CreateTaskResponse$json = {
  '1': 'CreateTaskResponse',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.task.v1.Task',
      '10': 'task'
    },
  ],
};

/// Descriptor for `CreateTaskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTaskResponseDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVUYXNrUmVzcG9uc2USLQoEdGFzaxgBIAEoCzIZLmFncmljdWx0dXJlLnRhc2sudj'
    'EuVGFza1IEdGFzaw==');

@$core.Deprecated('Use updateTaskRequestDescriptor instead')
const UpdateTaskRequest$json = {
  '1': 'UpdateTaskRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.task.v1.TaskStatus',
      '10': 'status'
    },
    {
      '1': 'priority',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.task.v1.TaskPriority',
      '10': 'priority'
    },
    {'1': 'assigned_to', '3': 6, '4': 1, '5': 9, '10': 'assignedTo'},
    {'1': 'field_id', '3': 7, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'due_date',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'dueDate'
    },
    {
      '1': 'update_mask',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
  ],
};

/// Descriptor for `UpdateTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateTaskRequestDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVUYXNrUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSFAoFdGl0bGUYAiABKAlSBXRpdG'
    'xlEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhI3CgZzdGF0dXMYBCABKA4yHy5h'
    'Z3JpY3VsdHVyZS50YXNrLnYxLlRhc2tTdGF0dXNSBnN0YXR1cxI9Cghwcmlvcml0eRgFIAEoDj'
    'IhLmFncmljdWx0dXJlLnRhc2sudjEuVGFza1ByaW9yaXR5Ughwcmlvcml0eRIfCgthc3NpZ25l'
    'ZF90bxgGIAEoCVIKYXNzaWduZWRUbxIZCghmaWVsZF9pZBgHIAEoCVIHZmllbGRJZBI1CghkdW'
    'VfZGF0ZRgIIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSB2R1ZURhdGUSOwoLdXBk'
    'YXRlX21hc2sYCSABKAsyGi5nb29nbGUucHJvdG9idWYuRmllbGRNYXNrUgp1cGRhdGVNYXNr');

@$core.Deprecated('Use updateTaskResponseDescriptor instead')
const UpdateTaskResponse$json = {
  '1': 'UpdateTaskResponse',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.task.v1.Task',
      '10': 'task'
    },
  ],
};

/// Descriptor for `UpdateTaskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateTaskResponseDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVUYXNrUmVzcG9uc2USLQoEdGFzaxgBIAEoCzIZLmFncmljdWx0dXJlLnRhc2sudj'
    'EuVGFza1IEdGFzaw==');

@$core.Deprecated('Use deleteTaskRequestDescriptor instead')
const DeleteTaskRequest$json = {
  '1': 'DeleteTaskRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteTaskRequestDescriptor =
    $convert.base64Decode('ChFEZWxldGVUYXNrUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use deleteTaskResponseDescriptor instead')
const DeleteTaskResponse$json = {
  '1': 'DeleteTaskResponse',
};

/// Descriptor for `DeleteTaskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteTaskResponseDescriptor =
    $convert.base64Decode('ChJEZWxldGVUYXNrUmVzcG9uc2U=');

const $core.Map<$core.String, $core.dynamic> TaskServiceBase$json = {
  '1': 'TaskService',
  '2': [
    {
      '1': 'GetTask',
      '2': '.agriculture.task.v1.GetTaskRequest',
      '3': '.agriculture.task.v1.GetTaskResponse'
    },
    {
      '1': 'ListTasks',
      '2': '.agriculture.task.v1.ListTasksRequest',
      '3': '.agriculture.task.v1.ListTasksResponse'
    },
    {
      '1': 'CreateTask',
      '2': '.agriculture.task.v1.CreateTaskRequest',
      '3': '.agriculture.task.v1.CreateTaskResponse'
    },
    {
      '1': 'UpdateTask',
      '2': '.agriculture.task.v1.UpdateTaskRequest',
      '3': '.agriculture.task.v1.UpdateTaskResponse'
    },
    {
      '1': 'DeleteTask',
      '2': '.agriculture.task.v1.DeleteTaskRequest',
      '3': '.agriculture.task.v1.DeleteTaskResponse'
    },
  ],
};

@$core.Deprecated('Use taskServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    TaskServiceBase$messageJson = {
  '.agriculture.task.v1.GetTaskRequest': GetTaskRequest$json,
  '.agriculture.task.v1.GetTaskResponse': GetTaskResponse$json,
  '.agriculture.task.v1.Task': Task$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.task.v1.ListTasksRequest': ListTasksRequest$json,
  '.agriculture.task.v1.ListTasksResponse': ListTasksResponse$json,
  '.agriculture.task.v1.CreateTaskRequest': CreateTaskRequest$json,
  '.agriculture.task.v1.CreateTaskResponse': CreateTaskResponse$json,
  '.agriculture.task.v1.UpdateTaskRequest': UpdateTaskRequest$json,
  '.google.protobuf.FieldMask': $1.FieldMask$json,
  '.agriculture.task.v1.UpdateTaskResponse': UpdateTaskResponse$json,
  '.agriculture.task.v1.DeleteTaskRequest': DeleteTaskRequest$json,
  '.agriculture.task.v1.DeleteTaskResponse': DeleteTaskResponse$json,
};

/// Descriptor for `TaskService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List taskServiceDescriptor = $convert.base64Decode(
    'CgtUYXNrU2VydmljZRJUCgdHZXRUYXNrEiMuYWdyaWN1bHR1cmUudGFzay52MS5HZXRUYXNrUm'
    'VxdWVzdBokLmFncmljdWx0dXJlLnRhc2sudjEuR2V0VGFza1Jlc3BvbnNlEloKCUxpc3RUYXNr'
    'cxIlLmFncmljdWx0dXJlLnRhc2sudjEuTGlzdFRhc2tzUmVxdWVzdBomLmFncmljdWx0dXJlLn'
    'Rhc2sudjEuTGlzdFRhc2tzUmVzcG9uc2USXQoKQ3JlYXRlVGFzaxImLmFncmljdWx0dXJlLnRh'
    'c2sudjEuQ3JlYXRlVGFza1JlcXVlc3QaJy5hZ3JpY3VsdHVyZS50YXNrLnYxLkNyZWF0ZVRhc2'
    'tSZXNwb25zZRJdCgpVcGRhdGVUYXNrEiYuYWdyaWN1bHR1cmUudGFzay52MS5VcGRhdGVUYXNr'
    'UmVxdWVzdBonLmFncmljdWx0dXJlLnRhc2sudjEuVXBkYXRlVGFza1Jlc3BvbnNlEl0KCkRlbG'
    'V0ZVRhc2sSJi5hZ3JpY3VsdHVyZS50YXNrLnYxLkRlbGV0ZVRhc2tSZXF1ZXN0GicuYWdyaWN1'
    'bHR1cmUudGFzay52MS5EZWxldGVUYXNrUmVzcG9uc2U=');
