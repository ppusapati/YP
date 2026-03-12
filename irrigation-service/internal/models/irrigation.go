package models

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// ScheduleType represents the type of irrigation schedule.
type ScheduleType string

const (
	ScheduleTypeFixed    ScheduleType = "FIXED"
	ScheduleTypeAdaptive ScheduleType = "ADAPTIVE"
	ScheduleTypeAIDriven ScheduleType = "AI_DRIVEN"
)

// Frequency represents the recurrence frequency of an irrigation schedule.
type Frequency string

const (
	FrequencyDaily        Frequency = "DAILY"
	FrequencyEveryOther   Frequency = "EVERY_OTHER_DAY"
	FrequencyWeekly       Frequency = "WEEKLY"
	FrequencyCustom       Frequency = "CUSTOM"
)

// ControllerType represents the type of water controller hardware.
type ControllerType string

const (
	ControllerTypeDrip      ControllerType = "DRIP"
	ControllerTypeValve     ControllerType = "VALVE"
	ControllerTypePump      ControllerType = "PUMP"
	ControllerTypeSprinkler ControllerType = "SPRINKLER"
)

// Protocol represents the IoT communication protocol.
type Protocol string

const (
	ProtocolMQTT    Protocol = "MQTT"
	ProtocolLoRaWAN Protocol = "LORAWAN"
	ProtocolModbus  Protocol = "MODBUS"
)

// ControllerStatus represents the operational status of a water controller.
type ControllerStatus string

const (
	ControllerStatusOnline  ControllerStatus = "ONLINE"
	ControllerStatusOffline ControllerStatus = "OFFLINE"
	ControllerStatusError   ControllerStatus = "ERROR"
)

// IrrigationStatus represents the current status of an irrigation schedule or event.
type IrrigationStatus string

const (
	IrrigationStatusScheduled IrrigationStatus = "SCHEDULED"
	IrrigationStatusActive    IrrigationStatus = "ACTIVE"
	IrrigationStatusCompleted IrrigationStatus = "COMPLETED"
	IrrigationStatusCancelled IrrigationStatus = "CANCELLED"
	IrrigationStatusFailed    IrrigationStatus = "FAILED"
)

// ---------------------------------------------------------------------------
// Domain Entities
// ---------------------------------------------------------------------------

// IrrigationZone represents a defined irrigation area within a field.
type IrrigationZone struct {
	models.BaseModel
	TenantID       string  `json:"tenant_id" db:"tenant_id"`
	FieldID        string  `json:"field_id" db:"field_id"`
	FarmID         string  `json:"farm_id" db:"farm_id"`
	Name           string  `json:"name" db:"name"`
	Description    string  `json:"description" db:"description"`
	AreaHectares   float64 `json:"area_hectares" db:"area_hectares"`
	SoilType       string  `json:"soil_type" db:"soil_type"`
	CropType       string  `json:"crop_type" db:"crop_type"`
	CropGrowthStage string `json:"crop_growth_stage" db:"crop_growth_stage"`
	Latitude       float64 `json:"latitude" db:"latitude"`
	Longitude      float64 `json:"longitude" db:"longitude"`
}

// WaterController represents a physical IoT controller for water delivery.
type WaterController struct {
	models.BaseModel
	TenantID                  string           `json:"tenant_id" db:"tenant_id"`
	ZoneID                    string           `json:"zone_id" db:"zone_id"`
	FieldID                   string           `json:"field_id" db:"field_id"`
	FarmID                    string           `json:"farm_id" db:"farm_id"`
	Name                      string           `json:"name" db:"name"`
	Model                     string           `json:"model" db:"model"`
	FirmwareVersion           string           `json:"firmware_version" db:"firmware_version"`
	ControllerType            ControllerType   `json:"controller_type" db:"controller_type"`
	Protocol                  Protocol         `json:"protocol" db:"protocol"`
	Status                    ControllerStatus `json:"status" db:"status"`
	Endpoint                  string           `json:"endpoint" db:"endpoint"`
	MaxFlowRateLitersPerHour  float64          `json:"max_flow_rate_liters_per_hour" db:"max_flow_rate_liters_per_hour"`
	LastHeartbeat             *time.Time       `json:"last_heartbeat" db:"last_heartbeat"`
}

