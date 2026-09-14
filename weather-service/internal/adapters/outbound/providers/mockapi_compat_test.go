package providers_test

import (
	"context"
	"net/http/httptest"
	"testing"
	"time"

	"p9e.in/samavaya/agriculture/internal/mockapi"
	"p9e.in/samavaya/agriculture/weather-service/internal/adapters/outbound/providers"
	"p9e.in/samavaya/agriculture/weather-service/internal/domain"
)

// These tests drive the real provider adapters against the offline mock in
// internal/mockapi.
//
// The point is not that the mock returns JSON — it is that this code accepts
// what the mock returns. A mock written against a remembered API shape drifts
// from the parser consuming it, and the drift stays invisible until someone
// runs the real system against the real upstream, usually in production. If a
// field name in the mock stops matching a struct tag here, these fail.
//
// They also pin the mock's output to physically coherent values. Dew point
// above air temperature, or a minimum above a maximum, is what a mock filling
// each field from an independent random draw produces, and it hides exactly
// the class of bug real data would surface.

// frozen fixes the clock so forecast windows are the same on every run.
var frozen = time.Date(2026, 3, 15, 10, 0, 0, 0, time.UTC)

func mockUpstream(t *testing.T) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(mockapi.New(mockapi.Options{
		Now: func() time.Time { return frozen },
	}).Handler())
	t.Cleanup(srv.Close)
	return srv
}

// A field in the Deccan, which is where the mock's monsoon logic is aimed.
func testLocation() domain.FieldLocation {
	return domain.FieldLocation{
		TenantID:   "t-1",
		FieldID:    "f-1",
		Latitude:   17.385,
		Longitude:  78.4867,
		ElevationM: 542,
	}
}

func openMeteoAgainstMock(t *testing.T) (outboundProvider, *httptest.Server) {
	t.Helper()
	srv := mockUpstream(t)
	return providers.NewOpenMeteo(srv.Client(), srv.URL+"/v1/forecast", srv.URL+"/v1/archive"), srv
}

// outboundProvider is the interface the adapters satisfy, named locally so the
// helpers above can return one without importing the ports package.
type outboundProvider interface {
	Name() domain.Provider
	FetchHourly(context.Context, domain.FieldLocation, time.Time, time.Time) ([]domain.Observation, error)
	FetchDailyForecast(context.Context, domain.FieldLocation, int) ([]domain.DailyForecast, error)
	FetchHistoricalDaily(context.Context, domain.FieldLocation, time.Time, time.Time) ([]domain.DailyAgroMetrics, error)
}

// ── Open-Meteo ──────────────────────────────────────────────────────────────

func TestOpenMeteoAdapterParsesMockHourly(t *testing.T) {
	p, _ := openMeteoAgainstMock(t)

	start := time.Date(2026, 3, 15, 0, 0, 0, 0, time.UTC)
	end := start.Add(47 * time.Hour)

	obs, err := p.FetchHourly(context.Background(), testLocation(), start, end)
	if err != nil {
		t.Fatalf("FetchHourly: %v", err)
	}
	if len(obs) != 48 {
		t.Fatalf("want 48 hourly observations across two days, got %d", len(obs))
	}

	// Each field is checked individually because `at_` returns zero for a
	// column the mock failed to emit — so a test that only asserted the slice
	// was non-empty would pass on a response missing half its variables.
	for i, o := range obs {
		if want := start.Add(time.Duration(i) * time.Hour); !o.ObservedAt.Equal(want) {
			t.Fatalf("observation %d at %s, want %s", i, o.ObservedAt, want)
		}
		if o.TemperatureC < -40 || o.TemperatureC > 55 {
			t.Errorf("observation %d: implausible temperature %.1f", i, o.TemperatureC)
		}
		if o.HumidityPct <= 0 || o.HumidityPct > 100 {
			t.Errorf("observation %d: humidity %.1f out of range", i, o.HumidityPct)
		}
		if o.PressureHPa < 850 || o.PressureHPa > 1100 {
			t.Errorf("observation %d: pressure %.1f out of range", i, o.PressureHPa)
		}
		if o.WindDirectionDeg < 0 || o.WindDirectionDeg > 360 {
			t.Errorf("observation %d: wind direction %.0f out of range", i, o.WindDirectionDeg)
		}
		if o.SoilMoistureM3M3 <= 0 || o.SoilMoistureM3M3 > 1 {
			t.Errorf("observation %d: soil moisture %.3f out of range", i, o.SoilMoistureM3M3)
		}
		if o.DewPointC > o.TemperatureC+0.6 {
			t.Errorf("observation %d: dew point %.1f above temperature %.1f",
				i, o.DewPointC, o.TemperatureC)
		}
		if o.Provider != domain.ProviderOpenMeteo {
			t.Errorf("observation %d: provider %q", i, o.Provider)
		}
	}
}

