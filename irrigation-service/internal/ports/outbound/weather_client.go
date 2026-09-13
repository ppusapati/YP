package outbound

import "context"

// FieldWeather is the weather summary needed to schedule irrigation for a field.
type FieldWeather struct {
	// Mean reference evapotranspiration over the trailing window (mm/day).
	ET0MMDay float64
	// Rainfall over the trailing window (mm).
	RecentRainfallMM float64
	// Daily rainfall forecast starting today (mm/day).
	ForecastRainfallMM []float64
	// Mean forecast ET0 (mm/day) when the provider supplies it; 0 otherwise.
	ForecastET0MMDay float64
}

// WeatherClient is the secondary port for calling weather-service.
type WeatherClient interface {
	FieldWeather(ctx context.Context, fieldID string, trailingDays, forecastDays int) (*FieldWeather, error)
}
