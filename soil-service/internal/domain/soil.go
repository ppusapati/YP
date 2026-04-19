// Package domain contains the pure domain model for the soil-service.
package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// SoilStatus represents the lifecycle status of a soil entity.
type SoilStatus string

const (
	SoilStatusUnspecified SoilStatus = ""
	SoilStatusActive      SoilStatus = "ACTIVE"
	SoilStatusInactive    SoilStatus = "INACTIVE"
	SoilStatusArchived    SoilStatus = "ARCHIVED"
)

// IsValid checks if the soil status is a recognized value.
func (s SoilStatus) IsValid() bool {
	switch s {
	case SoilStatusActive, SoilStatusInactive, SoilStatusArchived:
		return true
	}
	return false
}

// SoilTexture represents soil texture classification.
type SoilTexture string

const (
	SoilTextureUnspecified SoilTexture = "UNSPECIFIED"
	SoilTextureSandy       SoilTexture = "SANDY"
	SoilTextureLoamy       SoilTexture = "LOAMY"
	SoilTextureClay        SoilTexture = "CLAY"
	SoilTextureSilt        SoilTexture = "SILT"
	SoilTexturePeat        SoilTexture = "PEAT"
	SoilTextureChalk       SoilTexture = "CHALK"
)

// AnalysisStatus represents the status of a soil analysis.
type AnalysisStatus string

const (
	AnalysisStatusPending    AnalysisStatus = "PENDING"
	AnalysisStatusInProgress AnalysisStatus = "IN_PROGRESS"
	AnalysisStatusCompleted  AnalysisStatus = "COMPLETED"
	AnalysisStatusFailed     AnalysisStatus = "FAILED"
)

// NutrientLevel represents the level of a soil nutrient.
type NutrientLevel string

const (
	NutrientLevelDeficient NutrientLevel = "DEFICIENT"
	NutrientLevelLow       NutrientLevel = "LOW"
	NutrientLevelAdequate  NutrientLevel = "ADEQUATE"
	NutrientLevelHigh      NutrientLevel = "HIGH"
	NutrientLevelExcessive NutrientLevel = "EXCESSIVE"
)

// HealthCategory represents the overall soil health classification.
type HealthCategory string

const (
	HealthCategoryCritical  HealthCategory = "CRITICAL"
	HealthCategoryPoor      HealthCategory = "POOR"
	HealthCategoryFair      HealthCategory = "FAIR"
	HealthCategoryGood      HealthCategory = "GOOD"
	HealthCategoryExcellent HealthCategory = "EXCELLENT"
)

// Soil is the aggregate root for the soil-service (simple entity).
type Soil struct {
	models.BaseModel
	TenantID string     `json:"tenant_id"`
	Name     string     `json:"name"`
	Status   SoilStatus `json:"status"`
	Notes    *string    `json:"notes,omitempty"`
	Version  int64      `json:"version"`
}

// ListSoilParams holds filter and pagination parameters for listing soils.
type ListSoilParams struct {
	TenantID string
	Status   *SoilStatus
	Search   *string
	PageSize int32
	Offset   int32
}

// SoilSample represents a physical soil sample collected from a field.
type SoilSample struct {
	models.BaseModel
	TenantID               string      `json:"tenant_id"`
	FieldID                string      `json:"field_id"`
	FarmID                 string      `json:"farm_id"`
	Latitude               float64     `json:"latitude"`
	Longitude              float64     `json:"longitude"`
	SampleDepthCm          float64     `json:"sample_depth_cm"`
	CollectionDate         time.Time   `json:"collection_date"`
	PH                     float64     `json:"ph"`
	OrganicMatterPct       float64     `json:"organic_matter_pct"`
	NitrogenPPM            float64     `json:"nitrogen_ppm"`
	PhosphorusPPM          float64     `json:"phosphorus_ppm"`
	PotassiumPPM           float64     `json:"potassium_ppm"`
	CalciumPPM             float64     `json:"calcium_ppm"`
	MagnesiumPPM           float64     `json:"magnesium_ppm"`
	SulfurPPM              float64     `json:"sulfur_ppm"`
	IronPPM                float64     `json:"iron_ppm"`
	ManganesePPM           float64     `json:"manganese_ppm"`
	ZincPPM                float64     `json:"zinc_ppm"`
	CopperPPM              float64     `json:"copper_ppm"`
	BoronPPM               float64     `json:"boron_ppm"`
	MoisturePct            float64     `json:"moisture_pct"`
	Texture                SoilTexture `json:"texture"`
	BulkDensity            float64     `json:"bulk_density"`
	CationExchangeCapacity float64     `json:"cation_exchange_capacity"`
	ElectricalConductivity float64     `json:"electrical_conductivity"`
	CollectedBy            string      `json:"collected_by"`
	Notes                  string      `json:"notes"`
	Version                int64       `json:"version"`
}

