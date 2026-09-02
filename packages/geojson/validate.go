package geojson

import (
	"encoding/json"
	"fmt"
)

type geometry struct {
	Type        string            `json:"type"`
	Coordinates json.RawMessage   `json:"coordinates"`
}

// ValidatePolygon validates that raw JSON is a GeoJSON Polygon or MultiPolygon
// with valid coordinate bounds and closed rings (minimum 4 points).
func ValidatePolygon(raw string) error {
	var g geometry
	if err := json.Unmarshal([]byte(raw), &g); err != nil {
		return fmt.Errorf("invalid JSON: %w", err)
	}

	switch g.Type {
	case "Polygon":
		var rings [][][2]float64
		if err := json.Unmarshal(g.Coordinates, &rings); err != nil {
			return fmt.Errorf("invalid Polygon coordinates: %w", err)
		}
		if len(rings) == 0 {
			return fmt.Errorf("Polygon must have at least one ring")
		}
		for i, ring := range rings {
			if err := validateRing(ring, i); err != nil {
				return err
			}
		}

	case "MultiPolygon":
		var polys [][][][2]float64
		if err := json.Unmarshal(g.Coordinates, &polys); err != nil {
			return fmt.Errorf("invalid MultiPolygon coordinates: %w", err)
		}
		if len(polys) == 0 {
			return fmt.Errorf("MultiPolygon must have at least one polygon")
		}
		for pi, rings := range polys {
			for ri, ring := range rings {
				if err := validateRing(ring, ri); err != nil {
					return fmt.Errorf("polygon[%d]: %w", pi, err)
				}
			}
		}

	case "":
		return fmt.Errorf("missing geometry type")
	default:
		return fmt.Errorf("unsupported geometry type %q, expected Polygon or MultiPolygon", g.Type)
	}

	return nil
}

func validateRing(ring [][2]float64, idx int) error {
	if len(ring) < 4 {
		return fmt.Errorf("ring[%d] must have at least 4 positions, got %d", idx, len(ring))
	}
	first, last := ring[0], ring[len(ring)-1]
	if first[0] != last[0] || first[1] != last[1] {
		return fmt.Errorf("ring[%d] is not closed (first and last positions differ)", idx)
	}
	for i, coord := range ring {
		lng, lat := coord[0], coord[1]
		if lat < -90 || lat > 90 {
			return fmt.Errorf("ring[%d][%d]: latitude %f out of range [-90, 90]", idx, i, lat)
		}
		if lng < -180 || lng > 180 {
			return fmt.Errorf("ring[%d][%d]: longitude %f out of range [-180, 180]", idx, i, lng)
		}
	}
	return nil
}
