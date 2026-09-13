package outbound

import (
	"context"
	"time"
)

// SeasonWeather aggregates weather-service agro metrics over a growing window.
type SeasonWeather struct {
	Start             time.Time
	End               time.Time
	Days              int
	AvgTemperatureC   float64
	TotalPrecipMM     float64
	GrowingDegreeDays float64
	FrostDays         int
	HeatStressDays    int
	AvgHumidityPct    float64
	AvgSolarMJ        float64
	TotalET0MM        float64
}

// WeatherClient is the secondary port for calling weather-service.
type WeatherClient interface {
	SeasonWeather(ctx context.Context, fieldID string, start, end time.Time) (*SeasonWeather, error)
}
