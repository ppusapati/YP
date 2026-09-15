// Package postgres implements the outbound.WeatherRepository port using pgx.
package postgres

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/weather-service/internal/domain"
	"p9e.in/samavaya/agriculture/weather-service/internal/ports/outbound"
)

type weatherRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx
}

// NewWeatherRepository creates a new postgres-backed WeatherRepository.
func NewWeatherRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.WeatherRepository {
	return &weatherRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "WeatherPostgresRepository")),
	}
}

func (r *weatherRepository) withTx(tx pgx.Tx) *weatherRepository {
	return &weatherRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *weatherRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *weatherRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.pool.Query(ctx, sql, args...)
}

func (r *weatherRepository) exec(ctx context.Context, sql string, args ...any) (int64, error) {
	if r.tx != nil {
		tag, err := r.tx.Exec(ctx, sql, args...)
		return tag.RowsAffected(), err
	}
	tag, err := r.pool.Exec(ctx, sql, args...)
	return tag.RowsAffected(), err
}

func (r *weatherRepository) sendBatch(ctx context.Context, b *pgx.Batch) (int, error) {
	var br pgx.BatchResults
	if r.tx != nil {
		br = r.tx.SendBatch(ctx, b)
	} else {
		br = r.pool.SendBatch(ctx, b)
	}
	defer br.Close()
	n := 0
	for i := 0; i < b.Len(); i++ {
		tag, err := br.Exec()
		if err != nil {
			return n, err
		}
		n += int(tag.RowsAffected())
	}
	return n, nil
}

func (r *weatherRepository) InTenantTx(ctx context.Context, tenantID string, fn func(ctx context.Context, repo outbound.WeatherRepository) error) error {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tenant tx: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	if _, err := tx.Exec(ctx, "SELECT set_config('app.tenant_id', $1, true)", tenantID); err != nil {
		return fmt.Errorf("set tenant: %w", err)
	}
	if err := fn(ctx, r.withTx(tx)); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

func dbErr(r *weatherRepository, err error) error {
	r.log.Errorw("msg", "db error", "error", err)
	return p9errors.InternalServer("DB_ERROR", "an internal error occurred")
}

// ---------------------------------------------------------------------------
// Field locations
// ---------------------------------------------------------------------------

const locationCols = `id, tenant_id, field_id, COALESCE(farm_id,''), latitude, longitude, elevation_m, timezone, provider, last_polled_at, created_by, created_at, updated_at`

func scanLocation(row pgx.Row) (*domain.FieldLocation, error) {
	var l domain.FieldLocation
	var provider string
	if err := row.Scan(&l.ID, &l.TenantID, &l.FieldID, &l.FarmID, &l.Latitude, &l.Longitude, &l.ElevationM, &l.Timezone, &provider, &l.LastPolledAt, &l.CreatedBy, &l.CreatedAt, &l.UpdatedAt); err != nil {
		return nil, err
	}
	l.Provider = domain.Provider(provider)
	return &l, nil
}

func (r *weatherRepository) UpsertFieldLocation(ctx context.Context, loc *domain.FieldLocation) (*domain.FieldLocation, error) {
	if loc.ID == "" {
		loc.ID = ulid.NewString()
	}
	var farmID *string
	if loc.FarmID != "" {
		farmID = &loc.FarmID
	}
	row := r.queryRow(ctx, `
		INSERT INTO field_locations (id, tenant_id, field_id, farm_id, latitude, longitude, elevation_m, timezone, provider, created_by)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
		ON CONFLICT (tenant_id, field_id) DO UPDATE SET
			farm_id = COALESCE(EXCLUDED.farm_id, field_locations.farm_id),
			latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude,
			elevation_m = EXCLUDED.elevation_m, timezone = EXCLUDED.timezone,
			provider = EXCLUDED.provider, updated_at = NOW()
		RETURNING `+locationCols,
		loc.ID, loc.TenantID, loc.FieldID, farmID, loc.Latitude, loc.Longitude, loc.ElevationM, loc.Timezone, string(loc.Provider), loc.CreatedBy)
	out, err := scanLocation(row)
	if err != nil {
		return nil, dbErr(r, err)
	}
	return out, nil
}

func (r *weatherRepository) GetFieldLocation(ctx context.Context, fieldID, tenantID string) (*domain.FieldLocation, error) {
	row := r.queryRow(ctx, `SELECT `+locationCols+` FROM field_locations WHERE field_id=$1 AND tenant_id=$2`, fieldID, tenantID)
	out, err := scanLocation(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("FIELD_LOCATION_NOT_FOUND", fmt.Sprintf("no weather location registered for field %s", fieldID))
		}
		return nil, dbErr(r, err)
	}
	return out, nil
}

