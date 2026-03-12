package models

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

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

type AnalysisStatus string

const (
	AnalysisStatusPending    AnalysisStatus = "PENDING"
	AnalysisStatusInProgress AnalysisStatus = "IN_PROGRESS"
	AnalysisStatusCompleted  AnalysisStatus = "COMPLETED"
	AnalysisStatusFailed     AnalysisStatus = "FAILED"
)

type NutrientLevel string

const (
	NutrientLevelDeficient NutrientLevel = "DEFICIENT"
	NutrientLevelLow       NutrientLevel = "LOW"
	NutrientLevelAdequate  NutrientLevel = "ADEQUATE"
	NutrientLevelHigh      NutrientLevel = "HIGH"
	NutrientLevelExcessive NutrientLevel = "EXCESSIVE"
)

type HealthCategory string

const (
	HealthCategoryCritical  HealthCategory = "CRITICAL"
	HealthCategoryPoor      HealthCategory = "POOR"
	HealthCategoryFair      HealthCategory = "FAIR"
	HealthCategoryGood      HealthCategory = "GOOD"
	HealthCategoryExcellent HealthCategory = "EXCELLENT"
)

// ---------------------------------------------------------------------------
// Domain Models
// ---------------------------------------------------------------------------

// SoilSample represents a physical soil sample collected from a field.
type SoilSample struct {
	models.BaseModel
	TenantID               string      `json:"tenant_id"    db:"tenant_id"`
	FieldID                string      `json:"field_id"     db:"field_id"`
	FarmID                 string      `json:"farm_id"      db:"farm_id"`
	Latitude               float64     `json:"latitude"     db:"latitude"`
	Longitude              float64     `json:"longitude"    db:"longitude"`
	SampleDepthCm          float64     `json:"sample_depth_cm"  db:"sample_depth_cm"`
	CollectionDate         time.Time   `json:"collection_date"  db:"collection_date"`
	PH                     float64     `json:"ph"           db:"ph"`
	OrganicMatterPct       float64     `json:"organic_matter_pct" db:"organic_matter_pct"`
	NitrogenPPM            float64     `json:"nitrogen_ppm" db:"nitrogen_ppm"`
	PhosphorusPPM          float64     `json:"phosphorus_ppm" db:"phosphorus_ppm"`
	PotassiumPPM           float64     `json:"potassium_ppm" db:"potassium_ppm"`
	CalciumPPM             float64     `json:"calcium_ppm"  db:"calcium_ppm"`
	MagnesiumPPM           float64     `json:"magnesium_ppm" db:"magnesium_ppm"`
	SulfurPPM              float64     `json:"sulfur_ppm"   db:"sulfur_ppm"`
	IronPPM                float64     `json:"iron_ppm"     db:"iron_ppm"`
	ManganesePPM           float64     `json:"manganese_ppm" db:"manganese_ppm"`
	ZincPPM                float64     `json:"zinc_ppm"     db:"zinc_ppm"`
	CopperPPM              float64     `json:"copper_ppm"   db:"copper_ppm"`
	BoronPPM               float64     `json:"boron_ppm"    db:"boron_ppm"`
	MoisturePct            float64     `json:"moisture_pct" db:"moisture_pct"`
	Texture                SoilTexture `json:"texture"      db:"texture"`
	BulkDensity            float64     `json:"bulk_density" db:"bulk_density"`
	CationExchangeCapacity float64     `json:"cation_exchange_capacity" db:"cation_exchange_capacity"`
	ElectricalConductivity float64     `json:"electrical_conductivity" db:"electrical_conductivity"`
	CollectedBy            string      `json:"collected_by" db:"collected_by"`
	Notes                  string      `json:"notes"        db:"notes"`
	Version                int64       `json:"version"      db:"version"`
}

