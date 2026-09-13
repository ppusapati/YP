// Package timeseries implements vegetation-index time-series analytics:
// cross-sensor harmonization, gap filling, trend fitting, change detection,
// anomaly detection, and phenology extraction.
package timeseries

import (
	"math"
	"sort"
	"strings"
	"time"

	"p9e.in/samavaya/packages/pipeline"
)

// Sample is one vegetation-index observation for a field.
type Sample struct {
	Date   time.Time
	Value  float64
	StdDev float64
	Sensor string
	// Interpolated marks samples synthesized by GapFill.
	Interpolated bool
}

const (
	day = 24 * time.Hour

	// DefaultStep is the regular grid spacing used by GapFill.
	DefaultStep = 5 * day
	// DefaultMaxGap is the longest span GapFill will bridge by interpolation.
	DefaultMaxGap = 45 * day
	// DefaultAnomalyZ is the robust z-score above which a sample is anomalous.
	DefaultAnomalyZ = 3.0
	// DefaultPhenologyThreshold is the amplitude fraction that marks season start/end.
	DefaultPhenologyThreshold = 0.5
	// StressNDVIThreshold marks canopy stress for STRESS_DETECTION summaries.
	StressNDVIThreshold = 0.3
)

// Harmonize maps every sample onto the Sentinel-2 NDVI scale. Landsat OLI
// values use the Roy et al. (2016) OLS coefficients; other sensors are passed
// through unchanged.
func Harmonize(samples []Sample) []Sample {
	out := make([]Sample, len(samples))
	for i, s := range samples {
		out[i] = s
		switch normalizeSensor(s.Sensor) {
		case "LANDSAT8", "LANDSAT9", "LANDSAT":
			out[i].Value = clamp(0.0149+0.9723*s.Value, -1, 1)
		}
	}
	return out
}

func normalizeSensor(s string) string {
	u := strings.ToUpper(strings.NewReplacer("-", "", "_", "", " ", "").Replace(s))
	switch u {
	case "LC08", "L8", "OLI":
		return "LANDSAT8"
	case "LC09", "L9", "OLI2":
		return "LANDSAT9"
	}
	return u
}

// Sorted returns a copy sorted by date with exact-duplicate dates averaged.
func Sorted(samples []Sample) []Sample {
	out := append([]Sample(nil), samples...)
	sort.SliceStable(out, func(i, j int) bool { return out[i].Date.Before(out[j].Date) })
	merged := out[:0]
	for _, s := range out {
		if n := len(merged); n > 0 && merged[n-1].Date.Equal(s.Date) {
			merged[n-1].Value = (merged[n-1].Value + s.Value) / 2
			continue
		}
		merged = append(merged, s)
	}
	return merged
}

// GapFill resamples onto a regular grid starting at the first sample, linearly
// interpolating between neighbours. Grid points inside a gap longer than
// maxGap are dropped rather than invented.
func GapFill(samples []Sample, step, maxGap time.Duration) []Sample {
	src := Sorted(samples)
	if len(src) < 2 {
		return src
	}
	if step <= 0 {
		step = DefaultStep
	}
	if maxGap <= 0 {
		maxGap = DefaultMaxGap
	}

	var out []Sample
	j := 0
	for t := src[0].Date; !t.After(src[len(src)-1].Date); t = t.Add(step) {
		for j+1 < len(src) && !src[j+1].Date.After(t) {
			j++
		}
		if src[j].Date.Equal(t) {
			out = append(out, src[j])
			continue
		}
		if j+1 >= len(src) {
			break
		}
		a, b := src[j], src[j+1]
		if b.Date.Sub(a.Date) > maxGap {
			continue
		}
		frac := float64(t.Sub(a.Date)) / float64(b.Date.Sub(a.Date))
		out = append(out, Sample{
			Date:         t,
			Value:        a.Value + frac*(b.Value-a.Value),
			Sensor:       a.Sensor,
			Interpolated: true,
		})
	}
	// Always retain the final observation so the series ends on real data.
	last := src[len(src)-1]
	if len(out) == 0 || !out[len(out)-1].Date.Equal(last.Date) {
		out = append(out, last)
	}
	return out
}

// Smooth applies a centred moving average of odd window size.
func Smooth(samples []Sample, window int) []Sample {
	if window < 3 || len(samples) < window {
		return append([]Sample(nil), samples...)
	}
	if window%2 == 0 {
		window++
	}
	half := window / 2
	out := make([]Sample, len(samples))
	for i := range samples {
		lo, hi := max(0, i-half), min(len(samples)-1, i+half)
		var sum float64
		for k := lo; k <= hi; k++ {
			sum += samples[k].Value
		}
		out[i] = samples[i]
		out[i].Value = sum / float64(hi-lo+1)
	}
	return out
}

