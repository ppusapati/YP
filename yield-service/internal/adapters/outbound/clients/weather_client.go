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

	"p9e.in/samavaya/agriculture/yield-service/internal/ports/outbound"
)

type weatherClient struct {
	client weatherv1connect.WeatherServiceClient
}

// NewWeatherClient creates a Connect-backed WeatherClient.
func NewWeatherClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) outbound.WeatherClient {
	return &weatherClient{client: weatherv1connect.NewWeatherServiceClient(httpClient, baseURL, opts...)}
}

func (c *weatherClient) SeasonWeather(ctx context.Context, fieldID string, start, end time.Time) (*outbound.SeasonWeather, error) {
	resp, err := c.client.GetAgroMetrics(ctx, connect.NewRequest(&weatherv1.GetAgroMetricsRequest{
		FieldId: fieldID,
		Start:   timestamppb.New(start),
		End:     timestamppb.New(end),
	}))
	if err != nil {
		return nil, fmt.Errorf("weather GetAgroMetrics: %w", err)
	}
	daily := resp.Msg.GetDaily()
	summary := resp.Msg.GetSummary()
	out := &outbound.SeasonWeather{
		Start:             start,
		End:               end,
		Days:              len(daily),
		GrowingDegreeDays: summary.GetCumulativeGdd(),
		TotalPrecipMM:     summary.GetCumulativePrecipitationMm(),
		TotalET0MM:        summary.GetCumulativeEt0Mm(),
		FrostDays:         int(summary.GetFrostDays()),
		HeatStressDays:    int(summary.GetHeatStressDays()),
	}
	if len(daily) == 0 {
		return out, nil
	}
	var temp, rh, solar float64
	for _, d := range daily {
		temp += d.GetTemperatureMeanC()
		rh += d.GetHumidityMeanPct()
		solar += d.GetSolarRadiationMj()
	}
	n := float64(len(daily))
	out.AvgTemperatureC = temp / n
	out.AvgHumidityPct = rh / n
	out.AvgSolarMJ = solar / n
	return out, nil
}
