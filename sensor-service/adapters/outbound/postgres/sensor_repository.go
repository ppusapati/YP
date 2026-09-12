// Package postgres implements the outbound.SensorRepository port using pgx.
package postgres

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/sensor-service/internal/domain"
	"p9e.in/samavaya/agriculture/sensor-service/internal/ports/outbound"
)

type sensorRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx
}

// NewSensorRepository creates a new postgres-backed SensorRepository.
func NewSensorRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.SensorRepository {
	return &sensorRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "SensorPostgresRepository")),
	}
}

func (r *sensorRepository) WithTx(tx pgx.Tx) outbound.SensorRepository {
	return &sensorRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *sensorRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *sensorRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.pool.Query(ctx, sql, args...)
}

func (r *sensorRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.pool.Exec(ctx, sql, args...)
	}
	return err
}

// =============================================================================
// Sensor CRUD
// =============================================================================

const sensorColumns = `id, tenant_id, field_id, farm_id, sensor_type, device_id,
	manufacturer, model, firmware_version, latitude, longitude, elevation_m,
	installation_date, last_reading_at, battery_level_pct, signal_strength_dbm,
	status, protocol, reading_interval_seconds, metadata, version,
	is_active, created_by, created_at, updated_by, updated_at`

func scanSensor(row pgx.Row) (*domain.Sensor, error) {
	s := &domain.Sensor{}
	err := row.Scan(
		&s.ID, &s.TenantID, &s.FieldID, &s.FarmID,
		&s.SensorType, &s.DeviceID,
		&s.Manufacturer, &s.Model, &s.FirmwareVersion,
		&s.Latitude, &s.Longitude, &s.ElevationM,
		&s.InstallationDate, &s.LastReadingAt,
		&s.BatteryLevelPct, &s.SignalStrengthDbm,
		&s.Status, &s.Protocol, &s.ReadingIntervalSeconds,
		&s.Metadata, &s.Version,
		&s.IsActive, &s.CreatedBy, &s.CreatedAt,
		&s.UpdatedBy, &s.UpdatedAt,
	)
	return s, err
}

func (r *sensorRepository) CreateSensor(ctx context.Context, entity *domain.Sensor) (*domain.Sensor, error) {
	entity.ID = ulid.NewString()

	query := `
		INSERT INTO sensors (
			id, tenant_id, field_id, farm_id, sensor_type, device_id,
			manufacturer, model, firmware_version,
			latitude, longitude, elevation_m,
			installation_date, battery_level_pct, signal_strength_dbm,
			status, protocol, reading_interval_seconds, metadata,
			version, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6,
			$7, $8, $9,
			$10, $11, $12,
			$13, $14, $15,
			$16, $17, $18, $19,
			1, true, $20, NOW()
		) RETURNING ` + sensorColumns

	row := r.queryRow(ctx, query,
		entity.ID, entity.TenantID, entity.FieldID, entity.FarmID,
		string(entity.SensorType), entity.DeviceID,
		entity.Manufacturer, entity.Model, entity.FirmwareVersion,
		entity.Latitude, entity.Longitude, entity.ElevationM,
		entity.InstallationDate, entity.BatteryLevelPct, entity.SignalStrengthDbm,
		string(entity.Status), string(entity.Protocol), entity.ReadingIntervalSeconds,
		entity.Metadata, entity.CreatedBy,
	)
	result, err := scanSensor(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create sensor", "error", err)
		return nil, errors.Internal("failed to create sensor: %v", err)
	}
	return result, nil
}

func (r *sensorRepository) GetSensorByUUID(ctx context.Context, uuid, tenantID string) (*domain.Sensor, error) {
	query := `SELECT ` + sensorColumns + `
		FROM sensors
		WHERE id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL`

	row := r.queryRow(ctx, query, uuid, tenantID)
	s, err := scanSensor(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor %s not found", uuid))
		}
		r.log.Errorw("msg", "failed to get sensor by UUID", "error", err)
		return nil, errors.Internal("failed to get sensor: %v", err)
	}
	return s, nil
}

