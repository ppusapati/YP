/// Simulated protobuf generated code for field observation models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import 'farm.pb.dart';

/// A field observation recorded by a scout or farmer.
class FieldObservation extends $pb.GeneratedMessage {
  factory FieldObservation({
    String? id,
    String? fieldId,
    LatLng? location,
    List<String>? photos,
    String? notes,
    Int64? timestamp,
    String? category,
  }) {
    final msg = FieldObservation._();
    if (id != null) msg.id = id;
    if (fieldId != null) msg.fieldId = fieldId;
    if (location != null) msg.location = location;
    if (photos != null) msg.photos.addAll(photos);
    if (notes != null) msg.notes = notes;
    if (timestamp != null) msg.timestamp = timestamp;
    if (category != null) msg.category = category;
    return msg;
  }

  FieldObservation._() : super();

  factory FieldObservation.fromBuffer(List<int> data) =>
      FieldObservation._()..mergeFromBuffer(data);
  factory FieldObservation.fromJson(String json) =>
      FieldObservation._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'FieldObservation',
    package: const $pb.PackageName('yieldpoint.observation.v1'),
    createEmptyInstance: () => FieldObservation._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'fieldId', protoName: 'fieldId')
    ..aOM<LatLng>(3, 'location', subBuilder: LatLng._)
    ..pPS(4, 'photos')
    ..aOS(5, 'notes')
    ..aInt64(6, 'timestamp')
    ..aOS(7, 'category')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  FieldObservation createEmptyInstance() => FieldObservation._();
  static FieldObservation getDefault() =>
      _defaultInstance ??= FieldObservation._();
  static FieldObservation? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);
  @$pb.TagNumber(1)
  bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId(String v) => $_setString(1, v);
  @$pb.TagNumber(2)
  bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => clearField(2);

  @$pb.TagNumber(3)
  LatLng get location => $_getN(2);
  @$pb.TagNumber(3)
  set location(LatLng v) => setField(3, v);
  @$pb.TagNumber(3)
  bool hasLocation() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocation() => clearField(3);
  @$pb.TagNumber(3)
  LatLng ensureLocation() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<String> get photos => $_getList(3);

  @$pb.TagNumber(5)
  String get notes => $_getSZ(4);
  @$pb.TagNumber(5)
  set notes(String v) => $_setString(4, v);
  @$pb.TagNumber(5)
  bool hasNotes() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotes() => clearField(5);

  @$pb.TagNumber(6)
  Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set timestamp(Int64 v) => $_setInt64(5, v);
  @$pb.TagNumber(6)
  bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => clearField(6);

  @$pb.TagNumber(7)
  String get category => $_getSZ(6);
  @$pb.TagNumber(7)
  set category(String v) => $_setString(6, v);
  @$pb.TagNumber(7)
  bool hasCategory() => $_has(6);
  @$pb.TagNumber(7)
  void clearCategory() => clearField(7);
}
