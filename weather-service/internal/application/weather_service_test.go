package application

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"sync"
	"testing"
	"time"

	"go.uber.org/zap"

	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/weather-service/internal/domain"
	"p9e.in/samavaya/agriculture/weather-service/internal/ports/outbound"
)

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

type fakeRepo struct {
	mu        sync.Mutex
	locations map[string]domain.FieldLocation // key tenant|field
	obs       map[string]domain.Observation   // key tenant|field|time
	forecasts map[string]domain.DailyForecast // key tenant|field|date
	daily     map[string]domain.DailyAgroMetrics
	alerts    []domain.WeatherAlert
	txCalls   []string
}

func newFakeRepo() *fakeRepo {
	return &fakeRepo{
		locations: map[string]domain.FieldLocation{},
		obs:       map[string]domain.Observation{},
		forecasts: map[string]domain.DailyForecast{},
		daily:     map[string]domain.DailyAgroMetrics{},
	}
}

func k(parts ...string) string { return fmt.Sprint(parts) }

func (r *fakeRepo) UpsertFieldLocation(_ context.Context, loc *domain.FieldLocation) (*domain.FieldLocation, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if loc.ID == "" {
		loc.ID = "loc-" + loc.FieldID
	}
	loc.CreatedAt = time.Now()
	r.locations[k(loc.TenantID, loc.FieldID)] = *loc
	return loc, nil
}

func (r *fakeRepo) GetFieldLocation(_ context.Context, fieldID, tenantID string) (*domain.FieldLocation, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	l, ok := r.locations[k(tenantID, fieldID)]
	if !ok {
		return nil, errors.New("not found")
	}
	return &l, nil
}

func (r *fakeRepo) ListFieldLocations(_ context.Context, p domain.ListLocationsParams) ([]domain.FieldLocation, int64, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var out []domain.FieldLocation
	for _, l := range r.locations {
		if l.TenantID == p.TenantID {
			out = append(out, l)
		}
	}
	return out, int64(len(out)), nil
}

func (r *fakeRepo) ListAllFieldLocations(_ context.Context) ([]domain.FieldLocation, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var out []domain.FieldLocation
	for _, l := range r.locations {
		out = append(out, l)
	}
	return out, nil
}

func (r *fakeRepo) TouchLastPolled(_ context.Context, fieldID, tenantID string, at time.Time) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	l := r.locations[k(tenantID, fieldID)]
	l.LastPolledAt = &at
	r.locations[k(tenantID, fieldID)] = l
	return nil
}

func (r *fakeRepo) UpsertObservations(_ context.Context, obs []domain.Observation) (int, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, o := range obs {
		r.obs[k(o.TenantID, o.FieldID, o.ObservedAt.UTC().Format(time.RFC3339))] = o
	}
	return len(obs), nil
}

func (r *fakeRepo) GetLatestObservation(_ context.Context, fieldID, tenantID string) (*domain.Observation, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var latest *domain.Observation
	for _, o := range r.obs {
		o := o
		if o.TenantID == tenantID && o.FieldID == fieldID && (latest == nil || o.ObservedAt.After(latest.ObservedAt)) {
			latest = &o
		}
	}
	return latest, nil
}

func (r *fakeRepo) ListObservations(_ context.Context, p domain.ListObservationsParams) ([]domain.Observation, int64, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var out []domain.Observation
	for _, o := range r.obs {
		if o.TenantID == p.TenantID && o.FieldID == p.FieldID && !o.ObservedAt.Before(p.Start) && o.ObservedAt.Before(p.End) {
			out = append(out, o)
		}
	}
	return out, int64(len(out)), nil
}

func (r *fakeRepo) UpsertForecasts(_ context.Context, fc []domain.DailyForecast) (int, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, f := range fc {
		r.forecasts[k(f.TenantID, f.FieldID, f.ForecastDate.Format("2006-01-02"))] = f
	}
	return len(fc), nil
}

func (r *fakeRepo) ListForecasts(_ context.Context, fieldID, tenantID string, from time.Time, days int) ([]domain.DailyForecast, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var out []domain.DailyForecast
	for _, f := range r.forecasts {
		if f.TenantID == tenantID && f.FieldID == fieldID && !f.ForecastDate.Before(from) && f.ForecastDate.Before(from.AddDate(0, 0, days)) {
			out = append(out, f)
		}
	}
	return out, nil
}

