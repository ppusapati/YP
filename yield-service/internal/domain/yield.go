package domain

import (
	"time"

	"p9e.in/samavaya/packages/models"
)

// YieldFactors represents the individual contributing factors to yield prediction.
type YieldFactors struct {
	SoilQualityScore  float64 `json:"soil_quality_score" db:"soil_quality_score"`
	WeatherScore      float64 `json:"weather_score" db:"weather_score"`
	IrrigationScore   float64 `json:"irrigation_score" db:"irrigation_score"`
	PestPressureScore float64 `json:"pest_pressure_score" db:"pest_pressure_score"`
	NutrientScore     float64 `json:"nutrient_score" db:"nutrient_score"`
	ManagementScore   float64 `json:"management_score" db:"management_score"`
}

// WeightedScore returns the weighted aggregate score from all yield factors.
// Each factor contributes proportionally to the total based on agronomic research.
func (f *YieldFactors) WeightedScore() float64 {
	const (
		soilWeight       = 0.20
		weatherWeight    = 0.25
		irrigationWeight = 0.15
		pestWeight       = 0.15
		nutrientWeight   = 0.15
		managementWeight = 0.10
	)
	return f.SoilQualityScore*soilWeight +
		f.WeatherScore*weatherWeight +
		f.IrrigationScore*irrigationWeight +
		f.PestPressureScore*pestWeight +
		f.NutrientScore*nutrientWeight +
		f.ManagementScore*managementWeight
}

// YieldPrediction represents a yield forecast for a specific field and crop.
type YieldPrediction struct {
	models.BaseModel
	TenantID                   string  `json:"tenant_id" db:"tenant_id"`
	FarmID                     string  `json:"farm_id" db:"farm_id"`
	FieldID                    string  `json:"field_id" db:"field_id"`
	CropID                     string  `json:"crop_id" db:"crop_id"`
	Season                     string  `json:"season" db:"season"`
	Year                       int32   `json:"year" db:"year"`
	PredictedYieldKgPerHectare float64 `json:"predicted_yield_kg_per_hectare" db:"predicted_yield_kg_per_hectare"`
	PredictionConfidencePct    float64 `json:"prediction_confidence_pct" db:"prediction_confidence_pct"`
	PredictionModelVersion     string  `json:"prediction_model_version" db:"prediction_model_version"`
	Status                     string  `json:"status" db:"status"`
	SoilQualityScore           float64 `json:"soil_quality_score" db:"soil_quality_score"`
	WeatherScore               float64 `json:"weather_score" db:"weather_score"`
	IrrigationScore            float64 `json:"irrigation_score" db:"irrigation_score"`
	PestPressureScore          float64 `json:"pest_pressure_score" db:"pest_pressure_score"`
	NutrientScore              float64 `json:"nutrient_score" db:"nutrient_score"`
	ManagementScore            float64 `json:"management_score" db:"management_score"`
	Version                    int64   `json:"version" db:"version"`
}

// GetYieldFactors returns the yield factors as a YieldFactors struct.
func (p *YieldPrediction) GetYieldFactors() YieldFactors {
	return YieldFactors{
		SoilQualityScore:  p.SoilQualityScore,
		WeatherScore:      p.WeatherScore,
		IrrigationScore:   p.IrrigationScore,
		PestPressureScore: p.PestPressureScore,
		NutrientScore:     p.NutrientScore,
		ManagementScore:   p.ManagementScore,
	}
}

// YieldRecord represents an actual recorded yield after harvest.
type YieldRecord struct {
	models.BaseModel
	TenantID                   string     `json:"tenant_id" db:"tenant_id"`
	FarmID                     string     `json:"farm_id" db:"farm_id"`
	FieldID                    string     `json:"field_id" db:"field_id"`
	CropID                     string     `json:"crop_id" db:"crop_id"`
	Season                     string     `json:"season" db:"season"`
	Year                       int32      `json:"year" db:"year"`
	ActualYieldKgPerHectare    float64    `json:"actual_yield_kg_per_hectare" db:"actual_yield_kg_per_hectare"`
	TotalAreaHarvestedHectares float64    `json:"total_area_harvested_hectares" db:"total_area_harvested_hectares"`
	TotalYieldKg               float64    `json:"total_yield_kg" db:"total_yield_kg"`
	HarvestQualityGrade        string     `json:"harvest_quality_grade" db:"harvest_quality_grade"`
	MoistureContentPct         float64    `json:"moisture_content_pct" db:"moisture_content_pct"`
	HarvestDate                *time.Time `json:"harvest_date" db:"harvest_date"`
	RevenuePerHectare          float64    `json:"revenue_per_hectare" db:"revenue_per_hectare"`
	CostPerHectare             float64    `json:"cost_per_hectare" db:"cost_per_hectare"`
	ProfitPerHectare           float64    `json:"profit_per_hectare" db:"profit_per_hectare"`
	PredictionID               *string    `json:"prediction_id" db:"prediction_id"`
	Version                    int64      `json:"version" db:"version"`
}

