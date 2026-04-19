// Package domain contains the pure domain model for the crop-service.
package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// CropStatus represents the lifecycle status of a crop.
type CropStatus string

const (
	CropStatusUnspecified CropStatus = ""
	CropStatusActive      CropStatus = "ACTIVE"
	CropStatusInactive    CropStatus = "INACTIVE"
	CropStatusArchived    CropStatus = "ARCHIVED"
)

// IsValid checks if the crop status is a recognized value.
func (s CropStatus) IsValid() bool {
	switch s {
	case CropStatusActive, CropStatusInactive, CropStatusArchived:
		return true
	}
	return false
}

// CropCategory represents the classification of a crop.
type CropCategory string

const (
	CropCategoryUnspecified CropCategory = "UNSPECIFIED"
	CropCategoryCereal      CropCategory = "CEREAL"
	CropCategoryLegume      CropCategory = "LEGUME"
	CropCategoryVegetable   CropCategory = "VEGETABLE"
	CropCategoryFruit       CropCategory = "FRUIT"
	CropCategoryOilseed     CropCategory = "OILSEED"
	CropCategoryFiber       CropCategory = "FIBER"
	CropCategorySpice       CropCategory = "SPICE"
)

// ValidCropCategories returns all valid crop categories.
func ValidCropCategories() []CropCategory {
	return []CropCategory{
		CropCategoryCereal, CropCategoryLegume, CropCategoryVegetable,
		CropCategoryFruit, CropCategoryOilseed, CropCategoryFiber, CropCategorySpice,
	}
}

// Crop is the aggregate root for the crop-service.
type Crop struct {
	models.BaseModel
	TenantID                string       `json:"tenant_id"`
	Name                    string       `json:"name"`
	ScientificName          string       `json:"scientific_name"`
	Family                  string       `json:"family"`
	Category                CropCategory `json:"category"`
	Description             string       `json:"description"`
	ImageURL                string       `json:"image_url"`
	DiseaseSusceptibilities []string     `json:"disease_susceptibilities"`
	CompanionPlants         []string     `json:"companion_plants"`
	RotationGroup           string       `json:"rotation_group"`
	Version                 int64        `json:"version"`
	Status                  CropStatus   `json:"status"`
	// Relations (populated on demand)
	Varieties    []CropVariety     `json:"varieties,omitempty"`
	GrowthStages []CropGrowthStage `json:"growth_stages,omitempty"`
	Requirements *CropRequirements `json:"requirements,omitempty"`
}

// ListCropParams holds filter and pagination parameters for listing crops.
type ListCropParams struct {
	TenantID string
	Status   *CropStatus
	Search   *string
	PageSize int32
	Offset   int32
}

// CropVariety represents a specific variety of a crop.
type CropVariety struct {
	models.BaseModel
	CropID                     int64   `json:"crop_id"`
	TenantID                   string  `json:"tenant_id"`
	Name                       string  `json:"name"`
	Description                string  `json:"description"`
	MaturityDays               int32   `json:"maturity_days"`
	YieldPotentialKgPerHectare float64 `json:"yield_potential_kg_per_hectare"`
	IsHybrid                   bool    `json:"is_hybrid"`
	DiseaseResistance          string  `json:"disease_resistance"`
	SuitableRegions            string  `json:"suitable_regions"`
	SeedRateKgPerHectare       string  `json:"seed_rate_kg_per_hectare"`
}

// CropGrowthStage represents a growth stage in the lifecycle of a crop.
type CropGrowthStage struct {
	models.BaseModel
	CropID               int64   `json:"crop_id"`
	TenantID             string  `json:"tenant_id"`
	Name                 string  `json:"name"`
	StageOrder           int32   `json:"stage_order"`
	DurationDays         int32   `json:"duration_days"`
	WaterRequirementMM   float64 `json:"water_requirement_mm"`
	NutrientRequirements string  `json:"nutrient_requirements"`
	Description          string  `json:"description"`
	OptimalTempMin       float64 `json:"optimal_temp_min"`
	OptimalTempMax       float64 `json:"optimal_temp_max"`
}

// CropRequirements captures the optimal growing conditions for a crop.
type CropRequirements struct {
	models.BaseModel
	CropID                   int64   `json:"crop_id"`
	TenantID                 string  `json:"tenant_id"`
	OptimalTempMin           float64 `json:"optimal_temp_min"`
	OptimalTempMax           float64 `json:"optimal_temp_max"`
	OptimalHumidityMin       float64 `json:"optimal_humidity_min"`
	OptimalHumidityMax       float64 `json:"optimal_humidity_max"`
	OptimalSoilPhMin         float64 `json:"optimal_soil_ph_min"`
	OptimalSoilPhMax         float64 `json:"optimal_soil_ph_max"`
	WaterRequirementMMPerDay float64 `json:"water_requirement_mm_per_day"`
	SunlightHours            float64 `json:"sunlight_hours"`
	FrostTolerant            bool    `json:"frost_tolerant"`
	DroughtTolerant          bool    `json:"drought_tolerant"`
	SoilTypePreference       string  `json:"soil_type_preference"`
	NutrientRequirements     string  `json:"nutrient_requirements"`
}

// CropRecommendation represents an AI-generated recommendation for a crop.
type CropRecommendation struct {
	models.BaseModel
	CropID                int64      `json:"crop_id"`
	TenantID              string     `json:"tenant_id"`
	RecommendationType    string     `json:"recommendation_type"`
	Title                 string     `json:"title"`
	Description           string     `json:"description"`
	Severity              string     `json:"severity"`
	ConfidenceScore       float64    `json:"confidence_score"`
	Parameters            string     `json:"parameters"`
	ApplicableGrowthStage string     `json:"applicable_growth_stage"`
	ValidFrom             *time.Time `json:"valid_from"`
	ValidUntil            *time.Time `json:"valid_until"`
}

// RecommendationInput encapsulates the sensor/environment data for generating recommendations.
type RecommendationInput struct {
	CropID              string  `json:"crop_id"`
	TenantID            string  `json:"tenant_id"`
	RecommendationType  string  `json:"recommendation_type"`
	CurrentGrowthStage  string  `json:"current_growth_stage"`
	CurrentTemperature  float64 `json:"current_temperature"`
	CurrentHumidity     float64 `json:"current_humidity"`
	CurrentSoilPH       float64 `json:"current_soil_ph"`
	CurrentSoilMoisture float64 `json:"current_soil_moisture"`
}
