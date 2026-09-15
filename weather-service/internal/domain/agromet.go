package domain

import (
	"math"
	"sort"
	"time"
)

// Agronomic thresholds shared by metric derivation and alerting.
const (
	DefaultGDDBaseC   = 10.0
	DefaultGDDCapC    = 30.0
	ChillLowerC       = 0.0
	ChillUpperC       = 7.2
	FrostThresholdC   = 0.0
	HeatStressC       = 35.0
	HeavyRainMMPerDay = 50.0
	HighWindMS        = 15.0
	DroughtDays       = 14
)

// GrowingDegreeDays returns the daily GDD using the capped average method.
// Temperatures above capC are clamped to capC, and the result is never negative.
func GrowingDegreeDays(tmin, tmax, baseC, capC float64) float64 {
	if capC > baseC {
		tmax = math.Min(tmax, capC)
		tmin = math.Min(tmin, capC)
	}
	mean := (tmin + tmax) / 2
	if mean < baseC {
		return 0
	}
	return mean - baseC
}

// ChillHours counts hourly readings whose temperature falls in [ChillLowerC, ChillUpperC].
func ChillHours(hourlyTempsC []float64) float64 {
	var h float64
	for _, t := range hourlyTempsC {
		if t >= ChillLowerC && t <= ChillUpperC {
			h++
		}
	}
	return h
}

// ET0Inputs holds the daily inputs for FAO-56 Penman-Monteith.
type ET0Inputs struct {
	TminC            float64
	TmaxC            float64
	RHMeanPct        float64
	WindSpeed2mMS    float64
	SolarRadiationMJ float64 // incoming shortwave, MJ m-2 day-1
	ElevationM       float64
	LatitudeDeg      float64
	DayOfYear        int
}

// ReferenceET0 computes daily reference evapotranspiration (mm/day) using the
// FAO-56 Penman-Monteith equation. Result is floored at zero.
func ReferenceET0(in ET0Inputs) float64 {
	tmean := (in.TminC + in.TmaxC) / 2

	// Atmospheric pressure (kPa) and psychrometric constant.
	p := 101.3 * math.Pow((293-0.0065*in.ElevationM)/293, 5.26)
	gamma := 0.000665 * p

	// Saturation vapour pressure and slope of the curve.
	esTmax := satVapourPressure(in.TmaxC)
	esTmin := satVapourPressure(in.TminC)
	es := (esTmax + esTmin) / 2
	delta := 4098 * satVapourPressure(tmean) / math.Pow(tmean+237.3, 2)

	// Actual vapour pressure from mean relative humidity.
	rh := clamp(in.RHMeanPct, 0, 100)
	ea := es * rh / 100

	// Net radiation.
	rs := math.Max(in.SolarRadiationMJ, 0)
	ra := extraterrestrialRadiation(in.LatitudeDeg, in.DayOfYear)
	rso := (0.75 + 2e-5*in.ElevationM) * ra
	rns := (1 - 0.23) * rs

	tmaxK := in.TmaxC + 273.16
	tminK := in.TminC + 273.16
	rsRatio := 1.0
	if rso > 0 {
		rsRatio = clamp(rs/rso, 0.3, 1)
	}
	rnl := 4.903e-9 * ((math.Pow(tmaxK, 4) + math.Pow(tminK, 4)) / 2) *
		(0.34 - 0.14*math.Sqrt(math.Max(ea, 0))) *
		(1.35*rsRatio - 0.35)
	rn := rns - rnl

	u2 := math.Max(in.WindSpeed2mMS, 0)
	g := 0.0 // daily soil heat flux is negligible

	num := 0.408*delta*(rn-g) + gamma*(900/(tmean+273))*u2*(es-ea)
	den := delta + gamma*(1+0.34*u2)
	if den == 0 {
		return 0
	}
	return math.Max(num/den, 0)
}

// Wind10mTo2m converts a 10 m wind speed to the 2 m height FAO-56 expects.
func Wind10mTo2m(u10 float64) float64 {
	return u10 * 4.87 / math.Log(67.8*10-5.42)
}

// WattsToMJPerDay converts a mean W/m2 flux over a day to MJ m-2 day-1.
func WattsToMJPerDay(meanWM2 float64) float64 {
	return meanWM2 * 0.0864
}

