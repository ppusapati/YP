package mappers

import (
	"encoding/json"
	"time"

	pb "p9e.in/samavaya/agriculture/sensor-service/api/v1"
	"p9e.in/samavaya/agriculture/sensor-service/internal/models"
	"p9e.in/samavaya/packages/convert/ptr"

	"google.golang.org/protobuf/types/known/timestamppb"
)

// =============================================================================
// Proto Enum <-> Domain Model Mappers
// =============================================================================

// SensorTypeToProto converts a domain SensorType to its proto enum value.
func SensorTypeToProto(st models.SensorType) pb.SensorType {
	switch st {
	case models.SensorTypeSoilMoisture:
		return pb.SensorType_SENSOR_TYPE_SOIL_MOISTURE
	case models.SensorTypeSoilPH:
		return pb.SensorType_SENSOR_TYPE_SOIL_PH
	case models.SensorTypeTemperature:
		return pb.SensorType_SENSOR_TYPE_TEMPERATURE
	case models.SensorTypeHumidity:
		return pb.SensorType_SENSOR_TYPE_HUMIDITY
	case models.SensorTypeRainfall:
		return pb.SensorType_SENSOR_TYPE_RAINFALL
	case models.SensorTypeWindSpeed:
		return pb.SensorType_SENSOR_TYPE_WIND_SPEED
	case models.SensorTypeWindDirection:
		return pb.SensorType_SENSOR_TYPE_WIND_DIRECTION
	case models.SensorTypeLightIntensity:
		return pb.SensorType_SENSOR_TYPE_LIGHT_INTENSITY
	case models.SensorTypeLeafWetness:
		return pb.SensorType_SENSOR_TYPE_LEAF_WETNESS
	default:
		return pb.SensorType_SENSOR_TYPE_UNSPECIFIED
	}
}

// SensorTypeFromProto converts a proto SensorType enum to a domain SensorType.
func SensorTypeFromProto(st pb.SensorType) models.SensorType {
	switch st {
	case pb.SensorType_SENSOR_TYPE_SOIL_MOISTURE:
		return models.SensorTypeSoilMoisture
	case pb.SensorType_SENSOR_TYPE_SOIL_PH:
		return models.SensorTypeSoilPH
	case pb.SensorType_SENSOR_TYPE_TEMPERATURE:
		return models.SensorTypeTemperature
	case pb.SensorType_SENSOR_TYPE_HUMIDITY:
		return models.SensorTypeHumidity
	case pb.SensorType_SENSOR_TYPE_RAINFALL:
		return models.SensorTypeRainfall
	case pb.SensorType_SENSOR_TYPE_WIND_SPEED:
		return models.SensorTypeWindSpeed
	case pb.SensorType_SENSOR_TYPE_WIND_DIRECTION:
		return models.SensorTypeWindDirection
	case pb.SensorType_SENSOR_TYPE_LIGHT_INTENSITY:
		return models.SensorTypeLightIntensity
	case pb.SensorType_SENSOR_TYPE_LEAF_WETNESS:
		return models.SensorTypeLeafWetness
	default:
		return ""
	}
}

// SensorStatusToProto converts a domain SensorStatus to its proto enum.
func SensorStatusToProto(s models.SensorStatus) pb.SensorStatus {
	switch s {
	case models.SensorStatusActive:
		return pb.SensorStatus_SENSOR_STATUS_ACTIVE
	case models.SensorStatusInactive:
		return pb.SensorStatus_SENSOR_STATUS_INACTIVE
	case models.SensorStatusMaintenance:
		return pb.SensorStatus_SENSOR_STATUS_MAINTENANCE
	case models.SensorStatusDecommissioned:
		return pb.SensorStatus_SENSOR_STATUS_DECOMMISSIONED
	default:
		return pb.SensorStatus_SENSOR_STATUS_UNSPECIFIED
	}
}

