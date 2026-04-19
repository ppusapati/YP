package domain

import (
	"encoding/json"
	"time"

	"p9e.in/samavaya/packages/models"
)

// RiskLevel represents the pest risk level classification.
type RiskLevel string

const (
	RiskLevelUnspecified RiskLevel = ""
	RiskLevelNone        RiskLevel = "NONE"
	RiskLevelLow         RiskLevel = "LOW"
	RiskLevelModerate    RiskLevel = "MODERATE"
	RiskLevelHigh        RiskLevel = "HIGH"
	RiskLevelCritical    RiskLevel = "CRITICAL"
)

// IsValid checks if the risk level is a valid value.
func (r RiskLevel) IsValid() bool {
	switch r {
	case RiskLevelNone, RiskLevelLow, RiskLevelModerate, RiskLevelHigh, RiskLevelCritical:
		return true
	default:
		return false
	}
}

// Severity returns a numeric severity for comparison (higher = worse).
func (r RiskLevel) Severity() int {
	switch r {
	case RiskLevelNone:
		return 0
	case RiskLevelLow:
		return 1
	case RiskLevelModerate:
		return 2
	case RiskLevelHigh:
		return 3
	case RiskLevelCritical:
		return 4
	default:
		return -1
	}
}

// RiskLevelFromScore converts a numeric risk score (0-100) to a RiskLevel.
func RiskLevelFromScore(score int) RiskLevel {
	switch {
	case score <= 10:
		return RiskLevelNone
	case score <= 30:
		return RiskLevelLow
	case score <= 55:
		return RiskLevelModerate
	case score <= 80:
		return RiskLevelHigh
	default:
		return RiskLevelCritical
	}
}

// TreatmentType represents the type of pest treatment.
type TreatmentType string

const (
	TreatmentTypeUnspecified TreatmentType = ""
	TreatmentTypeChemical    TreatmentType = "CHEMICAL"
	TreatmentTypeBiological  TreatmentType = "BIOLOGICAL"
	TreatmentTypeCultural    TreatmentType = "CULTURAL"
	TreatmentTypeMechanical  TreatmentType = "MECHANICAL"
)

// IsValid checks if the treatment type is a valid value.
func (t TreatmentType) IsValid() bool {
	switch t {
	case TreatmentTypeChemical, TreatmentTypeBiological, TreatmentTypeCultural, TreatmentTypeMechanical:
		return true
	default:
		return false
	}
}

// AlertStatus represents the status of a pest alert.
type AlertStatus string

const (
	AlertStatusUnspecified  AlertStatus = ""
	AlertStatusActive       AlertStatus = "ACTIVE"
	AlertStatusAcknowledged AlertStatus = "ACKNOWLEDGED"
	AlertStatusResolved     AlertStatus = "RESOLVED"
	AlertStatusExpired      AlertStatus = "EXPIRED"
)

// IsValid checks if the alert status is a valid value.
func (a AlertStatus) IsValid() bool {
	switch a {
	case AlertStatusActive, AlertStatusAcknowledged, AlertStatusResolved, AlertStatusExpired:
		return true
	default:
		return false
	}
}

// DamageLevel represents the level of crop damage from pests.
type DamageLevel string

const (
	DamageLevelUnspecified DamageLevel = ""
	DamageLevelNone        DamageLevel = "NONE"
	DamageLevelLight       DamageLevel = "LIGHT"
	DamageLevelModerate    DamageLevel = "MODERATE"
	DamageLevelSevere      DamageLevel = "SEVERE"
	DamageLevelDevastating DamageLevel = "DEVASTATING"
)

// IsValid checks if the damage level is a valid value.
func (d DamageLevel) IsValid() bool {
	switch d {
	case DamageLevelNone, DamageLevelLight, DamageLevelModerate, DamageLevelSevere, DamageLevelDevastating:
		return true
	default:
		return false
	}
}

// GrowthStage represents the crop growth stage.
type GrowthStage string