func (r *sensorRepository) GetSensorByDeviceID(ctx context.Context, deviceID, tenantID string) (*domain.Sensor, error) {
	query := `SELECT ` + sensorColumns + `
		FROM sensors
		WHERE device_id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL`

	row := r.queryRow(ctx, query, deviceID, tenantID)
	s, err := scanSensor(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor with device_id %s not found", deviceID))
		}
		return nil, errors.Internal("failed to get sensor by device ID: %v", err)
	}
	return s, nil
}

func (r *sensorRepository) ListSensors(ctx context.Context, filter domain.SensorListFilter) ([]domain.Sensor, int32, error) {
	if filter.PageSize <= 0 {
		filter.PageSize = 20
	}
	if filter.PageSize > 100 {
		filter.PageSize = 100
	}

	countQuery := `
		SELECT COUNT(*) FROM sensors
		WHERE tenant_id = $1 AND is_active = true AND deleted_at IS NULL
		AND ($2::varchar = '' OR field_id = $2)
		AND ($3::varchar = '' OR farm_id = $3)
		AND ($4::varchar = '' OR sensor_type = $4)
		AND ($5::varchar = '' OR status = $5)
		AND ($6::varchar = '' OR protocol = $6)`

	var totalCount int32
	err := r.queryRow(ctx, countQuery,
		filter.TenantID, filter.FieldID, filter.FarmID,
		filter.SensorType, filter.Status, filter.Protocol,
	).Scan(&totalCount)
	if err != nil {
		r.log.Errorw("msg", "failed to count sensors", "error", err)
		return nil, 0, errors.Internal("failed to count sensors: %v", err)
	}

	listQuery := `SELECT ` + sensorColumns + `
		FROM sensors
		WHERE tenant_id = $1 AND is_active = true AND deleted_at IS NULL
		AND ($2::varchar = '' OR field_id = $2)
		AND ($3::varchar = '' OR farm_id = $3)
		AND ($4::varchar = '' OR sensor_type = $4)
		AND ($5::varchar = '' OR status = $5)
		AND ($6::varchar = '' OR protocol = $6)
		ORDER BY created_at DESC
		LIMIT $7 OFFSET $8`

	rows, err := r.query(ctx, listQuery,
		filter.TenantID, filter.FieldID, filter.FarmID,
		filter.SensorType, filter.Status, filter.Protocol,
		filter.PageSize, filter.PageOffset,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list sensors", "error", err)
		return nil, 0, errors.Internal("failed to list sensors: %v", err)
	}
	defer rows.Close()

	sensors := make([]domain.Sensor, 0)
	for rows.Next() {
		s, err := scanSensor(rows)
		if err != nil {
			r.log.Errorw("msg", "failed to scan sensor row", "error", err)
			return nil, 0, errors.Internal("failed to scan sensor: %v", err)
		}
		sensors = append(sensors, *s)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.Internal("error iterating sensor rows: %v", err)
	}

	return sensors, totalCount, nil
}

func (r *sensorRepository) UpdateSensor(ctx context.Context, entity *domain.Sensor) (*domain.Sensor, error) {
	query := `
		UPDATE sensors SET
			firmware_version = COALESCE(NULLIF($3, ''), firmware_version),
			latitude = COALESCE($4, latitude),
			longitude = COALESCE($5, longitude),
			elevation_m = COALESCE($6, elevation_m),
			status = COALESCE(NULLIF($7, ''), status),
			protocol = COALESCE(NULLIF($8, ''), protocol),
			reading_interval_seconds = CASE WHEN $9 > 0 THEN $9 ELSE reading_interval_seconds END,
			metadata = COALESCE($10, metadata),
			version = version + 1,
			updated_by = $11,
			updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
		RETURNING ` + sensorColumns

	row := r.queryRow(ctx, query,
		entity.ID, entity.TenantID,
		entity.FirmwareVersion,
		entity.Latitude, entity.Longitude, entity.ElevationM,
		string(entity.Status), string(entity.Protocol),
		entity.ReadingIntervalSeconds,
		entity.Metadata,
		entity.UpdatedBy,
	)
	result, err := scanSensor(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor %s not found", entity.ID))
		}
		r.log.Errorw("msg", "failed to update sensor", "error", err)
		return nil, errors.Internal("failed to update sensor: %v", err)
	}
	return result, nil
}

