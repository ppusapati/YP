package domain

import (
	"math"
	"testing"
	"time"
)

func TestGrowingDegreeDays(t *testing.T) {
	tests := []struct {
		name       string
		tmin, tmax float64
		want       float64
	}{
		{"typical warm day", 15, 25, 10},
		{"below base", 2, 8, 0},
		{"capped max", 20, 40, 15}, // tmax clamped to 30 -> mean 25
		{"exactly base", 10, 10, 0},
		{"cold night hot day", 5, 30, 7.5},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := GrowingDegreeDays(tt.tmin, tt.tmax, DefaultGDDBaseC, DefaultGDDCapC)
			if math.Abs(got-tt.want) > 1e-9 {
				t.Errorf("GDD = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestChillHours(t *testing.T) {
	temps := []float64{-1, 0, 3.5, 7.2, 7.3, 12, 5}
	if got := ChillHours(temps); got != 4 {
		t.Errorf("ChillHours = %v, want 4", got)
	}
	if got := ChillHours(nil); got != 0 {
		t.Errorf("ChillHours(nil) = %v, want 0", got)
	}
}

// FAO-56 Example 18 (Bangkok, April): expected ET0 ≈ 5.7 mm/day.
func TestReferenceET0_FAO56Example(t *testing.T) {
	et0 := ReferenceET0(ET0Inputs{
		TminC:            25.6,
		TmaxC:            34.8,
		RHMeanPct:        73, // derived from example ea≈2.85 kPa and es≈3.91 kPa
		WindSpeed2mMS:    2.0,
		SolarRadiationMJ: 22.65,
		ElevationM:       2,
		LatitudeDeg:      13.73,
		DayOfYear:        105,
	})
	if et0 < 5.2 || et0 > 6.2 {
		t.Errorf("ET0 = %.2f, want ≈5.7 mm/day", et0)
	}
}

func TestReferenceET0_NeverNegative(t *testing.T) {
	et0 := ReferenceET0(ET0Inputs{
		TminC: -15, TmaxC: -5, RHMeanPct: 95, WindSpeed2mMS: 0,
		SolarRadiationMJ: 0, ElevationM: 500, LatitudeDeg: 60, DayOfYear: 1,
	})
	if et0 < 0 {
		t.Errorf("ET0 should be floored at 0, got %v", et0)
	}
}

func TestReferenceET0_IncreasesWithRadiation(t *testing.T) {
	base := ET0Inputs{TminC: 15, TmaxC: 28, RHMeanPct: 60, WindSpeed2mMS: 2, ElevationM: 100, LatitudeDeg: 20, DayOfYear: 180}
	low := base
	low.SolarRadiationMJ = 10
	high := base
	high.SolarRadiationMJ = 25
	if ReferenceET0(high) <= ReferenceET0(low) {
		t.Error("ET0 should increase with solar radiation")
	}
}

func TestWind10mTo2m(t *testing.T) {
	got := Wind10mTo2m(3.2)
	if math.Abs(got-2.4) > 0.05 {
		t.Errorf("Wind10mTo2m(3.2) = %.2f, want ≈2.4", got)
	}
}

func TestRainfallDeficit(t *testing.T) {
	if got := RainfallDeficit(5, 2); got != 3 {
		t.Errorf("got %v want 3", got)
	}
	if got := RainfallDeficit(2, 5); got != 0 {
		t.Errorf("got %v want 0", got)
	}
}

func TestDeriveDailyMetrics(t *testing.T) {
	loc := FieldLocation{TenantID: "t1", FieldID: "f1", Latitude: 18.5, Longitude: 73.8, ElevationM: 560}
	tz, _ := time.LoadLocation("Asia/Kolkata")
	start := time.Date(2025, 3, 10, 0, 0, 0, 0, tz)

	var obs []Observation
	for h := 0; h < 48; h++ {
		ts := start.Add(time.Duration(h) * time.Hour)
		temp := 18 + 10*math.Sin(float64(h%24)/24*2*math.Pi)
		precip := 0.0
		if h == 30 {
			precip = 12
		}
		obs = append(obs, Observation{
			FieldID: "f1", ObservedAt: ts.UTC(), TemperatureC: temp,
			HumidityPct: 55, WindSpeedMS: 2.5, SolarRadiationWM2: 250, PrecipitationMM: precip,
		})
	}

	daily := DeriveDailyMetrics(obs, loc, tz, DefaultGDDBaseC, DefaultGDDCapC)
	if len(daily) != 2 {
		t.Fatalf("expected 2 days, got %d", len(daily))
	}
	if daily[0].ObservationCount != 24 || daily[1].ObservationCount != 24 {
		t.Errorf("expected 24 obs/day, got %d and %d", daily[0].ObservationCount, daily[1].ObservationCount)
	}
	if daily[0].Date.Day() != 10 || daily[1].Date.Day() != 11 {
		t.Errorf("unexpected day ordering: %v %v", daily[0].Date, daily[1].Date)
	}
	if daily[1].PrecipitationMM != 12 {
		t.Errorf("precip day 2 = %v, want 12", daily[1].PrecipitationMM)
	}
	if daily[0].GDD <= 0 {
		t.Errorf("GDD should be positive for warm day, got %v", daily[0].GDD)
	}
	if daily[0].ET0MM <= 0 || daily[0].ET0MM > 12 {
		t.Errorf("ET0 out of plausible range: %v", daily[0].ET0MM)
	}
	if daily[0].RainfallDeficitMM != daily[0].ET0MM {
		t.Errorf("dry day deficit should equal ET0")
	}
	if daily[1].RainfallDeficitMM != math.Max(daily[1].ET0MM-12, 0) {
		t.Errorf("deficit should subtract precipitation")
	}
}

func TestDeriveDailyMetrics_Empty(t *testing.T) {
	if got := DeriveDailyMetrics(nil, FieldLocation{}, nil, 10, 30); len(got) != 0 {
		t.Errorf("expected empty, got %d", len(got))
	}
}

func TestSummarize(t *testing.T) {
	daily := []DailyAgroMetrics{
		{GDD: 5, ET0MM: 4, PrecipitationMM: 0, ChillHours: 2, RainfallDeficitMM: 4, TemperatureMinC: -1, TemperatureMaxC: 20},
		{GDD: 8, ET0MM: 5, PrecipitationMM: 10, ChillHours: 0, RainfallDeficitMM: 0, TemperatureMinC: 12, TemperatureMaxC: 36},
	}
	s := Summarize(daily)
	if s.Days != 2 || s.CumulativeGDD != 13 || s.CumulativeET0MM != 9 || s.CumulativePrecipitationMM != 10 {
		t.Errorf("unexpected summary %+v", s)
	}
	if s.FrostDays != 1 || s.HeatStressDays != 1 {
		t.Errorf("frost/heat days wrong: %+v", s)
	}
}

func TestEvaluateForecastAlerts(t *testing.T) {
	loc := FieldLocation{TenantID: "t1", FieldID: "f1"}
	now := time.Date(2025, 1, 1, 0, 0, 0, 0, time.UTC)
	fc := []DailyForecast{
		{ForecastDate: now, TemperatureMinC: 5, TemperatureMaxC: 25, PrecipitationMM: 2},
		{ForecastDate: now.Add(24 * time.Hour), TemperatureMinC: -3, TemperatureMaxC: 10},
		{ForecastDate: now.Add(48 * time.Hour), TemperatureMinC: 22, TemperatureMaxC: 41, PrecipitationMM: 120, WindSpeedMaxMS: 20},
	}
	alerts := EvaluateForecastAlerts(loc, fc, now)

	byType := map[AlertType]WeatherAlert{}
	for _, a := range alerts {
		byType[a.Type] = a
	}
	if len(alerts) != 4 {
		t.Fatalf("expected 4 alerts, got %d: %+v", len(alerts), alerts)
	}
	if byType[AlertTypeFrost].Severity != SeverityCritical {
		t.Error("frost at -3 should be critical")
	}
	if byType[AlertTypeHeatStress].Severity != SeverityCritical {
		t.Error("41C should be critical heat")
	}
	if byType[AlertTypeHeavyRainfall].Severity != SeverityCritical {
		t.Error("120mm should be critical rainfall")
	}
	if byType[AlertTypeHighWind].Severity != SeverityWarning {
		t.Error("20 m/s wind should be warning")
	}
	if byType[AlertTypeFrost].FieldID != "f1" || byType[AlertTypeFrost].TenantID != "t1" {
		t.Error("alert should carry field and tenant")
	}
}

func TestEvaluateDroughtAlert(t *testing.T) {
	loc := FieldLocation{TenantID: "t1", FieldID: "f1"}
	now := time.Now()

	var dry []DailyAgroMetrics
	for i := 0; i < DroughtDays; i++ {
		dry = append(dry, DailyAgroMetrics{Date: now.AddDate(0, 0, -DroughtDays+i), PrecipitationMM: 0.2, RainfallDeficitMM: 4})
	}
	if a := EvaluateDroughtAlert(loc, dry, now); a == nil || a.Type != AlertTypeDrought {
		t.Error("expected drought alert for dry window")
	}

	wet := append([]DailyAgroMetrics{}, dry...)
	wet[5].PrecipitationMM = 25
	if a := EvaluateDroughtAlert(loc, wet, now); a != nil {
		t.Error("expected no drought alert after significant rain")
	}

	if a := EvaluateDroughtAlert(loc, dry[:5], now); a != nil {
		t.Error("expected no alert with insufficient history")
	}
}
