/// Simulated protobuf generated code for farm task models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import 'farm.pb.dart';

/// The type of farm task.
class TaskType extends $pb.ProtobufEnum {
  static const TaskType PLANTING = TaskType._(0, 'PLANTING');
  static const TaskType HARVESTING = TaskType._(1, 'HARVESTING');
  static const TaskType SPRAYING = TaskType._(2, 'SPRAYING');
  static const TaskType IRRIGATION = TaskType._(3, 'IRRIGATION');
  static const TaskType SCOUTING = TaskType._(4, 'SCOUTING');
  static const TaskType MAINTENANCE = TaskType._(5, 'MAINTENANCE');
  static const TaskType SOIL_SAMPLING = TaskType._(6, 'SOIL_SAMPLING');
  static const TaskType FERTILIZING = TaskType._(7, 'FERTILIZING');

  static const List<TaskType> values = [
    PLANTING,
    HARVESTING,
    SPRAYING,
    IRRIGATION,
    SCOUTING,
    MAINTENANCE,
    SOIL_SAMPLING,
    FERTILIZING,
  ];

  static final Map<int, TaskType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static TaskType? valueOf(int value) => _byValue[value];

  const TaskType._(int v, String n) : super(v, n);
}

/// The status of a farm task.
class TaskStatus extends $pb.ProtobufEnum {
  static const TaskStatus PENDING = TaskStatus._(0, 'PENDING');
  static const TaskStatus IN_PROGRESS = TaskStatus._(1, 'IN_PROGRESS');
  static const TaskStatus COMPLETED = TaskStatus._(2, 'COMPLETED');
  static const TaskStatus CANCELLED = TaskStatus._(3, 'CANCELLED');
  static const TaskStatus OVERDUE = TaskStatus._(4, 'OVERDUE');

  static const List<TaskStatus> values = [
    PENDING,
    IN_PROGRESS,
    COMPLETED,
    CANCELLED,
    OVERDUE,
  ];

  static final Map<int, TaskStatus> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static TaskStatus? valueOf(int value) => _byValue[value];

  const TaskStatus._(int v, String n) : super(v, n);
}

/// A farm task with metadata, assignment, and scheduling.
class FarmTask extends $pb.GeneratedMessage {
  factory FarmTask({
    String? id,
    String? farmId,
    String? title,
    String? description,
    TaskType? taskType,
    TaskStatus? status,
    LatLng? location,
    String? assignee,
    Int64? dueDate,
  }) {
    final msg = FarmTask._();
    if (id != null) msg.id = id;
    if (farmId != null) msg.farmId = farmId;
    if (title != null) msg.title = title;
    if (description != null) msg.description = description;
    if (taskType != null) msg.taskType = taskType;
    if (status != null) msg.status = status;
    if (location != null) msg.location = location;
    if (assignee != null) msg.assignee = assignee;
    if (dueDate != null) msg.dueDate = dueDate;
    return msg;
  }

  FarmTask._() : super();

  factory FarmTask.fromBuffer(List<int> data) =>
      FarmTask._()..mergeFromBuffer(data);
  factory FarmTask.fromJson(String json) =>
      FarmTask._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'FarmTask',
    package: const $pb.PackageName('yieldpoint.task.v1'),
    createEmptyInstance: () => FarmTask._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'farmId', protoName: 'farmId')
    ..aOS(3, 'title')
    ..aOS(4, 'description')
    ..e<TaskType>(5, 'taskType', $pb.PbFieldType.OE,
        protoName: 'taskType',
        defaultOrMaker: TaskType.PLANTING,
        valueOf: TaskType.valueOf,
        enumValues: TaskType.values)
    ..e<TaskStatus>(6, 'status', $pb.PbFieldType.OE,
        defaultOrMaker: TaskStatus.PENDING,
        valueOf: TaskStatus.valueOf,
        enumValues: TaskStatus.values)
    ..aOM<LatLng>(7, 'location', subBuilder: LatLng._)
    ..aOS(8, 'assignee')
    ..aInt64(9, 'dueDate', protoName: 'dueDate')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  FarmTask createEmptyInstance() => FarmTask._();
  static FarmTask getDefault() => _defaultInstance ??= FarmTask._();
  static FarmTask? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);
  @$pb.TagNumber(1)
  bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId(String v) => $_setString(1, v);
  @$pb.TagNumber(2)
  bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => clearField(2);

  @$pb.TagNumber(3)
  String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title(String v) => $_setString(2, v);
  @$pb.TagNumber(3)
  bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => clearField(3);

  @$pb.TagNumber(4)
  String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description(String v) => $_setString(3, v);
  @$pb.TagNumber(4)
  bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => clearField(4);

  @$pb.TagNumber(5)
  TaskType get taskType => $_getN(4);
  @$pb.TagNumber(5)
  set taskType(TaskType v) => setField(5, v);
  @$pb.TagNumber(5)
  bool hasTaskType() => $_has(4);
  @$pb.TagNumber(5)
  void clearTaskType() => clearField(5);

  @$pb.TagNumber(6)
  TaskStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(TaskStatus v) => setField(6, v);
  @$pb.TagNumber(6)
  bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => clearField(6);

  @$pb.TagNumber(7)
  LatLng get location => $_getN(6);
  @$pb.TagNumber(7)
  set location(LatLng v) => setField(7, v);
  @$pb.TagNumber(7)
  bool hasLocation() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocation() => clearField(7);
  @$pb.TagNumber(7)
  LatLng ensureLocation() => $_ensure(6);

  @$pb.TagNumber(8)
  String get assignee => $_getSZ(7);
  @$pb.TagNumber(8)
  set assignee(String v) => $_setString(7, v);
  @$pb.TagNumber(8)
  bool hasAssignee() => $_has(7);
  @$pb.TagNumber(8)
  void clearAssignee() => clearField(8);

  @$pb.TagNumber(9)
  Int64 get dueDate => $_getI64(8);
  @$pb.TagNumber(9)
  set dueDate(Int64 v) => $_setInt64(8, v);
  @$pb.TagNumber(9)
  bool hasDueDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearDueDate() => clearField(9);
}
