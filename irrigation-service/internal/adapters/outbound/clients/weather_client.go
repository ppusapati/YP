package clients

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	weatherv1 "p9e.in/samavaya/agriculture/weather-service/api/v1"
	"p9e.in/samavaya/agriculture/weather-service/api/v1/weatherv1connect"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

type weatherClient struct {
	client weatherv1connect.WeatherServiceClient
}

// NewWeatherClient creates a Connect-backed WeatherClient.
func NewWeatherClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) outbound.WeatherClient {
	return &weatherClient{client: weatherv1connect.NewWeatherServiceClient(httpClient, baseURL, opts...)}
}

func (c *weatherClient) FieldWeather(ctx context.Context, fieldID string, trailingDays, forecastDays int) (*outbound.FieldWeather, error) {
	if trailingDays <= 0 {
		trailingDays = 7
	}
	if forecastDays <= 0 {
		forecastDays = 7
	}
	now := time.Now().UTC()

	metrics, err := c.client.GetAgroMetrics(ctx, connect.NewRequest(&weatherv1.GetAgroMetricsRequest{
		FieldId: fieldID,
		Start:   timestamppb.New(now.AddDate(0, 0, -trailingDays)),
		End:     timestamppb.New(now),
	}))
	if err != nil {
		return nil, fmt.Errorf("weather GetAgroMetrics: %w", err)
	}
	out := &outbound.FieldWeather{}
	if daily := metrics.Msg.GetDaily(); len(daily) > 0 {
		var et0 float64
		for _, d := range daily {
			et0 += d.GetEt0Mm()
			out.RecentRainfallMM += d.GetPrecipitationMm()
		}
		out.ET0MMDay = et0 / float64(len(daily))
	}

	fc, err := c.client.GetForecast(ctx, connect.NewRequest(&weatherv1.GetForecastRequest{
		FieldId: fieldID,
		Days:    int32(forecastDays),
	}))
	if err != nil {
		return nil, fmt.Errorf("weather GetForecast: %w", err)
	}
	var fcET0 float64
	for _, day := range fc.Msg.GetForecasts() {
		out.ForecastRainfallMM = append(out.ForecastRainfallMM, day.GetPrecipitationMm())
		fcET0 += day.GetEt0Mm()
	}
	if n := len(fc.Msg.GetForecasts()); n > 0 {
		out.ForecastET0MMDay = fcET0 / float64(n)
	}
	return out, nil
}
