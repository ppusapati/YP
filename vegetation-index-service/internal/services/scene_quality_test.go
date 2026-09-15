package services

import (
	"math"
	"testing"
)

// near compares fractions derived by subtraction, which does not land on exact
// decimals.
func near(a, b float64) bool { return math.Abs(a-b) < 1e-9 }

func TestSceneQuality_Usable(t *testing.T) {
	cases := []struct {
		name  string
		valid float64
		want  bool
	}{
		{"a clear scene", 1.0, true},
		{"exactly at the threshold", MinValidPixelFraction, true},
		{"just under the threshold", MinValidPixelFraction - 0.01, false},
		{"almost entirely cloud", 0.05, false},
		{"nothing survived", 0.0, false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			q := SceneQuality{ValidPixelFraction: tc.valid}
			if got := q.Usable(); got != tc.want {
				t.Errorf("Usable() with valid=%v = %v, want %v", tc.valid, got, tc.want)
			}
		})
	}
}

func TestSceneQuality_NormaliseDerivesTheMissingHalf(t *testing.T) {
	// Providers report one or the other depending on the product.
	fromCloud := SceneQuality{CloudFraction: 0.8}.Normalise()
	if !near(fromCloud.ValidPixelFraction, 0.2) {
		t.Errorf("valid = %v, want 0.2", fromCloud.ValidPixelFraction)
	}
	if fromCloud.Usable() {
		t.Error("a scene that is 80 percent cloud should not be usable")
	}

	fromValid := SceneQuality{ValidPixelFraction: 0.6}.Normalise()
	if !near(fromValid.CloudFraction, 0.4) {
		t.Errorf("cloud = %v, want 0.4", fromValid.CloudFraction)
	}
}

func TestSceneQuality_NormaliseTreatsSilenceAsAClearScene(t *testing.T) {
	// A scene ingested before masking existed reports nothing. Its index was
	// already computed assuming every pixel counted; saying so explicitly
	// keeps it in the series instead of dropping the whole back-catalogue.
	q := SceneQuality{}.Normalise()
	if q.ValidPixelFraction != 1 {
		t.Errorf("valid = %v, want 1", q.ValidPixelFraction)
	}
	if !q.Usable() {
		t.Error("an unreported scene should stay usable")
	}
}

func TestSceneQuality_NormaliseClampsNonsense(t *testing.T) {
	// A provider reporting out-of-range fractions should not be able to make a
	// scene look better than fully clear or worse than fully cloudy.
	high := SceneQuality{CloudFraction: 3.0, ValidPixelFraction: 7.5}.Normalise()
	if high.CloudFraction != 1 || high.ValidPixelFraction != 1 {
		t.Errorf("got %+v, want both clamped to 1", high)
	}

	low := SceneQuality{CloudFraction: -2, ValidPixelFraction: -1}.Normalise()
	// Both clamp to zero, which reads as "nothing reported" and so is treated
	// as a clear scene rather than silently discarding it.
	if low.ValidPixelFraction != 1 {
		t.Errorf("got %+v, want the unreported default", low)
	}
}

func TestSceneQuality_PartialCloudIsStillWorthKeeping(t *testing.T) {
	// Cloud over one corner still says something useful about the rest, and in
	// a monsoon season a stricter bar would discard most of the record.
	q := SceneQuality{CloudFraction: 0.5}.Normalise()
	if !q.Usable() {
		t.Errorf("a half-clear scene should be kept, got %+v", q)
	}
}