func (r *sensorRepository) DecommissionSensor(ctx context.Context, uuid, tenantID, userID string) (*domain.Sensor, error) {
	query := `
		UPDATE sensors SET
			status = 'DECOMMISSIONED',
			is_active = false,
			version = version + 1,
			updated_by = $3,
			updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
		RETURNING ` + sensorColumns

	row := r.queryRow(ctx, query, uuid, tenantID, userID)
	result, err := scanSensor(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor %s not found", uuid))
		}
		r.log.Errorw("msg", "failed to decommission sensor", "error", err)
		return nil, errors.Internal("failed to decommission sensor: %v", err)
	}
	return result, nil
}

func (r *sensorRepository) UpdateSensorLastReading(ctx context.Context, uuid, tenantID string, readingTime time.Time, batteryPct, signalDbm *float64) error {
	query := `
		UPDATE sensors SET
			last_reading_at = $3,
			battery_level_pct = COALESCE($4, battery_level_pct),
			signal_strength_dbm = COALESCE($5, signal_strength_dbm),
			updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2`

	if err := r.exec(ctx, query, uuid, tenantID, readingTime, batteryPct, signalDbm); err != nil {
		r.log.Errorw("msg", "failed to update sensor last reading", "error", err)
		return errors.Internal("failed to update sensor last reading: %v", err)
	}
	return nil
}

// =============================================================================
// Sensor Readings
// =============================================================================

const readingColumns = `id, sensor_id, tenant_id, value, unit, recorded_at,
	quality, battery_level_pct, signal_strength_dbm, metadata, created_at`

func scanReading(row pgx.Row) (*domain.SensorReading, error) {
	rd := &domain.SensorReading{}
	err := row.Scan(
		&rd.ID, &rd.SensorID, &rd.TenantID,
		&rd.Value, &rd.Unit, &rd.RecordedAt,
		&rd.Quality, &rd.BatteryLevelPct, &rd.SignalStrengthDbm,
		&rd.Metadata, &rd.CreatedAt,
	)
	return rd, err
}

func (r *sensorRepository) CreateReading(ctx context.Context, reading *domain.SensorReading) (*domain.SensorReading, error) {
	reading.ID = ulid.NewString()

	query := `
		INSERT INTO sensor_readings (
			id, sensor_id, tenant_id, value, unit, recorded_at,
			quality, battery_level_pct, signal_strength_dbm, metadata, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW())
		RETURNING ` + readingColumns

	metadataJSON := reading.Metadata
	if metadataJSON == nil {
		metadataJSON = json.RawMessage("{}")
	}

	row := r.queryRow(ctx, query,
		reading.ID, reading.SensorID, reading.TenantID,
		reading.Value, reading.Unit, reading.RecordedAt,
		string(reading.Quality), reading.BatteryLevelPct, reading.SignalStrengthDbm,
		metadataJSON,
	)
	result, err := scanReading(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create sensor reading", "error", err)
		return nil, errors.Internal("failed to create sensor reading: %v", err)
	}
	return result, nil
}

func (r *sensorRepository) GetLatestReading(ctx context.Context, sensorID, tenantID string) (*domain.SensorReading, error) {
	query := `SELECT ` + readingColumns + `
		FROM sensor_readings
		WHERE sensor_id = $1 AND tenant_id = $2
		ORDER BY recorded_at DESC
		LIMIT 1`

	row := r.queryRow(ctx, query, sensorID, tenantID)
	rd, err := scanReading(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("READING_NOT_FOUND", "no readings found for sensor")
		}
		return nil, errors.Internal("failed to get latest reading: %v", err)
	}
	return rd, nil
}