const (
	GrowthStageUnspecified GrowthStage = ""
	GrowthStageGermination GrowthStage = "GERMINATION"
	GrowthStageSeedling    GrowthStage = "SEEDLING"
	GrowthStageVegetative  GrowthStage = "VEGETATIVE"
	GrowthStageFlowering   GrowthStage = "FLOWERING"
	GrowthStageFruiting    GrowthStage = "FRUITING"
	GrowthStageMaturation  GrowthStage = "MATURATION"
	GrowthStageHarvest     GrowthStage = "HARVEST"
)

// IsValid checks if the growth stage is a valid value.
func (g GrowthStage) IsValid() bool {
	switch g {
	case GrowthStageGermination, GrowthStageSeedling, GrowthStageVegetative,
		GrowthStageFlowering, GrowthStageFruiting, GrowthStageMaturation, GrowthStageHarvest:
		return true
	case GrowthStageUnspecified:
		return true
	default:
		return false
	}
}

// WeatherFactors holds weather conditions relevant to pest risk calculations.
type WeatherFactors struct {
	TemperatureCelsius float64 `json:"temperature_celsius"`
	HumidityPct        float64 `json:"humidity_pct"`
	RainfallMm         float64 `json:"rainfall_mm"`
	WindSpeedKmh       float64 `json:"wind_speed_kmh"`
}

// RecommendedTreatment is a single recommended treatment action.
type RecommendedTreatment struct {
	TreatmentType     TreatmentType `json:"treatment_type"`
	ProductName       string        `json:"product_name"`
	ApplicationRate   string        `json:"application_rate"`
	ApplicationMethod string        `json:"application_method"`
	Timing            string        `json:"timing"`
	SafetyInterval    string        `json:"safety_interval"`
}

// PestSpecies describes a known pest species in the catalogue.
type PestSpecies struct {
	models.BaseModel
	TenantID            string          `json:"tenant_id" db:"tenant_id"`
	CommonName          string          `json:"common_name" db:"common_name"`
	ScientificName      string          `json:"scientific_name" db:"scientific_name"`
	Family              *string         `json:"family,omitempty" db:"family"`
	Description         *string         `json:"description,omitempty" db:"description"`
	AffectedCrops       json.RawMessage `json:"affected_crops" db:"affected_crops"`
	FavorableConditions json.RawMessage `json:"favorable_conditions" db:"favorable_conditions"`
	ImageURL            *string         `json:"image_url,omitempty" db:"image_url"`
	Version             int64           `json:"version" db:"version"`
}

// GetID returns the primary key.
func (p *PestSpecies) GetID() int64 { return p.ID }

// GetUUID returns the ULID identifier.
func (p *PestSpecies) GetUUID() string { return p.UUID }

// PestPrediction is the main pest risk prediction entity.
type PestPrediction struct {
	models.BaseModel
	TenantID                  string          `json:"tenant_id" db:"tenant_id"`
	FarmID                    string          `json:"farm_id" db:"farm_id"`
	FieldID                   string          `json:"field_id" db:"field_id"`
	PestSpeciesID             int64           `json:"pest_species_id" db:"pest_species_id"`
	PestSpeciesUUID           string          `json:"pest_species_uuid" db:"pest_species_uuid"`
	PredictionDate            time.Time       `json:"prediction_date" db:"prediction_date"`
	RiskLevel                 RiskLevel       `json:"risk_level" db:"risk_level"`
	RiskScore                 int             `json:"risk_score" db:"risk_score"`
	ConfidencePct             float64         `json:"confidence_pct" db:"confidence_pct"`
	TemperatureCelsius        *float64        `json:"temperature_celsius,omitempty" db:"temperature_celsius"`
	HumidityPct               *float64        `json:"humidity_pct,omitempty" db:"humidity_pct"`
	RainfallMm                *float64        `json:"rainfall_mm,omitempty" db:"rainfall_mm"`
	WindSpeedKmh              *float64        `json:"wind_speed_kmh,omitempty" db:"wind_speed_kmh"`
	CropType                  string          `json:"crop_type" db:"crop_type"`
	GrowthStage               *GrowthStage    `json:"growth_stage,omitempty" db:"growth_stage"`
	GeographicRiskFactor      float64         `json:"geographic_risk_factor" db:"geographic_risk_factor"`
	HistoricalOccurrenceCount int             `json:"historical_occurrence_count" db:"historical_occurrence_count"`
	PredictedOnsetDate        *time.Time      `json:"predicted_onset_date,omitempty" db:"predicted_onset_date"`
	PredictedPeakDate         *time.Time      `json:"predicted_peak_date,omitempty" db:"predicted_peak_date"`
	TreatmentWindowStart      *time.Time      `json:"treatment_window_start,omitempty" db:"treatment_window_start"`
	TreatmentWindowEnd        *time.Time      `json:"treatment_window_end,omitempty" db:"treatment_window_end"`
	RecommendedTreatments     json.RawMessage `json:"recommended_treatments" db:"recommended_treatments"`
	Version                   int64           `json:"version" db:"version"`
}

