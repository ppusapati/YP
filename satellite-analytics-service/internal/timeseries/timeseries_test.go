package timeseries

import (
	"math"
	"testing"
	"time"
)

var t0 = time.Date(2025, 3, 1, 0, 0, 0, 0, time.UTC)

func at(days int, v float64) Sample {
	return Sample{Date: t0.AddDate(0, 0, days), Value: v, Sensor: "SENTINEL2"}
}

// seasonCurve returns a bell-shaped NDVI season peaking at day 90 over 180 days.
func seasonCurve(stepDays int) []Sample {
	var out []Sample
	for d := 0; d <= 180; d += stepDays {
		v := 0.2 + 0.6*math.Exp(-math.Pow(float64(d-90)/30, 2))
		out = append(out, at(d, v))
	}
	return out
}

func TestHarmonize(t *testing.T) {
	in := []Sample{
		{Value: 0.5, Sensor: "LANDSAT8"},
		{Value: 0.5, Sensor: "LC08"},
		{Value: 0.5, Sensor: "SENTINEL2"},
		{Value: 0.5, Sensor: "UAV"},
	}
	out := Harmonize(in)
	want := 0.0149 + 0.9723*0.5
	if math.Abs(out[0].Value-want) > 1e-12 || math.Abs(out[1].Value-want) > 1e-12 {
		t.Errorf("landsat not harmonized: %v %v", out[0].Value, out[1].Value)
	}
	if out[2].Value != 0.5 || out[3].Value != 0.5 {
		t.Error("non-landsat sensors must pass through")
	}
	if in[0].Value != 0.5 {
		t.Error("input must not be mutated")
	}
}

func TestSorted_DedupesAndOrders(t *testing.T) {
	s := Sorted([]Sample{at(10, 0.4), at(0, 0.2), at(10, 0.6)})
	if len(s) != 2 || !s[0].Date.Equal(t0) || s[1].Value != 0.5 {
		t.Errorf("unexpected %+v", s)
	}
}

func TestGapFill(t *testing.T) {
	in := []Sample{at(0, 0.2), at(10, 0.4), at(100, 0.8), at(110, 0.6)}
	out := GapFill(in, 5*day, 45*day)

	byDay := map[int]Sample{}
	for _, s := range out {
		byDay[int(s.Date.Sub(t0).Hours()/24)] = s
	}
	if s, ok := byDay[5]; !ok || !s.Interpolated || math.Abs(s.Value-0.3) > 1e-9 {
		t.Errorf("day 5 should be interpolated to 0.3, got %+v", s)
	}
	if _, ok := byDay[50]; ok {
		t.Error("points inside a 90-day gap must not be invented")
	}
	if s, ok := byDay[105]; !ok || math.Abs(s.Value-0.7) > 1e-9 {
		t.Errorf("day 105 should be 0.7, got %+v", s)
	}
	if s, ok := byDay[110]; !ok || s.Interpolated {
		t.Error("last real observation must be retained")
	}
	if got := GapFill([]Sample{at(0, 0.5)}, 0, 0); len(got) != 1 {
		t.Error("single sample passes through")
	}
}

func TestSmooth(t *testing.T) {
	in := []Sample{at(0, 0), at(1, 1), at(2, 0), at(3, 1), at(4, 0)}
	out := Smooth(in, 3)
	if math.Abs(out[2].Value-2.0/3) > 1e-12 {
		t.Errorf("centre = %v want 2/3", out[2].Value)
	}
	if math.Abs(out[0].Value-0.5) > 1e-12 {
		t.Errorf("edge = %v want 0.5", out[0].Value)
	}
	if got := Smooth(in, 1); got[1].Value != 1 {
		t.Error("window < 3 is identity")
	}
}

func TestFitTrend(t *testing.T) {
	var in []Sample
	for d := 0; d <= 100; d += 10 {
		in = append(in, at(d, 0.2+0.005*float64(d)))
	}
	tr := FitTrend(in)
	if math.Abs(tr.SlopePerDay-0.005) > 1e-9 || math.Abs(tr.Intercept-0.2) > 1e-9 {
		t.Errorf("slope/intercept = %v/%v", tr.SlopePerDay, tr.Intercept)
	}
	if tr.RSquared < 0.9999 || tr.Direction != "increasing" || tr.N != 11 {
		t.Errorf("unexpected trend %+v", tr)
	}
	if math.Abs(tr.DeviationPct-250) > 1e-6 {
		t.Errorf("deviation = %v want 250%%", tr.DeviationPct)
	}

	flat := FitTrend([]Sample{at(0, 0.5), at(10, 0.5), at(20, 0.5)})
	if flat.Direction != "stable" || flat.SlopePerDay != 0 {
		t.Errorf("flat series should be stable: %+v", flat)
	}
	if FitTrend(nil).N != 0 || FitTrend([]Sample{at(0, 0.3)}).LastValue != 0.3 {
		t.Error("degenerate inputs")
	}
}

