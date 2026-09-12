// Package clients contains Connect client adapters for peer services.
package clients

import (
	"context"
	"fmt"
	"math"
	"net/http"

	"connectrpc.com/connect"

	fieldv1 "p9e.in/samavaya/agriculture/field-service/api/v1"
	fieldv1connect "p9e.in/samavaya/agriculture/field-service/api/v1/fieldv1connect"
	"p9e.in/samavaya/agriculture/weather-service/internal/ports/outbound"
)

type fieldClient struct {
	client fieldv1connect.FieldServiceClient
}

// NewFieldClient creates a Connect-backed FieldClient.
func NewFieldClient(baseURL string, httpClient *http.Client, opts ...connect.ClientOption) outbound.FieldClient {
	return &fieldClient{client: fieldv1connect.NewFieldServiceClient(httpClient, baseURL, opts...)}
}

func (c *fieldClient) FieldCentroid(ctx context.Context, fieldID string) (float64, float64, string, error) {
	resp, err := c.client.GetField(ctx, connect.NewRequest(&fieldv1.GetFieldRequest{Id: fieldID}))
	if err != nil {
		return 0, 0, "", err
	}
	f := resp.Msg.GetField()
	if f == nil {
		return 0, 0, "", fmt.Errorf("field %s not found", fieldID)
	}
	pts := f.GetBoundary().GetPoints()
	if len(pts) == 0 {
		return 0, 0, f.GetFarmId(), fmt.Errorf("field %s has no boundary", fieldID)
	}
	lat, lon := PolygonCentroid(pts)
	return lat, lon, f.GetFarmId(), nil
}

// PolygonCentroid returns the area-weighted centroid of a polygon ring, falling
// back to the vertex mean for degenerate (zero-area) rings.
func PolygonCentroid(pts []*fieldv1.GeoPoint) (lat, lon float64) {
	n := len(pts)
	if n == 0 {
		return 0, 0
	}
	if n < 3 {
		return meanPoint(pts)
	}
	var area, cx, cy float64
	for i := 0; i < n; i++ {
		x0, y0 := pts[i].GetLongitude(), pts[i].GetLatitude()
		x1, y1 := pts[(i+1)%n].GetLongitude(), pts[(i+1)%n].GetLatitude()
		cross := x0*y1 - x1*y0
		area += cross
		cx += (x0 + x1) * cross
		cy += (y0 + y1) * cross
	}
	if math.Abs(area) < 1e-12 {
		return meanPoint(pts)
	}
	area /= 2
	return cy / (6 * area), cx / (6 * area)
}

func meanPoint(pts []*fieldv1.GeoPoint) (lat, lon float64) {
	for _, p := range pts {
		lat += p.GetLatitude()
		lon += p.GetLongitude()
	}
	return lat / float64(len(pts)), lon / float64(len(pts))
}
