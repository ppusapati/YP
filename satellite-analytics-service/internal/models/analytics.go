package models

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// StressType represents the type of crop stress detected.
type StressType string

const (
	StressTypeUnspecified StressType = ""
	StressTypeWater      StressType = "WATER"
	StressTypeNutrient   StressType = "NUTRIENT"
	StressTypeDisease    StressType = "DISEASE"
	StressTypePest       StressType = "PEST"
	StressTypeHeat       StressType = "HEAT"
	StressTypeFrost      StressType = "FROST"
)

// IsValid checks if the stress type is a valid value.
func (st StressType) IsValid() bool {
	switch st {
	case StressTypeWater, StressTypeNutrient, StressTypeDisease,
		StressTypePest, StressTypeHeat, StressTypeFrost:
		return true
	default:
		return false
	}
}

// SeverityLevel represents the severity of a stress alert.
type SeverityLevel string

const (
	SeverityLevelUnspecified SeverityLevel = ""
	SeverityLevelLow        SeverityLevel = "LOW"
	SeverityLevelMedium     SeverityLevel = "MEDIUM"
	SeverityLevelHigh       SeverityLevel = "HIGH"
	SeverityLevelCritical   SeverityLevel = "CRITICAL"
)

// IsValid checks if the severity level is a valid value.
func (sl SeverityLevel) IsValid() bool {
	switch sl {
	case SeverityLevelLow, SeverityLevelMedium, SeverityLevelHigh, SeverityLevelCritical:
		return true
	default:
		return false
	}
}

// AnalysisType represents the type of analysis performed.
type AnalysisType string

const (
	AnalysisTypeUnspecified        AnalysisType = ""
	AnalysisTypeStressDetection    AnalysisType = "STRESS_DETECTION"
	AnalysisTypeChangeDetection    AnalysisType = "CHANGE_DETECTION"
	AnalysisTypeTemporalTrend      AnalysisType = "TEMPORAL_TREND"
	AnalysisTypeAnomalyDetection   AnalysisType = "ANOMALY_DETECTION"
	AnalysisTypeCropClassification AnalysisType = "CROP_CLASSIFICATION"
)

// IsValid checks if the analysis type is a valid value.
func (at AnalysisType) IsValid() bool {
	switch at {
	case AnalysisTypeStressDetection, AnalysisTypeChangeDetection,
		AnalysisTypeTemporalTrend, AnalysisTypeAnomalyDetection,
		AnalysisTypeCropClassification:
		return true
	default:
		return false
	}
}

// StressAlert represents a detected crop stress alert in the domain.
type StressAlert struct {
	models.BaseModel
	TenantID             string        `json:"tenant_id" db:"tenant_id"`
	FarmID               string        `json:"farm_id" db:"farm_id"`
	FieldID              string        `json:"field_id" db:"field_id"`
	ProcessingJobID      *string       `json:"processing_job_id,omitempty" db:"processing_job_id"`
	StressType           StressType    `json:"stress_type" db:"stress_type"`
	Severity             SeverityLevel `json:"severity" db:"severity"`
	Confidence           float64       `json:"confidence" db:"confidence"`
	AffectedAreaHectares float64       `json:"affected_area_hectares" db:"affected_area_hectares"`
	AffectedPercentage   float64       `json:"affected_percentage" db:"affected_percentage"`
	BboxGeoJSON          *string       `json:"bbox_geojson,omitempty" db:"bbox_geojson"`
	Description          *string       `json:"description,omitempty" db:"description"`
	Recommendation       *string       `json:"recommendation,omitempty" db:"recommendation"`
	Acknowledged         bool          `json:"acknowledged" db:"acknowledged"`
	AcknowledgedAt       *time.Time    `json:"acknowledged_at,omitempty" db:"acknowledged_at"`
	AcknowledgedBy       *string       `json:"acknowledged_by,omitempty" db:"acknowledged_by"`
	DetectedAt           time.Time     `json:"detected_at" db:"detected_at"`
}

// GetID returns the primary key of the stress alert.
func (s *StressAlert) GetID() int64 {
	return s.ID
}

// GetUUID returns the ULID identifier of the stress alert.
func (s *StressAlert) GetUUID() string {
	return s.UUID
}

// TemporalAnalysis represents a temporal analysis result in the domain.
type TemporalAnalysis struct {
	models.BaseModel
	TenantID         string       `json:"tenant_id" db:"tenant_id"`
	FarmID           string       `json:"farm_id" db:"farm_id"`
	FieldID          string       `json:"field_id" db:"field_id"`
	AnalysisType     AnalysisType `json:"analysis_type" db:"analysis_type"`
	MetricName       string       `json:"metric_name" db:"metric_name"`
	TrendSlope       float64      `json:"trend_slope" db:"trend_slope"`
	TrendRSquared    float64      `json:"trend_r_squared" db:"trend_r_squared"`
	CurrentValue     float64      `json:"current_value" db:"current_value"`
	BaselineValue    float64      `json:"baseline_value" db:"baseline_value"`
	DeviationPercent float64      `json:"deviation_percent" db:"deviation_percent"`
	PeriodStart      time.Time    `json:"period_start" db:"period_start"`
	PeriodEnd        time.Time    `json:"period_end" db:"period_end"`
}

// GetID returns the primary key of the temporal analysis.
func (t *TemporalAnalysis) GetID() int64 {
	return t.ID
}

// GetUUID returns the ULID identifier of the temporal analysis.
func (t *TemporalAnalysis) GetUUID() string {
	return t.UUID
}

// ListStressAlertsParams holds the filter and pagination parameters for listing stress alerts.
type ListStressAlertsParams struct {
	TenantID           string
	FarmID             *string
	StressType         *StressType
	MinSeverity        *SeverityLevel
	UnacknowledgedOnly bool
	PageSize           int32
	Offset             int32
}

// FieldAnalyticsSummary holds summary analytics for a field.
type FieldAnalyticsSummary struct {
	ActiveStressAlerts int32      `json:"active_stress_alerts"`
	HealthScore        float64    `json:"health_score"`
	NdviTrend          float64    `json:"ndvi_trend"`
	DominantStressType string     `json:"dominant_stress_type"`
	LastAnalysis       *time.Time `json:"last_analysis,omitempty"`
}