func TestMockHourlyRadiationFollowsTheSun(t *testing.T) {
	p, _ := openMeteoAgainstMock(t)

	start := time.Date(2026, 3, 15, 0, 0, 0, 0, time.UTC)
	obs, err := p.FetchHourly(context.Background(), testLocation(), start, start.Add(23*time.Hour))
	if err != nil {
		t.Fatalf("FetchHourly: %v", err)
	}
	if len(obs) != 24 {
		t.Fatalf("want 24 observations, got %d", len(obs))
	}

	// A constant would satisfy a range check while making every
	// radiation-dependent calculation downstream meaningless.
	if obs[0].SolarRadiationWM2 != 0 {
		t.Errorf("radiation at 00:00 is %.0f, want darkness", obs[0].SolarRadiationWM2)
	}
	if obs[23].SolarRadiationWM2 != 0 {
		t.Errorf("radiation at 23:00 is %.0f, want darkness", obs[23].SolarRadiationWM2)
	}
	if obs[12].SolarRadiationWM2 < 200 {
		t.Errorf("radiation at midday is %.0f, want a daylight value", obs[12].SolarRadiationWM2)
	}
	// The solar constant is about 1361 W/m². More than that at the surface is
	// a unit error, which is the single most likely mistake in this code.
	for i, o := range obs {
		if o.SolarRadiationWM2 > 1361 {
			t.Errorf("hour %d: radiation %.0f exceeds the solar constant", i, o.SolarRadiationWM2)
		}
	}
}

func TestOpenMeteoAdapterParsesMockDailyForecast(t *testing.T) {
	p, _ := openMeteoAgainstMock(t)

	fc, err := p.FetchDailyForecast(context.Background(), testLocation(), 10)
	if err != nil {
		t.Fatalf("FetchDailyForecast: %v", err)
	}
	// The mock has to honour forecast_days rather than returning a fixed
	// window, or the date arithmetic around this call goes untested.
	if len(fc) != 10 {
		t.Fatalf("asked for 10 days, got %d", len(fc))
	}

	for i, d := range fc {
		if d.TemperatureMinC > d.TemperatureMaxC {
			t.Errorf("day %d: min %.1f above max %.1f", i, d.TemperatureMinC, d.TemperatureMaxC)
		}
		if d.PrecipitationProb < 0 || d.PrecipitationProb > 100 {
			t.Errorf("day %d: precipitation probability %.0f out of range", i, d.PrecipitationProb)
		}
		if d.ET0MM <= 0 || d.ET0MM > 20 {
			t.Errorf("day %d: ET0 %.2f mm implausible", i, d.ET0MM)
		}
		// Condition is derived from the WMO code, so an empty string means the
		// mock emitted a code this service does not recognise.
		if d.Condition == "" {
			t.Errorf("day %d: empty condition; the weather code did not map", i)
		}
	}
}