// IrrigationSchedule represents a planned irrigation cycle.
type IrrigationSchedule struct {
	models.BaseModel
	TenantID                string           `json:"tenant_id" db:"tenant_id"`
	FieldID                 string           `json:"field_id" db:"field_id"`
	FarmID                  string           `json:"farm_id" db:"farm_id"`
	ZoneID                  string           `json:"zone_id" db:"zone_id"`
	Name                    string           `json:"name" db:"name"`
	Description             string           `json:"description" db:"description"`
	ScheduleType            ScheduleType     `json:"schedule_type" db:"schedule_type"`
	StartTime               time.Time        `json:"start_time" db:"start_time"`
	EndTime                 *time.Time       `json:"end_time" db:"end_time"`
	DurationMinutes         int32            `json:"duration_minutes" db:"duration_minutes"`
	WaterQuantityLiters     float64          `json:"water_quantity_liters" db:"water_quantity_liters"`
	FlowRateLitersPerHour   float64          `json:"flow_rate_liters_per_hour" db:"flow_rate_liters_per_hour"`
	Frequency               Frequency        `json:"frequency" db:"frequency"`
	SoilMoistureThresholdPct float64         `json:"soil_moisture_threshold_pct" db:"soil_moisture_threshold_pct"`
	WeatherAdjusted         bool             `json:"weather_adjusted" db:"weather_adjusted"`
	CropGrowthStage         string           `json:"crop_growth_stage" db:"crop_growth_stage"`
	ControllerID            string           `json:"controller_id" db:"controller_id"`
	Status                  IrrigationStatus `json:"status" db:"status"`
	Version                 int64            `json:"version" db:"version"`
}

// IrrigationEvent represents a single irrigation execution event.
type IrrigationEvent struct {
	models.BaseModel
	TenantID              string           `json:"tenant_id" db:"tenant_id"`
	ScheduleID            string           `json:"schedule_id" db:"schedule_id"`
	ZoneID                string           `json:"zone_id" db:"zone_id"`
	ControllerID          string           `json:"controller_id" db:"controller_id"`
	Status                IrrigationStatus `json:"status" db:"status"`
	StartedAt             *time.Time       `json:"started_at" db:"started_at"`
	EndedAt               *time.Time       `json:"ended_at" db:"ended_at"`
	ActualDurationMinutes int32            `json:"actual_duration_minutes" db:"actual_duration_minutes"`
	ActualWaterLiters     float64          `json:"actual_water_liters" db:"actual_water_liters"`
	SoilMoistureBeforePct float64          `json:"soil_moisture_before_pct" db:"soil_moisture_before_pct"`
	SoilMoistureAfterPct  float64          `json:"soil_moisture_after_pct" db:"soil_moisture_after_pct"`
	FailureReason         string           `json:"failure_reason" db:"failure_reason"`
}

// DecisionInputs contains sensor and environmental data used for irrigation decisions.
type DecisionInputs struct {
	SoilMoisture          float64 `json:"soil_moisture"`
	Temperature           float64 `json:"temperature"`
	Humidity              float64 `json:"humidity"`
	RainfallForecastMM    float64 `json:"rainfall_forecast_mm"`
	WindSpeed             float64 `json:"wind_speed"`
	CropType              string  `json:"crop_type"`
	GrowthStage           string  `json:"growth_stage"`
	EvapotranspirationMM  float64 `json:"evapotranspiration_mm"`
}

// DecisionOutput contains the computed irrigation recommendation.
type DecisionOutput struct {
	ShouldIrrigate     bool      `json:"should_irrigate"`
	WaterQuantityLiters float64  `json:"water_quantity_liters"`
	DurationMinutes    int32     `json:"duration_minutes"`
	OptimalTime        *time.Time `json:"optimal_time"`
	Reasoning          string    `json:"reasoning"`
	ConfidenceScore    float64   `json:"confidence_score"`
}

// IrrigationDecision represents an AI-driven irrigation decision record.
type IrrigationDecision struct {
	models.BaseModel
	TenantID   string         `json:"tenant_id" db:"tenant_id"`
	ZoneID     string         `json:"zone_id" db:"zone_id"`
	FieldID    string         `json:"field_id" db:"field_id"`
	ScheduleID string         `json:"schedule_id" db:"schedule_id"`
	Inputs     DecisionInputs `json:"inputs"`
	Output     DecisionOutput `json:"output"`
	DecidedAt  time.Time      `json:"decided_at" db:"decided_at"`
	Applied    bool           `json:"applied" db:"applied"`
}

// WaterUsageLog records water consumption for a given period.
type WaterUsageLog struct {
	models.BaseModel
	TenantID     string    `json:"tenant_id" db:"tenant_id"`
	ZoneID       string    `json:"zone_id" db:"zone_id"`
	ControllerID string    `json:"controller_id" db:"controller_id"`
	WaterLiters  float64   `json:"water_liters" db:"water_liters"`
	RecordedAt   time.Time `json:"recorded_at" db:"recorded_at"`
	PeriodStart  time.Time `json:"period_start" db:"period_start"`
	PeriodEnd    time.Time `json:"period_end" db:"period_end"`
}

// ControllerCommand represents a command sent to a physical water controller.
type ControllerCommand struct {
	ControllerID string         `json:"controller_id"`
	Action       string         `json:"action"` // "START", "STOP"
	Protocol     Protocol       `json:"protocol"`
	Endpoint     string         `json:"endpoint"`
	DurationMin  int32          `json:"duration_min"`
	FlowRate     float64        `json:"flow_rate"`
	Payload      map[string]any `json:"payload"`
}

// ControllerCommandResult is the response from a controller command execution.
type ControllerCommandResult struct {
	Success      bool   `json:"success"`
	ErrorMessage string `json:"error_message"`
	AckTimestamp *time.Time `json:"ack_timestamp"`
}
