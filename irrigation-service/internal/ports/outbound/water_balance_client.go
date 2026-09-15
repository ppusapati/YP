package outbound

import "context"

// WaterBalanceRequest drives a FAO-56 water-balance simulation.
type WaterBalanceRequest struct {
	FieldAreaHa        float64
	CropType           string
	GrowthStage        string
	DaysAfterPlanting  int32
	ReferenceET0MMDay  float64
	InitialDepletionMM float64
	DailyRainfallMM    []float64
	SimulationDays     int
	RootZoneDepthM     float64
	FieldCapacity      float64
	WiltingPoint       float64
	AllowedDepletion   float64
}

// WaterBalanceDay is one simulated day.
type WaterBalanceDay struct {
	Day                 int
	ETcMMDay            float64
	DepletionMM         float64
	TotalAvailableMM    float64
	ReadilyAvailableMM  float64
	IrrigationNeeded    bool
	IrrigationAmountMM  float64
	EffectiveRainfallMM float64
}

// WaterBalanceResult is the simulation output.
type WaterBalanceResult struct {
	Days              []WaterBalanceDay
	TotalIrrigationMM float64
	IrrigationEvents  int
	CropCoefficient   float64
}

// WaterBalanceClient is the secondary port for the AI gateway water-flow simulation.
type WaterBalanceClient interface {
	Simulate(ctx context.Context, req WaterBalanceRequest) (*WaterBalanceResult, error)
}
