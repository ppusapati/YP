package models

import (
	"encoding/json"
	"time"

	"p9e.in/samavaya/packages/models"
)

// SensorType represents the type of agricultural sensor.
type SensorType string

const (
	SensorTypeSoilMoisture  SensorType = "SOIL_MOISTURE"
	SensorTypeSoilPH        SensorType = "SOIL_PH"
	SensorTypeTemperature   SensorType = "TEMPERATURE"
	SensorTypeHumidity      SensorType = "HUMIDITY"
	SensorTypeRainfall      SensorType = "RAINFALL"
	SensorTypeWindSpeed     SensorType = "WIND_SPEED"
	SensorTypeWindDirection SensorType = "WIND_DIRECTION"
	SensorTypeLightIntensity SensorType = "LIGHT_INTENSITY"
	SensorTypeLeafWetness   SensorType = "LEAF_WETNESS"
)

// ValidSensorTypes contains all valid sensor type values.
var ValidSensorTypes = map[SensorType]bool{
	SensorTypeSoilMoisture:   true,
	SensorTypeSoilPH:         true,
	SensorTypeTemperature:    true,
	SensorTypeHumidity:       true,
	SensorTypeRainfall:       true,
	SensorTypeWindSpeed:      true,
	SensorTypeWindDirection:  true,
	SensorTypeLightIntensity: true,
	SensorTypeLeafWetness:    true,
}

// SensorStatus represents the operational status of a sensor.
type SensorStatus string

const (
	SensorStatusActive         SensorStatus = "ACTIVE"
	SensorStatusInactive       SensorStatus = "INACTIVE"
	SensorStatusMaintenance    SensorStatus = "MAINTENANCE"
	SensorStatusDecommissioned SensorStatus = "DECOMMISSIONED"
)

// SensorProtocol represents the communication protocol used by a sensor.
type SensorProtocol string

const (
	SensorProtocolMQTT     SensorProtocol = "MQTT"
	SensorProtocolLoRaWAN  SensorProtocol = "LORAWAN"
	SensorProtocolZigbee   SensorProtocol = "ZIGBEE"
	SensorProtocolWiFi     SensorProtocol = "WIFI"
	SensorProtocolCellular SensorProtocol = "CELLULAR"
)

// ReadingQuality represents the quality assessment of a sensor reading.
type ReadingQuality string

const (
	ReadingQualityGood    ReadingQuality = "GOOD"
	ReadingQualitySuspect ReadingQuality = "SUSPECT"
	ReadingQualityBad     ReadingQuality = "BAD"
)

// AlertCondition represents the comparison condition for threshold alerts.
type AlertCondition string

const (
	AlertConditionGT  AlertCondition = "GT"
	AlertConditionLT  AlertCondition = "LT"
	AlertConditionEQ  AlertCondition = "EQ"
	AlertConditionGTE AlertCondition = "GTE"
	AlertConditionLTE AlertCondition = "LTE"
)

// AlertSeverity represents the severity level of an alert.
type AlertSeverity string

const (
	AlertSeverityLow      AlertSeverity = "LOW"
	AlertSeverityMedium   AlertSeverity = "MEDIUM"
	AlertSeverityHigh     AlertSeverity = "HIGH"
	AlertSeverityCritical AlertSeverity = "CRITICAL"
)

