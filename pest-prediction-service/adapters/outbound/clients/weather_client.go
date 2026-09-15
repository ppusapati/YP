package clients

import (
	"context"
	"fmt"
	"net/http"

	"connectrpc.com/connect"

	weatherv1 "p9e.in/samavaya/agriculture/weather-service/api/v1"
	"p9e.in/samavaya/agriculture/weather-service/api/v1/weatherv1connect"

	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ports/outbound"
)

// Pest risk is driven by weather, and weather is a property of the field, not
// of whoever happens to be calling. Taking it from the request meant every
// caller had to source it — and a caller that got it wrong, or sent stale
// numbers, silently moved the risk score.
type weatherClient struct {
	client weatherv1connect.WeatherServiceClient
}

// NewWeatherClient creates a Connect-backed WeatherClient.
func NewWeatherClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) outbound.WeatherClient {
	return &weatherClient{client: weatherv1connect.NewWeatherServiceClient(httpClient, baseURL, opts...)}
}

// CurrentWeather returns the latest observation recorded for a field.
func (c *weatherClient) CurrentWeather(ctx context.Context, fieldID string) (*outbound.FieldWeather, error) {
	if fieldID == "" {
		return nil, fmt.Errorf("field_id is required to look up weather")
	}
	resp, err := c.client.GetCurrentWeather(ctx, connect.NewRequest(&weatherv1.GetCurrentWeatherRequest{
		FieldId: fieldID,
	}))
	if err != nil {
		return nil, fmt.Errorf("weather GetCurrentWeather: %w", err)
	}

	obs := resp.Msg.GetObservation()
	if obs == nil {
		return nil, fmt.Errorf("no weather observation recorded for field %s", fieldID)
	}
	return &outbound.FieldWeather{
		TemperatureCelsius: obs.GetTemperatureC(),
		HumidityPct:        obs.GetHumidityPct(),
		RainfallMm:         obs.GetPrecipitationMm(),
		// The weather service records wind in m/s; pest risk thresholds are
		// expressed in km/h.
		WindSpeedKmh: obs.GetWindSpeedMs() * 3.6,
	}, nil
}