// GetID returns the primary key.
func (p *PestPrediction) GetID() int64 { return p.ID }

// GetUUID returns the ULID identifier.
func (p *PestPrediction) GetUUID() string { return p.UUID }

// PestAlert represents an early-warning alert for pest risk.
type PestAlert struct {
	models.BaseModel
	TenantID        string      `json:"tenant_id" db:"tenant_id"`
	PredictionID    int64       `json:"prediction_id" db:"prediction_id"`
	PredictionUUID  string      `json:"prediction_uuid" db:"prediction_uuid"`
	FarmID          string      `json:"farm_id" db:"farm_id"`
	FieldID         string      `json:"field_id" db:"field_id"`
	PestSpeciesID   int64       `json:"pest_species_id" db:"pest_species_id"`
	PestSpeciesUUID string      `json:"pest_species_uuid" db:"pest_species_uuid"`
	RiskLevel       RiskLevel   `json:"risk_level" db:"risk_level"`
	Status          AlertStatus `json:"status" db:"status"`
	Title           string      `json:"title" db:"title"`
	Message         string      `json:"message" db:"message"`
	AcknowledgedAt  *time.Time  `json:"acknowledged_at,omitempty" db:"acknowledged_at"`
	AcknowledgedBy  *string     `json:"acknowledged_by,omitempty" db:"acknowledged_by"`
	Version         int64       `json:"version" db:"version"`
}

// GetID returns the primary key.
func (a *PestAlert) GetID() int64 { return a.ID }

// GetUUID returns the ULID identifier.
func (a *PestAlert) GetUUID() string { return a.UUID }

// PestObservation records a field observation of pest activity.
type PestObservation struct {
	models.BaseModel
	TenantID        string      `json:"tenant_id" db:"tenant_id"`
	FarmID          string      `json:"farm_id" db:"farm_id"`
	FieldID         string      `json:"field_id" db:"field_id"`
	PestSpeciesID   int64       `json:"pest_species_id" db:"pest_species_id"`
	PestSpeciesUUID string      `json:"pest_species_uuid" db:"pest_species_uuid"`
	PestCount       int         `json:"pest_count" db:"pest_count"`
	DamageLevel     DamageLevel `json:"damage_level" db:"damage_level"`
	TrapType        *string     `json:"trap_type,omitempty" db:"trap_type"`
	ImageURL        *string     `json:"image_url,omitempty" db:"image_url"`
	Latitude        *float64    `json:"latitude,omitempty" db:"latitude"`
	Longitude       *float64    `json:"longitude,omitempty" db:"longitude"`
	Notes           *string     `json:"notes,omitempty" db:"notes"`
	ObservedBy      string      `json:"observed_by" db:"observed_by"`
	ObservedAt      time.Time   `json:"observed_at" db:"observed_at"`
	Version         int64       `json:"version" db:"version"`
}

// GetID returns the primary key.
func (o *PestObservation) GetID() int64 { return o.ID }

// GetUUID returns the ULID identifier.
func (o *PestObservation) GetUUID() string { return o.UUID }