// Sensor represents an IoT sensor device in the agricultural monitoring network.
type Sensor struct {
	models.BaseModel
	TenantID              string         `json:"tenant_id" db:"tenant_id"`
	FieldID               string         `json:"field_id" db:"field_id"`
	FarmID                string         `json:"farm_id" db:"farm_id"`
	SensorType            SensorType     `json:"sensor_type" db:"sensor_type"`
	DeviceID              string         `json:"device_id" db:"device_id"`
	Manufacturer          string         `json:"manufacturer" db:"manufacturer"`
	Model                 string         `json:"model" db:"model"`
	FirmwareVersion       string         `json:"firmware_version" db:"firmware_version"`
	Latitude              *float64       `json:"latitude" db:"latitude"`
	Longitude             *float64       `json:"longitude" db:"longitude"`
	ElevationM            float64        `json:"elevation_m" db:"elevation_m"`
	InstallationDate      *time.Time     `json:"installation_date" db:"installation_date"`
	LastReadingAt         *time.Time     `json:"last_reading_at" db:"last_reading_at"`
	BatteryLevelPct       float64        `json:"battery_level_pct" db:"battery_level_pct"`
	SignalStrengthDbm     float64        `json:"signal_strength_dbm" db:"signal_strength_dbm"`
	Status                SensorStatus   `json:"status" db:"status"`
	Protocol              SensorProtocol `json:"protocol" db:"protocol"`
	ReadingIntervalSeconds int32         `json:"reading_interval_seconds" db:"reading_interval_seconds"`
	Metadata              json.RawMessage `json:"metadata" db:"metadata"`
	Version               int64          `json:"version" db:"version"`
}

// SensorReading represents a single time-series data point from a sensor.
type SensorReading struct {
	ID                int64           `json:"id" db:"id"`
	UUID              string          `json:"uuid" db:"uuid"`
	SensorID          string          `json:"sensor_id" db:"sensor_id"`
	TenantID          string          `json:"tenant_id" db:"tenant_id"`
	Value             float64         `json:"value" db:"value"`
	Unit              string          `json:"unit" db:"unit"`
	RecordedAt        time.Time       `json:"recorded_at" db:"recorded_at"`
	Quality           ReadingQuality  `json:"quality" db:"quality"`
	BatteryLevelPct   *float64        `json:"battery_level_pct" db:"battery_level_pct"`
	SignalStrengthDbm *float64        `json:"signal_strength_dbm" db:"signal_strength_dbm"`
	Metadata          json.RawMessage `json:"metadata" db:"metadata"`
	CreatedAt         time.Time       `json:"created_at" db:"created_at"`
}

// SensorAlert represents a threshold-based alert triggered by a sensor reading.
type SensorAlert struct {
	models.BaseModel
	SensorID       string         `json:"sensor_id" db:"sensor_id"`
	TenantID       string         `json:"tenant_id" db:"tenant_id"`
	FieldID        string         `json:"field_id" db:"field_id"`
	SensorType     SensorType     `json:"sensor_type" db:"sensor_type"`
	Threshold      float64        `json:"threshold" db:"threshold"`
	ActualValue    float64        `json:"actual_value" db:"actual_value"`
	Condition      AlertCondition `json:"condition" db:"condition"`
	Severity       AlertSeverity  `json:"severity" db:"severity"`
	Message        string         `json:"message" db:"message"`
	Acknowledged   bool           `json:"acknowledged" db:"acknowledged"`
	AcknowledgedBy *string        `json:"acknowledged_by" db:"acknowledged_by"`
	AcknowledgedAt *time.Time     `json:"acknowledged_at" db:"acknowledged_at"`
}

// SensorNetwork represents a group of sensors sharing a gateway or protocol.
type SensorNetwork struct {
	models.BaseModel
	TenantID      string         `json:"tenant_id" db:"tenant_id"`
	FarmID        string         `json:"farm_id" db:"farm_id"`
	Name          string         `json:"name" db:"name"`
	Description   string         `json:"description" db:"description"`
	Protocol      SensorProtocol `json:"protocol" db:"protocol"`
	GatewayID     string         `json:"gateway_id" db:"gateway_id"`
	SensorIDs     []string       `json:"sensor_ids" db:"sensor_ids"`
	TotalSensors  int32          `json:"total_sensors" db:"total_sensors"`
	ActiveSensors int32          `json:"active_sensors" db:"active_sensors"`
}

