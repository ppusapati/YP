package geojson

import (
	"testing"
)

func TestValidatePolygon_ValidPolygon(t *testing.T) {
	raw := `{"type":"Polygon","coordinates":[[[0,0],[1,0],[1,1],[0,0]]]}`
	if err := ValidatePolygon(raw); err != nil {
		t.Fatalf("expected valid, got: %v", err)
	}
}

func TestValidatePolygon_ValidMultiPolygon(t *testing.T) {
	raw := `{"type":"MultiPolygon","coordinates":[[[[0,0],[1,0],[1,1],[0,0]]]]}`
	if err := ValidatePolygon(raw); err != nil {
		t.Fatalf("expected valid, got: %v", err)
	}
}

func TestValidatePolygon_MissingType(t *testing.T) {
	raw := `{"coordinates":[[[0,0],[1,0],[1,1],[0,0]]]}`
	if err := ValidatePolygon(raw); err == nil {
		t.Fatal("expected error for missing type")
	}
}

func TestValidatePolygon_UnsupportedType(t *testing.T) {
	raw := `{"type":"Point","coordinates":[0,0]}`
	if err := ValidatePolygon(raw); err == nil {
		t.Fatal("expected error for Point type")
	}
}

func TestValidatePolygon_TooFewPoints(t *testing.T) {
	raw := `{"type":"Polygon","coordinates":[[[0,0],[1,0],[0,0]]]}`
	if err := ValidatePolygon(raw); err == nil {
		t.Fatal("expected error for ring with < 4 points")
	}
}

func TestValidatePolygon_UnclosedRing(t *testing.T) {
	raw := `{"type":"Polygon","coordinates":[[[0,0],[1,0],[1,1],[0,1]]]}`
	if err := ValidatePolygon(raw); err == nil {
		t.Fatal("expected error for unclosed ring")
	}
}

func TestValidatePolygon_OutOfRangeLat(t *testing.T) {
	raw := `{"type":"Polygon","coordinates":[[[0,91],[1,0],[1,1],[0,91]]]}`
	if err := ValidatePolygon(raw); err == nil {
		t.Fatal("expected error for latitude > 90")
	}
}

func TestValidatePolygon_OutOfRangeLng(t *testing.T) {
	raw := `{"type":"Polygon","coordinates":[[[181,0],[1,0],[1,1],[181,0]]]}`
	if err := ValidatePolygon(raw); err == nil {
		t.Fatal("expected error for longitude > 180")
	}
}

func TestValidatePolygon_InvalidJSON(t *testing.T) {
	if err := ValidatePolygon("{not json}"); err == nil {
		t.Fatal("expected error for invalid JSON")
	}
}

func TestValidatePolygon_EmptyRings(t *testing.T) {
	raw := `{"type":"Polygon","coordinates":[]}`
	if err := ValidatePolygon(raw); err == nil {
		t.Fatal("expected error for empty rings")
	}
}
