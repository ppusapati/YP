// Package application contains the weather-service application service.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"sort"
	"sync"
	"time"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/weather-service/internal/domain"
	"p9e.in/samavaya/agriculture/weather-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/weather-service/internal/ports/outbound"
)

const (
	serviceName = "weather-service"
	// EventTopic carries all weather domain events.
	EventTopic = "samavaya.agriculture.weather.events"

	EventLocationRegistered = "agriculture.weather.location.registered"
	EventObservation        = "agriculture.weather.observation"
	EventForecast           = "agriculture.weather.forecast"
	EventAlertTriggered     = "agriculture.weather.alert.triggered"
	EventBackfillCompleted  = "agriculture.weather.backfill.completed"

	maxPageSize     int32 = 500
	defaultPageSize int32 = 50

	observationLookback = 48 * time.Hour
	forecastHorizonDays = 7
	staleObservation    = 2 * time.Hour
	staleForecast       = 6 * time.Hour
	refreshConcurrency  = 4
	maxBackfillYears    = 10
	defaultBackfillYrs  = 5
)

// ProviderResolver picks the upstream provider for a location.
type ProviderResolver interface {
	For(loc domain.FieldLocation) (outbound.WeatherProvider, error)
	Default() domain.Provider
}

// Clock abstracts time for tests.
type Clock func() time.Time

type weatherService struct {
	repo        outbound.WeatherRepository
	providers   ProviderResolver
	pub         outbound.EventPublisher
	fieldClient outbound.FieldClient
	now         Clock
	log         *p9log.Helper
}

// NewWeatherService creates the application-layer WeatherService.
func NewWeatherService(
	repo outbound.WeatherRepository,
	providers ProviderResolver,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	log p9log.Logger,
) inbound.WeatherService {
	return &weatherService{
		repo:        repo,
		providers:   providers,
		pub:         pub,
		fieldClient: fieldClient,
		now:         time.Now,
		log:         p9log.NewHelper(p9log.With(log, "component", "WeatherService")),
	}
}

// ---------------------------------------------------------------------------
// Locations
// ---------------------------------------------------------------------------

func (s *weatherService) RegisterFieldLocation(ctx context.Context, loc *domain.FieldLocation) (*domain.FieldLocation, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if loc.FieldID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if loc.Latitude < -90 || loc.Latitude > 90 || loc.Longitude < -180 || loc.Longitude > 180 {
		return nil, errors.BadRequest("INVALID_COORDINATES", "latitude must be in [-90,90] and longitude in [-180,180]")
	}
	if loc.Timezone == "" {
		loc.Timezone = "UTC"
	} else if _, err := time.LoadLocation(loc.Timezone); err != nil {
		return nil, errors.BadRequest("INVALID_TIMEZONE", fmt.Sprintf("unknown timezone %q", loc.Timezone))
	}
	if loc.Provider == domain.ProviderUnspecified {
		loc.Provider = s.providers.Default()
	}
	loc.TenantID = tenantID
	if loc.CreatedBy = p9context.UserID(ctx); loc.CreatedBy == "" {
		loc.CreatedBy = "system"
	}

	saved, err := s.repo.UpsertFieldLocation(ctx, loc)
	if err != nil {
		return nil, err
	}
	s.emitEvent(ctx, EventLocationRegistered, saved.FieldID, map[string]interface{}{
		"field_id": saved.FieldID, "farm_id": saved.FarmID, "tenant_id": tenantID,
		"latitude": saved.Latitude, "longitude": saved.Longitude, "provider": string(saved.Provider),
	})
	s.log.Infow("msg", "field location registered", "field_id", saved.FieldID, "tenant_id", tenantID)
	return saved, nil
}

func (s *weatherService) RegisterFieldFromFieldService(ctx context.Context, tenantID, fieldID string) (*domain.FieldLocation, error) {
	if tenantID == "" || fieldID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant_id and field_id are required")
	}
	if s.fieldClient == nil {
		return nil, errors.InternalServer("FIELD_CLIENT_UNAVAILABLE", "field-service client not configured")
	}
	ctx = tenantContext(ctx, tenantID)
	lat, lon, farmID, err := s.fieldClient.FieldCentroid(ctx, fieldID)
	if err != nil {
		return nil, fmt.Errorf("resolve field centroid: %w", err)
	}
	return s.RegisterFieldLocation(ctx, &domain.FieldLocation{FieldID: fieldID, FarmID: farmID, Latitude: lat, Longitude: lon})
}

