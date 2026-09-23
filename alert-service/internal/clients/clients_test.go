package clients

import "testing"

// soil-service records moisture_pct as a percentage; the AI gateway's
// soil_moisture is a fraction on the same scale as its own default of 0.30.
// Without the conversion a typical 30% sample arrives as 30.0 — a hundred
// times saturated — and it compiles, runs and looks like a reading.
func TestMoisturePercentBecomesAFraction(t *testing.T) {
	for _, tc := range []struct {
		pct   float64
		want  float64
		found bool
	}{
		{30.0, 0.30, true},  // the gateway's own default, for scale
		{12.5, 0.125, true}, // dry
		{48.0, 0.48, true},  // near saturation
		{100.0, 1.0, true},  // the top of the percentage scale is 1.0, not 100
		{0, 0, false},       // not recorded, not bone dry
		{-1, 0, false},      // nonsense reading
	} {
		got, found := moistureFraction(tc.pct)
		if found != tc.found {
			t.Errorf("moistureFraction(%v) found = %v, want %v", tc.pct, found, tc.found)
		}
		if got != tc.want {
			t.Errorf("moistureFraction(%v) = %v, want %v", tc.pct, got, tc.want)
		}
	}
}
