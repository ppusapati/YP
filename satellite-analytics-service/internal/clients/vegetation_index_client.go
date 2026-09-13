// Package clients contains Connect client adapters for peer services.
package clients

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"connectrpc.com/connect"

	"google.golang.org/protobuf/types/known/timestamppb"
	vegv1 "p9e.in/samavaya/agriculture/vegetation-index-service/api/v1"
	"p9e.in/samavaya/agriculture/vegetation-index-service/api/v1/v1connect"

	"p9e.in/samavaya/agriculture/satellite-analytics-service/internal/timeseries"
)

// VegetationIndexClient fetches per-field index time series.
type VegetationIndexClient interface {
	GetNDVITimeSeries(ctx context.Context, farmID, fieldID string, from, to time.Time) ([]timeseries.Sample, error)
}

type vegetationIndexClient struct {
	client v1connect.VegetationIndexServiceClient
}

// NewVegetationIndexClient creates a Connect-backed VegetationIndexClient.
func NewVegetationIndexClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) VegetationIndexClient {
	return &vegetationIndexClient{client: v1connect.NewVegetationIndexServiceClient(httpClient, baseURL, opts...)}
}

func (c *vegetationIndexClient) GetNDVITimeSeries(ctx context.Context, farmID, fieldID string, from, to time.Time) ([]timeseries.Sample, error) {
	resp, err := c.client.GetNDVITimeSeries(ctx, connect.NewRequest(&vegv1.GetNDVITimeSeriesRequest{
		FarmId:   farmID,
		FieldId:  fieldID,
		DateFrom: timestamppb.New(from),
		DateTo:   timestamppb.New(to),
	}))
	if err != nil {
		return nil, fmt.Errorf("vegetation-index GetNDVITimeSeries: %w", err)
	}
	points := resp.Msg.GetTimeSeries().GetPoints()
	out := make([]timeseries.Sample, 0, len(points))
	for _, p := range points {
		if p.GetDate() == nil {
			continue
		}
		out = append(out, timeseries.Sample{
			Date:   p.GetDate().AsTime(),
			Value:  p.GetValue(),
			StdDev: p.GetStdDeviation(),
		})
	}
	return out, nil
}