// HarvestPlan represents a planned harvest operation.
type HarvestPlan struct {
	models.BaseModel
	TenantID          string    `json:"tenant_id" db:"tenant_id"`
	FarmID            string    `json:"farm_id" db:"farm_id"`
	FieldID           string    `json:"field_id" db:"field_id"`
	CropID            string    `json:"crop_id" db:"crop_id"`
	Season            string    `json:"season" db:"season"`
	Year              int32     `json:"year" db:"year"`
	PlannedStartDate  time.Time `json:"planned_start_date" db:"planned_start_date"`
	PlannedEndDate    time.Time `json:"planned_end_date" db:"planned_end_date"`
	EstimatedYieldKg  float64   `json:"estimated_yield_kg" db:"estimated_yield_kg"`
	TotalAreaHectares float64   `json:"total_area_hectares" db:"total_area_hectares"`
	Status            string    `json:"status" db:"status"`
	Notes             *string   `json:"notes" db:"notes"`
	Version           int64     `json:"version" db:"version"`
}

// CropPerformance represents analytics for a specific crop's performance.
type CropPerformance struct {
	models.BaseModel
	TenantID                     string  `json:"tenant_id" db:"tenant_id"`
	FarmID                       string  `json:"farm_id" db:"farm_id"`
	FieldID                      string  `json:"field_id" db:"field_id"`
	CropID                       string  `json:"crop_id" db:"crop_id"`
	Season                       string  `json:"season" db:"season"`
	Year                         int32   `json:"year" db:"year"`
	ActualYieldKgPerHectare      float64 `json:"actual_yield_kg_per_hectare" db:"actual_yield_kg_per_hectare"`
	PredictedYieldKgPerHectare   float64 `json:"predicted_yield_kg_per_hectare" db:"predicted_yield_kg_per_hectare"`
	YieldVariancePct             float64 `json:"yield_variance_pct" db:"yield_variance_pct"`
	ComparisonToRegionalAvgPct   float64 `json:"comparison_to_regional_avg_pct" db:"comparison_to_regional_avg_pct"`
	ComparisonToHistoricalAvgPct float64 `json:"comparison_to_historical_avg_pct" db:"comparison_to_historical_avg_pct"`
	RevenuePerHectare            float64 `json:"revenue_per_hectare" db:"revenue_per_hectare"`
	CostPerHectare               float64 `json:"cost_per_hectare" db:"cost_per_hectare"`
	ProfitPerHectare             float64 `json:"profit_per_hectare" db:"profit_per_hectare"`
	SoilQualityScore             float64 `json:"soil_quality_score" db:"soil_quality_score"`
	WeatherScore                 float64 `json:"weather_score" db:"weather_score"`
	IrrigationScore              float64 `json:"irrigation_score" db:"irrigation_score"`
	PestPressureScore            float64 `json:"pest_pressure_score" db:"pest_pressure_score"`
	NutrientScore                float64 `json:"nutrient_score" db:"nutrient_score"`
	ManagementScore              float64 `json:"management_score" db:"management_score"`
	Version                      int64   `json:"version" db:"version"`
}

// GetYieldFactors returns the yield factors as a YieldFactors struct.
func (cp *CropPerformance) GetYieldFactors() YieldFactors {
	return YieldFactors{
		SoilQualityScore:  cp.SoilQualityScore,
		WeatherScore:      cp.WeatherScore,
		IrrigationScore:   cp.IrrigationScore,
		PestPressureScore: cp.PestPressureScore,
		NutrientScore:     cp.NutrientScore,
		ManagementScore:   cp.ManagementScore,
	}
}

// Prediction status constants.
const (
	PredictionStatusPending    = "pending"
	PredictionStatusCompleted  = "completed"
	PredictionStatusFailed     = "failed"
	PredictionStatusSuperseded = "superseded"
)

// Harvest plan status constants.
const (
	HarvestPlanStatusDraft      = "draft"
	HarvestPlanStatusScheduled  = "scheduled"
	HarvestPlanStatusInProgress = "in_progress"
	HarvestPlanStatusCompleted  = "completed"
	HarvestPlanStatusCancelled  = "cancelled"
)

// Harvest quality grade constants.
const (
	HarvestQualityGradeA = "A"
	HarvestQualityGradeB = "B"
	HarvestQualityGradeC = "C"
	HarvestQualityGradeD = "D"
)

// PredictionModelVersion is the current version of the yield prediction model.
const PredictionModelVersion = "v1.0.0"

// BaseCropYieldKgPerHectare contains reference base yields (kg/ha) for common crops.
// These are used as starting points in the prediction algorithm and represent
// average yields under optimal conditions.
var BaseCropYieldKgPerHectare = map[string]float64{
	"wheat":     3500.0,
	"rice":      4500.0,
	"corn":      9000.0,
	"soybean":   2800.0,
	"cotton":    1800.0,
	"sugarcane": 70000.0,
	"potato":    20000.0,
	"tomato":    60000.0,
	"barley":    3200.0,
	"sunflower": 1500.0,
	"default":   4000.0,
}