func (r *fakeRepo) UpsertDailyMetrics(_ context.Context, rows []domain.DailyAgroMetrics) (int, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, d := range rows {
		r.daily[k(d.TenantID, d.FieldID, d.Date.Format("2006-01-02"))] = d
	}
	return len(rows), nil
}

func (r *fakeRepo) ListDailyMetrics(_ context.Context, fieldID, tenantID string, start, end time.Time) ([]domain.DailyAgroMetrics, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var out []domain.DailyAgroMetrics
	for _, d := range r.daily {
		if d.TenantID == tenantID && d.FieldID == fieldID && !d.Date.Before(startOfDay(start)) && !d.Date.After(end) {
			out = append(out, d)
		}
	}
	return out, nil
}

func (r *fakeRepo) CreateAlert(_ context.Context, a *domain.WeatherAlert) (*domain.WeatherAlert, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	a.ID = fmt.Sprintf("alert-%d", len(r.alerts)+1)
	r.alerts = append(r.alerts, *a)
	return a, nil
}

func (r *fakeRepo) AlertExists(_ context.Context, tenantID, fieldID string, t domain.AlertType, from time.Time) (bool, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, a := range r.alerts {
		if a.TenantID == tenantID && a.FieldID == fieldID && a.Type == t && a.ValidFrom.Equal(from) {
			return true, nil
		}
	}
	return false, nil
}

func (r *fakeRepo) ListAlerts(_ context.Context, p domain.ListAlertsParams) ([]domain.WeatherAlert, int64, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var out []domain.WeatherAlert
	for _, a := range r.alerts {
		if a.TenantID == p.TenantID && (p.FieldID == "" || a.FieldID == p.FieldID) && (!p.ActiveOnly || !a.ValidTo.Before(p.Now)) {
			out = append(out, a)
		}
	}
	return out, int64(len(out)), nil
}

func (r *fakeRepo) InTenantTx(ctx context.Context, tenantID string, fn func(context.Context, outbound.WeatherRepository) error) error {
	r.mu.Lock()
	r.txCalls = append(r.txCalls, tenantID)
	r.mu.Unlock()
	return fn(ctx, r)
}

type fakeProvider struct {
	name       domain.Provider
	hourly     []domain.Observation
	forecast   []domain.DailyForecast
	historical func(start, end time.Time) []domain.DailyAgroMetrics
	err        error
	calls      int
}

func (p *fakeProvider) Name() domain.Provider { return p.name }
func (p *fakeProvider) FetchHourly(_ context.Context, _ domain.FieldLocation, _, _ time.Time) ([]domain.Observation, error) {
	p.calls++
	return p.hourly, p.err
}
func (p *fakeProvider) FetchDailyForecast(_ context.Context, _ domain.FieldLocation, _ int) ([]domain.DailyForecast, error) {
	p.calls++
	return p.forecast, p.err
}
func (p *fakeProvider) FetchHistoricalDaily(_ context.Context, _ domain.FieldLocation, start, end time.Time) ([]domain.DailyAgroMetrics, error) {
	p.calls++
	if p.err != nil {
		return nil, p.err
	}
	if p.historical == nil {
		return nil, nil
	}
	return p.historical(start, end), nil
}

type fakeResolver struct{ p outbound.WeatherProvider }

func (r fakeResolver) For(domain.FieldLocation) (outbound.WeatherProvider, error) { return r.p, nil }
func (r fakeResolver) Default() domain.Provider                                   { return r.p.Name() }

type fakePub struct {
	mu     sync.Mutex
	events []map[string]interface{}
}

func (p *fakePub) Publish(_ context.Context, _, _ string, payload []byte) error {
	var m map[string]interface{}
	_ = json.Unmarshal(payload, &m)
	p.mu.Lock()
	p.events = append(p.events, m)
	p.mu.Unlock()
	return nil
}

func (p *fakePub) types() []string {
	p.mu.Lock()
	defer p.mu.Unlock()
	var out []string
	for _, e := range p.events {
		out = append(out, e["type"].(string))
	}
	return out
}

type fakeFieldClient struct {
	lat, lon float64
	farm     string
	err      error
}

func (f fakeFieldClient) FieldCentroid(context.Context, string) (float64, float64, string, error) {
	return f.lat, f.lon, f.farm, f.err
}

