package application

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
	"p9e.in/samavaya/agriculture/yield-service/internal/ports/outbound"
)

type fakeWeatherClient struct {
	weather   *outbound.SeasonWeather
	err       error
	lastStart time.Time
	lastEnd   time.Time
	calls     int
}

func (f *fakeWeatherClient) SeasonWeather(_ context.Context, _ string, start, end time.Time) (*outbound.SeasonWeather, error) {
	f.calls++
	f.lastStart, f.lastEnd = start, end
	return f.weather, f.err
}

func TestSeasonWindow(t *testing.T) {
	now := time.Date(2026, 8, 15, 0, 0, 0, 0, time.UTC)

	start, end := SeasonWindow("kharif", 2026, now)
	assert.Equal(t, time.Date(2026, 6, 1, 0, 0, 0, 0, time.UTC), start)
	assert.Equal(t, now, end, "in-season window is clipped to today")

	start, end = SeasonWindow("Rabi", 2025, now)
	assert.Equal(t, time.Date(2025, 11, 1, 0, 0, 0, 0, time.UTC), start)
	assert.Equal(t, time.Date(2026, 3, 31, 0, 0, 0, 0, time.UTC), end, "completed season keeps its full range")

	start, end = SeasonWindow("zaid", 2026, now)
	assert.Equal(t, time.March, start.Month())
	assert.Equal(t, time.Date(2026, 6, 30, 0, 0, 0, 0, time.UTC), end)

	start, end = SeasonWindow("unknown", 2026, now)
	assert.Equal(t, time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC), start)
	assert.Equal(t, now, end)

	start, end = SeasonWindow("kharif", 2027, now)
	assert.False(t, end.After(start), "future season yields an empty window")
}

func TestObservedEnvironment(t *testing.T) {
	_, _, svc := newService()
	svc.now = func() time.Time { return time.Date(2026, 9, 1, 0, 0, 0, 0, time.UTC) }
	pred := &domain.YieldPrediction{FieldID: "field-001", Season: "kharif", Year: 2026}

	assert.Nil(t, svc.observedEnvironment(context.Background(), pred), "no weather client => placeholders")

	fake := &fakeWeatherClient{weather: &outbound.SeasonWeather{
		Days: 92, AvgTemperatureC: 27.5, TotalPrecipMM: 640, GrowingDegreeDays: 1610,
		FrostDays: 0, HeatStressDays: 4, AvgHumidityPct: 78, AvgSolarMJ: 17.2,
	}}
	svc.WithWeatherClient(fake)

	env := svc.observedEnvironment(context.Background(), pred)
	require.NotNil(t, env)
	assert.InDelta(t, 27.5, env.AvgTemperatureC, 1e-9)
	assert.InDelta(t, 640, env.RainfallMM, 1e-9)
	assert.InDelta(t, 1610, env.GrowingDegreeDays, 1e-9)
	assert.Equal(t, 4, env.HeatStressDays)
	assert.InDelta(t, 17.2, env.SolarRadiationMJ, 1e-9)
	assert.Equal(t, time.Date(2026, 6, 1, 0, 0, 0, 0, time.UTC), fake.lastStart)
	assert.Equal(t, svc.now(), fake.lastEnd, "season-to-date window")

	fake.err = errors.New("weather down")
	assert.Nil(t, svc.observedEnvironment(context.Background(), pred), "failure falls back to placeholders")

	fake.err = nil
	fake.weather = &outbound.SeasonWeather{Days: 0}
	assert.Nil(t, svc.observedEnvironment(context.Background(), pred), "empty window falls back to placeholders")

	future := &domain.YieldPrediction{FieldID: "field-001", Season: "kharif", Year: 2030}
	calls := fake.calls
	assert.Nil(t, svc.observedEnvironment(context.Background(), future))
	assert.Equal(t, calls, fake.calls, "future season must not call weather")
}