func (r *sensorRepository) GetReadingHistory(ctx context.Context, sensorID, tenantID string, start, end time.Time, minQuality string, pageSize, pageOffset int32) ([]domain.SensorReading, int32, error) {
	if pageSize <= 0 {
		pageSize = 50
	}
	if pageSize > 1000 {
		pageSize = 1000
	}

	countQuery := `
		SELECT COUNT(*) FROM sensor_readings
		WHERE sensor_id = $1 AND tenant_id = $2
		AND recorded_at >= $3 AND recorded_at <= $4
		AND ($5::varchar = '' OR quality = $5)`

	var totalCount int32
	err := r.queryRow(ctx, countQuery, sensorID, tenantID, start, end, minQuality).Scan(&totalCount)
	if err != nil {
		return nil, 0, errors.Internal("failed to count readings: %v", err)
	}

	listQuery := `SELECT ` + readingColumns + `
		FROM sensor_readings
		WHERE sensor_id = $1 AND tenant_id = $2
		AND recorded_at >= $3 AND recorded_at <= $4
		AND ($5::varchar = '' OR quality = $5)
		ORDER BY recorded_at DESC
		LIMIT $6 OFFSET $7`

	rows, err := r.query(ctx, listQuery, sensorID, tenantID, start, end, minQuality, pageSize, pageOffset)
	if err != nil {
		return nil, 0, errors.Internal("failed to list readings: %v", err)
	}
	defer rows.Close()

	readings := make([]domain.SensorReading, 0)
	for rows.Next() {
		rd, err := scanReading(rows)
		if err != nil {
			return nil, 0, errors.Internal("failed to scan reading row: %v", err)
		}
		readings = append(readings, *rd)
	}

	return readings, totalCount, rows.Err()
}

// =============================================================================
// Sensor Alerts
// =============================================================================

const alertColumns = `id, sensor_id, tenant_id, field_id, sensor_type,
	threshold, actual_value, condition, severity, message,
	acknowledged, acknowledged_by, acknowledged_at,
	is_active, created_by, created_at, updated_by, updated_at`

func scanAlert(row pgx.Row) (*domain.SensorAlert, error) {
	a := &domain.SensorAlert{}
	err := row.Scan(
		&a.ID, &a.SensorID, &a.TenantID,
		&a.FieldID, &a.SensorType,
		&a.Threshold, &a.ActualValue,
		&a.Condition, &a.Severity, &a.Message,
		&a.Acknowledged, &a.AcknowledgedBy, &a.AcknowledgedAt,
		&a.IsActive, &a.CreatedBy, &a.CreatedAt,
		&a.UpdatedBy, &a.UpdatedAt,
	)
	return a, err
}

func (r *sensorRepository) CreateAlert(ctx context.Context, alert *domain.SensorAlert) (*domain.SensorAlert, error) {
	alert.ID = ulid.NewString()

	query := `
		INSERT INTO sensor_alerts (
			id, sensor_id, tenant_id, field_id, sensor_type,
			threshold, actual_value, condition, severity, message,
			acknowledged, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
			false, true, $11, NOW()
		) RETURNING ` + alertColumns

	row := r.queryRow(ctx, query,
		alert.ID, alert.SensorID, alert.TenantID, alert.FieldID,
		string(alert.SensorType),
		alert.Threshold, alert.ActualValue,
		string(alert.Condition), string(alert.Severity), alert.Message,
		alert.CreatedBy,
	)
	result, err := scanAlert(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create alert", "error", err)
		return nil, errors.Internal("failed to create alert: %v", err)
	}
	return result, nil
}