func (r *weatherRepository) ListFieldLocations(ctx context.Context, p domain.ListLocationsParams) ([]domain.FieldLocation, int64, error) {
	var total int64
	if err := r.queryRow(ctx,
		`SELECT COUNT(*) FROM field_locations WHERE tenant_id=$1 AND ($2='' OR farm_id=$2)`,
		p.TenantID, p.FarmID).Scan(&total); err != nil {
		return nil, 0, dbErr(r, err)
	}
	rows, err := r.query(ctx,
		`SELECT `+locationCols+` FROM field_locations WHERE tenant_id=$1 AND ($2='' OR farm_id=$2)
		 ORDER BY created_at DESC LIMIT $3 OFFSET $4`,
		p.TenantID, p.FarmID, p.PageSize, p.PageOffset)
	if err != nil {
		return nil, 0, dbErr(r, err)
	}
	defer rows.Close()
	var out []domain.FieldLocation
	for rows.Next() {
		l, err := scanLocation(rows)
		if err != nil {
			return nil, 0, dbErr(r, err)
		}
		out = append(out, *l)
	}
	return out, total, rows.Err()
}

func (r *weatherRepository) ListAllFieldLocations(ctx context.Context) ([]domain.FieldLocation, error) {
	rows, err := r.query(ctx, `SELECT `+locationCols+` FROM field_locations ORDER BY last_polled_at NULLS FIRST`)
	if err != nil {
		return nil, dbErr(r, err)
	}
	defer rows.Close()
	var out []domain.FieldLocation
	for rows.Next() {
		l, err := scanLocation(rows)
		if err != nil {
			return nil, dbErr(r, err)
		}
		out = append(out, *l)
	}
	return out, rows.Err()
}

func (r *weatherRepository) TouchLastPolled(ctx context.Context, fieldID, tenantID string, at time.Time) error {
	_, err := r.exec(ctx, `UPDATE field_locations SET last_polled_at=$1, updated_at=NOW() WHERE field_id=$2 AND tenant_id=$3`, at, fieldID, tenantID)
	return err
}

// ---------------------------------------------------------------------------
// Observations
// ---------------------------------------------------------------------------

const observationCols = `id, tenant_id, field_id, observed_at, COALESCE(temperature_c,0), COALESCE(humidity_pct,0), precipitation_mm,
	COALESCE(wind_speed_ms,0), COALESCE(wind_direction_deg,0), COALESCE(pressure_hpa,0), COALESCE(solar_radiation_wm2,0),
	COALESCE(cloud_cover_pct,0), COALESCE(dew_point_c,0), COALESCE(soil_temperature_c,0), COALESCE(soil_moisture_m3m3,0), provider`

func scanObservation(row pgx.Row) (*domain.Observation, error) {
	var o domain.Observation
	var provider string
	if err := row.Scan(&o.ID, &o.TenantID, &o.FieldID, &o.ObservedAt, &o.TemperatureC, &o.HumidityPct, &o.PrecipitationMM,
		&o.WindSpeedMS, &o.WindDirectionDeg, &o.PressureHPa, &o.SolarRadiationWM2, &o.CloudCoverPct, &o.DewPointC,
		&o.SoilTemperatureC, &o.SoilMoistureM3M3, &provider); err != nil {
		return nil, err
	}
	o.Provider = domain.Provider(provider)
	return &o, nil
}

