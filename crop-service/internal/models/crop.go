package models

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

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
		CropCategoryCereal,
		CropCategoryLegume,
		CropCategoryVegetable,
		CropCategoryFruit,
		CropCategoryOilseed,
		CropCategoryFiber,
		CropCategorySpice,
	}
}

// IsValid checks whether the crop category is a recognized value.
func (c CropCategory) IsValid() bool {
	switch c {
	case CropCategoryCereal, CropCategoryLegume, CropCategoryVegetable,
		CropCategoryFruit, CropCategoryOilseed, CropCategoryFiber, CropCategorySpice:
		return true
	default:
		return false
	}
}

// Crop represents a crop in the catalog.
type Crop struct {
	models.BaseModel
	TenantID               string       `json:"tenant_id" db:"tenant_id"`
	Name                   string       `json:"name" db:"name"`
	ScientificName         string       `json:"scientific_name" db:"scientific_name"`
	Family                 string       `json:"family" db:"family"`
	Category               CropCategory `json:"category" db:"category"`
	Description            string       `json:"description" db:"description"`
	ImageURL               string       `json:"image_url" db:"image_url"`
	DiseaseSusceptibilities []string    `json:"disease_susceptibilities" db:"disease_susceptibilities"`
	CompanionPlants        []string     `json:"companion_plants" db:"companion_plants"`
	RotationGroup          string       `json:"rotation_group" db:"rotation_group"`
	Version                int32        `json:"version" db:"version"`
	// Relations (populated on demand)
	Varieties    []CropVariety     `json:"varieties,omitempty" db:"-"`
	GrowthStages []CropGrowthStage `json:"growth_stages,omitempty" db:"-"`
	Requirements *CropRequirements `json:"requirements,omitempty" db:"-"`
}

// CropVariety represents a specific variety of a crop.
type CropVariety struct {
	models.BaseModel
	CropID                     int64   `json:"crop_id" db:"crop_id"`
	TenantID                   string  `json:"tenant_id" db:"tenant_id"`
	Name                       string  `json:"name" db:"name"`
	Description                string  `json:"description" db:"description"`
	MaturityDays               int32   `json:"maturity_days" db:"maturity_days"`
	YieldPotentialKgPerHectare float64 `json:"yield_potential_kg_per_hectare" db:"yield_potential_kg_per_hectare"`
	IsHybrid                   bool    `json:"is_hybrid" db:"is_hybrid"`
	DiseaseResistance          string  `json:"disease_resistance" db:"disease_resistance"`
	SuitableRegions            string  `json:"suitable_regions" db:"suitable_regions"`
	SeedRateKgPerHectare       string  `json:"seed_rate_kg_per_hectare" db:"seed_rate_kg_per_hectare"`
}

// CropGrowthStage represents a growth stage in the lifecycle of a crop.
type CropGrowthStage struct {
	models.BaseModel
	CropID               int64   `json:"crop_id" db:"crop_id"`
	TenantID             string  `json:"tenant_id" db:"tenant_id"`
	Name                 string  `json:"name" db:"name"`
	StageOrder           int32   `json:"stage_order" db:"stage_order"`
	DurationDays         int32   `json:"duration_days" db:"duration_days"`
	WaterRequirementMM   float64 `json:"water_requirement_mm" db:"water_requirement_mm"`
	NutrientRequirements string  `json:"nutrient_requirements" db:"nutrient_requirements"`
	Description          string  `json:"description" db:"description"`
	OptimalTempMin       float64 `json:"optimal_temp_min" db:"optimal_temp_min"`
	OptimalTempMax       float64 `json:"optimal_temp_max" db:"optimal_temp_max"`
}

// CropRequirements captures the optimal growing conditions for a crop.
type CropRequirements struct {
	models.BaseModel
	CropID                   int64   `json:"crop_id" db:"crop_id"`
	TenantID                 string  `json:"tenant_id" db:"tenant_id"`
	OptimalTempMin           float64 `json:"optimal_temp_min" db:"optimal_temp_min"`
	OptimalTempMax           float64 `json:"optimal_temp_max" db:"optimal_temp_max"`
	OptimalHumidityMin       float64 `json:"optimal_humidity_min" db:"optimal_humidity_min"`
	OptimalHumidityMax       float64 `json:"optimal_humidity_max" db:"optimal_humidity_max"`
	OptimalSoilPhMin         float64 `json:"optimal_soil_ph_min" db:"optimal_soil_ph_min"`
	OptimalSoilPhMax         float64 `json:"optimal_soil_ph_max" db:"optimal_soil_ph_max"`
	WaterRequirementMMPerDay float64 `json:"water_requirement_mm_per_day" db:"water_requirement_mm_per_day"`
	SunlightHours            float64 `json:"sunlight_hours" db:"sunlight_hours"`
	FrostTolerant            bool    `json:"frost_tolerant" db:"frost_tolerant"`
	DroughtTolerant          bool    `json:"drought_tolerant" db:"drought_tolerant"`
	SoilTypePreference       string  `json:"soil_type_preference" db:"soil_type_preference"`
	NutrientRequirements     string  `json:"nutrient_requirements" db:"nutrient_requirements"`
}

// CropRecommendation represents an AI-generated recommendation for a crop.
type CropRecommendation struct {
	models.BaseModel
	CropID                int64      `json:"crop_id" db:"crop_id"`
	TenantID              string     `json:"tenant_id" db:"tenant_id"`
	RecommendationType    string     `json:"recommendation_type" db:"recommendation_type"`
	Title                 string     `json:"title" db:"title"`
	Description           string     `json:"description" db:"description"`
	Severity              string     `json:"severity" db:"severity"`
	ConfidenceScore       float64    `json:"confidence_score" db:"confidence_score"`
	Parameters            string     `json:"parameters" db:"parameters"`
	ApplicableGrowthStage string     `json:"applicable_growth_stage" db:"applicable_growth_stage"`
	ValidFrom             *time.Time `json:"valid_from" db:"valid_from"`
	ValidUntil            *time.Time `json:"valid_until" db:"valid_until"`
}

// RecommendationInput encapsulates the sensor/environment data for generating recommendations.
type RecommendationInput struct {
	CropID             string  `json:"crop_id"`
	TenantID           string  `json:"tenant_id"`
	RecommendationType string  `json:"recommendation_type"`
	CurrentGrowthStage string  `json:"current_growth_stage"`
	CurrentTemperature float64 `json:"current_temperature"`
	CurrentHumidity    float64 `json:"current_humidity"`
	CurrentSoilPH      float64 `json:"current_soil_ph"`
	CurrentSoilMoisture float64 `json:"current_soil_moisture"`
}
