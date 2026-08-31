package models

import "time"

// AlertSeverity represents the severity level of an alert.
type AlertSeverity string

const (
	AlertSeverityInfo      AlertSeverity = "INFO"
	AlertSeverityWarning   AlertSeverity = "WARNING"
	AlertSeverityCritical  AlertSeverity = "CRITICAL"
	AlertSeverityEmergency AlertSeverity = "EMERGENCY"
)

// ValidAlertSeverities returns all valid alert severity levels.
func ValidAlertSeverities() []AlertSeverity {
	return []AlertSeverity{
		AlertSeverityInfo,
		AlertSeverityWarning,
		AlertSeverityCritical,
		AlertSeverityEmergency,
	}
}

// IsValid checks whether the alert severity is a recognized value.
func (s AlertSeverity) IsValid() bool {
	switch s {
	case AlertSeverityInfo, AlertSeverityWarning, AlertSeverityCritical, AlertSeverityEmergency:
		return true
	default:
		return false
	}
}

// AlertType represents the category of an alert condition.
type AlertType string

const (
	AlertTypeFrostRisk           AlertType = "FROST_RISK"
	AlertTypeHeatStress          AlertType = "HEAT_STRESS"
	AlertTypeDroughtWarning      AlertType = "DROUGHT_WARNING"
	AlertTypeExcessiveRain       AlertType = "EXCESSIVE_RAIN"
	AlertTypePestOutbreak        AlertType = "PEST_OUTBREAK"
	AlertTypeDiseaseDetected     AlertType = "DISEASE_DETECTED"
	AlertTypeNutrientDeficiency  AlertType = "NUTRIENT_DEFICIENCY"
	AlertTypeWaterStress         AlertType = "WATER_STRESS"
	AlertTypeGrowthAnomaly       AlertType = "GROWTH_ANOMALY"
)

// ValidAlertTypes returns all valid alert types.
func ValidAlertTypes() []AlertType {
	return []AlertType{
		AlertTypeFrostRisk,
		AlertTypeHeatStress,
		AlertTypeDroughtWarning,
		AlertTypeExcessiveRain,
		AlertTypePestOutbreak,
		AlertTypeDiseaseDetected,
		AlertTypeNutrientDeficiency,
		AlertTypeWaterStress,
		AlertTypeGrowthAnomaly,
	}
}

// IsValid checks whether the alert type is a recognized value.
func (t AlertType) IsValid() bool {
	switch t {
	case AlertTypeFrostRisk, AlertTypeHeatStress, AlertTypeDroughtWarning,
		AlertTypeExcessiveRain, AlertTypePestOutbreak, AlertTypeDiseaseDetected,
		AlertTypeNutrientDeficiency, AlertTypeWaterStress, AlertTypeGrowthAnomaly:
		return true
	default:
		return false
	}
}

// AlertStatus represents the lifecycle state of an alert.
type AlertStatus string

const (
	AlertStatusActive       AlertStatus = "ACTIVE"
	AlertStatusAcknowledged AlertStatus = "ACKNOWLEDGED"
	AlertStatusResolved     AlertStatus = "RESOLVED"
	AlertStatusExpired      AlertStatus = "EXPIRED"
)

// ValidAlertStatuses returns all valid alert statuses.
func ValidAlertStatuses() []AlertStatus {
	return []AlertStatus{
		AlertStatusActive,
		AlertStatusAcknowledged,
		AlertStatusResolved,
		AlertStatusExpired,
	}
}

// IsValid checks whether the alert status is a recognized value.
func (s AlertStatus) IsValid() bool {
	switch s {
	case AlertStatusActive, AlertStatusAcknowledged, AlertStatusResolved, AlertStatusExpired:
		return true
	default:
		return false
	}
}

// Alert represents a field-level alert raised by the system.
type Alert struct {
	ID              string        `json:"id" db:"id"`
	FieldID         string        `json:"field_id" db:"field_id"`
	FarmID          string        `json:"farm_id" db:"farm_id"`
	FieldName       string        `json:"field_name" db:"field_name"`
	AlertType       AlertType     `json:"alert_type" db:"alert_type"`
	Severity        AlertSeverity `json:"severity" db:"severity"`
	Status          AlertStatus   `json:"status" db:"status"`
	Title           string        `json:"title" db:"title"`
	Message         string        `json:"message" db:"message"`
	Read            bool          `json:"read" db:"read"`
	ActionURL       string        `json:"action_url,omitempty" db:"action_url"`
	Recommendations []string      `json:"recommendations" db:"recommendations"`
	Metrics         map[string]float64 `json:"metrics,omitempty" db:"metrics"`
	MetricValue     float64       `json:"metric_value" db:"metric_value"`
	ThresholdValue  float64       `json:"threshold_value" db:"threshold_value"`
	CreatedAt       time.Time     `json:"created_at" db:"created_at"`
	AcknowledgedAt  *time.Time    `json:"acknowledged_at,omitempty" db:"acknowledged_at"`
	AcknowledgedBy  string        `json:"acknowledged_by,omitempty" db:"acknowledged_by"`
	ResolvedAt      *time.Time    `json:"resolved_at,omitempty" db:"resolved_at"`
	ExpiresAt       *time.Time    `json:"expires_at,omitempty" db:"expires_at"`
}

// AlertRule defines a user-configurable rule that triggers alerts.
type AlertRule struct {
	ID              string        `json:"id" db:"id"`
	FieldID         string        `json:"field_id" db:"field_id"`
	FarmID          string        `json:"farm_id" db:"farm_id"`
	AlertType       AlertType     `json:"alert_type" db:"alert_type"`
	Metric          string        `json:"metric" db:"metric"`
	Condition       string        `json:"condition" db:"condition"`
	Threshold       float64       `json:"threshold" db:"threshold"`
	Severity        AlertSeverity `json:"severity" db:"severity"`
	Enabled         bool          `json:"enabled" db:"enabled"`
	ThresholdJSON   string        `json:"threshold_json" db:"threshold_json"`
	NotifyChannels  []string      `json:"notify_channels" db:"notify_channels"`
	CooldownMinutes int32         `json:"cooldown_minutes" db:"cooldown_minutes"`
	CreatedAt       time.Time     `json:"created_at" db:"created_at"`
	UpdatedAt       time.Time     `json:"updated_at" db:"updated_at"`
}

// FieldRiskScore mirrors the Rust alert-engine FieldRiskScore output.
type FieldRiskScore struct {
	FieldID         string             `json:"field_id"`
	FieldName       string             `json:"field_name"`
	FarmID          string             `json:"farm_id"`
	OverallRisk     float64            `json:"overall_risk"`
	TemperatureRisk float64            `json:"temperature_risk"`
	WaterRisk       float64            `json:"water_risk"`
	PestRisk        float64            `json:"pest_risk"`
	DiseaseRisk     float64            `json:"disease_risk"`
	NutrientRisk    float64            `json:"nutrient_risk"`
	GrowthRisk      float64            `json:"growth_risk"`
	RiskFactors     map[string]float64 `json:"risk_factors"`
	Alerts          []Alert            `json:"alerts"`
	EvaluatedAt     time.Time          `json:"evaluated_at"`
	CalculatedAt    string             `json:"calculated_at"`
	Trend           string             `json:"trend"`
}