func (r *weatherRepository) UpsertObservations(ctx context.Context, obs []domain.Observation) (int, error) {
	if len(obs) == 0 {
		return 0, nil
	}
	b := &pgx.Batch{}
	for _, o := range obs {
		id := o.ID
		if id == "" {
			id = ulid.NewString()
		}
		b.Queue(`
			INSERT INTO weather_observations (id, tenant_id, field_id, observed_at, temperature_c, humidity_pct, precipitation_mm,
				wind_speed_ms, wind_direction_deg, pressure_hpa, solar_radiation_wm2, cloud_cover_pct, dew_point_c,
				soil_temperature_c, soil_moisture_m3m3, provider)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
			ON CONFLICT (tenant_id, field_id, observed_at) DO UPDATE SET
				temperature_c=EXCLUDED.temperature_c, humidity_pct=EXCLUDED.humidity_pct, precipitation_mm=EXCLUDED.precipitation_mm,
				wind_speed_ms=EXCLUDED.wind_speed_ms, wind_direction_deg=EXCLUDED.wind_direction_deg, pressure_hpa=EXCLUDED.pressure_hpa,
				solar_radiation_wm2=EXCLUDED.solar_radiation_wm2, cloud_cover_pct=EXCLUDED.cloud_cover_pct, dew_point_c=EXCLUDED.dew_point_c,
				soil_temperature_c=EXCLUDED.soil_temperature_c, soil_moisture_m3m3=EXCLUDED.soil_moisture_m3m3, provider=EXCLUDED.provider`,
			id, o.TenantID, o.FieldID, o.ObservedAt.UTC(), o.TemperatureC, o.HumidityPct, o.PrecipitationMM,
			o.WindSpeedMS, o.WindDirectionDeg, o.PressureHPa, o.SolarRadiationWM2, o.CloudCoverPct, o.DewPointC,
			o.SoilTemperatureC, o.SoilMoistureM3M3, string(o.Provider))
	}
	n, err := r.sendBatch(ctx, b)
	if err != nil {
		return n, dbErr(r, err)
	}
	return n, nil
}

func (r *weatherRepository) GetLatestObservation(ctx context.Context, fieldID, tenantID string) (*domain.Observation, error) {
	row := r.queryRow(ctx, `SELECT `+observationCols+` FROM weather_observations
		WHERE field_id=$1 AND tenant_id=$2 AND observed_at <= NOW() ORDER BY observed_at DESC LIMIT 1`, fieldID, tenantID)
	o, err := scanObservation(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, dbErr(r, err)
	}
	return o, nil
}

func (r *weatherRepository) ListObservations(ctx context.Context, p domain.ListObservationsParams) ([]domain.Observation, int64, error) {
	var total int64
	if err := r.queryRow(ctx,
		`SELECT COUNT(*) FROM weather_observations WHERE tenant_id=$1 AND field_id=$2 AND observed_at >= $3 AND observed_at < $4`,
		p.TenantID, p.FieldID, p.Start, p.End).Scan(&total); err != nil {
		return nil, 0, dbErr(r, err)
	}
	limit := int64(p.PageSize)
	if limit <= 0 {
		limit = 10000
	}
	rows, err := r.query(ctx, `SELECT `+observationCols+` FROM weather_observations
		WHERE tenant_id=$1 AND field_id=$2 AND observed_at >= $3 AND observed_at < $4
		ORDER BY observed_at ASC LIMIT $5 OFFSET $6`, p.TenantID, p.FieldID, p.Start, p.End, limit, p.PageOffset)
	if err != nil {
		return nil, 0, dbErr(r, err)
	}
	defer rows.Close()
	var out []domain.Observation
	for rows.Next() {
		o, err := scanObservation(rows)
		if err != nil {
			return nil, 0, dbErr(r, err)
		}
		out = append(out, *o)
	}
	return out, total, rows.Err()
}