// SensorStatusFromProto converts a proto SensorStatus to a domain SensorStatus.
func SensorStatusFromProto(s pb.SensorStatus) models.SensorStatus {
	switch s {
	case pb.SensorStatus_SENSOR_STATUS_ACTIVE:
		return models.SensorStatusActive
	case pb.SensorStatus_SENSOR_STATUS_INACTIVE:
		return models.SensorStatusInactive
	case pb.SensorStatus_SENSOR_STATUS_MAINTENANCE:
		return models.SensorStatusMaintenance
	case pb.SensorStatus_SENSOR_STATUS_DECOMMISSIONED:
		return models.SensorStatusDecommissioned
	default:
		return ""
	}
}

// SensorProtocolToProto converts a domain SensorProtocol to its proto enum.
func SensorProtocolToProto(p models.SensorProtocol) pb.SensorProtocol {
	switch p {
	case models.SensorProtocolMQTT:
		return pb.SensorProtocol_SENSOR_PROTOCOL_MQTT
	case models.SensorProtocolLoRaWAN:
		return pb.SensorProtocol_SENSOR_PROTOCOL_LORAWAN
	case models.SensorProtocolZigbee:
		return pb.SensorProtocol_SENSOR_PROTOCOL_ZIGBEE
	case models.SensorProtocolWiFi:
		return pb.SensorProtocol_SENSOR_PROTOCOL_WIFI
	case models.SensorProtocolCellular:
		return pb.SensorProtocol_SENSOR_PROTOCOL_CELLULAR
	default:
		return pb.SensorProtocol_SENSOR_PROTOCOL_UNSPECIFIED
	}
}

// SensorProtocolFromProto converts a proto SensorProtocol to a domain SensorProtocol.
func SensorProtocolFromProto(p pb.SensorProtocol) models.SensorProtocol {
	switch p {
	case pb.SensorProtocol_SENSOR_PROTOCOL_MQTT:
		return models.SensorProtocolMQTT
	case pb.SensorProtocol_SENSOR_PROTOCOL_LORAWAN:
		return models.SensorProtocolLoRaWAN
	case pb.SensorProtocol_SENSOR_PROTOCOL_ZIGBEE:
		return models.SensorProtocolZigbee
	case pb.SensorProtocol_SENSOR_PROTOCOL_WIFI:
		return models.SensorProtocolWiFi
	case pb.SensorProtocol_SENSOR_PROTOCOL_CELLULAR:
		return models.SensorProtocolCellular
	default:
		return ""
	}
}

// ReadingQualityToProto converts a domain ReadingQuality to its proto enum.
func ReadingQualityToProto(q models.ReadingQuality) pb.ReadingQuality {
	switch q {
	case models.ReadingQualityGood:
		return pb.ReadingQuality_READING_QUALITY_GOOD
	case models.ReadingQualitySuspect:
		return pb.ReadingQuality_READING_QUALITY_SUSPECT
	case models.ReadingQualityBad:
		return pb.ReadingQuality_READING_QUALITY_BAD
	default:
		return pb.ReadingQuality_READING_QUALITY_UNSPECIFIED
	}
}

// ReadingQualityFromProto converts a proto ReadingQuality to a domain ReadingQuality.
func ReadingQualityFromProto(q pb.ReadingQuality) models.ReadingQuality {
	switch q {
	case pb.ReadingQuality_READING_QUALITY_GOOD:
		return models.ReadingQualityGood
	case pb.ReadingQuality_READING_QUALITY_SUSPECT:
		return models.ReadingQualitySuspect
	case pb.ReadingQuality_READING_QUALITY_BAD:
		return models.ReadingQualityBad
	default:
		return models.ReadingQualityGood
	}
}

// AlertConditionToProto converts a domain AlertCondition to its proto enum.
func AlertConditionToProto(c models.AlertCondition) pb.AlertCondition {
	switch c {
	case models.AlertConditionGT:
		return pb.AlertCondition_ALERT_CONDITION_GT
	case models.AlertConditionLT:
		return pb.AlertCondition_ALERT_CONDITION_LT
	case models.AlertConditionEQ:
		return pb.AlertCondition_ALERT_CONDITION_EQ
	case models.AlertConditionGTE:
		return pb.AlertCondition_ALERT_CONDITION_GTE
	case models.AlertConditionLTE:
		return pb.AlertCondition_ALERT_CONDITION_LTE
	default:
		return pb.AlertCondition_ALERT_CONDITION_UNSPECIFIED
	}
}