// SoilAnalysis represents an analysis performed on a soil sample.
type SoilAnalysis struct {
	models.BaseModel
	TenantID        string         `json:"tenant_id"`
	SampleID        string         `json:"sample_id"`
	FieldID         string         `json:"field_id"`
	FarmID          string         `json:"farm_id"`
	Status          AnalysisStatus `json:"status"`
	AnalysisType    string         `json:"analysis_type"`
	SoilHealthScore float64        `json:"soil_health_score"`
	HealthCategory  HealthCategory `json:"health_category"`
	Recommendations []string       `json:"recommendations"`
	AnalyzedBy      string         `json:"analyzed_by"`
	AnalyzedAt      *time.Time     `json:"analyzed_at"`
	Summary         string         `json:"summary"`
	Version         int64          `json:"version"`
}

// SoilMap represents a geospatial soil map for a field.
type SoilMap struct {
	models.BaseModel
	TenantID    string     `json:"tenant_id"`
	FieldID     string     `json:"field_id"`
	FarmID      string     `json:"farm_id"`
	MapType     string     `json:"map_type"`
	RasterData  []byte     `json:"raster_data"`
	CRS         string     `json:"crs"`
	Resolution  float64    `json:"resolution"`
	BboxMinLat  float64    `json:"bbox_min_lat"`
	BboxMinLng  float64    `json:"bbox_min_lng"`
	BboxMaxLat  float64    `json:"bbox_max_lat"`
	BboxMaxLng  float64    `json:"bbox_max_lng"`
	GeneratedBy string     `json:"generated_by"`
	GeneratedAt *time.Time `json:"generated_at"`
	Version     int64      `json:"version"`
}

// SoilNutrient represents a specific nutrient measurement from a soil sample.
type SoilNutrient struct {
	models.BaseModel
	TenantID     string        `json:"tenant_id"`
	SampleID     string        `json:"sample_id"`
	NutrientName string        `json:"nutrient_name"`
	ValuePPM     float64       `json:"value_ppm"`
	Level        NutrientLevel `json:"level"`
	OptimalMin   float64       `json:"optimal_min"`
	OptimalMax   float64       `json:"optimal_max"`
	Unit         string        `json:"unit"`
}

// SoilHealthScore represents a computed health score for a field's soil.
type SoilHealthScore struct {
	models.BaseModel
	TenantID        string         `json:"tenant_id"`
	FieldID         string         `json:"field_id"`
	FarmID          string         `json:"farm_id"`
	OverallScore    float64        `json:"overall_score"`
	Category        HealthCategory `json:"category"`
	PhysicalScore   float64        `json:"physical_score"`
	ChemicalScore   float64        `json:"chemical_score"`
	BiologicalScore float64        `json:"biological_score"`
	Recommendations []string       `json:"recommendations"`
	AssessedAt      *time.Time     `json:"assessed_at"`
	Version         int64          `json:"version"`
}

// NutrientDeficiency captures a specific nutrient deficiency finding.
type NutrientDeficiency struct {
	NutrientName   string        `json:"nutrient_name"`
	CurrentValue   float64       `json:"current_value"`
	OptimalValue   float64       `json:"optimal_value"`
	Level          NutrientLevel `json:"level"`
	Recommendation string        `json:"recommendation"`
}

// SoilReport is an aggregated view combining sample, analysis, health, and nutrients.
type SoilReport struct {
	Sample          *SoilSample      `json:"sample"`
	Analysis        *SoilAnalysis    `json:"analysis"`
	HealthScore     *SoilHealthScore `json:"health_score"`
	Nutrients       []SoilNutrient   `json:"nutrients"`
	Recommendations []string         `json:"recommendations"`
	GeneratedAt     time.Time        `json:"generated_at"`
}
