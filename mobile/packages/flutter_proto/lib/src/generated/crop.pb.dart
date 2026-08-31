/// Simulated protobuf generated code for crop models.
import 'package:protobuf/protobuf.dart' as $pb;

/// A crop entity with type and growth information.
class Crop extends $pb.GeneratedMessage {
  factory Crop({
    String? id,
    String? name,
    String? variety,
    List<GrowthStage>? growthStages,
    String? type,
    String? plantingDate,
    String? harvestDate,
  }) {
    final msg = Crop._();
    if (id != null) msg.id = id;
    if (name != null) msg.name = name;
    if (variety != null) msg.variety = variety;
    if (growthStages != null) msg.growthStages.addAll(growthStages);
    if (type != null) msg.type = type;
    if (plantingDate != null) msg.plantingDate = plantingDate;
    if (harvestDate != null) msg.harvestDate = harvestDate;
    return msg;
  }

  Crop._() : super();

  factory Crop.fromBuffer(List<int> data) => Crop._()..mergeFromBuffer(data);
  factory Crop.fromJson(String json) => Crop._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'Crop',
    package: const $pb.PackageName('yieldpoint.crop.v1'),
    createEmptyInstance: () => Crop._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'name')
    ..aOS(3, 'variety')
    ..pc<GrowthStage>(4, 'growthStages', $pb.PbFieldType.PM,
        protoName: 'growthStages', subBuilder: GrowthStage._)
    ..aOS(5, 'type')
    ..aOS(6, 'plantingDate', protoName: 'plantingDate')
    ..aOS(7, 'harvestDate', protoName: 'harvestDate')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  Crop createEmptyInstance() => Crop._();
  static Crop getDefault() => _defaultInstance ??= Crop._();
  static Crop? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get variety => $_getSZ(2);
  @$pb.TagNumber(3)
  set variety(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  $pb.PbList<GrowthStage> get growthStages => $_getList(3);

  @$pb.TagNumber(5)
  String get type => $_getSZ(4);
  @$pb.TagNumber(5)
  set type(String v) => $_setString(4, v);

  @$pb.TagNumber(6)
  String get plantingDate => $_getSZ(5);
  @$pb.TagNumber(6)
  set plantingDate(String v) => $_setString(5, v);

  @$pb.TagNumber(7)
  String get harvestDate => $_getSZ(6);
  @$pb.TagNumber(7)
  set harvestDate(String v) => $_setString(6, v);
}

/// A variety of a crop.
class CropVariety extends $pb.GeneratedMessage {
  factory CropVariety({
    String? id,
    String? cropId,
    String? name,
    String? characteristics,
  }) {
    final msg = CropVariety._();
    if (id != null) msg.id = id;
    if (cropId != null) msg.cropId = cropId;
    if (name != null) msg.name = name;
    if (characteristics != null) msg.characteristics = characteristics;
    return msg;
  }

  CropVariety._() : super();

  factory CropVariety.fromBuffer(List<int> data) =>
      CropVariety._()..mergeFromBuffer(data);
  factory CropVariety.fromJson(String json) =>
      CropVariety._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'CropVariety',
    package: const $pb.PackageName('yieldpoint.crop.v1'),
    createEmptyInstance: () => CropVariety._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'cropId', protoName: 'cropId')
    ..aOS(3, 'name')
    ..aOS(4, 'characteristics')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  CropVariety createEmptyInstance() => CropVariety._();
  static CropVariety getDefault() => _defaultInstance ??= CropVariety._();
  static CropVariety? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get cropId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  String get characteristics => $_getSZ(3);
  @$pb.TagNumber(4)
  set characteristics(String v) => $_setString(3, v);
}

/// Requirements for growing a crop.
class CropRequirements extends $pb.GeneratedMessage {
  factory CropRequirements({
    String? cropId,
    double? minTemp,
    double? maxTemp,
    double? waterNeeds,
    String? soilType,
  }) {
    final msg = CropRequirements._();
    if (cropId != null) msg.cropId = cropId;
    if (minTemp != null) msg.minTemp = minTemp;
    if (maxTemp != null) msg.maxTemp = maxTemp;
    if (waterNeeds != null) msg.waterNeeds = waterNeeds;
    if (soilType != null) msg.soilType = soilType;
    return msg;
  }

  CropRequirements._() : super();

  factory CropRequirements.fromBuffer(List<int> data) =>
      CropRequirements._()..mergeFromBuffer(data);
  factory CropRequirements.fromJson(String json) =>
      CropRequirements._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'CropRequirements',
    package: const $pb.PackageName('yieldpoint.crop.v1'),
    createEmptyInstance: () => CropRequirements._(),
  )
    ..aOS(1, 'cropId', protoName: 'cropId')
    ..a<double>(2, 'minTemp', $pb.PbFieldType.OD, protoName: 'minTemp')
    ..a<double>(3, 'maxTemp', $pb.PbFieldType.OD, protoName: 'maxTemp')
    ..a<double>(4, 'waterNeeds', $pb.PbFieldType.OD, protoName: 'waterNeeds')
    ..aOS(5, 'soilType', protoName: 'soilType')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  CropRequirements createEmptyInstance() => CropRequirements._();
  static CropRequirements getDefault() =>
      _defaultInstance ??= CropRequirements._();
  static CropRequirements? _defaultInstance;

  @$pb.TagNumber(1)
  String get cropId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cropId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  double get minTemp => $_getN(1);
  @$pb.TagNumber(2)
  set minTemp(double v) => $_setDouble(1, v);

  @$pb.TagNumber(3)
  double get maxTemp => $_getN(2);
  @$pb.TagNumber(3)
  set maxTemp(double v) => $_setDouble(2, v);

  @$pb.TagNumber(4)
  double get waterNeeds => $_getN(3);
  @$pb.TagNumber(4)
  set waterNeeds(double v) => $_setDouble(3, v);

  @$pb.TagNumber(5)
  String get soilType => $_getSZ(4);
  @$pb.TagNumber(5)
  set soilType(String v) => $_setString(4, v);
}

/// A growth stage of a crop.
class GrowthStage extends $pb.GeneratedMessage {
  factory GrowthStage({
    String? id,
    String? cropId,
    String? name,
    int? durationDays,
    String? description,
  }) {
    final msg = GrowthStage._();
    if (id != null) msg.id = id;
    if (cropId != null) msg.cropId = cropId;
    if (name != null) msg.name = name;
    if (durationDays != null) msg.durationDays = durationDays;
    if (description != null) msg.description = description;
    return msg;
  }

  GrowthStage._() : super();

  factory GrowthStage.fromBuffer(List<int> data) =>
      GrowthStage._()..mergeFromBuffer(data);
  factory GrowthStage.fromJson(String json) =>
      GrowthStage._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'GrowthStage',
    package: const $pb.PackageName('yieldpoint.crop.v1'),
    createEmptyInstance: () => GrowthStage._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'cropId', protoName: 'cropId')
    ..aOS(3, 'name')
    ..a<int>(4, 'durationDays', $pb.PbFieldType.O3,
        protoName: 'durationDays')
    ..aOS(5, 'description')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  GrowthStage createEmptyInstance() => GrowthStage._();
  static GrowthStage getDefault() => _defaultInstance ??= GrowthStage._();
  static GrowthStage? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get cropId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  int get durationDays => $_getIZ(3);
  @$pb.TagNumber(4)
  set durationDays(int v) => $_setSignedInt32(3, v);

  @$pb.TagNumber(5)
  String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description(String v) => $_setString(4, v);
}
