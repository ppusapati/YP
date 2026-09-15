package application

import (
	"context"
	"errors"
	"math"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

type fakeWeather struct {
	weather *outbound.FieldWeather
	err     error
	calls   int
}

func (f *fakeWeather) FieldWeather(_ context.Context, _ string, _, _ int) (*outbound.FieldWeather, error) {
	f.calls++
	return f.weather, f.err
}

type fakeWaterBalance struct {
	result  *outbound.WaterBalanceResult
	err     error
	lastReq outbound.WaterBalanceRequest
}

func (f *fakeWaterBalance) Simulate(_ context.Context, req outbound.WaterBalanceRequest) (*outbound.WaterBalanceResult, error) {
	f.lastReq = req
	return f.result, f.err
}

func balanceDays(firstNeeded int, n int) []outbound.WaterBalanceDay {
	days := make([]outbound.WaterBalanceDay, n)
	for i := range days {
		days[i] = outbound.WaterBalanceDay{
			Day:                i + 1,
			ETcMMDay:           5.5,
			DepletionMM:        20 + 5*float64(i),
			TotalAvailableMM:   120,
			ReadilyAvailableMM: 60,
			IrrigationNeeded:   firstNeeded >= 0 && i >= firstNeeded,
			IrrigationAmountMM: 35,
		}
	}
	return days
}

func TestInitialDepletionMM(t *testing.T) {
	// TAW for loam, 0.6 m root zone = (0.30-0.10)*0.6*1000 = 120 mm.
	assert.InDelta(t, 0, initialDepletionMM(0, 0.6, 0.30, 0.10), 1e-9, "unknown moisture => at field capacity")
	assert.InDelta(t, 60, initialDepletionMM(50, 0.6, 0.30, 0.10), 1e-9)
	assert.InDelta(t, 0, initialDepletionMM(-5, 0.6, 0.30, 0.10), 1e-9, "negative reading is treated as unknown")
	assert.InDelta(t, 120, initialDepletionMM(0.001, 0.6, 0.30, 0.10), 1, "near-zero reading is fully depleted")
	assert.InDelta(t, 0, initialDepletionMM(150, 0.6, 0.30, 0.10), 1e-9, "over 100% clamps to zero")
}

func TestDecisionFromWaterBalance_IrrigateToday(t *testing.T) {
	res := &outbound.WaterBalanceResult{Days: balanceDays(0, 7), CropCoefficient: 5.5}
	out := decisionFromWaterBalance(res, 2.0, 5.0, domain.DecisionInputs{WindSpeed: 25})

	assert.True(t, out.ShouldIrrigate)
	assert.Equal(t, domain.DecisionMethodWaterBalance, out.Method)
	assert.InDelta(t, 35, out.RecommendedDepthMM, 1e-9)
	// 35 mm over 2 ha = 700,000 L, +10% for wind.
	assert.InDelta(t, 35*10_000*2*1.1, out.WaterQuantityLiters, 1e-6)
	assert.Equal(t, int32(210), out.DurationMinutes)
	assert.InDelta(t, 1.1, out.CropCoefficient, 1e-9)
	assert.InDelta(t, 5.0, out.ET0MMDay, 1e-9)
	require.NotNil(t, out.OptimalTime)
	assert.Contains(t, out.Reasoning, "Apply 35.0 mm")
}

func TestDecisionFromWaterBalance_ScheduledLater(t *testing.T) {
	res := &outbound.WaterBalanceResult{Days: balanceDays(3, 7), CropCoefficient: 5.5}
	out := decisionFromWaterBalance(res, 1.0, 5.0, domain.DecisionInputs{RainfallForecastMM: 4})

	assert.False(t, out.ShouldIrrigate)
	assert.InDelta(t, 35, out.RecommendedDepthMM, 1e-9)
	require.NotNil(t, out.OptimalTime)
	assert.Contains(t, out.Reasoning, "expected in 3 day(s)")
	assert.Zero(t, out.WaterQuantityLiters)
}

func TestDecisionFromWaterBalance_NoneNeeded(t *testing.T) {
	res := &outbound.WaterBalanceResult{Days: balanceDays(-1, 7), CropCoefficient: 5.5}
	out := decisionFromWaterBalance(res, 1.0, 5.0, domain.DecisionInputs{})
	assert.False(t, out.ShouldIrrigate)
	assert.Nil(t, out.OptimalTime)
	assert.Contains(t, out.Reasoning, "no irrigation needed")
}

func TestDecisionFromWaterBalance_UnknownArea(t *testing.T) {
	res := &outbound.WaterBalanceResult{Days: balanceDays(0, 3), CropCoefficient: 5.5}
	out := decisionFromWaterBalance(res, 0, 5.0, domain.DecisionInputs{})
	assert.InDelta(t, 350, out.WaterQuantityLiters, 1e-9, "falls back to legacy 10 L per mm")
}

func newWaterBalanceService(t *testing.T, w *fakeWeather, wb *fakeWaterBalance) (*mockIrrigationRepo, *irrigationService) {
	t.Helper()
	repo, _, svc := newService()
	svc.WithWaterBalance(w, wb)
	repo.zones["zone-wb"] = &domain.IrrigationZone{
		TenantID: "tenant-1", Name: "Zone WB", FieldID: "field-001",
		AreaHectares: 1.5, CropType: "cotton", CropGrowthStage: "flowering",
	}
	repo.zones["zone-wb"].ID = "zone-wb"
	return repo, svc
}

func TestRequestDecision_UsesWaterBalance(t *testing.T) {
	weather := &fakeWeather{weather: &outbound.FieldWeather{
		ET0MMDay: 4.0, ForecastET0MMDay: 6.0, RecentRainfallMM: 2,
		ForecastRainfallMM: []float64{0, 0, 3, 0, 0, 0, 0},
	}}
	water := &fakeWaterBalance{result: &outbound.WaterBalanceResult{Days: balanceDays(0, 7), CropCoefficient: 6.6}}
	_, svc := newWaterBalanceService(t, weather, water)
	ctx := testContext("tenant-1", "user-1")

	result, err := svc.RequestDecision(ctx, &domain.IrrigationDecision{
		ZoneID: "zone-wb",
		Inputs: domain.DecisionInputs{SoilMoisture: 50},
	})
	require.NoError(t, err)

	assert.Equal(t, domain.DecisionMethodWaterBalance, result.Output.Method)
	assert.True(t, result.Output.ShouldIrrigate)
	assert.InDelta(t, 35*10_000*1.5, result.Output.WaterQuantityLiters, 1e-6)
	assert.InDelta(t, 6.0, result.Output.ET0MMDay, 1e-9, "forecast ET0 preferred over trailing mean")
	assert.InDelta(t, 1.1, result.Output.CropCoefficient, 1e-9)

	// Zone metadata and observed weather are copied into the stored inputs.
	assert.Equal(t, "field-001", result.FieldID)
	assert.Equal(t, "cotton", result.Inputs.CropType)
	assert.Equal(t, "flowering", result.Inputs.GrowthStage)
	assert.InDelta(t, 6.0, result.Inputs.EvapotranspirationMM, 1e-9)
	assert.InDelta(t, 3.0, result.Inputs.RainfallForecastMM, 1e-9)

	// The simulation was driven by the zone crop, forecast rain, and soil moisture.
	assert.Equal(t, "cotton", water.lastReq.CropType)
	assert.Equal(t, "flowering", water.lastReq.GrowthStage)
	assert.Equal(t, 7, water.lastReq.SimulationDays)
	assert.Len(t, water.lastReq.DailyRainfallMM, 7)
	assert.InDelta(t, 60, water.lastReq.InitialDepletionMM, 1e-9)
	assert.InDelta(t, 1.5, water.lastReq.FieldAreaHa, 1e-9)
}

func TestRequestDecision_FallsBackWhenWeatherFails(t *testing.T) {
	weather := &fakeWeather{err: errors.New("weather down")}
	water := &fakeWaterBalance{result: &outbound.WaterBalanceResult{Days: balanceDays(0, 7)}}
	_, svc := newWaterBalanceService(t, weather, water)
	ctx := testContext("tenant-1", "user-1")

	result, err := svc.RequestDecision(ctx, &domain.IrrigationDecision{
		ZoneID: "zone-wb",
		Inputs: domain.DecisionInputs{SoilMoisture: 20, Temperature: 30},
	})
	require.NoError(t, err)
	assert.Equal(t, domain.DecisionMethodHeuristic, result.Output.Method)
	assert.True(t, result.Output.ShouldIrrigate)
	assert.Equal(t, 1, weather.calls)
}

func TestRequestDecision_FallsBackWhenSimulationFails(t *testing.T) {
	weather := &fakeWeather{weather: &outbound.FieldWeather{ET0MMDay: 5}}
	water := &fakeWaterBalance{err: errors.New("gateway down")}
	_, svc := newWaterBalanceService(t, weather, water)
	ctx := testContext("tenant-1", "user-1")

	result, err := svc.RequestDecision(ctx, &domain.IrrigationDecision{
		ZoneID: "zone-wb",
		Inputs: domain.DecisionInputs{SoilMoisture: 45},
	})
	require.NoError(t, err)
	assert.Equal(t, domain.DecisionMethodHeuristic, result.Output.Method)
	assert.False(t, result.Output.ShouldIrrigate)
}

func TestRequestDecision_HeuristicWithoutClients(t *testing.T) {
	repo, _, svc := newService()
	repo.zones["zone-001"] = &domain.IrrigationZone{TenantID: "tenant-1", Name: "Zone A"}
	repo.zones["zone-001"].ID = "zone-001"
	ctx := testContext("tenant-1", "user-1")

	result, err := svc.RequestDecision(ctx, &domain.IrrigationDecision{
		ZoneID: "zone-001",
		Inputs: domain.DecisionInputs{SoilMoisture: 20},
	})
	require.NoError(t, err)
	assert.Equal(t, domain.DecisionMethodHeuristic, result.Output.Method)
	assert.InDelta(t, 10, result.Output.RecommendedDepthMM, 1e-9, "100 L => 10 mm under the legacy conversion")
	assert.False(t, math.IsNaN(result.Output.WaterQuantityLiters))
}