// RainfallDeficit returns ET0 minus precipitation, floored at zero.
func RainfallDeficit(et0MM, precipMM float64) float64 {
	return math.Max(et0MM-precipMM, 0)
}

// DeriveDailyMetrics groups hourly observations by local calendar day and
// computes GDD, ET0, chill hours, and rainfall deficit for each day.
func DeriveDailyMetrics(obs []Observation, loc FieldLocation, tz *time.Location, baseC, capC float64) []DailyAgroMetrics {
	if tz == nil {
		tz = time.UTC
	}
	if capC <= baseC {
		capC = DefaultGDDCapC
	}

	type bucket struct {
		date   time.Time
		temps  []float64
		rh     []float64
		wind   []float64
		solar  []float64
		precip float64
	}
	buckets := map[string]*bucket{}
	for _, o := range obs {
		local := o.ObservedAt.In(tz)
		day := time.Date(local.Year(), local.Month(), local.Day(), 0, 0, 0, 0, tz)
		key := day.Format("2006-01-02")
		b, ok := buckets[key]
		if !ok {
			b = &bucket{date: day}
			buckets[key] = b
		}
		b.temps = append(b.temps, o.TemperatureC)
		b.rh = append(b.rh, o.HumidityPct)
		b.wind = append(b.wind, o.WindSpeedMS)
		b.solar = append(b.solar, o.SolarRadiationWM2)
		b.precip += o.PrecipitationMM
	}

	keys := make([]string, 0, len(buckets))
	for k := range buckets {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	out := make([]DailyAgroMetrics, 0, len(keys))
	for _, k := range keys {
		b := buckets[k]
		tmin, tmax, tmean := minMaxMean(b.temps)
		rh := mean(b.rh)
		wind := mean(b.wind)
		solarMJ := WattsToMJPerDay(mean(b.solar))

		et0 := ReferenceET0(ET0Inputs{
			TminC:            tmin,
			TmaxC:            tmax,
			RHMeanPct:        rh,
			WindSpeed2mMS:    Wind10mTo2m(wind),
			SolarRadiationMJ: solarMJ,
			ElevationM:       loc.ElevationM,
			LatitudeDeg:      loc.Latitude,
			DayOfYear:        b.date.YearDay(),
		})

		out = append(out, DailyAgroMetrics{
			TenantID:          loc.TenantID,
			FieldID:           loc.FieldID,
			Date:              b.date,
			TemperatureMinC:   tmin,
			TemperatureMaxC:   tmax,
			TemperatureMeanC:  tmean,
			PrecipitationMM:   b.precip,
			HumidityMeanPct:   rh,
			WindSpeedMeanMS:   wind,
			SolarRadiationMJ:  solarMJ,
			GDD:               GrowingDegreeDays(tmin, tmax, baseC, capC),
			ET0MM:             et0,
			ChillHours:        ChillHours(b.temps),
			RainfallDeficitMM: RainfallDeficit(et0, b.precip),
			ObservationCount:  len(b.temps),
		})
	}
	return out
}

// Summarize aggregates daily metrics over the range.
func Summarize(daily []DailyAgroMetrics) AgroMetricsSummary {
	var s AgroMetricsSummary
	for _, d := range daily {
		s.CumulativeGDD += d.GDD
		s.CumulativeET0MM += d.ET0MM
		s.CumulativePrecipitationMM += d.PrecipitationMM
		s.CumulativeChillHours += d.ChillHours
		s.CumulativeDeficitMM += d.RainfallDeficitMM
		s.Days++
		if d.TemperatureMinC <= FrostThresholdC {
			s.FrostDays++
		}
		if d.TemperatureMaxC >= HeatStressC {
			s.HeatStressDays++
		}
	}
	return s
}

// EvaluateForecastAlerts inspects forecasts and returns alerts for hazardous days.
// It does not deduplicate; callers decide whether an equivalent alert already exists.
func EvaluateForecastAlerts(loc FieldLocation, forecasts []DailyForecast, now time.Time) []WeatherAlert {
	var alerts []WeatherAlert
	mk := func(t AlertType, sev Severity, msg string, value, threshold float64, day time.Time) WeatherAlert {
		return WeatherAlert{
			TenantID:  loc.TenantID,
			FieldID:   loc.FieldID,
			Type:      t,
			Severity:  sev,
			Message:   msg,
			Value:     value,
			Threshold: threshold,
			ValidFrom: day,
			ValidTo:   day.Add(24 * time.Hour),
			CreatedAt: now,
		}
	}

	dryStreak := 0
	for _, f := range forecasts {
		day := f.ForecastDate
		if f.TemperatureMinC <= FrostThresholdC {
			sev := SeverityWarning
			if f.TemperatureMinC <= -2 {
				sev = SeverityCritical
			}
			alerts = append(alerts, mk(AlertTypeFrost, sev, "Frost expected: minimum temperature at or below freezing", f.TemperatureMinC, FrostThresholdC, day))
		}
		if f.TemperatureMaxC >= HeatStressC {
			sev := SeverityWarning
			if f.TemperatureMaxC >= 40 {
				sev = SeverityCritical
			}
			alerts = append(alerts, mk(AlertTypeHeatStress, sev, "Heat stress expected: maximum temperature above crop tolerance", f.TemperatureMaxC, HeatStressC, day))
		}
		if f.PrecipitationMM >= HeavyRainMMPerDay {
			sev := SeverityWarning
			if f.PrecipitationMM >= 100 {
				sev = SeverityCritical
			}
			alerts = append(alerts, mk(AlertTypeHeavyRainfall, sev, "Heavy rainfall expected", f.PrecipitationMM, HeavyRainMMPerDay, day))
		}
		if f.WindSpeedMaxMS >= HighWindMS {
			alerts = append(alerts, mk(AlertTypeHighWind, SeverityWarning, "High winds expected", f.WindSpeedMaxMS, HighWindMS, day))
		}
		if f.PrecipitationMM < 1 {
			dryStreak++
		} else {
			dryStreak = 0
		}
	}
	return alerts
}

// EvaluateDroughtAlert raises a drought alert when the trailing window has
// negligible rainfall and a sustained deficit.
func EvaluateDroughtAlert(loc FieldLocation, daily []DailyAgroMetrics, now time.Time) *WeatherAlert {
	if len(daily) < DroughtDays {
		return nil
	}
	window := daily[len(daily)-DroughtDays:]
	var rain, deficit float64
	for _, d := range window {
		rain += d.PrecipitationMM
		deficit += d.RainfallDeficitMM
	}
	if rain >= 10 {
		return nil
	}
	return &WeatherAlert{
		TenantID:  loc.TenantID,
		FieldID:   loc.FieldID,
		Type:      AlertTypeDrought,
		Severity:  SeverityWarning,
		Message:   "Drought conditions: negligible rainfall over the trailing two weeks",
		Value:     deficit,
		Threshold: 10,
		ValidFrom: window[0].Date,
		ValidTo:   now.Add(24 * time.Hour),
		CreatedAt: now,
	}
}

// --------------------------------------------------------------------------
// Helpers
// --------------------------------------------------------------------------

func satVapourPressure(tC float64) float64 {
	return 0.6108 * math.Exp(17.27*tC/(tC+237.3))
}

func extraterrestrialRadiation(latDeg float64, doy int) float64 {
	const gsc = 0.0820 // MJ m-2 min-1
	lat := latDeg * math.Pi / 180
	dr := 1 + 0.033*math.Cos(2*math.Pi/365*float64(doy))
	decl := 0.409 * math.Sin(2*math.Pi/365*float64(doy)-1.39)
	x := -math.Tan(lat) * math.Tan(decl)
	x = clamp(x, -1, 1)
	ws := math.Acos(x)
	return 24 * 60 / math.Pi * gsc * dr *
		(ws*math.Sin(lat)*math.Sin(decl) + math.Cos(lat)*math.Cos(decl)*math.Sin(ws))
}

func clamp(v, lo, hi float64) float64 {
	return math.Max(lo, math.Min(hi, v))
}

func mean(xs []float64) float64 {
	if len(xs) == 0 {
		return 0
	}
	var s float64
	for _, x := range xs {
		s += x
	}
	return s / float64(len(xs))
}

func minMaxMean(xs []float64) (lo, hi, avg float64) {
	if len(xs) == 0 {
		return 0, 0, 0
	}
	lo, hi = xs[0], xs[0]
	var s float64
	for _, x := range xs {
		lo = math.Min(lo, x)
		hi = math.Max(hi, x)
		s += x
	}
	return lo, hi, s / float64(len(xs))
}