func TestOpenMeteoAdapterParsesMockArchive(t *testing.T) {
	p, _ := openMeteoAgainstMock(t)

	start := time.Date(2025, 6, 1, 0, 0, 0, 0, time.UTC)
	end := time.Date(2025, 6, 30, 0, 0, 0, 0, time.UTC)

	rows, err := p.FetchHistoricalDaily(context.Background(), testLocation(), start, end)
	if err != nil {
		t.Fatalf("FetchHistoricalDaily: %v", err)
	}
	if len(rows) != 30 {
		t.Fatalf("want the 30 days of June, got %d", len(rows))
	}

	var wet int
	for i, r := range rows {
		if r.GDD < 0 || r.GDD > 30 {
			t.Errorf("day %d: GDD %.1f implausible", i, r.GDD)
		}
		if r.ET0MM <= 0 {
			t.Errorf("day %d: ET0 is %.2f, but the archive response carries one", i, r.ET0MM)
		}
		if r.PrecipitationMM > 0 {
			wet++
		}
	}
	// June in the Deccan is monsoon. If the seasonal weighting were inert this
	// would land near the dry-season rate instead, and a test written against
	// it would never see rain.
	if wet < 10 {
		t.Errorf("only %d of 30 monsoon days were wet; the seasonal weighting is not reaching the output", wet)
	}
}

func TestMockCanWithholdET0SoTheServiceRecomputesIt(t *testing.T) {
	// This service recomputes ET0 itself when the upstream returns zero, which
	// the real API does outside its supported range. Both branches need to be
	// reachable offline, so the mock can be told to withhold it.
	srv := httptest.NewServer(mockapi.New(mockapi.Options{
		Now:     func() time.Time { return frozen },
		OmitET0: true,
	}).Handler())
	defer srv.Close()

	p := providers.NewOpenMeteo(srv.Client(), srv.URL+"/v1/forecast", srv.URL+"/v1/archive")

	start := time.Date(2025, 6, 1, 0, 0, 0, 0, time.UTC)
	rows, err := p.FetchHistoricalDaily(context.Background(), testLocation(), start, start.AddDate(0, 0, 4))
	if err != nil {
		t.Fatalf("FetchHistoricalDaily: %v", err)
	}
	if len(rows) == 0 {
		t.Fatal("no rows returned")
	}
	for i, r := range rows {
		// The value must still be there — computed here rather than read from
		// the response.
		if r.ET0MM <= 0 {
			t.Errorf("day %d: ET0 %.2f; the service should have recomputed it locally", i, r.ET0MM)
		}
	}
}

func TestMockWeatherIsDeterministic(t *testing.T) {
	p, _ := openMeteoAgainstMock(t)

	start := time.Date(2025, 6, 1, 0, 0, 0, 0, time.UTC)
	end := start.AddDate(0, 0, 6)

	first, err := p.FetchHistoricalDaily(context.Background(), testLocation(), start, end)
	if err != nil {
		t.Fatalf("first fetch: %v", err)
	}
	second, err := p.FetchHistoricalDaily(context.Background(), testLocation(), start, end)
	if err != nil {
		t.Fatalf("second fetch: %v", err)
	}
	// Without this, every test that asserts on a weather value is flaky.
	for i := range first {
		if first[i] != second[i] {
			t.Fatalf("day %d differs between two identical requests:\n %+v\n %+v", i, first[i], second[i])
		}
	}

	// And a different place must give different weather, or the coordinates
	// are not reaching the synthesis at all.
	elsewhere := testLocation()
	elsewhere.Latitude, elsewhere.Longitude = 30.73, 76.78 // Chandigarh
	other, err := p.FetchHistoricalDaily(context.Background(), elsewhere, start, end)
	if err != nil {
		t.Fatalf("other location: %v", err)
	}
	same := true
	for i := range first {
		if first[i].TemperatureMeanC != other[i].TemperatureMeanC {
			same = false
			break
		}
	}
	if same {
		t.Error("two locations 1,500 km apart produced identical temperatures")
	}
}