// PestTreatment records an applied treatment.
type PestTreatment struct {
	models.BaseModel
	TenantID            string        `json:"tenant_id" db:"tenant_id"`
	FarmID              string        `json:"farm_id" db:"farm_id"`
	FieldID             string        `json:"field_id" db:"field_id"`
	PestSpeciesID       int64         `json:"pest_species_id" db:"pest_species_id"`
	PestSpeciesUUID     string        `json:"pest_species_uuid" db:"pest_species_uuid"`
	PredictionID        *int64        `json:"prediction_id,omitempty" db:"prediction_id"`
	PredictionUUID      *string       `json:"prediction_uuid,omitempty" db:"prediction_uuid"`
	TreatmentType       TreatmentType `json:"treatment_type" db:"treatment_type"`
	ProductName         string        `json:"product_name" db:"product_name"`
	ApplicationRate     *string       `json:"application_rate,omitempty" db:"application_rate"`
	ApplicationMethod   *string       `json:"application_method,omitempty" db:"application_method"`
	Cost                float64       `json:"cost" db:"cost"`
	EffectivenessRating *string       `json:"effectiveness_rating,omitempty" db:"effectiveness_rating"`
	AppliedBy           string        `json:"applied_by" db:"applied_by"`
	AppliedAt           time.Time     `json:"applied_at" db:"applied_at"`
	Notes               *string       `json:"notes,omitempty" db:"notes"`
	Version             int64         `json:"version" db:"version"`
}

// GetID returns the primary key.
func (t *PestTreatment) GetID() int64 { return t.ID }

// GetUUID returns the ULID identifier.
func (t *PestTreatment) GetUUID() string { return t.UUID }

// PestRiskMap represents a geographic risk map for a region.
type PestRiskMap struct {
	models.BaseModel
	TenantID         string    `json:"tenant_id" db:"tenant_id"`
	PestSpeciesID    int64     `json:"pest_species_id" db:"pest_species_id"`
	PestSpeciesUUID  string    `json:"pest_species_uuid" db:"pest_species_uuid"`
	Region           string    `json:"region" db:"region"`
	OverallRiskLevel RiskLevel `json:"overall_risk_level" db:"overall_risk_level"`
	GeoJSON          string    `json:"geojson" db:"geojson"`
	ValidFrom        time.Time `json:"valid_from" db:"valid_from"`
	ValidUntil       time.Time `json:"valid_until" db:"valid_until"`
	Version          int64     `json:"version" db:"version"`
}

// GetID returns the primary key.
func (m *PestRiskMap) GetID() int64 { return m.ID }

// GetUUID returns the ULID identifier.
func (m *PestRiskMap) GetUUID() string { return m.UUID }

// ---------------------------------------------------------------------------
// Request parameter structs
// ---------------------------------------------------------------------------

// PredictPestRiskParams holds inputs for the pest risk prediction algorithm.
type PredictPestRiskParams struct {
	TenantID      string
	FarmID        string
	FieldID       string
	PestSpeciesID string
	CropType      string
	GrowthStage   *GrowthStage
	Weather       WeatherFactors
	Latitude      float64
	Longitude     float64
}

// ListPredictionsParams holds filter and pagination params for listing predictions.
type ListPredictionsParams struct {
	TenantID      string
	FarmID        *string
	FieldID       *string
	PestSpeciesID *string
	MinRiskLevel  *RiskLevel
	PageSize      int32
	Offset        int32
}

// ListAlertsParams holds filter and pagination params for listing alerts.
type ListAlertsParams struct {
	TenantID     string
	FarmID       *string
	FieldID      *string
	Status       *AlertStatus
	MinRiskLevel *RiskLevel
	PageSize     int32
	Offset       int32
}

// ListObservationsParams holds filter and pagination params for listing observations.
type ListObservationsParams struct {
	TenantID      string
	FarmID        *string
	FieldID       *string
	PestSpeciesID *string
	PageSize      int32
	Offset        int32
}

// ListPestSpeciesParams holds filter and pagination params for listing species.
type ListPestSpeciesParams struct {
	TenantID string
	Search   *string
	CropType *string
	PageSize int32
	Offset   int32
}

// ReportObservationParams holds inputs for reporting a pest observation.
type ReportObservationParams struct {
	TenantID      string
	FarmID        string
	FieldID       string
	PestSpeciesID string
	PestCount     int
	DamageLevel   DamageLevel
	TrapType      *string
	ImageURL      *string
	Latitude      *float64
	Longitude     *float64
	Notes         *string
	ObservedBy    string
}