func TestDetectChange(t *testing.T) {
	var in []Sample
	for d := 0; d < 50; d += 5 {
		in = append(in, at(d, 0.7+0.01*float64(d%2)))
	}
	for d := 50; d < 100; d += 5 {
		in = append(in, at(d, 0.4+0.01*float64(d%2)))
	}
	c := DetectChange(in, t0.AddDate(0, 0, 50))
	if c.NBefore != 10 || c.NAfter != 10 {
		t.Fatalf("split counts %d/%d", c.NBefore, c.NAfter)
	}
	if math.Abs(c.Delta-(-0.3)) > 1e-9 || !c.Significant || c.ZScore > -10 {
		t.Errorf("expected significant drop, got %+v", c)
	}
	// before mean is 0.705 (alternating +0.01), so -0.3/0.705.
	if math.Abs(c.PctChange-(-42.553)) > 0.01 {
		t.Errorf("pct change = %v", c.PctChange)
	}

	none := DetectChange(in, t0.AddDate(0, 0, 500))
	if none.NAfter != 0 || none.Significant {
		t.Error("no after-samples should yield no change")
	}
}

func TestDetectAnomalies(t *testing.T) {
	in := seasonCurve(5)
	in[10].Value = 0.05 // cloud-contaminated dip on the rising limb
	an := DetectAnomalies(in, 3)
	if len(an) != 1 {
		t.Fatalf("expected exactly one anomaly, got %d: %+v", len(an), an)
	}
	if !an[0].Date.Equal(in[10].Date) || an[0].ZScore > -3 {
		t.Errorf("wrong anomaly %+v", an[0])
	}
	if got := DetectAnomalies(seasonCurve(5), 3); len(got) != 0 {
		t.Errorf("clean curve should have no anomalies, got %d", len(got))
	}
	if got := DetectAnomalies(in[:3], 3); got != nil {
		t.Error("too few samples returns nil")
	}
}

func TestExtractPhenology(t *testing.T) {
	p := ExtractPhenology(seasonCurve(5), 0.5)
	if !p.Detected {
		t.Fatalf("season not detected: %+v", p)
	}
	peakDay := p.PeakDate.Sub(t0).Hours() / 24
	if math.Abs(peakDay-90) > 5 {
		t.Errorf("peak day = %v want ≈90", peakDay)
	}
	if math.Abs(p.PeakValue-0.8) > 0.05 || math.Abs(p.BaseValue-0.2) > 0.05 {
		t.Errorf("peak/base = %v/%v", p.PeakValue, p.BaseValue)
	}
	// Half-amplitude crossings of a Gaussian with sigma 30 are at ±25 days.
	sos := p.SeasonStart.Sub(t0).Hours() / 24
	eos := p.SeasonEnd.Sub(t0).Hours() / 24
	if math.Abs(sos-65) > 5 || math.Abs(eos-115) > 5 {
		t.Errorf("SOS/EOS = %v/%v want ≈65/115", sos, eos)
	}
	if p.SeasonLengthDays < 40 || p.SeasonLengthDays > 60 {
		t.Errorf("season length = %d", p.SeasonLengthDays)
	}
	if p.GreenUpRatePerDay <= 0 || p.SenescenceRatePerDay <= 0 {
		t.Errorf("rates should be positive: %+v", p)
	}

	flat := ExtractPhenology([]Sample{at(0, 0.5), at(10, 0.5), at(20, 0.5), at(30, 0.5)}, 0.5)
	if flat.Detected {
		t.Error("flat series has no season")
	}
	if ExtractPhenology(seasonCurve(5)[:3], 0.5).Detected {
		t.Error("too few samples")
	}
}

func TestFractionBelowAndMedian(t *testing.T) {
	in := []Sample{at(0, 0.1), at(1, 0.2), at(2, 0.5), at(3, 0.9)}
	if got := FractionBelow(in, 0.3); got != 0.5 {
		t.Errorf("fraction = %v", got)
	}
	if got := Median(in); got != 0.35 {
		t.Errorf("median = %v", got)
	}
	if FractionBelow(nil, 0.3) != 0 {
		t.Error("empty")
	}
}