func TestAdapterSurfacesAnInjectedFault(t *testing.T) {
	srv := httptest.NewServer(func() *mockapi.Server {
		s := mockapi.New(mockapi.Options{Now: func() time.Time { return frozen }})
		s.SetFault("openmeteo", &mockapi.Fault{Status: 503})
		return s
	}().Handler())
	defer srv.Close()

	p := providers.NewOpenMeteo(srv.Client(), srv.URL+"/v1/forecast", srv.URL+"/v1/archive")
	// An upstream outage has to reach the caller as an error rather than as an
	// empty-but-successful result, which is how a silently wrong forecast gets
	// stored.
	if _, err := p.FetchDailyForecast(context.Background(), testLocation(), 3); err == nil {
		t.Fatal("the adapter reported success against a failing upstream")
	}
}

// ── OpenWeather ─────────────────────────────────────────────────────────────

func TestOpenWeatherAdapterParsesMockHourly(t *testing.T) {
	srv := mockUpstream(t)
	p := providers.NewOpenWeather(srv.Client(), srv.URL+"/data/3.0/onecall", "mock-key")

	start := frozen.Truncate(time.Hour)
	obs, err := p.FetchHourly(context.Background(), testLocation(), start, start.Add(24*time.Hour))
	if err != nil {
		t.Fatalf("FetchHourly: %v", err)
	}
	if len(obs) == 0 {
		t.Fatal("no observations parsed from the OpenWeather response")
	}
	for i, o := range obs {
		if o.TemperatureC < -40 || o.TemperatureC > 55 {
			t.Errorf("observation %d: implausible temperature %.1f", i, o.TemperatureC)
		}
		if o.Provider != domain.ProviderOpenWeather {
			t.Errorf("observation %d: provider %q", i, o.Provider)
		}
		if o.DewPointC > o.TemperatureC+0.6 {
			t.Errorf("observation %d: dew point %.1f above temperature %.1f",
				i, o.DewPointC, o.TemperatureC)
		}
	}
}

func TestOpenWeatherAdapterParsesMockDailyForecast(t *testing.T) {
	srv := mockUpstream(t)
	p := providers.NewOpenWeather(srv.Client(), srv.URL+"/data/3.0/onecall", "mock-key")

	fc, err := p.FetchDailyForecast(context.Background(), testLocation(), 7)
	if err != nil {
		t.Fatalf("FetchDailyForecast: %v", err)
	}
	if len(fc) == 0 {
		t.Fatal("no forecast days parsed")
	}
	for i, d := range fc {
		if d.TemperatureMinC > d.TemperatureMaxC {
			t.Errorf("day %d: min %.1f above max %.1f", i, d.TemperatureMinC, d.TemperatureMaxC)
		}
		// The adapter reads weather[0].main, which is nested two levels down;
		// an empty condition means that nesting did not survive the round trip.
		if d.Condition == "" {
			t.Errorf("day %d: empty condition; weather[0].main did not arrive", i)
		}
		// pop arrives as a 0–1 fraction and is multiplied by 100 here, so a
		// value of 1 in the output would mean the scaling was dropped.
		if d.PrecipitationProb < 0 || d.PrecipitationProb > 100 {
			t.Errorf("day %d: probability %.0f out of range", i, d.PrecipitationProb)
		}
	}
}

func TestOpenWeatherStillRefusesHistoricalAgainstTheMock(t *testing.T) {
	srv := mockUpstream(t)
	p := providers.NewOpenWeather(srv.Client(), srv.URL+"/data/3.0/onecall", "mock-key")

	// The adapter refuses historical backfill regardless of what the upstream
	// would serve. Running against a mock must not quietly make an unsupported
	// operation look supported.
	start := time.Date(2025, 6, 1, 0, 0, 0, 0, time.UTC)
	if _, err := p.FetchHistoricalDaily(context.Background(), testLocation(), start, start.AddDate(0, 0, 5)); err == nil {
		t.Error("FetchHistoricalDaily succeeded; OpenWeather does not support archive data here")
	}
}