func (s *weatherService) GetFieldLocation(ctx context.Context, fieldID string) (*domain.FieldLocation, error) {
	tenantID, err := requireTenant(ctx)
	if err != nil {
		return nil, err
	}
	if fieldID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	return s.repo.GetFieldLocation(ctx, fieldID, tenantID)
}

func (s *weatherService) ListFieldLocations(ctx context.Context, p domain.ListLocationsParams) ([]domain.FieldLocation, int64, error) {
	tenantID, err := requireTenant(ctx)
	if err != nil {
		return nil, 0, err
	}
	p.TenantID = tenantID
	p.PageSize = clampPage(p.PageSize)
	return s.repo.ListFieldLocations(ctx, p)
}

// ---------------------------------------------------------------------------
// Reads (with lazy refresh)
// ---------------------------------------------------------------------------

func (s *weatherService) GetCurrentWeather(ctx context.Context, fieldID string) (*domain.Observation, error) {
	loc, err := s.GetFieldLocation(ctx, fieldID)
	if err != nil {
		return nil, err
	}
	latest, err := s.repo.GetLatestObservation(ctx, fieldID, loc.TenantID)
	if err != nil {
		return nil, err
	}
	if latest == nil || s.now().Sub(latest.ObservedAt) > staleObservation {
		if _, ferr := s.ingestObservations(ctx, *loc); ferr != nil {
			if latest == nil {
				return nil, errors.InternalServer("PROVIDER_UNAVAILABLE", fmt.Sprintf("no cached weather and provider fetch failed: %v", ferr))
			}
			s.log.Warnw("msg", "provider refresh failed, serving stale observation", "field_id", fieldID, "error", ferr)
			return latest, nil
		}
		if latest, err = s.repo.GetLatestObservation(ctx, fieldID, loc.TenantID); err != nil {
			return nil, err
		}
	}
	if latest == nil {
		return nil, errors.NotFound("NO_OBSERVATIONS", fmt.Sprintf("no observations available for field %s", fieldID))
	}
	return latest, nil
}

func (s *weatherService) GetForecast(ctx context.Context, fieldID string, days int) ([]domain.DailyForecast, error) {
	loc, err := s.GetFieldLocation(ctx, fieldID)
	if err != nil {
		return nil, err
	}
	if days <= 0 {
		days = forecastHorizonDays
	}
	if days > 16 {
		days = 16
	}
	today := startOfDay(s.now())
	fc, err := s.repo.ListForecasts(ctx, fieldID, loc.TenantID, today, days)
	if err != nil {
		return nil, err
	}
	if len(fc) < days || (len(fc) > 0 && s.now().Sub(fc[0].IssuedAt) > staleForecast) {
		if _, ferr := s.ingestForecast(ctx, *loc, days); ferr != nil {
			if len(fc) == 0 {
				return nil, errors.InternalServer("PROVIDER_UNAVAILABLE", fmt.Sprintf("no cached forecast and provider fetch failed: %v", ferr))
			}
			s.log.Warnw("msg", "provider refresh failed, serving stale forecast", "field_id", fieldID, "error", ferr)
			return fc, nil
		}
		if fc, err = s.repo.ListForecasts(ctx, fieldID, loc.TenantID, today, days); err != nil {
			return nil, err
		}
	}
	return fc, nil
}