// SensorCalibration represents a calibration event for a sensor.
type SensorCalibration struct {
	ID                  int64      `json:"id" db:"id"`
	UUID                string     `json:"uuid" db:"uuid"`
	SensorID            string     `json:"sensor_id" db:"sensor_id"`
	TenantID            string     `json:"tenant_id" db:"tenant_id"`
	OffsetValue         float64    `json:"offset_value" db:"offset_value"`
	ScaleFactor         float64    `json:"scale_factor" db:"scale_factor"`
	CalibrationDate     time.Time  `json:"calibration_date" db:"calibration_date"`
	NextCalibrationDate *time.Time `json:"next_calibration_date" db:"next_calibration_date"`
	CalibratedBy        string     `json:"calibrated_by" db:"calibrated_by"`
	Notes               string     `json:"notes" db:"notes"`
	IsActive            bool       `json:"is_active" db:"is_active"`
	CreatedBy           string     `json:"created_by" db:"created_by"`
	CreatedAt           time.Time  `json:"created_at" db:"created_at"`
}

// ReadingValidationRange defines the valid value range for each sensor type.
type ReadingValidationRange struct {
	Min  float64
	Max  float64
	Unit string
}

// ValidReadingRanges maps sensor types to their valid reading ranges.
var ValidReadingRanges = map[SensorType]ReadingValidationRange{
	SensorTypeSoilMoisture:   {Min: 0, Max: 100, Unit: "%"},
	SensorTypeSoilPH:         {Min: 0, Max: 14, Unit: "pH"},
	SensorTypeTemperature:    {Min: -50, Max: 60, Unit: "°C"},
	SensorTypeHumidity:       {Min: 0, Max: 100, Unit: "%"},
	SensorTypeRainfall:       {Min: 0, Max: 500, Unit: "mm"},
	SensorTypeWindSpeed:      {Min: 0, Max: 200, Unit: "km/h"},
	SensorTypeWindDirection:  {Min: 0, Max: 360, Unit: "°"},
	SensorTypeLightIntensity: {Min: 0, Max: 200000, Unit: "lux"},
	SensorTypeLeafWetness:    {Min: 0, Max: 100, Unit: "%"},
}

// IsValidReading checks whether a value falls within the expected range for the sensor type.
// Returns the quality assessment: GOOD if within range, SUSPECT if marginally outside,
// BAD if far outside expected range.
func (st SensorType) IsValidReading(value float64) ReadingQuality {
	r, ok := ValidReadingRanges[st]
	if !ok {
		return ReadingQualitySuspect
	}
	rangeSpan := r.Max - r.Min
	margin := rangeSpan * 0.1 // 10% margin for SUSPECT

	if value >= r.Min && value <= r.Max {
		return ReadingQualityGood
	}
	if value >= (r.Min-margin) && value <= (r.Max+margin) {
		return ReadingQualitySuspect
	}
	return ReadingQualityBad
}

// EvaluateCondition checks if the actual value satisfies the alert condition relative to the threshold.
func EvaluateCondition(condition AlertCondition, actual, threshold float64) bool {
	switch condition {
	case AlertConditionGT:
		return actual > threshold
	case AlertConditionLT:
		return actual < threshold
	case AlertConditionEQ:
		return actual == threshold
	case AlertConditionGTE:
		return actual >= threshold
	case AlertConditionLTE:
		return actual <= threshold
	default:
		return false
	}
}

// SensorListFilter encapsulates all filter parameters for listing sensors.
type SensorListFilter struct {
	TenantID   string
	FieldID    string
	FarmID     string
	SensorType string
	Status     string
	Protocol   string
	PageSize   int32
	PageOffset int32
}

// AlertListFilter encapsulates all filter parameters for listing alerts.
type AlertListFilter struct {
	TenantID           string
	SensorID           string
	FieldID            string
	Severity           string
	UnacknowledgedOnly bool
	PageSize           int32
	PageOffset         int32
}