// Trend is a least-squares linear fit over time.
type Trend struct {
	SlopePerDay  float64
	Intercept    float64
	RSquared     float64
	N            int
	Direction    string
	FirstValue   float64
	LastValue    float64
	FittedStart  float64
	FittedEnd    float64
	DeviationPct float64
}

// FitTrend regresses value on days-since-first-sample.
func FitTrend(samples []Sample) Trend {
	src := Sorted(samples)
	t := Trend{N: len(src), Direction: "stable"}
	if len(src) == 0 {
		return t
	}
	t.FirstValue, t.LastValue = src[0].Value, src[len(src)-1].Value
	if len(src) < 2 {
		t.FittedStart, t.FittedEnd = t.FirstValue, t.LastValue
		return t
	}
	xs := make([]float64, len(src))
	ys := make([]float64, len(src))
	for i, s := range src {
		xs[i] = s.Date.Sub(src[0].Date).Hours() / 24
		ys[i] = s.Value
	}
	t.SlopePerDay, t.Intercept, t.RSquared = pipeline.LinearRegression(xs, ys)
	t.FittedStart = t.Intercept
	t.FittedEnd = t.Intercept + t.SlopePerDay*xs[len(xs)-1]
	if t.FittedStart != 0 {
		t.DeviationPct = (t.FittedEnd - t.FittedStart) / math.Abs(t.FittedStart) * 100
	}
	// 0.001 NDVI/day ≈ 0.09 over a 90-day season: below that is noise.
	switch {
	case t.SlopePerDay > 0.001:
		t.Direction = "increasing"
	case t.SlopePerDay < -0.001:
		t.Direction = "decreasing"
	}
	return t
}

// Change compares the series before and after a split date.
type Change struct {
	BeforeMean  float64
	AfterMean   float64
	BeforeStd   float64
	AfterStd    float64
	NBefore     int
	NAfter      int
	Delta       float64
	PctChange   float64
	ZScore      float64
	Significant bool
}

// DetectChange computes a two-sample comparison around splitAt using a
// Welch-style standard error for the z-score.
func DetectChange(samples []Sample, splitAt time.Time) Change {
	var before, after []float64
	for _, s := range Sorted(samples) {
		if s.Date.Before(splitAt) {
			before = append(before, s.Value)
		} else {
			after = append(after, s.Value)
		}
	}
	c := Change{NBefore: len(before), NAfter: len(after)}
	if len(before) == 0 || len(after) == 0 {
		return c
	}
	c.BeforeMean, c.BeforeStd = meanStd(before)
	c.AfterMean, c.AfterStd = meanStd(after)
	c.Delta = c.AfterMean - c.BeforeMean
	if c.BeforeMean != 0 {
		c.PctChange = c.Delta / math.Abs(c.BeforeMean) * 100
	}
	se := math.Sqrt(c.BeforeStd*c.BeforeStd/float64(len(before)) + c.AfterStd*c.AfterStd/float64(len(after)))
	if se < 1e-9 {
		se = 1e-9
	}
	c.ZScore = c.Delta / se
	c.Significant = math.Abs(c.ZScore) >= 1.96 && len(before) >= 2 && len(after) >= 2
	return c
}

// Anomaly is a sample whose residual from the smoothed baseline is extreme.
type Anomaly struct {
	Date     time.Time
	Value    float64
	Expected float64
	ZScore   float64
}

// NDVINoiseFloor is the smallest dispersion used when scoring anomalies;
// residual atmospheric and BRDF effects put per-scene NDVI noise near 0.03.
const NDVINoiseFloor = 0.03

// DetectAnomalies flags isolated spikes or dips: each sample is compared with
// the median of its four nearest neighbours (excluding itself), and residuals
// are scored with a robust z (median / MAD, floored at NDVINoiseFloor).
// Excluding the sample from its own baseline keeps a single contaminated
// scene from masking itself, and the neighbour median keeps it from
// contaminating its neighbours' baselines.
func DetectAnomalies(samples []Sample, zThreshold float64) []Anomaly {
	src := Sorted(samples)
	if len(src) < 5 {
		return nil
	}
	if zThreshold <= 0 {
		zThreshold = DefaultAnomalyZ
	}
	expected := make([]float64, len(src))
	residuals := make([]float64, len(src))
	for i := range src {
		var neigh []float64
		for k := max(0, i-2); k <= min(len(src)-1, i+2); k++ {
			if k != i {
				neigh = append(neigh, src[k].Value)
			}
		}
		expected[i] = median(neigh)
		residuals[i] = src[i].Value - expected[i]
	}
	med := median(residuals)
	dev := make([]float64, len(residuals))
	for i, r := range residuals {
		dev[i] = math.Abs(r - med)
	}
	scale := math.Max(median(dev)*1.4826, NDVINoiseFloor)
	var out []Anomaly
	for i, r := range residuals {
		z := (r - med) / scale
		if math.Abs(z) >= zThreshold {
			out = append(out, Anomaly{Date: src[i].Date, Value: src[i].Value, Expected: expected[i], ZScore: z})
		}
	}
	return out
}