func (s *weatherService) ListObservations(ctx context.Context, p domain.ListObservationsParams) ([]domain.Observation, int64, error) {
	tenantID, err := requireTenant(ctx)
	if err != nil {
		return nil, 0, err
	}
	if p.FieldID == "" {
		return nil, 0, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	p.TenantID = tenantID
	if p.End.IsZero() {
		p.End = s.now()
	}
	if p.Start.IsZero() {
		p.Start = p.End.Add(-7 * 24 * time.Hour)
	}
	if !p.End.After(p.Start) {
		return nil, 0, errors.BadRequest("INVALID_RANGE", "end must be after start")
	}
	p.PageSize = clampPage(p.PageSize)
	return s.repo.ListObservations(ctx, p)
}

func (s *weatherService) GetAgroMetrics(ctx context.Context, fieldID string, start, end time.Time, baseC, capC float64) ([]domain.DailyAgroMetrics, domain.AgroMetricsSummary, error) {
	loc, err := s.GetFieldLocation(ctx, fieldID)
	if err != nil {
		return nil, domain.AgroMetricsSummary{}, err
	}
	if end.IsZero() {
		end = s.now()
	}
	if start.IsZero() {
		start = end.AddDate(0, 0, -30)
	}
	if !end.After(start) {
		return nil, domain.AgroMetricsSummary{}, errors.BadRequest("INVALID_RANGE", "end must be after start")
	}
	if baseC == 0 {
		baseC = domain.DefaultGDDBaseC
	}
	if capC <= baseC {
		capC = domain.DefaultGDDCapC
	}
	tz, _ := time.LoadLocation(loc.Timezone)
	if tz == nil {
		tz = time.UTC
	}

	stored, err := s.repo.ListDailyMetrics(ctx, fieldID, loc.TenantID, start, end)
	if err != nil {
		return nil, domain.AgroMetricsSummary{}, err
	}
	obs, _, err := s.repo.ListObservations(ctx, domain.ListObservationsParams{TenantID: loc.TenantID, FieldID: fieldID, Start: start, End: end})
	if err != nil {
		return nil, domain.AgroMetricsSummary{}, err
	}
	derived := domain.DeriveDailyMetrics(obs, *loc, tz, baseC, capC)

	// Prefer hourly-derived days; fall back to stored (backfilled) daily rows.
	byDate := make(map[string]domain.DailyAgroMetrics, len(stored)+len(derived))
	for _, d := range stored {
		d.GDD = domain.GrowingDegreeDays(d.TemperatureMinC, d.TemperatureMaxC, baseC, capC)
		byDate[d.Date.Format("2006-01-02")] = d
	}
	for _, d := range derived {
		if d.ObservationCount >= 12 {
			byDate[d.Date.Format("2006-01-02")] = d
		}
	}
	keys := make([]string, 0, len(byDate))
	for k := range byDate {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	daily := make([]domain.DailyAgroMetrics, 0, len(keys))
	for _, k := range keys {
		daily = append(daily, byDate[k])
	}
	return daily, domain.Summarize(daily), nil
}

func (s *weatherService) ListWeatherAlerts(ctx context.Context, p domain.ListAlertsParams) ([]domain.WeatherAlert, int64, error) {
	tenantID, err := requireTenant(ctx)
	if err != nil {
		return nil, 0, err
	}
	p.TenantID = tenantID
	p.Now = s.now()
	p.PageSize = clampPage(p.PageSize)
	return s.repo.ListAlerts(ctx, p)
}

// ---------------------------------------------------------------------------
// Ingestion
// ---------------------------------------------------------------------------

func (s *weatherService) RefreshFieldWeather(ctx context.Context, fieldID string) (int, int, error) {
	loc, err := s.GetFieldLocation(ctx, fieldID)
	if err != nil {
		return 0, 0, err
	}
	return s.refresh(ctx, *loc)
}

func (s *weatherService) refresh(ctx context.Context, loc domain.FieldLocation) (int, int, error) {
	obsCount, err := s.ingestObservations(ctx, loc)
	if err != nil {
		return 0, 0, err
	}
	fcCount, err := s.ingestForecast(ctx, loc, forecastHorizonDays)
	if err != nil {
		return obsCount, 0, err
	}
	if err := s.evaluateAlerts(ctx, loc); err != nil {
		s.log.Warnw("msg", "alert evaluation failed", "field_id", loc.FieldID, "error", err)
	}
	if err := s.repo.TouchLastPolled(ctx, loc.FieldID, loc.TenantID, s.now()); err != nil {
		s.log.Warnw("msg", "failed to update last_polled_at", "field_id", loc.FieldID, "error", err)
	}
	return obsCount, fcCount, nil
}

func (s *weatherService) ingestObservations(ctx context.Context, loc domain.FieldLocation) (int, error) {
	provider, err := s.providers.For(loc)
	if err != nil {
		return 0, err
	}
	now := s.now()
	obs, err := provider.FetchHourly(ctx, loc, now.Add(-observationLookback), now)
	if err != nil {
		return 0, fmt.Errorf("%s: fetch hourly: %w", provider.Name(), err)
	}
	for i := range obs {
		obs[i].TenantID, obs[i].FieldID = loc.TenantID, loc.FieldID
	}
	n, err := s.repo.UpsertObservations(ctx, obs)
	if err != nil {
		return 0, err
	}

	tz, _ := time.LoadLocation(loc.Timezone)
	daily := domain.DeriveDailyMetrics(obs, loc, tz, domain.DefaultGDDBaseC, domain.DefaultGDDCapC)
	if _, err := s.repo.UpsertDailyMetrics(ctx, daily); err != nil {
		return n, err
	}

	if len(obs) > 0 {
		latest := obs[len(obs)-1]
		s.emitEvent(ctx, EventObservation, loc.FieldID, map[string]interface{}{
			"field_id": loc.FieldID, "tenant_id": loc.TenantID, "observed_at": latest.ObservedAt,
			"temperature_c": latest.TemperatureC, "humidity_pct": latest.HumidityPct,
			"precipitation_mm": latest.PrecipitationMM, "wind_speed_ms": latest.WindSpeedMS,
			"provider": string(latest.Provider),
		})
	}
	return n, nil
}

func (s *weatherService) ingestForecast(ctx context.Context, loc domain.FieldLocation, days int) (int, error) {
	provider, err := s.providers.For(loc)
	if err != nil {
		return 0, err
	}
	fc, err := provider.FetchDailyForecast(ctx, loc, days)
	if err != nil {
		return 0, fmt.Errorf("%s: fetch forecast: %w", provider.Name(), err)
	}
	for i := range fc {
		fc[i].TenantID, fc[i].FieldID = loc.TenantID, loc.FieldID
	}
	n, err := s.repo.UpsertForecasts(ctx, fc)
	if err != nil {
		return 0, err
	}
	if len(fc) > 0 {
		var rain float64
		tmin, tmax := fc[0].TemperatureMinC, fc[0].TemperatureMaxC
		for _, f := range fc {
			rain += f.PrecipitationMM
			if f.TemperatureMinC < tmin {
				tmin = f.TemperatureMinC
			}
			if f.TemperatureMaxC > tmax {
				tmax = f.TemperatureMaxC
			}
		}
		s.emitEvent(ctx, EventForecast, loc.FieldID, map[string]interface{}{
			"field_id": loc.FieldID, "tenant_id": loc.TenantID, "days": len(fc),
			"total_precipitation_mm": rain, "temperature_min_c": tmin, "temperature_max_c": tmax,
			"provider": string(fc[0].Provider),
		})
	}
	return n, nil
}

func (s *weatherService) evaluateAlerts(ctx context.Context, loc domain.FieldLocation) error {
	now := s.now()
	fc, err := s.repo.ListForecasts(ctx, loc.FieldID, loc.TenantID, startOfDay(now), forecastHorizonDays)
	if err != nil {
		return err
	}
	candidates := domain.EvaluateForecastAlerts(loc, fc, now)

	daily, err := s.repo.ListDailyMetrics(ctx, loc.FieldID, loc.TenantID, now.AddDate(0, 0, -domain.DroughtDays), now)
	if err != nil {
		return err
	}
	if d := domain.EvaluateDroughtAlert(loc, daily, now); d != nil {
		candidates = append(candidates, *d)
	}

	for _, a := range candidates {
		exists, err := s.repo.AlertExists(ctx, loc.TenantID, loc.FieldID, a.Type, a.ValidFrom)
		if err != nil {
			return err
		}
		if exists {
			continue
		}
		created, err := s.repo.CreateAlert(ctx, &a)
		if err != nil {
			return err
		}
		s.emitEvent(ctx, EventAlertTriggered, created.ID, map[string]interface{}{
			"alert_id": created.ID, "field_id": loc.FieldID, "farm_id": loc.FarmID, "tenant_id": loc.TenantID,
			"alert_type": string(created.Type), "severity": string(created.Severity), "message": created.Message,
			"value": created.Value, "threshold": created.Threshold,
			"valid_from": created.ValidFrom, "valid_to": created.ValidTo,
		})
		s.log.Infow("msg", "weather alert raised", "field_id", loc.FieldID, "type", created.Type, "severity", created.Severity)
	}
	return nil
}

func (s *weatherService) BackfillHistory(ctx context.Context, fieldID string, years int) (int, time.Time, time.Time, error) {
	loc, err := s.GetFieldLocation(ctx, fieldID)
	if err != nil {
		return 0, time.Time{}, time.Time{}, err
	}
	if years <= 0 {
		years = defaultBackfillYrs
	}
	if years > maxBackfillYears {
		years = maxBackfillYears
	}
	provider, err := s.providers.For(*loc)
	if err != nil {
		return 0, time.Time{}, time.Time{}, err
	}

	to := startOfDay(s.now()).AddDate(0, 0, -1)
	from := to.AddDate(-years, 0, 0)
	total := 0
	for chunkStart := from; chunkStart.Before(to); {
		chunkEnd := chunkStart.AddDate(1, 0, 0).AddDate(0, 0, -1)
		if chunkEnd.After(to) {
			chunkEnd = to
		}
		rows, err := provider.FetchHistoricalDaily(ctx, *loc, chunkStart, chunkEnd)
		if err != nil {
			return total, from, to, fmt.Errorf("%s: backfill %s..%s: %w", provider.Name(), chunkStart.Format("2006-01-02"), chunkEnd.Format("2006-01-02"), err)
		}
		for i := range rows {
			rows[i].TenantID, rows[i].FieldID = loc.TenantID, loc.FieldID
		}
		n, err := s.repo.UpsertDailyMetrics(ctx, rows)
		if err != nil {
			return total, from, to, err
		}
		total += n
		chunkStart = chunkEnd.AddDate(0, 0, 1)
	}

	s.emitEvent(ctx, EventBackfillCompleted, loc.FieldID, map[string]interface{}{
		"field_id": loc.FieldID, "tenant_id": loc.TenantID, "days": total, "from": from, "to": to,
	})
	s.log.Infow("msg", "weather backfill completed", "field_id", fieldID, "days", total, "years", years)
	return total, from, to, nil
}

func (s *weatherService) RefreshAll(ctx context.Context) error {
	locs, err := s.repo.ListAllFieldLocations(ctx)
	if err != nil {
		return err
	}
	s.log.Infow("msg", "refreshing weather for registered fields", "count", len(locs))

	sem := make(chan struct{}, refreshConcurrency)
	var wg sync.WaitGroup
	var mu sync.Mutex
	var failures int
	for _, loc := range locs {
		if ctx.Err() != nil {
			break
		}
		wg.Add(1)
		sem <- struct{}{}
		go func(loc domain.FieldLocation) {
			defer wg.Done()
			defer func() { <-sem }()
			tctx := tenantContext(ctx, loc.TenantID)
			err := s.repo.InTenantTx(tctx, loc.TenantID, func(txCtx context.Context, repo outbound.WeatherRepository) error {
				scoped := *s
				scoped.repo = repo
				_, _, err := scoped.refresh(txCtx, loc)
				return err
			})
			if err != nil {
				mu.Lock()
				failures++
				mu.Unlock()
				s.log.Errorw("msg", "field weather refresh failed", "field_id", loc.FieldID, "tenant_id", loc.TenantID, "error", err)
			}
		}(loc)
	}
	wg.Wait()
	if failures > 0 {
		return fmt.Errorf("weather refresh: %d of %d fields failed", failures, len(locs))
	}
	return nil
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func (s *weatherService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
	if s.pub == nil {
		return
	}
	payload := map[string]interface{}{
		"id":             ulid.NewString(),
		"type":           eventType,
		"aggregate_id":   aggregateID,
		"aggregate_type": "weather",
		"source":         serviceName,
		"correlation_id": p9context.RequestID(ctx),
		"timestamp":      s.now(),
		"data":           data,
	}
	raw, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "failed to marshal event", "error", err)
		return
	}
	if err := s.pub.Publish(ctx, EventTopic, aggregateID, raw); err != nil {
		s.log.Errorw("msg", "failed to publish event", "event_type", eventType, "error", err)
	}
}

// tenantContext builds a system-actor context for background and event-driven
// work; TenantID() reads the UserContext, which RPC calls get from the JWT.
func tenantContext(ctx context.Context, tenantID string) context.Context {
	if p9context.TenantID(ctx) != tenantID {
		ctx = p9context.NewUserContext(ctx, p9context.UserContext{UserID: "system", TenantID: tenantID})
	}
	ctx = p9context.NewCurrentTenant(ctx, tenantID, "")
	return p9context.NewRLSScopeTenantOnly(ctx, tenantID)
}

func requireTenant(ctx context.Context) (string, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return "", errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	return tenantID, nil
}

func clampPage(n int32) int32 {
	if n <= 0 {
		return defaultPageSize
	}
	if n > maxPageSize {
		return maxPageSize
	}
	return n
}

func startOfDay(t time.Time) time.Time {
	t = t.UTC()
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC)
}