// SoilAnalysis represents an analysis performed on a soil sample.
type SoilAnalysis struct {
	models.BaseModel
	TenantID        string         `json:"tenant_id"        db:"tenant_id"`
	SampleID        string         `json:"sample_id"        db:"sample_id"`
	FieldID         string         `json:"field_id"         db:"field_id"`
	FarmID          string         `json:"farm_id"          db:"farm_id"`
	Status          AnalysisStatus `json:"status"           db:"status"`
	AnalysisType    string         `json:"analysis_type"    db:"analysis_type"`
	SoilHealthScore float64        `json:"soil_health_score" db:"soil_health_score"`
	HealthCategory  HealthCategory `json:"health_category"  db:"health_category"`
	Recommendations []string       `json:"recommendations"  db:"recommendations"`
	AnalyzedBy      string         `json:"analyzed_by"      db:"analyzed_by"`
	AnalyzedAt      *time.Time     `json:"analyzed_at"      db:"analyzed_at"`
	Summary         string         `json:"summary"          db:"summary"`
	Version         int64          `json:"version"          db:"version"`
}

// SoilMap represents a geospatial soil map for a field.
type SoilMap struct {
	models.BaseModel
	TenantID    string     `json:"tenant_id"    db:"tenant_id"`
	FieldID     string     `json:"field_id"     db:"field_id"`
	FarmID      string     `json:"farm_id"      db:"farm_id"`
	MapType     string     `json:"map_type"     db:"map_type"`
	RasterData  []byte     `json:"raster_data"  db:"raster_data"`
	CRS         string     `json:"crs"          db:"crs"`
	Resolution  float64    `json:"resolution"   db:"resolution"`
	BboxMinLat  float64    `json:"bbox_min_lat" db:"bbox_min_lat"`
	BboxMinLng  float64    `json:"bbox_min_lng" db:"bbox_min_lng"`
	BboxMaxLat  float64    `json:"bbox_max_lat" db:"bbox_max_lat"`
	BboxMaxLng  float64    `json:"bbox_max_lng" db:"bbox_max_lng"`
	GeneratedBy string     `json:"generated_by" db:"generated_by"`
	GeneratedAt *time.Time `json:"generated_at" db:"generated_at"`
	Version     int64      `json:"version"      db:"version"`
}

// SoilNutrient represents a specific nutrient measurement from a soil sample.
type SoilNutrient struct {
	models.BaseModel
	TenantID     string        `json:"tenant_id"     db:"tenant_id"`
	SampleID     string        `json:"sample_id"     db:"sample_id"`
	NutrientName string        `json:"nutrient_name" db:"nutrient_name"`
	ValuePPM     float64       `json:"value_ppm"     db:"value_ppm"`
	Level        NutrientLevel `json:"level"         db:"level"`
	OptimalMin   float64       `json:"optimal_min"   db:"optimal_min"`
	OptimalMax   float64       `json:"optimal_max"   db:"optimal_max"`
	Unit         string        `json:"unit"          db:"unit"`
}

// SoilHealthScore represents a computed health score for a field's soil.
type SoilHealthScore struct {
	models.BaseModel
	TenantID        string         `json:"tenant_id"        db:"tenant_id"`
	FieldID         string         `json:"field_id"         db:"field_id"`
	FarmID          string         `json:"farm_id"          db:"farm_id"`
	OverallScore    float64        `json:"overall_score"    db:"overall_score"`
	Category        HealthCategory `json:"category"         db:"category"`
	PhysicalScore   float64        `json:"physical_score"   db:"physical_score"`
	ChemicalScore   float64        `json:"chemical_score"   db:"chemical_score"`
	BiologicalScore float64        `json:"biological_score" db:"biological_score"`
	Recommendations []string       `json:"recommendations"  db:"recommendations"`
	AssessedAt      *time.Time     `json:"assessed_at"      db:"assessed_at"`
	Version         int64          `json:"version"          db:"version"`
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
	Sample          *SoilSample       `json:"sample"`
	Analysis        *SoilAnalysis     `json:"analysis"`
	HealthScore     *SoilHealthScore  `json:"health_score"`
	Nutrients       []SoilNutrient    `json:"nutrients"`
	Recommendations []string          `json:"recommendations"`
	GeneratedAt     time.Time         `json:"generated_at"`
}
