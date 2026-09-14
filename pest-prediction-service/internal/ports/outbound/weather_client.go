package outbound

import "context"

// FieldWeather is the current weather at a field, in the units pest risk
// thresholds are expressed in.
type FieldWeather struct {
	TemperatureCelsius float64
	HumidityPct        float64
	RainfallMm         float64
	WindSpeedKmh       float64
}

// WeatherClient is the secondary port for calling weather-service.
type WeatherClient interface {
	// CurrentWeather returns the latest observation for a field.
	CurrentWeather(ctx context.Context, fieldID string) (*FieldWeather, error)
}