// AlertConditionFromProto converts a proto AlertCondition to a domain AlertCondition.
func AlertConditionFromProto(c pb.AlertCondition) models.AlertCondition {
	switch c {
	case pb.AlertCondition_ALERT_CONDITION_GT:
		return models.AlertConditionGT
	case pb.AlertCondition_ALERT_CONDITION_LT:
		return models.AlertConditionLT
	case pb.AlertCondition_ALERT_CONDITION_EQ:
		return models.AlertConditionEQ
	case pb.AlertCondition_ALERT_CONDITION_GTE:
		return models.AlertConditionGTE
	case pb.AlertCondition_ALERT_CONDITION_LTE:
		return models.AlertConditionLTE
	default:
		return ""
	}
}

// AlertSeverityToProto converts a domain AlertSeverity to its proto enum.
func AlertSeverityToProto(s models.AlertSeverity) pb.AlertSeverity {
	switch s {
	case models.AlertSeverityLow:
		return pb.AlertSeverity_ALERT_SEVERITY_LOW
	case models.AlertSeverityMedium:
		return pb.AlertSeverity_ALERT_SEVERITY_MEDIUM
	case models.AlertSeverityHigh:
		return pb.AlertSeverity_ALERT_SEVERITY_HIGH
	case models.AlertSeverityCritical:
		return pb.AlertSeverity_ALERT_SEVERITY_CRITICAL
	default:
		return pb.AlertSeverity_ALERT_SEVERITY_UNSPECIFIED
	}
}

// AlertSeverityFromProto converts a proto AlertSeverity to a domain AlertSeverity.
func AlertSeverityFromProto(s pb.AlertSeverity) models.AlertSeverity {
	switch s {
	case pb.AlertSeverity_ALERT_SEVERITY_LOW:
		return models.AlertSeverityLow
	case pb.AlertSeverity_ALERT_SEVERITY_MEDIUM:
		return models.AlertSeverityMedium
	case pb.AlertSeverity_ALERT_SEVERITY_HIGH:
		return models.AlertSeverityHigh
	case pb.AlertSeverity_ALERT_SEVERITY_CRITICAL:
		return models.AlertSeverityCritical
	default:
		return models.AlertSeverityMedium
	}
}

// =============================================================================
// Sensor Mappers
// =============================================================================

// SensorToProto maps a domain Sensor model to its protobuf representation.
func SensorToProto(s *models.Sensor) *pb.Sensor {
	if s == nil {
		return nil
	}

	sensor := &pb.Sensor{
		Id:                     s.UUID,
		TenantId:               s.TenantID,
		FieldId:                s.FieldID,
		FarmId:                 s.FarmID,
		SensorType:             SensorTypeToProto(s.SensorType),
		DeviceId:               s.DeviceID,
		Manufacturer:           s.Manufacturer,
		Model:                  s.Model,
		FirmwareVersion:        s.FirmwareVersion,
		BatteryLevelPct:        s.BatteryLevelPct,
		SignalStrengthDbm:      s.SignalStrengthDbm,
		Status:                 SensorStatusToProto(s.Status),
		Protocol:               SensorProtocolToProto(s.Protocol),
		ReadingIntervalSeconds: s.ReadingIntervalSeconds,
		Version:                s.Version,
		CreatedAt:              timestamppb.New(s.CreatedAt),
	}

	if s.Latitude != nil && s.Longitude != nil {
		sensor.Location = &pb.GeoLocation{
			Latitude:    *s.Latitude,
			Longitude:   *s.Longitude,
			ElevationM:  s.ElevationM,
		}
	}

	if s.InstallationDate != nil {
		sensor.InstallationDate = timestamppb.New(*s.InstallationDate)
	}

	if s.LastReadingAt != nil {
		sensor.LastReadingAt = timestamppb.New(*s.LastReadingAt)
	}

	if s.UpdatedAt != nil {
		sensor.UpdatedAt = timestamppb.New(*s.UpdatedAt)
	}

	if s.Metadata != nil {
		var md map[string]string
		if err := json.Unmarshal(s.Metadata, &md); err == nil {
			sensor.Metadata = md
		}
	}

	return sensor
}