func (r *sensorRepository) ListAlerts(ctx context.Context, filter domain.AlertListFilter) ([]domain.SensorAlert, int32, error) {
	if filter.PageSize <= 0 {
		filter.PageSize = 20
	}
	if filter.PageSize > 100 {
		filter.PageSize = 100
	}

	countQuery := `
		SELECT COUNT(*) FROM sensor_alerts
		WHERE tenant_id = $1 AND is_active = true AND deleted_at IS NULL
		AND ($2::varchar = '' OR sensor_id = $2)
		AND ($3::varchar = '' OR field_id = $3)
		AND ($4::varchar = '' OR severity = $4)
		AND ($5::boolean = false OR acknowledged = false)`

	var totalCount int32
	err := r.queryRow(ctx, countQuery,
		filter.TenantID, filter.SensorID, filter.FieldID,
		filter.Severity, filter.UnacknowledgedOnly,
	).Scan(&totalCount)
	if err != nil {
		return nil, 0, errors.Internal("failed to count alerts: %v", err)
	}

	listQuery := `SELECT ` + alertColumns + `
		FROM sensor_alerts
		WHERE tenant_id = $1 AND is_active = true AND deleted_at IS NULL
		AND ($2::varchar = '' OR sensor_id = $2)
		AND ($3::varchar = '' OR field_id = $3)
		AND ($4::varchar = '' OR severity = $4)
		AND ($5::boolean = false OR acknowledged = false)
		ORDER BY created_at DESC
		LIMIT $6 OFFSET $7`

	rows, err := r.query(ctx, listQuery,
		filter.TenantID, filter.SensorID, filter.FieldID,
		filter.Severity, filter.UnacknowledgedOnly,
		filter.PageSize, filter.PageOffset,
	)
	if err != nil {
		return nil, 0, errors.Internal("failed to list alerts: %v", err)
	}
	defer rows.Close()

	alerts := make([]domain.SensorAlert, 0)
	for rows.Next() {
		a, err := scanAlert(rows)
		if err != nil {
			return nil, 0, errors.Internal("failed to scan alert row: %v", err)
		}
		alerts = append(alerts, *a)
	}

	return alerts, totalCount, rows.Err()
}

func (r *sensorRepository) AcknowledgeAlert(ctx context.Context, uuid, tenantID, userID string) (*domain.SensorAlert, error) {
	query := `
		UPDATE sensor_alerts SET
			acknowledged = true,
			acknowledged_by = $3,
			acknowledged_at = NOW(),
			updated_by = $3,
			updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
		RETURNING ` + alertColumns

	row := r.queryRow(ctx, query, uuid, tenantID, userID)
	a, err := scanAlert(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ALERT_NOT_FOUND", fmt.Sprintf("alert %s not found", uuid))
		}
		return nil, errors.Internal("failed to acknowledge alert: %v", err)
	}
	return a, nil
}

func (r *sensorRepository) GetActiveAlertsForSensor(ctx context.Context, sensorID, tenantID string) ([]domain.SensorAlert, error) {
	query := `SELECT ` + alertColumns + `
		FROM sensor_alerts
		WHERE sensor_id = $1 AND tenant_id = $2
		AND is_active = true AND acknowledged = false AND deleted_at IS NULL
		ORDER BY severity DESC, created_at DESC`

	rows, err := r.query(ctx, query, sensorID, tenantID)
	if err != nil {
		return nil, errors.Internal("failed to get active alerts: %v", err)
	}
	defer rows.Close()

	alerts := make([]domain.SensorAlert, 0)
	for rows.Next() {
		a, err := scanAlert(rows)
		if err != nil {
			return nil, errors.Internal("failed to scan active alert: %v", err)
		}
		alerts = append(alerts, *a)
	}

	return alerts, rows.Err()
}

// =============================================================================
// Sensor Networks
// =============================================================================

const networkColumns = `id, tenant_id, farm_id, name, description, protocol,
	gateway_id, sensor_ids, total_sensors, active_sensors,
	is_active, created_by, created_at, updated_by, updated_at`

