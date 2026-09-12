package clients

import (
	"math"
	"testing"

	fieldv1 "p9e.in/samavaya/agriculture/field-service/api/v1"
)

func pt(lat, lon float64) *fieldv1.GeoPoint { return &fieldv1.GeoPoint{Latitude: lat, Longitude: lon} }

func TestPolygonCentroid_Square(t *testing.T) {
	lat, lon := PolygonCentroid([]*fieldv1.GeoPoint{pt(0, 0), pt(0, 2), pt(2, 2), pt(2, 0)})
	if math.Abs(lat-1) > 1e-9 || math.Abs(lon-1) > 1e-9 {
		t.Errorf("centroid = (%v,%v), want (1,1)", lat, lon)
	}
}

func TestPolygonCentroid_ClosedRing(t *testing.T) {
	lat, lon := PolygonCentroid([]*fieldv1.GeoPoint{pt(10, 20), pt(10, 22), pt(12, 22), pt(12, 20), pt(10, 20)})
	if math.Abs(lat-11) > 1e-9 || math.Abs(lon-21) > 1e-9 {
		t.Errorf("centroid = (%v,%v), want (11,21)", lat, lon)
	}
}

func TestPolygonCentroid_Degenerate(t *testing.T) {
	lat, lon := PolygonCentroid([]*fieldv1.GeoPoint{pt(1, 1), pt(3, 3)})
	if lat != 2 || lon != 2 {
		t.Errorf("degenerate should use mean, got (%v,%v)", lat, lon)
	}
	lat, lon = PolygonCentroid([]*fieldv1.GeoPoint{pt(1, 1), pt(2, 2), pt(3, 3)})
	if lat != 2 || lon != 2 {
		t.Errorf("collinear should use mean, got (%v,%v)", lat, lon)
	}
	if lat, lon := PolygonCentroid(nil); lat != 0 || lon != 0 {
		t.Error("empty should be zero")
	}
}