// SensorsToProto maps a slice of domain Sensor models to proto representations.
func SensorsToProto(sensors []models.Sensor) []*pb.Sensor {
	result := make([]*pb.Sensor, 0, len(sensors))
	for i := range sensors {
		result = append(result, SensorToProto(&sensors[i]))
	}
	return result
}

// =============================================================================
// SensorReading Mappers
// =============================================================================

// SensorReadingToProto maps a domain SensorReading to its protobuf representation.
func SensorReadingToProto(r *models.SensorReading) *pb.SensorReading {
	if r == nil {
		return nil
	}

	reading := &pb.SensorReading{
		Id:        r.UUID,
		SensorId:  r.SensorID,
		TenantId:  r.TenantID,
		Value:     r.Value,
		Unit:      r.Unit,
		Timestamp: timestamppb.New(r.RecordedAt),
		Quality:   ReadingQualityToProto(r.Quality),
		CreatedAt: timestamppb.New(r.CreatedAt),
	}

	if r.BatteryLevelPct != nil {
		reading.BatteryLevelPct = *r.BatteryLevelPct
	}

	if r.SignalStrengthDbm != nil {
		reading.SignalStrengthDbm = *r.SignalStrengthDbm
	}

	if r.Metadata != nil {
		var md map[string]string
		if err := json.Unmarshal(r.Metadata, &md); err == nil {
			reading.Metadata = md
		}
	}

	return reading
}

// SensorReadingsToProto maps a slice of domain SensorReading models to proto representations.
func SensorReadingsToProto(readings []models.SensorReading) []*pb.SensorReading {
	result := make([]*pb.SensorReading, 0, len(readings))
	for i := range readings {
		result = append(result, SensorReadingToProto(&readings[i]))
	}
	return result
}

// =============================================================================
// SensorAlert Mappers
// =============================================================================

// SensorAlertToProto maps a domain SensorAlert to its protobuf representation.
func SensorAlertToProto(a *models.SensorAlert) *pb.SensorAlert {
	if a == nil {
		return nil
	}

	alert := &pb.SensorAlert{
		Id:           a.UUID,
		SensorId:     a.SensorID,
		TenantId:     a.TenantID,
		FieldId:      a.FieldID,
		SensorType:   SensorTypeToProto(a.SensorType),
		Threshold:    a.Threshold,
		ActualValue:  a.ActualValue,
		Condition:    AlertConditionToProto(a.Condition),
		Severity:     AlertSeverityToProto(a.Severity),
		Message:      a.Message,
		Acknowledged: a.Acknowledged,
		CreatedAt:    timestamppb.New(a.CreatedAt),
	}

	if a.AcknowledgedBy != nil {
		alert.AcknowledgedBy = *a.AcknowledgedBy
	}

	if a.AcknowledgedAt != nil {
		alert.AcknowledgedAt = timestamppb.New(*a.AcknowledgedAt)
	}

	if a.UpdatedAt != nil {
		alert.UpdatedAt = timestamppb.New(*a.UpdatedAt)
	}

	return alert
}

// SensorAlertsToProto maps a slice of domain SensorAlert models to proto representations.
func SensorAlertsToProto(alerts []models.SensorAlert) []*pb.SensorAlert {
	result := make([]*pb.SensorAlert, 0, len(alerts))
	for i := range alerts {
		result = append(result, SensorAlertToProto(&alerts[i]))
	}
	return result
}

// =============================================================================
// SensorNetwork Mappers
// =============================================================================

