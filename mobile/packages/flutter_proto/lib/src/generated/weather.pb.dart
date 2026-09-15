// This is a generated file - do not edit.
//
// Generated from weather.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'weather.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'weather.pbenum.dart';

class FieldLocation extends $pb.GeneratedMessage {
  factory FieldLocation({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    $core.double? latitude,
    $core.double? longitude,
    $core.double? elevationM,
    $core.String? timezone,
    WeatherProvider? provider,
    $0.Timestamp? lastPolledAt,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (elevationM != null) result.elevationM = elevationM;
    if (timezone != null) result.timezone = timezone;
    if (provider != null) result.provider = provider;
    if (lastPolledAt != null) result.lastPolledAt = lastPolledAt;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  FieldLocation._();

  factory FieldLocation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FieldLocation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldLocation',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aD(5, _omitFieldNames ? '' : 'latitude')
    ..aD(6, _omitFieldNames ? '' : 'longitude')
    ..aD(7, _omitFieldNames ? '' : 'elevationM')
    ..aOS(8, _omitFieldNames ? '' : 'timezone')
    ..aE<WeatherProvider>(9, _omitFieldNames ? '' : 'provider',
        enumValues: WeatherProvider.values)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'lastPolledAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldLocation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldLocation copyWith(void Function(FieldLocation) updates) =>
      super.copyWith((message) => updates(message as FieldLocation))
          as FieldLocation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldLocation create() => FieldLocation._();
  @$core.override
  FieldLocation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FieldLocation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldLocation>(create);
  static FieldLocation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get farmId => $_getSZ(3);
  @$pb.TagNumber(4)
  set farmId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFarmId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFarmId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get latitude => $_getN(4);
  @$pb.TagNumber(5)
  set latitude($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLatitude() => $_has(4);
  @$pb.TagNumber(5)
  void clearLatitude() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get longitude => $_getN(5);
  @$pb.TagNumber(6)
  set longitude($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLongitude() => $_has(5);
  @$pb.TagNumber(6)
  void clearLongitude() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get elevationM => $_getN(6);
  @$pb.TagNumber(7)
  set elevationM($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasElevationM() => $_has(6);
  @$pb.TagNumber(7)
  void clearElevationM() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get timezone => $_getSZ(7);
  @$pb.TagNumber(8)
  set timezone($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTimezone() => $_has(7);
  @$pb.TagNumber(8)
  void clearTimezone() => $_clearField(8);

  @$pb.TagNumber(9)
  WeatherProvider get provider => $_getN(8);
  @$pb.TagNumber(9)
  set provider(WeatherProvider value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasProvider() => $_has(8);
  @$pb.TagNumber(9)
  void clearProvider() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get lastPolledAt => $_getN(9);
  @$pb.TagNumber(10)
  set lastPolledAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasLastPolledAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearLastPolledAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureLastPolledAt() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Timestamp get createdAt => $_getN(10);
  @$pb.TagNumber(11)
  set createdAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreatedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureCreatedAt() => $_ensure(10);

  @$pb.TagNumber(12)
  $0.Timestamp get updatedAt => $_getN(11);
  @$pb.TagNumber(12)
  set updatedAt($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasUpdatedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearUpdatedAt() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureUpdatedAt() => $_ensure(11);
}

class Observation extends $pb.GeneratedMessage {
  factory Observation({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $0.Timestamp? observedAt,
    $core.double? temperatureC,
    $core.double? humidityPct,
    $core.double? precipitationMm,
    $core.double? windSpeedMs,
    $core.double? windDirectionDeg,
    $core.double? pressureHpa,
    $core.double? solarRadiationWm2,
    $core.double? cloudCoverPct,
    $core.double? dewPointC,
    $core.double? soilTemperatureC,
    $core.double? soilMoistureM3m3,
    WeatherProvider? provider,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (observedAt != null) result.observedAt = observedAt;
    if (temperatureC != null) result.temperatureC = temperatureC;
    if (humidityPct != null) result.humidityPct = humidityPct;
    if (precipitationMm != null) result.precipitationMm = precipitationMm;
    if (windSpeedMs != null) result.windSpeedMs = windSpeedMs;
    if (windDirectionDeg != null) result.windDirectionDeg = windDirectionDeg;
    if (pressureHpa != null) result.pressureHpa = pressureHpa;
    if (solarRadiationWm2 != null) result.solarRadiationWm2 = solarRadiationWm2;
    if (cloudCoverPct != null) result.cloudCoverPct = cloudCoverPct;
    if (dewPointC != null) result.dewPointC = dewPointC;
    if (soilTemperatureC != null) result.soilTemperatureC = soilTemperatureC;
    if (soilMoistureM3m3 != null) result.soilMoistureM3m3 = soilMoistureM3m3;
    if (provider != null) result.provider = provider;
    return result;
  }

  Observation._();

  factory Observation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Observation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Observation',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'observedAt',
        subBuilder: $0.Timestamp.create)
    ..aD(5, _omitFieldNames ? '' : 'temperatureC')
    ..aD(6, _omitFieldNames ? '' : 'humidityPct')
    ..aD(7, _omitFieldNames ? '' : 'precipitationMm')
    ..aD(8, _omitFieldNames ? '' : 'windSpeedMs')
    ..aD(9, _omitFieldNames ? '' : 'windDirectionDeg')
    ..aD(10, _omitFieldNames ? '' : 'pressureHpa')
    ..aD(11, _omitFieldNames ? '' : 'solarRadiationWm2')
    ..aD(12, _omitFieldNames ? '' : 'cloudCoverPct')
    ..aD(13, _omitFieldNames ? '' : 'dewPointC')
    ..aD(14, _omitFieldNames ? '' : 'soilTemperatureC')
    ..aD(15, _omitFieldNames ? '' : 'soilMoistureM3m3')
    ..aE<WeatherProvider>(16, _omitFieldNames ? '' : 'provider',
        enumValues: WeatherProvider.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Observation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Observation copyWith(void Function(Observation) updates) =>
      super.copyWith((message) => updates(message as Observation))
          as Observation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Observation create() => Observation._();
  @$core.override
  Observation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Observation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Observation>(create);
  static Observation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldId() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get observedAt => $_getN(3);
  @$pb.TagNumber(4)
  set observedAt($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasObservedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearObservedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureObservedAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.double get temperatureC => $_getN(4);
  @$pb.TagNumber(5)
  set temperatureC($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTemperatureC() => $_has(4);
  @$pb.TagNumber(5)
  void clearTemperatureC() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get humidityPct => $_getN(5);
  @$pb.TagNumber(6)
  set humidityPct($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHumidityPct() => $_has(5);
  @$pb.TagNumber(6)
  void clearHumidityPct() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get precipitationMm => $_getN(6);
  @$pb.TagNumber(7)
  set precipitationMm($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPrecipitationMm() => $_has(6);
  @$pb.TagNumber(7)
  void clearPrecipitationMm() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get windSpeedMs => $_getN(7);
  @$pb.TagNumber(8)
  set windSpeedMs($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWindSpeedMs() => $_has(7);
  @$pb.TagNumber(8)
  void clearWindSpeedMs() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get windDirectionDeg => $_getN(8);
  @$pb.TagNumber(9)
  set windDirectionDeg($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWindDirectionDeg() => $_has(8);
  @$pb.TagNumber(9)
  void clearWindDirectionDeg() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get pressureHpa => $_getN(9);
  @$pb.TagNumber(10)
  set pressureHpa($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPressureHpa() => $_has(9);
  @$pb.TagNumber(10)
  void clearPressureHpa() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get solarRadiationWm2 => $_getN(10);
  @$pb.TagNumber(11)
  set solarRadiationWm2($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSolarRadiationWm2() => $_has(10);
  @$pb.TagNumber(11)
  void clearSolarRadiationWm2() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get cloudCoverPct => $_getN(11);
  @$pb.TagNumber(12)
  set cloudCoverPct($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasCloudCoverPct() => $_has(11);
  @$pb.TagNumber(12)
  void clearCloudCoverPct() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get dewPointC => $_getN(12);
  @$pb.TagNumber(13)
  set dewPointC($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDewPointC() => $_has(12);
  @$pb.TagNumber(13)
  void clearDewPointC() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get soilTemperatureC => $_getN(13);
  @$pb.TagNumber(14)
  set soilTemperatureC($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSoilTemperatureC() => $_has(13);
  @$pb.TagNumber(14)
  void clearSoilTemperatureC() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get soilMoistureM3m3 => $_getN(14);
  @$pb.TagNumber(15)
  set soilMoistureM3m3($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasSoilMoistureM3m3() => $_has(14);
  @$pb.TagNumber(15)
  void clearSoilMoistureM3m3() => $_clearField(15);

  @$pb.TagNumber(16)
  WeatherProvider get provider => $_getN(15);
  @$pb.TagNumber(16)
  set provider(WeatherProvider value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasProvider() => $_has(15);
  @$pb.TagNumber(16)
  void clearProvider() => $_clearField(16);
}

class DailyForecast extends $pb.GeneratedMessage {
  factory DailyForecast({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $0.Timestamp? forecastDate,
    $0.Timestamp? issuedAt,
    $core.double? temperatureMinC,
    $core.double? temperatureMaxC,
    $core.double? temperatureMeanC,
    $core.double? precipitationMm,
    $core.double? precipitationProb,
    $core.double? humidityMeanPct,
    $core.double? windSpeedMaxMs,
    $core.double? solarRadiationMj,
    $core.double? et0Mm,
    $core.String? condition,
    WeatherProvider? provider,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (forecastDate != null) result.forecastDate = forecastDate;
    if (issuedAt != null) result.issuedAt = issuedAt;
    if (temperatureMinC != null) result.temperatureMinC = temperatureMinC;
    if (temperatureMaxC != null) result.temperatureMaxC = temperatureMaxC;
    if (temperatureMeanC != null) result.temperatureMeanC = temperatureMeanC;
    if (precipitationMm != null) result.precipitationMm = precipitationMm;
    if (precipitationProb != null) result.precipitationProb = precipitationProb;
    if (humidityMeanPct != null) result.humidityMeanPct = humidityMeanPct;
    if (windSpeedMaxMs != null) result.windSpeedMaxMs = windSpeedMaxMs;
    if (solarRadiationMj != null) result.solarRadiationMj = solarRadiationMj;
    if (et0Mm != null) result.et0Mm = et0Mm;
    if (condition != null) result.condition = condition;
    if (provider != null) result.provider = provider;
    return result;
  }

  DailyForecast._();

  factory DailyForecast.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DailyForecast.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DailyForecast',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'forecastDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'issuedAt',
        subBuilder: $0.Timestamp.create)
    ..aD(6, _omitFieldNames ? '' : 'temperatureMinC')
    ..aD(7, _omitFieldNames ? '' : 'temperatureMaxC')
    ..aD(8, _omitFieldNames ? '' : 'temperatureMeanC')
    ..aD(9, _omitFieldNames ? '' : 'precipitationMm')
    ..aD(10, _omitFieldNames ? '' : 'precipitationProb')
    ..aD(11, _omitFieldNames ? '' : 'humidityMeanPct')
    ..aD(12, _omitFieldNames ? '' : 'windSpeedMaxMs')
    ..aD(13, _omitFieldNames ? '' : 'solarRadiationMj')
    ..aD(14, _omitFieldNames ? '' : 'et0Mm')
    ..aOS(15, _omitFieldNames ? '' : 'condition')
    ..aE<WeatherProvider>(16, _omitFieldNames ? '' : 'provider',
        enumValues: WeatherProvider.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DailyForecast clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DailyForecast copyWith(void Function(DailyForecast) updates) =>
      super.copyWith((message) => updates(message as DailyForecast))
          as DailyForecast;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DailyForecast create() => DailyForecast._();
  @$core.override
  DailyForecast createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DailyForecast getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DailyForecast>(create);
  static DailyForecast? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldId() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get forecastDate => $_getN(3);
  @$pb.TagNumber(4)
  set forecastDate($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasForecastDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearForecastDate() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureForecastDate() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Timestamp get issuedAt => $_getN(4);
  @$pb.TagNumber(5)
  set issuedAt($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasIssuedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearIssuedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureIssuedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.double get temperatureMinC => $_getN(5);
  @$pb.TagNumber(6)
  set temperatureMinC($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTemperatureMinC() => $_has(5);
  @$pb.TagNumber(6)
  void clearTemperatureMinC() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get temperatureMaxC => $_getN(6);
  @$pb.TagNumber(7)
  set temperatureMaxC($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTemperatureMaxC() => $_has(6);
  @$pb.TagNumber(7)
  void clearTemperatureMaxC() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get temperatureMeanC => $_getN(7);
  @$pb.TagNumber(8)
  set temperatureMeanC($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTemperatureMeanC() => $_has(7);
  @$pb.TagNumber(8)
  void clearTemperatureMeanC() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get precipitationMm => $_getN(8);
  @$pb.TagNumber(9)
  set precipitationMm($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPrecipitationMm() => $_has(8);
  @$pb.TagNumber(9)
  void clearPrecipitationMm() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get precipitationProb => $_getN(9);
  @$pb.TagNumber(10)
  set precipitationProb($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPrecipitationProb() => $_has(9);
  @$pb.TagNumber(10)
  void clearPrecipitationProb() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get humidityMeanPct => $_getN(10);
  @$pb.TagNumber(11)
  set humidityMeanPct($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasHumidityMeanPct() => $_has(10);
  @$pb.TagNumber(11)
  void clearHumidityMeanPct() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get windSpeedMaxMs => $_getN(11);
  @$pb.TagNumber(12)
  set windSpeedMaxMs($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasWindSpeedMaxMs() => $_has(11);
  @$pb.TagNumber(12)
  void clearWindSpeedMaxMs() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get solarRadiationMj => $_getN(12);
  @$pb.TagNumber(13)
  set solarRadiationMj($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSolarRadiationMj() => $_has(12);
  @$pb.TagNumber(13)
  void clearSolarRadiationMj() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get et0Mm => $_getN(13);
  @$pb.TagNumber(14)
  set et0Mm($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasEt0Mm() => $_has(13);
  @$pb.TagNumber(14)
  void clearEt0Mm() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get condition => $_getSZ(14);
  @$pb.TagNumber(15)
  set condition($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasCondition() => $_has(14);
  @$pb.TagNumber(15)
  void clearCondition() => $_clearField(15);

  @$pb.TagNumber(16)
  WeatherProvider get provider => $_getN(15);
  @$pb.TagNumber(16)
  set provider(WeatherProvider value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasProvider() => $_has(15);
  @$pb.TagNumber(16)
  void clearProvider() => $_clearField(16);
}

/// DailyAgroMetrics holds derived agronomic values for one field-day.
class DailyAgroMetrics extends $pb.GeneratedMessage {
  factory DailyAgroMetrics({
    $core.String? fieldId,
    $0.Timestamp? date,
    $core.double? temperatureMinC,
    $core.double? temperatureMaxC,
    $core.double? temperatureMeanC,
    $core.double? precipitationMm,
    $core.double? gdd,
    $core.double? et0Mm,
    $core.double? chillHours,
    $core.double? rainfallDeficitMm,
    $core.double? humidityMeanPct,
    $core.double? solarRadiationMj,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (date != null) result.date = date;
    if (temperatureMinC != null) result.temperatureMinC = temperatureMinC;
    if (temperatureMaxC != null) result.temperatureMaxC = temperatureMaxC;
    if (temperatureMeanC != null) result.temperatureMeanC = temperatureMeanC;
    if (precipitationMm != null) result.precipitationMm = precipitationMm;
    if (gdd != null) result.gdd = gdd;
    if (et0Mm != null) result.et0Mm = et0Mm;
    if (chillHours != null) result.chillHours = chillHours;
    if (rainfallDeficitMm != null) result.rainfallDeficitMm = rainfallDeficitMm;
    if (humidityMeanPct != null) result.humidityMeanPct = humidityMeanPct;
    if (solarRadiationMj != null) result.solarRadiationMj = solarRadiationMj;
    return result;
  }

  DailyAgroMetrics._();

  factory DailyAgroMetrics.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DailyAgroMetrics.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DailyAgroMetrics',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'date',
        subBuilder: $0.Timestamp.create)
    ..aD(3, _omitFieldNames ? '' : 'temperatureMinC')
    ..aD(4, _omitFieldNames ? '' : 'temperatureMaxC')
    ..aD(5, _omitFieldNames ? '' : 'temperatureMeanC')
    ..aD(6, _omitFieldNames ? '' : 'precipitationMm')
    ..aD(7, _omitFieldNames ? '' : 'gdd')
    ..aD(8, _omitFieldNames ? '' : 'et0Mm')
    ..aD(9, _omitFieldNames ? '' : 'chillHours')
    ..aD(10, _omitFieldNames ? '' : 'rainfallDeficitMm')
    ..aD(11, _omitFieldNames ? '' : 'humidityMeanPct')
    ..aD(12, _omitFieldNames ? '' : 'solarRadiationMj')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DailyAgroMetrics clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DailyAgroMetrics copyWith(void Function(DailyAgroMetrics) updates) =>
      super.copyWith((message) => updates(message as DailyAgroMetrics))
          as DailyAgroMetrics;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DailyAgroMetrics create() => DailyAgroMetrics._();
  @$core.override
  DailyAgroMetrics createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DailyAgroMetrics getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DailyAgroMetrics>(create);
  static DailyAgroMetrics? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get date => $_getN(1);
  @$pb.TagNumber(2)
  set date($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearDate() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureDate() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.double get temperatureMinC => $_getN(2);
  @$pb.TagNumber(3)
  set temperatureMinC($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTemperatureMinC() => $_has(2);
  @$pb.TagNumber(3)
  void clearTemperatureMinC() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get temperatureMaxC => $_getN(3);
  @$pb.TagNumber(4)
  set temperatureMaxC($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTemperatureMaxC() => $_has(3);
  @$pb.TagNumber(4)
  void clearTemperatureMaxC() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get temperatureMeanC => $_getN(4);
  @$pb.TagNumber(5)
  set temperatureMeanC($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTemperatureMeanC() => $_has(4);
  @$pb.TagNumber(5)
  void clearTemperatureMeanC() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get precipitationMm => $_getN(5);
  @$pb.TagNumber(6)
  set precipitationMm($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPrecipitationMm() => $_has(5);
  @$pb.TagNumber(6)
  void clearPrecipitationMm() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get gdd => $_getN(6);
  @$pb.TagNumber(7)
  set gdd($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGdd() => $_has(6);
  @$pb.TagNumber(7)
  void clearGdd() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get et0Mm => $_getN(7);
  @$pb.TagNumber(8)
  set et0Mm($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEt0Mm() => $_has(7);
  @$pb.TagNumber(8)
  void clearEt0Mm() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get chillHours => $_getN(8);
  @$pb.TagNumber(9)
  set chillHours($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasChillHours() => $_has(8);
  @$pb.TagNumber(9)
  void clearChillHours() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get rainfallDeficitMm => $_getN(9);
  @$pb.TagNumber(10)
  set rainfallDeficitMm($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRainfallDeficitMm() => $_has(9);
  @$pb.TagNumber(10)
  void clearRainfallDeficitMm() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get humidityMeanPct => $_getN(10);
  @$pb.TagNumber(11)
  set humidityMeanPct($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasHumidityMeanPct() => $_has(10);
  @$pb.TagNumber(11)
  void clearHumidityMeanPct() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get solarRadiationMj => $_getN(11);
  @$pb.TagNumber(12)
  set solarRadiationMj($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasSolarRadiationMj() => $_has(11);
  @$pb.TagNumber(12)
  void clearSolarRadiationMj() => $_clearField(12);
}

class AgroMetricsSummary extends $pb.GeneratedMessage {
  factory AgroMetricsSummary({
    $core.double? cumulativeGdd,
    $core.double? cumulativeEt0Mm,
    $core.double? cumulativePrecipitationMm,
    $core.double? cumulativeChillHours,
    $core.double? cumulativeDeficitMm,
    $core.int? days,
    $core.int? frostDays,
    $core.int? heatStressDays,
  }) {
    final result = create();
    if (cumulativeGdd != null) result.cumulativeGdd = cumulativeGdd;
    if (cumulativeEt0Mm != null) result.cumulativeEt0Mm = cumulativeEt0Mm;
    if (cumulativePrecipitationMm != null)
      result.cumulativePrecipitationMm = cumulativePrecipitationMm;
    if (cumulativeChillHours != null)
      result.cumulativeChillHours = cumulativeChillHours;
    if (cumulativeDeficitMm != null)
      result.cumulativeDeficitMm = cumulativeDeficitMm;
    if (days != null) result.days = days;
    if (frostDays != null) result.frostDays = frostDays;
    if (heatStressDays != null) result.heatStressDays = heatStressDays;
    return result;
  }

  AgroMetricsSummary._();

  factory AgroMetricsSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AgroMetricsSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgroMetricsSummary',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'cumulativeGdd')
    ..aD(2, _omitFieldNames ? '' : 'cumulativeEt0Mm')
    ..aD(3, _omitFieldNames ? '' : 'cumulativePrecipitationMm')
    ..aD(4, _omitFieldNames ? '' : 'cumulativeChillHours')
    ..aD(5, _omitFieldNames ? '' : 'cumulativeDeficitMm')
    ..aI(6, _omitFieldNames ? '' : 'days')
    ..aI(7, _omitFieldNames ? '' : 'frostDays')
    ..aI(8, _omitFieldNames ? '' : 'heatStressDays')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgroMetricsSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgroMetricsSummary copyWith(void Function(AgroMetricsSummary) updates) =>
      super.copyWith((message) => updates(message as AgroMetricsSummary))
          as AgroMetricsSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgroMetricsSummary create() => AgroMetricsSummary._();
  @$core.override
  AgroMetricsSummary createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AgroMetricsSummary getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgroMetricsSummary>(create);
  static AgroMetricsSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get cumulativeGdd => $_getN(0);
  @$pb.TagNumber(1)
  set cumulativeGdd($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCumulativeGdd() => $_has(0);
  @$pb.TagNumber(1)
  void clearCumulativeGdd() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get cumulativeEt0Mm => $_getN(1);
  @$pb.TagNumber(2)
  set cumulativeEt0Mm($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCumulativeEt0Mm() => $_has(1);
  @$pb.TagNumber(2)
  void clearCumulativeEt0Mm() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get cumulativePrecipitationMm => $_getN(2);
  @$pb.TagNumber(3)
  set cumulativePrecipitationMm($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCumulativePrecipitationMm() => $_has(2);
  @$pb.TagNumber(3)
  void clearCumulativePrecipitationMm() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get cumulativeChillHours => $_getN(3);
  @$pb.TagNumber(4)
  set cumulativeChillHours($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCumulativeChillHours() => $_has(3);
  @$pb.TagNumber(4)
  void clearCumulativeChillHours() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get cumulativeDeficitMm => $_getN(4);
  @$pb.TagNumber(5)
  set cumulativeDeficitMm($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCumulativeDeficitMm() => $_has(4);
  @$pb.TagNumber(5)
  void clearCumulativeDeficitMm() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get days => $_getIZ(5);
  @$pb.TagNumber(6)
  set days($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDays() => $_has(5);
  @$pb.TagNumber(6)
  void clearDays() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get frostDays => $_getIZ(6);
  @$pb.TagNumber(7)
  set frostDays($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFrostDays() => $_has(6);
  @$pb.TagNumber(7)
  void clearFrostDays() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get heatStressDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set heatStressDays($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasHeatStressDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearHeatStressDays() => $_clearField(8);
}

class WeatherAlert extends $pb.GeneratedMessage {
  factory WeatherAlert({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    WeatherAlertType? type,
    AlertSeverity? severity,
    $core.String? message,
    $core.double? value,
    $core.double? threshold,
    $0.Timestamp? validFrom,
    $0.Timestamp? validTo,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (type != null) result.type = type;
    if (severity != null) result.severity = severity;
    if (message != null) result.message = message;
    if (value != null) result.value = value;
    if (threshold != null) result.threshold = threshold;
    if (validFrom != null) result.validFrom = validFrom;
    if (validTo != null) result.validTo = validTo;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  WeatherAlert._();

  factory WeatherAlert.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WeatherAlert.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WeatherAlert',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aE<WeatherAlertType>(4, _omitFieldNames ? '' : 'type',
        enumValues: WeatherAlertType.values)
    ..aE<AlertSeverity>(5, _omitFieldNames ? '' : 'severity',
        enumValues: AlertSeverity.values)
    ..aOS(6, _omitFieldNames ? '' : 'message')
    ..aD(7, _omitFieldNames ? '' : 'value')
    ..aD(8, _omitFieldNames ? '' : 'threshold')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'validFrom',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'validTo',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WeatherAlert clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WeatherAlert copyWith(void Function(WeatherAlert) updates) =>
      super.copyWith((message) => updates(message as WeatherAlert))
          as WeatherAlert;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WeatherAlert create() => WeatherAlert._();
  @$core.override
  WeatherAlert createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WeatherAlert getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WeatherAlert>(create);
  static WeatherAlert? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldId() => $_clearField(3);

  @$pb.TagNumber(4)
  WeatherAlertType get type => $_getN(3);
  @$pb.TagNumber(4)
  set type(WeatherAlertType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  @$pb.TagNumber(5)
  AlertSeverity get severity => $_getN(4);
  @$pb.TagNumber(5)
  set severity(AlertSeverity value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSeverity() => $_has(4);
  @$pb.TagNumber(5)
  void clearSeverity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get message => $_getSZ(5);
  @$pb.TagNumber(6)
  set message($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessage() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get value => $_getN(6);
  @$pb.TagNumber(7)
  set value($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearValue() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get threshold => $_getN(7);
  @$pb.TagNumber(8)
  set threshold($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasThreshold() => $_has(7);
  @$pb.TagNumber(8)
  void clearThreshold() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get validFrom => $_getN(8);
  @$pb.TagNumber(9)
  set validFrom($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasValidFrom() => $_has(8);
  @$pb.TagNumber(9)
  void clearValidFrom() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureValidFrom() => $_ensure(8);

  @$pb.TagNumber(10)
  $0.Timestamp get validTo => $_getN(9);
  @$pb.TagNumber(10)
  set validTo($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasValidTo() => $_has(9);
  @$pb.TagNumber(10)
  void clearValidTo() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureValidTo() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Timestamp get createdAt => $_getN(10);
  @$pb.TagNumber(11)
  set createdAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreatedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureCreatedAt() => $_ensure(10);
}

class RegisterFieldLocationRequest extends $pb.GeneratedMessage {
  factory RegisterFieldLocationRequest({
    $core.String? fieldId,
    $core.String? farmId,
    $core.double? latitude,
    $core.double? longitude,
    $core.double? elevationM,
    $core.String? timezone,
    WeatherProvider? provider,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (elevationM != null) result.elevationM = elevationM;
    if (timezone != null) result.timezone = timezone;
    if (provider != null) result.provider = provider;
    return result;
  }

  RegisterFieldLocationRequest._();

  factory RegisterFieldLocationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterFieldLocationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterFieldLocationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aD(3, _omitFieldNames ? '' : 'latitude')
    ..aD(4, _omitFieldNames ? '' : 'longitude')
    ..aD(5, _omitFieldNames ? '' : 'elevationM')
    ..aOS(6, _omitFieldNames ? '' : 'timezone')
    ..aE<WeatherProvider>(7, _omitFieldNames ? '' : 'provider',
        enumValues: WeatherProvider.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterFieldLocationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterFieldLocationRequest copyWith(
          void Function(RegisterFieldLocationRequest) updates) =>
      super.copyWith(
              (message) => updates(message as RegisterFieldLocationRequest))
          as RegisterFieldLocationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterFieldLocationRequest create() =>
      RegisterFieldLocationRequest._();
  @$core.override
  RegisterFieldLocationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterFieldLocationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterFieldLocationRequest>(create);
  static RegisterFieldLocationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get latitude => $_getN(2);
  @$pb.TagNumber(3)
  set latitude($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLatitude() => $_has(2);
  @$pb.TagNumber(3)
  void clearLatitude() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get longitude => $_getN(3);
  @$pb.TagNumber(4)
  set longitude($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLongitude() => $_has(3);
  @$pb.TagNumber(4)
  void clearLongitude() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get elevationM => $_getN(4);
  @$pb.TagNumber(5)
  set elevationM($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasElevationM() => $_has(4);
  @$pb.TagNumber(5)
  void clearElevationM() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get timezone => $_getSZ(5);
  @$pb.TagNumber(6)
  set timezone($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimezone() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimezone() => $_clearField(6);

  @$pb.TagNumber(7)
  WeatherProvider get provider => $_getN(6);
  @$pb.TagNumber(7)
  set provider(WeatherProvider value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasProvider() => $_has(6);
  @$pb.TagNumber(7)
  void clearProvider() => $_clearField(7);
}

class RegisterFieldLocationResponse extends $pb.GeneratedMessage {
  factory RegisterFieldLocationResponse({
    FieldLocation? location,
  }) {
    final result = create();
    if (location != null) result.location = location;
    return result;
  }

  RegisterFieldLocationResponse._();

  factory RegisterFieldLocationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterFieldLocationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterFieldLocationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOM<FieldLocation>(1, _omitFieldNames ? '' : 'location',
        subBuilder: FieldLocation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterFieldLocationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterFieldLocationResponse copyWith(
          void Function(RegisterFieldLocationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as RegisterFieldLocationResponse))
          as RegisterFieldLocationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterFieldLocationResponse create() =>
      RegisterFieldLocationResponse._();
  @$core.override
  RegisterFieldLocationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterFieldLocationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterFieldLocationResponse>(create);
  static RegisterFieldLocationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FieldLocation get location => $_getN(0);
  @$pb.TagNumber(1)
  set location(FieldLocation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLocation() => $_has(0);
  @$pb.TagNumber(1)
  void clearLocation() => $_clearField(1);
  @$pb.TagNumber(1)
  FieldLocation ensureLocation() => $_ensure(0);
}

class GetFieldLocationRequest extends $pb.GeneratedMessage {
  factory GetFieldLocationRequest({
    $core.String? fieldId,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  GetFieldLocationRequest._();

  factory GetFieldLocationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldLocationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldLocationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldLocationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldLocationRequest copyWith(
          void Function(GetFieldLocationRequest) updates) =>
      super.copyWith((message) => updates(message as GetFieldLocationRequest))
          as GetFieldLocationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldLocationRequest create() => GetFieldLocationRequest._();
  @$core.override
  GetFieldLocationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldLocationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldLocationRequest>(create);
  static GetFieldLocationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);
}

class GetFieldLocationResponse extends $pb.GeneratedMessage {
  factory GetFieldLocationResponse({
    FieldLocation? location,
  }) {
    final result = create();
    if (location != null) result.location = location;
    return result;
  }

  GetFieldLocationResponse._();

  factory GetFieldLocationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldLocationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldLocationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOM<FieldLocation>(1, _omitFieldNames ? '' : 'location',
        subBuilder: FieldLocation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldLocationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldLocationResponse copyWith(
          void Function(GetFieldLocationResponse) updates) =>
      super.copyWith((message) => updates(message as GetFieldLocationResponse))
          as GetFieldLocationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldLocationResponse create() => GetFieldLocationResponse._();
  @$core.override
  GetFieldLocationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldLocationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldLocationResponse>(create);
  static GetFieldLocationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FieldLocation get location => $_getN(0);
  @$pb.TagNumber(1)
  set location(FieldLocation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLocation() => $_has(0);
  @$pb.TagNumber(1)
  void clearLocation() => $_clearField(1);
  @$pb.TagNumber(1)
  FieldLocation ensureLocation() => $_ensure(0);
}

class ListFieldLocationsRequest extends $pb.GeneratedMessage {
  factory ListFieldLocationsRequest({
    $core.String? farmId,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListFieldLocationsRequest._();

  factory ListFieldLocationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFieldLocationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFieldLocationsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..aI(3, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldLocationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldLocationsRequest copyWith(
          void Function(ListFieldLocationsRequest) updates) =>
      super.copyWith((message) => updates(message as ListFieldLocationsRequest))
          as ListFieldLocationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFieldLocationsRequest create() => ListFieldLocationsRequest._();
  @$core.override
  ListFieldLocationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFieldLocationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFieldLocationsRequest>(create);
  static ListFieldLocationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageOffset => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageOffset($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageOffset() => $_clearField(3);
}

class ListFieldLocationsResponse extends $pb.GeneratedMessage {
  factory ListFieldLocationsResponse({
    $core.Iterable<FieldLocation>? locations,
    $core.int? totalCount,
  }) {
    final result = create();
    if (locations != null) result.locations.addAll(locations);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListFieldLocationsResponse._();

  factory ListFieldLocationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFieldLocationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFieldLocationsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..pPM<FieldLocation>(1, _omitFieldNames ? '' : 'locations',
        subBuilder: FieldLocation.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldLocationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldLocationsResponse copyWith(
          void Function(ListFieldLocationsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListFieldLocationsResponse))
          as ListFieldLocationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFieldLocationsResponse create() => ListFieldLocationsResponse._();
  @$core.override
  ListFieldLocationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFieldLocationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFieldLocationsResponse>(create);
  static ListFieldLocationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FieldLocation> get locations => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class GetCurrentWeatherRequest extends $pb.GeneratedMessage {
  factory GetCurrentWeatherRequest({
    $core.String? fieldId,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  GetCurrentWeatherRequest._();

  factory GetCurrentWeatherRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCurrentWeatherRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCurrentWeatherRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCurrentWeatherRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCurrentWeatherRequest copyWith(
          void Function(GetCurrentWeatherRequest) updates) =>
      super.copyWith((message) => updates(message as GetCurrentWeatherRequest))
          as GetCurrentWeatherRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCurrentWeatherRequest create() => GetCurrentWeatherRequest._();
  @$core.override
  GetCurrentWeatherRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCurrentWeatherRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCurrentWeatherRequest>(create);
  static GetCurrentWeatherRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);
}

class GetCurrentWeatherResponse extends $pb.GeneratedMessage {
  factory GetCurrentWeatherResponse({
    Observation? observation,
  }) {
    final result = create();
    if (observation != null) result.observation = observation;
    return result;
  }

  GetCurrentWeatherResponse._();

  factory GetCurrentWeatherResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCurrentWeatherResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCurrentWeatherResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOM<Observation>(1, _omitFieldNames ? '' : 'observation',
        subBuilder: Observation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCurrentWeatherResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCurrentWeatherResponse copyWith(
          void Function(GetCurrentWeatherResponse) updates) =>
      super.copyWith((message) => updates(message as GetCurrentWeatherResponse))
          as GetCurrentWeatherResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCurrentWeatherResponse create() => GetCurrentWeatherResponse._();
  @$core.override
  GetCurrentWeatherResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCurrentWeatherResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCurrentWeatherResponse>(create);
  static GetCurrentWeatherResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Observation get observation => $_getN(0);
  @$pb.TagNumber(1)
  set observation(Observation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasObservation() => $_has(0);
  @$pb.TagNumber(1)
  void clearObservation() => $_clearField(1);
  @$pb.TagNumber(1)
  Observation ensureObservation() => $_ensure(0);
}

class GetForecastRequest extends $pb.GeneratedMessage {
  factory GetForecastRequest({
    $core.String? fieldId,
    $core.int? days,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (days != null) result.days = days;
    return result;
  }

  GetForecastRequest._();

  factory GetForecastRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetForecastRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetForecastRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aI(2, _omitFieldNames ? '' : 'days')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetForecastRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetForecastRequest copyWith(void Function(GetForecastRequest) updates) =>
      super.copyWith((message) => updates(message as GetForecastRequest))
          as GetForecastRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetForecastRequest create() => GetForecastRequest._();
  @$core.override
  GetForecastRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetForecastRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetForecastRequest>(create);
  static GetForecastRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get days => $_getIZ(1);
  @$pb.TagNumber(2)
  set days($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDays() => $_has(1);
  @$pb.TagNumber(2)
  void clearDays() => $_clearField(2);
}

class GetForecastResponse extends $pb.GeneratedMessage {
  factory GetForecastResponse({
    $core.Iterable<DailyForecast>? forecasts,
  }) {
    final result = create();
    if (forecasts != null) result.forecasts.addAll(forecasts);
    return result;
  }

  GetForecastResponse._();

  factory GetForecastResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetForecastResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetForecastResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..pPM<DailyForecast>(1, _omitFieldNames ? '' : 'forecasts',
        subBuilder: DailyForecast.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetForecastResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetForecastResponse copyWith(void Function(GetForecastResponse) updates) =>
      super.copyWith((message) => updates(message as GetForecastResponse))
          as GetForecastResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetForecastResponse create() => GetForecastResponse._();
  @$core.override
  GetForecastResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetForecastResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetForecastResponse>(create);
  static GetForecastResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DailyForecast> get forecasts => $_getList(0);
}

class ListObservationsRequest extends $pb.GeneratedMessage {
  factory ListObservationsRequest({
    $core.String? fieldId,
    $0.Timestamp? start,
    $0.Timestamp? end,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListObservationsRequest._();

  factory ListObservationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListObservationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListObservationsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'start',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'end',
        subBuilder: $0.Timestamp.create)
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aI(5, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListObservationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListObservationsRequest copyWith(
          void Function(ListObservationsRequest) updates) =>
      super.copyWith((message) => updates(message as ListObservationsRequest))
          as ListObservationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListObservationsRequest create() => ListObservationsRequest._();
  @$core.override
  ListObservationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListObservationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListObservationsRequest>(create);
  static ListObservationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get start => $_getN(1);
  @$pb.TagNumber(2)
  set start($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStart() => $_has(1);
  @$pb.TagNumber(2)
  void clearStart() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureStart() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.Timestamp get end => $_getN(2);
  @$pb.TagNumber(3)
  set end($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEnd() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnd() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureEnd() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageSize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pageOffset => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageOffset($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageOffset() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageOffset() => $_clearField(5);
}

class ListObservationsResponse extends $pb.GeneratedMessage {
  factory ListObservationsResponse({
    $core.Iterable<Observation>? observations,
    $core.int? totalCount,
  }) {
    final result = create();
    if (observations != null) result.observations.addAll(observations);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListObservationsResponse._();

  factory ListObservationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListObservationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListObservationsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..pPM<Observation>(1, _omitFieldNames ? '' : 'observations',
        subBuilder: Observation.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListObservationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListObservationsResponse copyWith(
          void Function(ListObservationsResponse) updates) =>
      super.copyWith((message) => updates(message as ListObservationsResponse))
          as ListObservationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListObservationsResponse create() => ListObservationsResponse._();
  @$core.override
  ListObservationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListObservationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListObservationsResponse>(create);
  static ListObservationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Observation> get observations => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class GetAgroMetricsRequest extends $pb.GeneratedMessage {
  factory GetAgroMetricsRequest({
    $core.String? fieldId,
    $0.Timestamp? start,
    $0.Timestamp? end,
    $core.double? baseTempC,
    $core.double? capTempC,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    if (baseTempC != null) result.baseTempC = baseTempC;
    if (capTempC != null) result.capTempC = capTempC;
    return result;
  }

  GetAgroMetricsRequest._();

  factory GetAgroMetricsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAgroMetricsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAgroMetricsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'start',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'end',
        subBuilder: $0.Timestamp.create)
    ..aD(4, _omitFieldNames ? '' : 'baseTempC')
    ..aD(5, _omitFieldNames ? '' : 'capTempC')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAgroMetricsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAgroMetricsRequest copyWith(
          void Function(GetAgroMetricsRequest) updates) =>
      super.copyWith((message) => updates(message as GetAgroMetricsRequest))
          as GetAgroMetricsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAgroMetricsRequest create() => GetAgroMetricsRequest._();
  @$core.override
  GetAgroMetricsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAgroMetricsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAgroMetricsRequest>(create);
  static GetAgroMetricsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get start => $_getN(1);
  @$pb.TagNumber(2)
  set start($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStart() => $_has(1);
  @$pb.TagNumber(2)
  void clearStart() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureStart() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.Timestamp get end => $_getN(2);
  @$pb.TagNumber(3)
  set end($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEnd() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnd() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureEnd() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.double get baseTempC => $_getN(3);
  @$pb.TagNumber(4)
  set baseTempC($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBaseTempC() => $_has(3);
  @$pb.TagNumber(4)
  void clearBaseTempC() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get capTempC => $_getN(4);
  @$pb.TagNumber(5)
  set capTempC($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCapTempC() => $_has(4);
  @$pb.TagNumber(5)
  void clearCapTempC() => $_clearField(5);
}

class GetAgroMetricsResponse extends $pb.GeneratedMessage {
  factory GetAgroMetricsResponse({
    $core.Iterable<DailyAgroMetrics>? daily,
    AgroMetricsSummary? summary,
  }) {
    final result = create();
    if (daily != null) result.daily.addAll(daily);
    if (summary != null) result.summary = summary;
    return result;
  }

  GetAgroMetricsResponse._();

  factory GetAgroMetricsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAgroMetricsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAgroMetricsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..pPM<DailyAgroMetrics>(1, _omitFieldNames ? '' : 'daily',
        subBuilder: DailyAgroMetrics.create)
    ..aOM<AgroMetricsSummary>(2, _omitFieldNames ? '' : 'summary',
        subBuilder: AgroMetricsSummary.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAgroMetricsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAgroMetricsResponse copyWith(
          void Function(GetAgroMetricsResponse) updates) =>
      super.copyWith((message) => updates(message as GetAgroMetricsResponse))
          as GetAgroMetricsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAgroMetricsResponse create() => GetAgroMetricsResponse._();
  @$core.override
  GetAgroMetricsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAgroMetricsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAgroMetricsResponse>(create);
  static GetAgroMetricsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DailyAgroMetrics> get daily => $_getList(0);

  @$pb.TagNumber(2)
  AgroMetricsSummary get summary => $_getN(1);
  @$pb.TagNumber(2)
  set summary(AgroMetricsSummary value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSummary() => $_has(1);
  @$pb.TagNumber(2)
  void clearSummary() => $_clearField(2);
  @$pb.TagNumber(2)
  AgroMetricsSummary ensureSummary() => $_ensure(1);
}

class RefreshFieldWeatherRequest extends $pb.GeneratedMessage {
  factory RefreshFieldWeatherRequest({
    $core.String? fieldId,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  RefreshFieldWeatherRequest._();

  factory RefreshFieldWeatherRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RefreshFieldWeatherRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RefreshFieldWeatherRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshFieldWeatherRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshFieldWeatherRequest copyWith(
          void Function(RefreshFieldWeatherRequest) updates) =>
      super.copyWith(
              (message) => updates(message as RefreshFieldWeatherRequest))
          as RefreshFieldWeatherRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshFieldWeatherRequest create() => RefreshFieldWeatherRequest._();
  @$core.override
  RefreshFieldWeatherRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RefreshFieldWeatherRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RefreshFieldWeatherRequest>(create);
  static RefreshFieldWeatherRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);
}

class RefreshFieldWeatherResponse extends $pb.GeneratedMessage {
  factory RefreshFieldWeatherResponse({
    $core.int? observationsIngested,
    $core.int? forecastsIngested,
  }) {
    final result = create();
    if (observationsIngested != null)
      result.observationsIngested = observationsIngested;
    if (forecastsIngested != null) result.forecastsIngested = forecastsIngested;
    return result;
  }

  RefreshFieldWeatherResponse._();

  factory RefreshFieldWeatherResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RefreshFieldWeatherResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RefreshFieldWeatherResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'observationsIngested')
    ..aI(2, _omitFieldNames ? '' : 'forecastsIngested')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshFieldWeatherResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshFieldWeatherResponse copyWith(
          void Function(RefreshFieldWeatherResponse) updates) =>
      super.copyWith(
              (message) => updates(message as RefreshFieldWeatherResponse))
          as RefreshFieldWeatherResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshFieldWeatherResponse create() =>
      RefreshFieldWeatherResponse._();
  @$core.override
  RefreshFieldWeatherResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RefreshFieldWeatherResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RefreshFieldWeatherResponse>(create);
  static RefreshFieldWeatherResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get observationsIngested => $_getIZ(0);
  @$pb.TagNumber(1)
  set observationsIngested($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasObservationsIngested() => $_has(0);
  @$pb.TagNumber(1)
  void clearObservationsIngested() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get forecastsIngested => $_getIZ(1);
  @$pb.TagNumber(2)
  set forecastsIngested($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasForecastsIngested() => $_has(1);
  @$pb.TagNumber(2)
  void clearForecastsIngested() => $_clearField(2);
}

class BackfillHistoryRequest extends $pb.GeneratedMessage {
  factory BackfillHistoryRequest({
    $core.String? fieldId,
    $core.int? years,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (years != null) result.years = years;
    return result;
  }

  BackfillHistoryRequest._();

  factory BackfillHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BackfillHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BackfillHistoryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aI(2, _omitFieldNames ? '' : 'years')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackfillHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackfillHistoryRequest copyWith(
          void Function(BackfillHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as BackfillHistoryRequest))
          as BackfillHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BackfillHistoryRequest create() => BackfillHistoryRequest._();
  @$core.override
  BackfillHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BackfillHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BackfillHistoryRequest>(create);
  static BackfillHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get years => $_getIZ(1);
  @$pb.TagNumber(2)
  set years($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasYears() => $_has(1);
  @$pb.TagNumber(2)
  void clearYears() => $_clearField(2);
}

class BackfillHistoryResponse extends $pb.GeneratedMessage {
  factory BackfillHistoryResponse({
    $core.int? daysIngested,
    $0.Timestamp? from,
    $0.Timestamp? to,
  }) {
    final result = create();
    if (daysIngested != null) result.daysIngested = daysIngested;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    return result;
  }

  BackfillHistoryResponse._();

  factory BackfillHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BackfillHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BackfillHistoryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'daysIngested')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'from',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'to',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackfillHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackfillHistoryResponse copyWith(
          void Function(BackfillHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as BackfillHistoryResponse))
          as BackfillHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BackfillHistoryResponse create() => BackfillHistoryResponse._();
  @$core.override
  BackfillHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BackfillHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BackfillHistoryResponse>(create);
  static BackfillHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get daysIngested => $_getIZ(0);
  @$pb.TagNumber(1)
  set daysIngested($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDaysIngested() => $_has(0);
  @$pb.TagNumber(1)
  void clearDaysIngested() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get from => $_getN(1);
  @$pb.TagNumber(2)
  set from($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearFrom() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureFrom() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.Timestamp get to => $_getN(2);
  @$pb.TagNumber(3)
  set to($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTo() => $_has(2);
  @$pb.TagNumber(3)
  void clearTo() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureTo() => $_ensure(2);
}

class ListWeatherAlertsRequest extends $pb.GeneratedMessage {
  factory ListWeatherAlertsRequest({
    $core.String? fieldId,
    $core.bool? activeOnly,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (activeOnly != null) result.activeOnly = activeOnly;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListWeatherAlertsRequest._();

  factory ListWeatherAlertsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListWeatherAlertsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListWeatherAlertsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOB(2, _omitFieldNames ? '' : 'activeOnly')
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..aI(4, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWeatherAlertsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWeatherAlertsRequest copyWith(
          void Function(ListWeatherAlertsRequest) updates) =>
      super.copyWith((message) => updates(message as ListWeatherAlertsRequest))
          as ListWeatherAlertsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListWeatherAlertsRequest create() => ListWeatherAlertsRequest._();
  @$core.override
  ListWeatherAlertsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListWeatherAlertsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListWeatherAlertsRequest>(create);
  static ListWeatherAlertsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get activeOnly => $_getBF(1);
  @$pb.TagNumber(2)
  set activeOnly($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActiveOnly() => $_has(1);
  @$pb.TagNumber(2)
  void clearActiveOnly() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageOffset => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageOffset($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageOffset() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageOffset() => $_clearField(4);
}

class ListWeatherAlertsResponse extends $pb.GeneratedMessage {
  factory ListWeatherAlertsResponse({
    $core.Iterable<WeatherAlert>? alerts,
    $core.int? totalCount,
  }) {
    final result = create();
    if (alerts != null) result.alerts.addAll(alerts);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListWeatherAlertsResponse._();

  factory ListWeatherAlertsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListWeatherAlertsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListWeatherAlertsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.weather.v1'),
      createEmptyInstance: create)
    ..pPM<WeatherAlert>(1, _omitFieldNames ? '' : 'alerts',
        subBuilder: WeatherAlert.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWeatherAlertsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWeatherAlertsResponse copyWith(
          void Function(ListWeatherAlertsResponse) updates) =>
      super.copyWith((message) => updates(message as ListWeatherAlertsResponse))
          as ListWeatherAlertsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListWeatherAlertsResponse create() => ListWeatherAlertsResponse._();
  @$core.override
  ListWeatherAlertsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListWeatherAlertsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListWeatherAlertsResponse>(create);
  static ListWeatherAlertsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WeatherAlert> get alerts => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class WeatherServiceApi {
  final $pb.RpcClient _client;

  WeatherServiceApi(this._client);

  $async.Future<RegisterFieldLocationResponse> registerFieldLocation(
          $pb.ClientContext? ctx, RegisterFieldLocationRequest request) =>
      _client.invoke<RegisterFieldLocationResponse>(ctx, 'WeatherService',
          'RegisterFieldLocation', request, RegisterFieldLocationResponse());
  $async.Future<GetFieldLocationResponse> getFieldLocation(
          $pb.ClientContext? ctx, GetFieldLocationRequest request) =>
      _client.invoke<GetFieldLocationResponse>(ctx, 'WeatherService',
          'GetFieldLocation', request, GetFieldLocationResponse());
  $async.Future<ListFieldLocationsResponse> listFieldLocations(
          $pb.ClientContext? ctx, ListFieldLocationsRequest request) =>
      _client.invoke<ListFieldLocationsResponse>(ctx, 'WeatherService',
          'ListFieldLocations', request, ListFieldLocationsResponse());
  $async.Future<GetCurrentWeatherResponse> getCurrentWeather(
          $pb.ClientContext? ctx, GetCurrentWeatherRequest request) =>
      _client.invoke<GetCurrentWeatherResponse>(ctx, 'WeatherService',
          'GetCurrentWeather', request, GetCurrentWeatherResponse());
  $async.Future<GetForecastResponse> getForecast(
          $pb.ClientContext? ctx, GetForecastRequest request) =>
      _client.invoke<GetForecastResponse>(
          ctx, 'WeatherService', 'GetForecast', request, GetForecastResponse());
  $async.Future<ListObservationsResponse> listObservations(
          $pb.ClientContext? ctx, ListObservationsRequest request) =>
      _client.invoke<ListObservationsResponse>(ctx, 'WeatherService',
          'ListObservations', request, ListObservationsResponse());
  $async.Future<GetAgroMetricsResponse> getAgroMetrics(
          $pb.ClientContext? ctx, GetAgroMetricsRequest request) =>
      _client.invoke<GetAgroMetricsResponse>(ctx, 'WeatherService',
          'GetAgroMetrics', request, GetAgroMetricsResponse());
  $async.Future<RefreshFieldWeatherResponse> refreshFieldWeather(
          $pb.ClientContext? ctx, RefreshFieldWeatherRequest request) =>
      _client.invoke<RefreshFieldWeatherResponse>(ctx, 'WeatherService',
          'RefreshFieldWeather', request, RefreshFieldWeatherResponse());
  $async.Future<BackfillHistoryResponse> backfillHistory(
          $pb.ClientContext? ctx, BackfillHistoryRequest request) =>
      _client.invoke<BackfillHistoryResponse>(ctx, 'WeatherService',
          'BackfillHistory', request, BackfillHistoryResponse());
  $async.Future<ListWeatherAlertsResponse> listWeatherAlerts(
          $pb.ClientContext? ctx, ListWeatherAlertsRequest request) =>
      _client.invoke<ListWeatherAlertsResponse>(ctx, 'WeatherService',
          'ListWeatherAlerts', request, ListWeatherAlertsResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