func scanNetwork(row pgx.Row) (*domain.SensorNetwork, error) {
	n := &domain.SensorNetwork{}
	err := row.Scan(
		&n.ID, &n.TenantID, &n.FarmID,
		&n.Name, &n.Description, &n.Protocol,
		&n.GatewayID, &n.SensorIDs, &n.TotalSensors, &n.ActiveSensors,
		&n.IsActive, &n.CreatedBy, &n.CreatedAt,
		&n.UpdatedBy, &n.UpdatedAt,
	)
	return n, err
}

func (r *sensorRepository) GetSensorNetworkByUUID(ctx context.Context, uuid, tenantID string) (*domain.SensorNetwork, error) {
	query := `SELECT ` + networkColumns + `
		FROM sensor_networks
		WHERE id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL`

	row := r.queryRow(ctx, query, uuid, tenantID)
	n, err := scanNetwork(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("NETWORK_NOT_FOUND", fmt.Sprintf("sensor network %s not found", uuid))
		}
		return nil, errors.Internal("failed to get sensor network: %v", err)
	}
	return n, nil
}

func (r *sensorRepository) GetSensorNetworkByFarm(ctx context.Context, farmID, tenantID string) (*domain.SensorNetwork, error) {
	query := `SELECT ` + networkColumns + `
		FROM sensor_networks
		WHERE farm_id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
		LIMIT 1`

	row := r.queryRow(ctx, query, farmID, tenantID)
	n, err := scanNetwork(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("NETWORK_NOT_FOUND", fmt.Sprintf("sensor network for farm %s not found", farmID))
		}
		return nil, errors.Internal("failed to get sensor network by farm: %v", err)
	}
	return n, nil
}

// =============================================================================
// Sensor Calibrations
// =============================================================================

const calibrationColumns = `id, sensor_id, tenant_id, offset_value, scale_factor,
	calibration_date, next_calibration_date, calibrated_by, notes,
	is_active, created_by, created_at`

func scanCalibration(row pgx.Row) (*domain.SensorCalibration, error) {
	c := &domain.SensorCalibration{}
	err := row.Scan(
		&c.ID, &c.SensorID, &c.TenantID,
		&c.OffsetValue, &c.ScaleFactor,
		&c.CalibrationDate, &c.NextCalibrationDate,
		&c.CalibratedBy, &c.Notes,
		&c.IsActive, &c.CreatedBy, &c.CreatedAt,
	)
	return c, err
}

func (r *sensorRepository) CreateCalibration(ctx context.Context, cal *domain.SensorCalibration) (*domain.SensorCalibration, error) {
	cal.ID = ulid.NewString()

	query := `
		INSERT INTO sensor_calibrations (
			id, sensor_id, tenant_id, offset_value, scale_factor,
			calibration_date, next_calibration_date, calibrated_by, notes,
			is_active, created_by, created_at
		) VALUES ($1, $2, $3, $4, $5, NOW(), $6, $7, $8, true, $7, NOW())
		RETURNING ` + calibrationColumns

	row := r.queryRow(ctx, query,
		cal.ID, cal.SensorID, cal.TenantID,
		cal.OffsetValue, cal.ScaleFactor,
		cal.NextCalibrationDate, cal.CalibratedBy, cal.Notes,
	)
	result, err := scanCalibration(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create calibration", "error", err)
		return nil, errors.Internal("failed to create calibration: %v", err)
	}
	return result, nil
}

func (r *sensorRepository) GetLatestCalibration(ctx context.Context, sensorID, tenantID string) (*domain.SensorCalibration, error) {
	query := `SELECT ` + calibrationColumns + `
		FROM sensor_calibrations
		WHERE sensor_id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
		ORDER BY calibration_date DESC
		LIMIT 1`

	row := r.queryRow(ctx, query, sensorID, tenantID)
	result, err := scanCalibration(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil // No calibration is not an error.
		}
		return nil, errors.Internal("failed to get latest calibration: %v", err)
	}
	return result, nil
}