// SensorNetworkToProto maps a domain SensorNetwork to its protobuf representation.
func SensorNetworkToProto(n *models.SensorNetwork) *pb.SensorNetwork {
	if n == nil {
		return nil
	}

	network := &pb.SensorNetwork{
		Id:            n.UUID,
		TenantId:      n.TenantID,
		FarmId:        n.FarmID,
		Name:          n.Name,
		Description:   n.Description,
		Protocol:      SensorProtocolToProto(n.Protocol),
		GatewayId:     n.GatewayID,
		SensorIds:     n.SensorIDs,
		TotalSensors:  n.TotalSensors,
		ActiveSensors: n.ActiveSensors,
		CreatedAt:     timestamppb.New(n.CreatedAt),
	}

	if n.UpdatedAt != nil {
		network.UpdatedAt = timestamppb.New(*n.UpdatedAt)
	}

	return network
}

// =============================================================================
// SensorCalibration Mappers
// =============================================================================

// SensorCalibrationToProto maps a domain SensorCalibration to its protobuf representation.
func SensorCalibrationToProto(c *models.SensorCalibration) *pb.SensorCalibration {
	if c == nil {
		return nil
	}

	cal := &pb.SensorCalibration{
		Id:              c.UUID,
		SensorId:        c.SensorID,
		TenantId:        c.TenantID,
		Offset:          c.OffsetValue,
		ScaleFactor:     c.ScaleFactor,
		CalibrationDate: timestamppb.New(c.CalibrationDate),
		CalibratedBy:    c.CalibratedBy,
		Notes:           c.Notes,
		CreatedAt:       timestamppb.New(c.CreatedAt),
	}

	if c.NextCalibrationDate != nil {
		cal.NextCalibrationDate = timestamppb.New(*c.NextCalibrationDate)
	}

	return cal
}

// =============================================================================
// Proto -> Domain Mappers for Requests
// =============================================================================

// RegisterSensorRequestToModel converts a RegisterSensorRequest proto into a domain Sensor.
func RegisterSensorRequestToModel(req *pb.RegisterSensorRequest, tenantID, userID, uuid string) *models.Sensor {
	now := time.Now()
	sensor := &models.Sensor{
		TenantID:               tenantID,
		FieldID:                req.GetFieldId(),
		FarmID:                 req.GetFarmId(),
		SensorType:             SensorTypeFromProto(req.GetSensorType()),
		DeviceID:               req.GetDeviceId(),
		Manufacturer:           req.GetManufacturer(),
		Model:                  req.GetModel(),
		FirmwareVersion:        req.GetFirmwareVersion(),
		Status:                 models.SensorStatusActive,
		Protocol:               SensorProtocolFromProto(req.GetProtocol()),
		ReadingIntervalSeconds: req.GetReadingIntervalSeconds(),
		BatteryLevelPct:        100,
		Version:                1,
	}

	sensor.UUID = uuid
	sensor.CreatedBy = userID
	sensor.CreatedAt = now
	sensor.IsActive = true

	if req.GetLocation() != nil {
		sensor.Latitude = ptr.Ptr(req.GetLocation().GetLatitude())
		sensor.Longitude = ptr.Ptr(req.GetLocation().GetLongitude())
		sensor.ElevationM = req.GetLocation().GetElevationM()
	}

	if req.GetInstallationDate() != nil {
		t := req.GetInstallationDate().AsTime()
		sensor.InstallationDate = &t
	}

	if req.GetMetadata() != nil {
		md, err := json.Marshal(req.GetMetadata())
		if err == nil {
			sensor.Metadata = md
		}
	}

	if sensor.ReadingIntervalSeconds <= 0 {
		sensor.ReadingIntervalSeconds = 300 // default 5 minutes
	}

	return sensor
}

// MetadataToJSON safely converts a proto metadata map to a JSON RawMessage.
func MetadataToJSON(md map[string]string) json.RawMessage {
	if md == nil {
		return json.RawMessage("{}")
	}
	data, err := json.Marshal(md)
	if err != nil {
		return json.RawMessage("{}")
	}
	return data
}
