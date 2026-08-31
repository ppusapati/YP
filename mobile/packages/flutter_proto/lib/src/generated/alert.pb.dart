/// Simulated protobuf generated code for alert models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

/// The type of alert.
class AlertType extends $pb.ProtobufEnum {
  static const AlertType CROP_STRESS = AlertType._(0, 'CROP_STRESS');
  static const AlertType WATER_SHORTAGE = AlertType._(1, 'WATER_SHORTAGE');
  static const AlertType DISEASE_OUTBREAK = AlertType._(2, 'DISEASE_OUTBREAK');
  static const AlertType PEST_OUTBREAK = AlertType._(3, 'PEST_OUTBREAK');

  static const List<AlertType> values = [
    CROP_STRESS,
    WATER_SHORTAGE,
    DISEASE_OUTBREAK,
    PEST_OUTBREAK,
  ];

  static final Map<int, AlertType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static AlertType? valueOf(int value) => _byValue[value];

  const AlertType._(int v, String n) : super(v, n);
}

/// An alert notification for a farm or field.
class Alert extends $pb.GeneratedMessage {
  factory Alert({
    String? id,
    AlertType? type,
    String? title,
    String? message,
    String? severity,
    String? farmId,
    String? fieldId,
    Int64? timestamp,
    bool? read,
  }) {
    final msg = Alert._();
    if (id != null) msg.id = id;
    if (type != null) msg.type = type;
    if (title != null) msg.title = title;
    if (message != null) msg.message = message;
    if (severity != null) msg.severity = severity;
    if (farmId != null) msg.farmId = farmId;
    if (fieldId != null) msg.fieldId = fieldId;
    if (timestamp != null) msg.timestamp = timestamp;
    if (read != null) msg.read = read;
    return msg;
  }

  Alert._() : super();

  factory Alert.fromBuffer(List<int> data) =>
      Alert._()..mergeFromBuffer(data);
  factory Alert.fromJson(String json) => Alert._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'Alert',
    package: const $pb.PackageName('yieldpoint.alert.v1'),
    createEmptyInstance: () => Alert._(),
  )
    ..aOS(1, 'id')
    ..e<AlertType>(2, 'type', $pb.PbFieldType.OE,
        defaultOrMaker: AlertType.CROP_STRESS,
        valueOf: AlertType.valueOf,
        enumValues: AlertType.values)
    ..aOS(3, 'title')
    ..aOS(4, 'message')
    ..aOS(5, 'severity')
    ..aOS(6, 'farmId', protoName: 'farmId')
    ..aOS(7, 'fieldId', protoName: 'fieldId')
    ..aInt64(8, 'timestamp')
    ..aOB(9, 'read')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  Alert createEmptyInstance() => Alert._();
  static Alert getDefault() => _defaultInstance ??= Alert._();
  static Alert? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);
  @$pb.TagNumber(1)
  bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  AlertType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(AlertType v) => setField(2, v);
  @$pb.TagNumber(2)
  bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title(String v) => $_setString(2, v);
  @$pb.TagNumber(3)
  bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => clearField(3);

  @$pb.TagNumber(4)
  String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message(String v) => $_setString(3, v);
  @$pb.TagNumber(4)
  bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => clearField(4);

  @$pb.TagNumber(5)
  String get severity => $_getSZ(4);
  @$pb.TagNumber(5)
  set severity(String v) => $_setString(4, v);

  @$pb.TagNumber(6)
  String get farmId => $_getSZ(5);
  @$pb.TagNumber(6)
  set farmId(String v) => $_setString(5, v);

  @$pb.TagNumber(7)
  String get fieldId => $_getSZ(6);
  @$pb.TagNumber(7)
  set fieldId(String v) => $_setString(6, v);

  @$pb.TagNumber(8)
  Int64 get timestamp => $_getI64(7);
  @$pb.TagNumber(8)
  set timestamp(Int64 v) => $_setInt64(7, v);

  @$pb.TagNumber(9)
  bool get read => $_getBF(8);
  @$pb.TagNumber(9)
  set read(bool v) => $_setBool(8, v);
  @$pb.TagNumber(9)
  bool hasRead() => $_has(8);
  @$pb.TagNumber(9)
  void clearRead() => clearField(9);
}