// ---------------------------------------------------------------------------
// Harness
// ---------------------------------------------------------------------------

var fixedNow = time.Date(2025, 6, 15, 12, 0, 0, 0, time.UTC)

func newSvc(repo *fakeRepo, p *fakeProvider, pub *fakePub, fc outbound.FieldClient) *weatherService {
	logger := p9log.NewLogger(zap.NewNop())
	s := NewWeatherService(repo, fakeResolver{p}, pub, fc, logger).(*weatherService)
	s.now = func() time.Time { return fixedNow }
	return s
}

func tenantCtx(tenant string) context.Context {
	return tenantContext(context.Background(), tenant)
}

func hourlyObs(n int, temp float64) []domain.Observation {
	var out []domain.Observation
	for i := n; i > 0; i-- {
		out = append(out, domain.Observation{ObservedAt: fixedNow.Add(-time.Duration(i) * time.Hour), TemperatureC: temp, HumidityPct: 50, WindSpeedMS: 2, SolarRadiationWM2: 200, Provider: domain.ProviderOpenMeteo})
	}
	return out
}

func forecastDays(n int, tmin, tmax, rain float64) []domain.DailyForecast {
	var out []domain.DailyForecast
	for i := 0; i < n; i++ {
		out = append(out, domain.DailyForecast{ForecastDate: startOfDay(fixedNow).AddDate(0, 0, i), IssuedAt: fixedNow, TemperatureMinC: tmin, TemperatureMaxC: tmax, PrecipitationMM: rain, Provider: domain.ProviderOpenMeteo})
	}
	return out
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

func TestRegisterFieldLocation(t *testing.T) {
	repo, pub := newFakeRepo(), &fakePub{}
	s := newSvc(repo, &fakeProvider{name: domain.ProviderOpenMeteo}, pub, nil)

	loc, err := s.RegisterFieldLocation(tenantCtx("t1"), &domain.FieldLocation{FieldID: "f1", Latitude: 18.5, Longitude: 73.8})
	if err != nil {
		t.Fatal(err)
	}
	if loc.TenantID != "t1" || loc.Provider != domain.ProviderOpenMeteo || loc.Timezone != "UTC" || loc.CreatedBy != "system" {
		t.Errorf("defaults not applied: %+v", loc)
	}
	if got := pub.types(); len(got) != 1 || got[0] != EventLocationRegistered {
		t.Errorf("expected registered event, got %v", got)
	}

	if _, err := s.RegisterFieldLocation(context.Background(), &domain.FieldLocation{FieldID: "f1"}); err == nil {
		t.Error("expected missing tenant error")
	}
	if _, err := s.RegisterFieldLocation(tenantCtx("t1"), &domain.FieldLocation{FieldID: "f1", Latitude: 95}); err == nil {
		t.Error("expected invalid coordinates error")
	}
	if _, err := s.RegisterFieldLocation(tenantCtx("t1"), &domain.FieldLocation{FieldID: "f1", Timezone: "Mars/Olympus"}); err == nil {
		t.Error("expected invalid timezone error")
	}
	if _, err := s.RegisterFieldLocation(tenantCtx("t1"), &domain.FieldLocation{}); err == nil {
		t.Error("expected missing field_id error")
	}
}

func TestRegisterFieldFromFieldService(t *testing.T) {
	repo := newFakeRepo()
	s := newSvc(repo, &fakeProvider{name: domain.ProviderOpenMeteo}, &fakePub{}, fakeFieldClient{lat: 10.5, lon: 76.2, farm: "farm-1"})

	loc, err := s.RegisterFieldFromFieldService(context.Background(), "t9", "f9")
	if err != nil {
		t.Fatal(err)
	}
	if loc.TenantID != "t9" || loc.FarmID != "farm-1" || loc.Latitude != 10.5 || loc.Longitude != 76.2 {
		t.Errorf("unexpected location %+v", loc)
	}

	s2 := newSvc(repo, &fakeProvider{name: domain.ProviderOpenMeteo}, &fakePub{}, fakeFieldClient{err: errors.New("boom")})
	if _, err := s2.RegisterFieldFromFieldService(context.Background(), "t9", "f10"); err == nil {
		t.Error("expected error from field client")
	}
}

func TestRefreshFieldWeather_IngestsAndAlerts(t *testing.T) {
	repo, pub := newFakeRepo(), &fakePub{}
	p := &fakeProvider{name: domain.ProviderOpenMeteo, hourly: hourlyObs(48, 22), forecast: forecastDays(7, -3, 38, 0)}
	s := newSvc(repo, p, pub, nil)
	ctx := tenantCtx("t1")
	if _, err := s.RegisterFieldLocation(ctx, &domain.FieldLocation{FieldID: "f1", Latitude: 18.5, Longitude: 73.8}); err != nil {
		t.Fatal(err)
	}

	obsN, fcN, err := s.RefreshFieldWeather(ctx, "f1")
	if err != nil {
		t.Fatal(err)
	}
	if obsN != 48 || fcN != 7 {
		t.Errorf("counts = %d obs, %d fc; want 48, 7", obsN, fcN)
	}
	if len(repo.daily) != 2 && len(repo.daily) != 3 {
		t.Errorf("expected daily metrics derived for 2-3 days, got %d", len(repo.daily))
	}
	// 7 days × (frost + heat) = 14 alerts, no duplicates
	if len(repo.alerts) != 14 {
		t.Errorf("expected 14 alerts, got %d", len(repo.alerts))
	}
	loc, _ := repo.GetFieldLocation(ctx, "f1", "t1")
	if loc.LastPolledAt == nil || !loc.LastPolledAt.Equal(fixedNow) {
		t.Error("last_polled_at should be set")
	}

	// Second refresh must not duplicate alerts.
	if _, _, err := s.RefreshFieldWeather(ctx, "f1"); err != nil {
		t.Fatal(err)
	}
	if len(repo.alerts) != 14 {
		t.Errorf("alerts duplicated on second refresh: %d", len(repo.alerts))
	}

	types := map[string]int{}
	for _, ty := range pub.types() {
		types[ty]++
	}
	if types[EventObservation] != 2 || types[EventForecast] != 2 || types[EventAlertTriggered] != 14 {
		t.Errorf("unexpected event mix: %v", types)
	}
}

func TestRefreshFieldWeather_ProviderError(t *testing.T) {
	repo := newFakeRepo()
	p := &fakeProvider{name: domain.ProviderOpenMeteo, err: errors.New("upstream 503")}
	s := newSvc(repo, p, &fakePub{}, nil)
	ctx := tenantCtx("t1")
	_, _ = s.RegisterFieldLocation(ctx, &domain.FieldLocation{FieldID: "f1"})

	if _, _, err := s.RefreshFieldWeather(ctx, "f1"); err == nil {
		t.Error("expected provider error to propagate")
	}
}

func TestGetCurrentWeather_LazyRefreshAndStaleFallback(t *testing.T) {
	repo := newFakeRepo()
	p := &fakeProvider{name: domain.ProviderOpenMeteo, hourly: hourlyObs(3, 25)}
	s := newSvc(repo, p, &fakePub{}, nil)
	ctx := tenantCtx("t1")
	_, _ = s.RegisterFieldLocation(ctx, &domain.FieldLocation{FieldID: "f1"})

	obs, err := s.GetCurrentWeather(ctx, "f1")
	if err != nil {
		t.Fatal(err)
	}
	if obs.TemperatureC != 25 || p.calls != 1 {
		t.Errorf("expected lazy fetch, temp=%v calls=%d", obs.TemperatureC, p.calls)
	}

	// Fresh cache: no provider call.
	if _, err := s.GetCurrentWeather(ctx, "f1"); err != nil || p.calls != 1 {
		t.Errorf("expected cache hit, calls=%d err=%v", p.calls, err)
	}

	// Stale cache + provider failure: serve stale.
	s.now = func() time.Time { return fixedNow.Add(5 * time.Hour) }
	p.err = errors.New("down")
	obs, err = s.GetCurrentWeather(ctx, "f1")
	if err != nil || obs == nil {
		t.Errorf("expected stale observation served, got err=%v", err)
	}

	// No cache + provider failure: error.
	_, _ = s.RegisterFieldLocation(ctx, &domain.FieldLocation{FieldID: "f2"})
	if _, err := s.GetCurrentWeather(ctx, "f2"); err == nil {
		t.Error("expected error when no cache and provider down")
	}
}

func TestGetForecast(t *testing.T) {
	repo := newFakeRepo()
	p := &fakeProvider{name: domain.ProviderOpenMeteo, forecast: forecastDays(7, 15, 28, 3)}
	s := newSvc(repo, p, &fakePub{}, nil)
	ctx := tenantCtx("t1")
	_, _ = s.RegisterFieldLocation(ctx, &domain.FieldLocation{FieldID: "f1"})

	fc, err := s.GetForecast(ctx, "f1", 0)
	if err != nil {
		t.Fatal(err)
	}
	if len(fc) != 7 || p.calls != 1 {
		t.Errorf("expected 7-day lazy forecast, got %d calls=%d", len(fc), p.calls)
	}
	if _, err := s.GetForecast(ctx, "f1", 7); err != nil || p.calls != 1 {
		t.Errorf("expected cached forecast, calls=%d", p.calls)
	}
	if _, err := s.GetForecast(ctx, "f1", 10); err != nil || p.calls != 2 {
		t.Errorf("longer horizon should refetch, calls=%d", p.calls)
	}
}

func TestGetAgroMetrics_MergesDerivedAndBackfilled(t *testing.T) {
	repo := newFakeRepo()
	p := &fakeProvider{name: domain.ProviderOpenMeteo}
	s := newSvc(repo, p, &fakePub{}, nil)
	ctx := tenantCtx("t1")
	_, _ = s.RegisterFieldLocation(ctx, &domain.FieldLocation{FieldID: "f1", Latitude: 18.5, Timezone: "UTC"})

	// Backfilled day 10 days ago, and hourly obs yesterday (full day) + today (partial).
	_, _ = repo.UpsertDailyMetrics(ctx, []domain.DailyAgroMetrics{{TenantID: "t1", FieldID: "f1", Date: startOfDay(fixedNow).AddDate(0, 0, -10), TemperatureMinC: 12, TemperatureMaxC: 24, PrecipitationMM: 5, ET0MM: 3}})
	var obs []domain.Observation
	yesterday := startOfDay(fixedNow).AddDate(0, 0, -1)
	for h := 0; h < 24; h++ {
		obs = append(obs, domain.Observation{TenantID: "t1", FieldID: "f1", ObservedAt: yesterday.Add(time.Duration(h) * time.Hour), TemperatureC: 20, HumidityPct: 50, WindSpeedMS: 2, SolarRadiationWM2: 200})
	}
	for h := 0; h < 6; h++ {
		obs = append(obs, domain.Observation{TenantID: "t1", FieldID: "f1", ObservedAt: startOfDay(fixedNow).Add(time.Duration(h) * time.Hour), TemperatureC: 30})
	}
	_, _ = repo.UpsertObservations(ctx, obs)

	daily, summary, err := s.GetAgroMetrics(ctx, "f1", fixedNow.AddDate(0, 0, -30), fixedNow.Add(time.Hour), 0, 0)
	if err != nil {
		t.Fatal(err)
	}
	if len(daily) != 2 {
		t.Fatalf("expected 2 days (backfilled + full hourly day; partial day dropped), got %d", len(daily))
	}
	if daily[0].GDD != 8 {
		t.Errorf("backfilled GDD should be recomputed with base 10: got %v", daily[0].GDD)
	}
	if daily[1].ObservationCount != 24 || daily[1].GDD != 10 {
		t.Errorf("derived day wrong: %+v", daily[1])
	}
	if summary.Days != 2 || summary.CumulativeGDD != 18 {
		t.Errorf("summary wrong: %+v", summary)
	}
}

func TestBackfillHistory_ChunksByYear(t *testing.T) {
	repo := newFakeRepo()
	p := &fakeProvider{name: domain.ProviderOpenMeteo, historical: func(start, end time.Time) []domain.DailyAgroMetrics {
		var out []domain.DailyAgroMetrics
		for d := start; !d.After(end); d = d.AddDate(0, 0, 1) {
			out = append(out, domain.DailyAgroMetrics{Date: d, TemperatureMinC: 10, TemperatureMaxC: 20})
		}
		return out
	}}
	s := newSvc(repo, p, &fakePub{}, nil)
	ctx := tenantCtx("t1")
	_, _ = s.RegisterFieldLocation(ctx, &domain.FieldLocation{FieldID: "f1"})

	days, from, to, err := s.BackfillHistory(ctx, "f1", 2)
	if err != nil {
		t.Fatal(err)
	}
	if p.calls != 2 {
		t.Errorf("expected 2 yearly chunks, got %d calls", p.calls)
	}
	wantTo := startOfDay(fixedNow).AddDate(0, 0, -1)
	if !to.Equal(wantTo) || !from.Equal(wantTo.AddDate(-2, 0, 0)) {
		t.Errorf("range = %v..%v", from, to)
	}
	if days < 729 || days > 731 || len(repo.daily) != days {
		t.Errorf("expected ~730 days ingested, got %d (stored %d)", days, len(repo.daily))
	}
	for _, d := range repo.daily {
		if d.TenantID != "t1" || d.FieldID != "f1" {
			t.Fatal("tenant/field not stamped on backfilled rows")
		}
	}

	if _, _, _, err := s.BackfillHistory(ctx, "f1", 50); err != nil || p.calls != 2+maxBackfillYears {
		t.Errorf("years should be capped at %d, calls=%d err=%v", maxBackfillYears, p.calls, err)
	}
}

func TestRefreshAll_ScopesEachTenant(t *testing.T) {
	repo := newFakeRepo()
	p := &fakeProvider{name: domain.ProviderOpenMeteo, hourly: hourlyObs(2, 20), forecast: forecastDays(2, 15, 25, 0)}
	s := newSvc(repo, p, &fakePub{}, nil)
	_, _ = s.RegisterFieldLocation(tenantCtx("tA"), &domain.FieldLocation{FieldID: "f1"})
	_, _ = s.RegisterFieldLocation(tenantCtx("tB"), &domain.FieldLocation{FieldID: "f2"})
	_, _ = s.RegisterFieldLocation(tenantCtx("tB"), &domain.FieldLocation{FieldID: "f3"})

	if err := s.RefreshAll(context.Background()); err != nil {
		t.Fatal(err)
	}
	if len(repo.txCalls) != 3 {
		t.Errorf("expected one tenant tx per location, got %v", repo.txCalls)
	}
	for _, l := range repo.locations {
		if l.LastPolledAt == nil {
			t.Errorf("field %s not polled", l.FieldID)
		}
	}
	for _, o := range repo.obs {
		if o.TenantID == "" {
			t.Fatal("observation missing tenant")
		}
	}

	p.err = errors.New("down")
	if err := s.RefreshAll(context.Background()); err == nil {
		t.Error("expected aggregated failure error")
	}
}

func TestListWeatherAlerts(t *testing.T) {
	repo := newFakeRepo()
	s := newSvc(repo, &fakeProvider{name: domain.ProviderOpenMeteo}, &fakePub{}, nil)
	_, _ = repo.CreateAlert(context.Background(), &domain.WeatherAlert{TenantID: "t1", FieldID: "f1", Type: domain.AlertTypeFrost, ValidTo: fixedNow.Add(time.Hour)})
	_, _ = repo.CreateAlert(context.Background(), &domain.WeatherAlert{TenantID: "t1", FieldID: "f1", Type: domain.AlertTypeHeatStress, ValidTo: fixedNow.Add(-time.Hour)})
	_, _ = repo.CreateAlert(context.Background(), &domain.WeatherAlert{TenantID: "t2", FieldID: "f1", Type: domain.AlertTypeFrost, ValidTo: fixedNow.Add(time.Hour)})

	all, total, err := s.ListWeatherAlerts(tenantCtx("t1"), domain.ListAlertsParams{FieldID: "f1"})
	if err != nil || total != 2 || len(all) != 2 {
		t.Errorf("expected 2 alerts for t1, got %d err=%v", total, err)
	}
	active, _, _ := s.ListWeatherAlerts(tenantCtx("t1"), domain.ListAlertsParams{FieldID: "f1", ActiveOnly: true})
	if len(active) != 1 || active[0].Type != domain.AlertTypeFrost {
		t.Errorf("expected only active frost alert, got %+v", active)
	}
	if _, _, err := s.ListWeatherAlerts(context.Background(), domain.ListAlertsParams{}); err == nil {
		t.Error("expected missing tenant error")
	}
}

func TestTenantContext(t *testing.T) {
	ctx := tenantContext(context.Background(), "t-42")
	if p9context.TenantID(ctx) != "t-42" {
		t.Error("tenant not set in context")
	}
	if !p9context.HasRLSScope(ctx) {
		t.Error("RLS scope not set in context")
	}
}