// ---------------------------------------------------------------------------
// Forecasts
// ---------------------------------------------------------------------------

const forecastCols = `id, tenant_id, field_id, forecast_date, issued_at, COALESCE(temperature_min_c,0), COALESCE(temperature_max_c,0),
	COALESCE(temperature_mean_c,0), precipitation_mm, COALESCE(precipitation_prob,0), COALESCE(humidity_mean_pct,0),
	COALESCE(wind_speed_max_ms,0), COALESCE(solar_radiation_mj,0), COALESCE(et0_mm,0), COALESCE(condition,''), provider`

func scanForecast(row pgx.Row) (*domain.DailyForecast, error) {
	var f domain.DailyForecast
	var provider string
	if err := row.Scan(&f.ID, &f.TenantID, &f.FieldID, &f.ForecastDate, &f.IssuedAt, &f.TemperatureMinC, &f.TemperatureMaxC,
		&f.TemperatureMeanC, &f.PrecipitationMM, &f.PrecipitationProb, &f.HumidityMeanPct, &f.WindSpeedMaxMS,
		&f.SolarRadiationMJ, &f.ET0MM, &f.Condition, &provider); err != nil {
		return nil, err
	}
	f.Provider = domain.Provider(provider)
	return &f, nil
}

func (r *weatherRepository) UpsertForecasts(ctx context.Context, fc []domain.DailyForecast) (int, error) {
	if len(fc) == 0 {
		return 0, nil
	}
	b := &pgx.Batch{}
	for _, f := range fc {
		id := f.ID
		if id == "" {
			id = ulid.NewString()
		}
		b.Queue(`
			INSERT INTO weather_forecasts (id, tenant_id, field_id, forecast_date, issued_at, temperature_min_c, temperature_max_c,
				temperature_mean_c, precipitation_mm, precipitation_prob, humidity_mean_pct, wind_speed_max_ms, solar_radiation_mj,
				et0_mm, condition, provider)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
			ON CONFLICT (tenant_id, field_id, forecast_date) DO UPDATE SET
				issued_at=EXCLUDED.issued_at, temperature_min_c=EXCLUDED.temperature_min_c, temperature_max_c=EXCLUDED.temperature_max_c,
				temperature_mean_c=EXCLUDED.temperature_mean_c, precipitation_mm=EXCLUDED.precipitation_mm,
				precipitation_prob=EXCLUDED.precipitation_prob, humidity_mean_pct=EXCLUDED.humidity_mean_pct,
				wind_speed_max_ms=EXCLUDED.wind_speed_max_ms, solar_radiation_mj=EXCLUDED.solar_radiation_mj,
				et0_mm=EXCLUDED.et0_mm, condition=EXCLUDED.condition, provider=EXCLUDED.provider`,
			id, f.TenantID, f.FieldID, f.ForecastDate.UTC(), f.IssuedAt.UTC(), f.TemperatureMinC, f.TemperatureMaxC,
			f.TemperatureMeanC, f.PrecipitationMM, f.PrecipitationProb, f.HumidityMeanPct, f.WindSpeedMaxMS, f.SolarRadiationMJ,
			f.ET0MM, f.Condition, string(f.Provider))
	}
	n, err := r.sendBatch(ctx, b)
	if err != nil {
		return n, dbErr(r, err)
	}
	return n, nil
}

