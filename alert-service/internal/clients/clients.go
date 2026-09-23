// Package clients holds alert-service's outbound clients for the services that
// hold a field's current conditions.
//
// They exist because the risk score did not previously describe the field it
// named. alert-service sent the gateway a field id and nothing else, and the
// gateway substitutes defaults for whatever is absent — 22°C, 30% soil
// moisture, no detections — so every field came back scored against the same
// imaginary temperate day. Nothing errored, and the number looked like a
// measurement.
//
// That mattered more once the rule scanner began calling it on a timer: a
// farmer who sets a threshold on water risk was being told about a default,
// not their field.
package clients

import (
	"context"
	"fmt"
	"net/http"

	"connectrpc.com/connect"

	soilv1 "p9e.in/samavaya/agriculture/soil-service/api/v1"
	"p9e.in/samavaya/agriculture/soil-service/api/v1/soilv1connect"
	weatherv1 "p9e.in/samavaya/agriculture/weather-service/api/v1"
	"p9e.in/samavaya/agriculture/weather-service/api/v1/weatherv1connect"
)

// FieldWeather is a field's current and near-term weather, in the units the
// AI gateway's FieldWeather message expects.
type FieldWeather struct {
	TemperatureCurrent      float64
	TemperatureMinForecast  float64
	TemperatureMaxForecast  float64
	PrecipitationMm         float64
	PrecipitationForecastMm float64
	EtReferenceMm           float64

	// SoilMoisture is volumetric, m³/m³, which is already the unit and scale
	// the gateway wants — its own default is 0.30. Present only when the
	// observation carried one, which is why it is reported separately.
	SoilMoisture    float64
	HasSoilMoisture bool
}

// WeatherClient reads a field's weather from weather-service.
type WeatherClient interface {
	FieldWeather(ctx context.Context, fieldID string) (*FieldWeather, error)
}

// SoilClient reads a field's soil state from soil-service.
type SoilClient interface {
	// LatestMoistureFraction returns the most recent sampled soil moisture as
	// a 0..1 fraction, and whether one was found.
	LatestMoistureFraction(ctx context.Context, fieldID string) (float64, bool, error)
}

// ---------------------------------------------------------------------------

type weatherClient struct {
	client weatherv1connect.WeatherServiceClient
}

// NewWeatherClient creates a Connect-backed WeatherClient.
func NewWeatherClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) WeatherClient {
	return &weatherClient{client: weatherv1connect.NewWeatherServiceClient(httpClient, baseURL, opts...)}
}

// FieldWeather returns the field's latest observation plus tomorrow's forecast.
//
// Two calls because the gateway wants both: the current temperature and
// rainfall come from the observation, while the min/max it scores frost and
// heat risk against, and the reference ET it scores water risk against, only
// exist in the forecast.
//
// A missing forecast is not fatal. The observation alone is still far better
// than the gateway's defaults, and refusing to score a field because tomorrow
// is unknown would take the whole evaluation down with it.
func (c *weatherClient) FieldWeather(ctx context.Context, fieldID string) (*FieldWeather, error) {
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

	out := &FieldWeather{
		TemperatureCurrent: obs.GetTemperatureC(),
		PrecipitationMm:    obs.GetPrecipitationMm(),
		// Defaulted to the current temperature so that, without a forecast,
		// frost and heat risk are scored against today rather than against
		// zero — which would read as a hard freeze.
		TemperatureMinForecast: obs.GetTemperatureC(),
		TemperatureMaxForecast: obs.GetTemperatureC(),
	}
	if m := obs.GetSoilMoistureM3M3(); m > 0 {
		out.SoilMoisture, out.HasSoilMoisture = m, true
	}

	fc, err := c.client.GetForecast(ctx, connect.NewRequest(&weatherv1.GetForecastRequest{
		FieldId: fieldID,
		Days:    1,
	}))
	if err != nil {
		return out, nil
	}
	if days := fc.Msg.GetForecasts(); len(days) > 0 {
		d := days[0]
		out.TemperatureMinForecast = d.GetTemperatureMinC()
		out.TemperatureMaxForecast = d.GetTemperatureMaxC()
		out.PrecipitationForecastMm = d.GetPrecipitationMm()
		out.EtReferenceMm = d.GetEt0Mm()
	}
	return out, nil
}

// ---------------------------------------------------------------------------

type soilClient struct {
	client soilv1connect.SoilServiceClient
}

// NewSoilClient creates a Connect-backed SoilClient.
func NewSoilClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) SoilClient {
	return &soilClient{client: soilv1connect.NewSoilServiceClient(httpClient, baseURL, opts...)}
}

// LatestMoistureFraction returns the field's most recent sampled soil moisture.
//
// Divided by 100 on the way out, and that is the whole reason this returns a
// named fraction rather than the number soil-service stores. A sample's
// moisture_pct is a percentage — 30 means 30% — while the gateway's
// soil_moisture is a fraction whose own default is 0.30. Passing the
// percentage straight through would hand it 30.0 where it expects 0.3, a
// hundredfold error that would read as saturated ground on every field.
func (c *soilClient) LatestMoistureFraction(ctx context.Context, fieldID string) (float64, bool, error) {
	if fieldID == "" {
		return 0, false, fmt.Errorf("field_id is required to look up soil moisture")
	}

	resp, err := c.client.ListSoilSamples(ctx, connect.NewRequest(&soilv1.ListSoilSamplesRequest{
		FieldId:  fieldID,
		PageSize: 1,
	}))
	if err != nil {
		return 0, false, fmt.Errorf("soil ListSoilSamples: %w", err)
	}

	samples := resp.Msg.GetSamples()
	if len(samples) == 0 {
		return 0, false, nil
	}
	fraction, ok := moistureFraction(samples[0].GetMoisturePct())
	return fraction, ok, nil
}

// moistureFraction converts a sample's moisture percentage to the fraction the
// gateway expects, and reports whether there was a reading at all.
//
// Extracted so it can be tested without a server, because nothing else catches
// this: dropping the division still compiles and still runs, and the wrong
// number is a plausible one. 30% arriving as 30.0 where 0.3 belongs reads as
// ground a hundred times wetter than saturated.
//
// A zero or negative percentage is "not recorded", not "bone dry". Sent as a
// real 0.0 it would be drier than any soil, and water risk would peg high on
// every field whose sample happened to omit it.
func moistureFraction(pct float64) (float64, bool) {
	if pct <= 0 {
		return 0, false
	}
	return pct / 100.0, true
}