// Phenology describes the growing-season shape of an index curve.
type Phenology struct {
	Detected             bool
	SeasonStart          time.Time
	PeakDate             time.Time
	SeasonEnd            time.Time
	BaseValue            float64
	PeakValue            float64
	Amplitude            float64
	SeasonLengthDays     int
	GreenUpRatePerDay    float64
	SenescenceRatePerDay float64
}

// ExtractPhenology finds season start (SOS), peak (POS), and end (EOS) using
// the amplitude-threshold method: SOS is the first crossing of
// base + threshold*amplitude on the rising limb, EOS the last crossing on the
// falling limb.
func ExtractPhenology(samples []Sample, threshold float64) Phenology {
	src := Smooth(Sorted(samples), 3)
	p := Phenology{}
	if len(src) < 4 {
		return p
	}
	if threshold <= 0 || threshold >= 1 {
		threshold = DefaultPhenologyThreshold
	}

	peakIdx := 0
	for i, s := range src {
		if s.Value > src[peakIdx].Value {
			peakIdx = i
		}
	}
	p.PeakDate = src[peakIdx].Date
	p.PeakValue = src[peakIdx].Value

	minBefore, minAfter := src[0].Value, src[len(src)-1].Value
	for i := 0; i < peakIdx; i++ {
		minBefore = math.Min(minBefore, src[i].Value)
	}
	for i := peakIdx + 1; i < len(src); i++ {
		minAfter = math.Min(minAfter, src[i].Value)
	}
	p.BaseValue = math.Max(minBefore, minAfter)
	p.Amplitude = p.PeakValue - p.BaseValue
	// A season needs a real rise and fall; 0.1 NDVI is the noise floor.
	if p.Amplitude < 0.1 || peakIdx == 0 || peakIdx == len(src)-1 {
		return p
	}
	level := p.BaseValue + threshold*p.Amplitude

	sosIdx := -1
	for i := 1; i <= peakIdx; i++ {
		if src[i-1].Value < level && src[i].Value >= level {
			sosIdx = i
			break
		}
	}
	eosIdx := -1
	for i := len(src) - 2; i >= peakIdx; i-- {
		if src[i+1].Value < level && src[i].Value >= level {
			eosIdx = i
			break
		}
	}
	if sosIdx < 0 || eosIdx < 0 {
		return p
	}

	p.SeasonStart = crossingDate(src[sosIdx-1], src[sosIdx], level)
	p.SeasonEnd = crossingDate(src[eosIdx], src[eosIdx+1], level)
	p.SeasonLengthDays = int(math.Round(p.SeasonEnd.Sub(p.SeasonStart).Hours() / 24))
	if d := p.PeakDate.Sub(p.SeasonStart).Hours() / 24; d > 0 {
		p.GreenUpRatePerDay = (p.PeakValue - level) / d
	}
	if d := p.SeasonEnd.Sub(p.PeakDate).Hours() / 24; d > 0 {
		p.SenescenceRatePerDay = (p.PeakValue - level) / d
	}
	p.Detected = p.SeasonLengthDays > 0
	return p
}

// crossingDate linearly interpolates the date at which the line a→b crosses level.
func crossingDate(a, b Sample, level float64) time.Time {
	if b.Value == a.Value {
		return a.Date
	}
	frac := (level - a.Value) / (b.Value - a.Value)
	frac = clamp(frac, 0, 1)
	return a.Date.Add(time.Duration(frac * float64(b.Date.Sub(a.Date))))
}

// FractionBelow returns the share of samples under the threshold.
func FractionBelow(samples []Sample, threshold float64) float64 {
	if len(samples) == 0 {
		return 0
	}
	n := 0
	for _, s := range samples {
		if s.Value < threshold {
			n++
		}
	}
	return float64(n) / float64(len(samples))
}

// Median returns the median value of the samples.
func Median(samples []Sample) float64 {
	vals := make([]float64, len(samples))
	for i, s := range samples {
		vals[i] = s.Value
	}
	return median(vals)
}

func meanStd(xs []float64) (mean, std float64) {
	if len(xs) == 0 {
		return 0, 0
	}
	for _, x := range xs {
		mean += x
	}
	mean /= float64(len(xs))
	if len(xs) < 2 {
		return mean, 0
	}
	for _, x := range xs {
		std += (x - mean) * (x - mean)
	}
	return mean, math.Sqrt(std / float64(len(xs)-1))
}

func median(xs []float64) float64 {
	if len(xs) == 0 {
		return 0
	}
	s := append([]float64(nil), xs...)
	sort.Float64s(s)
	m := len(s) / 2
	if len(s)%2 == 0 {
		return (s[m-1] + s[m]) / 2
	}
	return s[m]
}

func clamp(v, lo, hi float64) float64 { return math.Max(lo, math.Min(hi, v)) }