func (r *weatherRepository) ListForecasts(ctx context.Context, fieldID, tenantID string, from time.Time, days int) ([]domain.DailyForecast, error) {
	rows, err := r.query(ctx, `SELECT `+forecastCols+` FROM weather_forecasts
		WHERE tenant_id=$1 AND field_id=$2 AND forecast_date >= $3::date AND forecast_date < ($3::date + $4::int)
		ORDER BY forecast_date ASC`, tenantID, fieldID, from.UTC(), days)
	if err != nil {
		return nil, dbErr(r, err)
	}
	defer rows.Close()
	var out []domain.DailyForecast
	for rows.Next() {
		f, err := scanForecast(rows)
		if err != nil {
			return nil, dbErr(r, err)
		}
		out = append(out, *f)
	}
	return out, rows.Err()
}

// ---------------------------------------------------------------------------
// Daily metrics
// ---------------------------------------------------------------------------

func (r *weatherRepository) UpsertDailyMetrics(ctx context.Context, rowsIn []domain.DailyAgroMetrics) (int, error) {
	if len(rowsIn) == 0 {
		return 0, nil
	}
	b := &pgx.Batch{}
	for _, d := range rowsIn {
		b.Queue(`
			INSERT INTO weather_daily_metrics (tenant_id, field_id, date, temperature_min_c, temperature_max_c, temperature_mean_c,
				precipitation_mm, humidity_mean_pct, wind_speed_mean_ms, solar_radiation_mj, gdd, et0_mm, chill_hours,
				rainfall_deficit_mm, observation_count, updated_at)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,NOW())
			ON CONFLICT (tenant_id, field_id, date) DO UPDATE SET
				temperature_min_c=EXCLUDED.temperature_min_c, temperature_max_c=EXCLUDED.temperature_max_c,
				temperature_mean_c=EXCLUDED.temperature_mean_c, precipitation_mm=EXCLUDED.precipitation_mm,
				humidity_mean_pct=EXCLUDED.humidity_mean_pct, wind_speed_mean_ms=EXCLUDED.wind_speed_mean_ms,
				solar_radiation_mj=EXCLUDED.solar_radiation_mj, gdd=EXCLUDED.gdd, et0_mm=EXCLUDED.et0_mm,
				chill_hours=EXCLUDED.chill_hours, rainfall_deficit_mm=EXCLUDED.rainfall_deficit_mm,
				observation_count=GREATEST(weather_daily_metrics.observation_count, EXCLUDED.observation_count), updated_at=NOW()`,
			d.TenantID, d.FieldID, d.Date.UTC(), d.TemperatureMinC, d.TemperatureMaxC, d.TemperatureMeanC,
			d.PrecipitationMM, d.HumidityMeanPct, d.WindSpeedMeanMS, d.SolarRadiationMJ, d.GDD, d.ET0MM, d.ChillHours,
			d.RainfallDeficitMM, d.ObservationCount)
	}
	n, err := r.sendBatch(ctx, b)
	if err != nil {
		return n, dbErr(r, err)
	}
	return n, nil
}

func (r *weatherRepository) ListDailyMetrics(ctx context.Context, fieldID, tenantID string, start, end time.Time) ([]domain.DailyAgroMetrics, error) {
	rows, err := r.query(ctx, `
		SELECT tenant_id, field_id, date, COALESCE(temperature_min_c,0), COALESCE(temperature_max_c,0), COALESCE(temperature_mean_c,0),
			precipitation_mm, COALESCE(humidity_mean_pct,0), COALESCE(wind_speed_mean_ms,0), COALESCE(solar_radiation_mj,0),
			gdd, et0_mm, chill_hours, rainfall_deficit_mm, observation_count
		FROM weather_daily_metrics
		WHERE tenant_id=$1 AND field_id=$2 AND date >= $3::date AND date <= $4::date
		ORDER BY date ASC`, tenantID, fieldID, start.UTC(), end.UTC())
	if err != nil {
		return nil, dbErr(r, err)
	}
	defer rows.Close()
	var out []domain.DailyAgroMetrics
	for rows.Next() {
		var d domain.DailyAgroMetrics
		if err := rows.Scan(&d.TenantID, &d.FieldID, &d.Date, &d.TemperatureMinC, &d.TemperatureMaxC, &d.TemperatureMeanC,
			&d.PrecipitationMM, &d.HumidityMeanPct, &d.WindSpeedMeanMS, &d.SolarRadiationMJ, &d.GDD, &d.ET0MM, &d.ChillHours,
			&d.RainfallDeficitMM, &d.ObservationCount); err != nil {
			return nil, dbErr(r, err)
		}
		out = append(out, d)
	}
	return out, rows.Err()
}

// ---------------------------------------------------------------------------
// Alerts
// ---------------------------------------------------------------------------

const alertCols = `id, tenant_id, field_id, alert_type, severity, message, value, threshold, valid_from, valid_to, created_at`

func scanAlert(row pgx.Row) (*domain.WeatherAlert, error) {
	var a domain.WeatherAlert
	var typ, sev string
	if err := row.Scan(&a.ID, &a.TenantID, &a.FieldID, &typ, &sev, &a.Message, &a.Value, &a.Threshold, &a.ValidFrom, &a.ValidTo, &a.CreatedAt); err != nil {
		return nil, err
	}
	a.Type = domain.AlertType(typ)
	a.Severity = domain.Severity(sev)
	return &a, nil
}

func (r *weatherRepository) CreateAlert(ctx context.Context, a *domain.WeatherAlert) (*domain.WeatherAlert, error) {
	if a.ID == "" {
		a.ID = ulid.NewString()
	}
	row := r.queryRow(ctx, `
		INSERT INTO weather_alerts (id, tenant_id, field_id, alert_type, severity, message, value, threshold, valid_from, valid_to)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
		ON CONFLICT (tenant_id, field_id, alert_type, valid_from) DO UPDATE SET
			severity=EXCLUDED.severity, message=EXCLUDED.message, value=EXCLUDED.value, threshold=EXCLUDED.threshold, valid_to=EXCLUDED.valid_to
		RETURNING `+alertCols,
		a.ID, a.TenantID, a.FieldID, string(a.Type), string(a.Severity), a.Message, a.Value, a.Threshold, a.ValidFrom.UTC(), a.ValidTo.UTC())
	out, err := scanAlert(row)
	if err != nil {
		return nil, dbErr(r, err)
	}
	return out, nil
}

func (r *weatherRepository) AlertExists(ctx context.Context, tenantID, fieldID string, alertType domain.AlertType, validFrom time.Time) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM weather_alerts WHERE tenant_id=$1 AND field_id=$2 AND alert_type=$3 AND valid_from=$4)`,
		tenantID, fieldID, string(alertType), validFrom.UTC()).Scan(&exists)
	if err != nil {
		return false, dbErr(r, err)
	}
	return exists, nil
}

func (r *weatherRepository) ListAlerts(ctx context.Context, p domain.ListAlertsParams) ([]domain.WeatherAlert, int64, error) {
	now := p.Now
	if now.IsZero() {
		now = time.Now()
	}
	where := `tenant_id=$1 AND ($2='' OR field_id=$2) AND (NOT $3::bool OR valid_to >= $4)`
	var total int64
	if err := r.queryRow(ctx, `SELECT COUNT(*) FROM weather_alerts WHERE `+where, p.TenantID, p.FieldID, p.ActiveOnly, now).Scan(&total); err != nil {
		return nil, 0, dbErr(r, err)
	}
	rows, err := r.query(ctx, `SELECT `+alertCols+` FROM weather_alerts WHERE `+where+` ORDER BY valid_from DESC, severity LIMIT $5 OFFSET $6`,
		p.TenantID, p.FieldID, p.ActiveOnly, now, p.PageSize, p.PageOffset)
	if err != nil {
		return nil, 0, dbErr(r, err)
	}
	defer rows.Close()
	var out []domain.WeatherAlert
	for rows.Next() {
		a, err := scanAlert(rows)
		if err != nil {
			return nil, 0, dbErr(r, err)
		}
		out = append(out, *a)
	}
	return out, total, rows.Err()
}
