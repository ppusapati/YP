package repositories

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/agriculture/sensor-service/internal/models"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// SensorRepository defines the contract for sensor data persistence.
type SensorRepository interface {
	// Sensor CRUD
	CreateSensor(ctx context.Context, sensor *models.Sensor) (*models.Sensor, error)
	GetSensorByUUID(ctx context.Context, tenantID, uuid string) (*models.Sensor, error)
	GetSensorByDeviceID(ctx context.Context, tenantID, deviceID string) (*models.Sensor, error)
	ListSensors(ctx context.Context, filter models.SensorListFilter) ([]models.Sensor, int32, error)
	UpdateSensor(ctx context.Context, sensor *models.Sensor) (*models.Sensor, error)
	DecommissionSensor(ctx context.Context, tenantID, uuid, userID string) (*models.Sensor, error)
	UpdateSensorLastReading(ctx context.Context, tenantID, uuid string, readingTime time.Time, batteryPct, signalDbm *float64) error
	ListSensorsByFieldForIrrigation(ctx context.Context, tenantID, fieldID string) ([]models.Sensor, error)

	// Sensor Readings
	CreateReading(ctx context.Context, reading *models.SensorReading) (*models.SensorReading, error)
	BatchCreateReadings(ctx context.Context, readings []models.SensorReading) (int, error)
	GetLatestReading(ctx context.Context, tenantID, sensorID string) (*models.SensorReading, error)
	GetReadingHistory(ctx context.Context, tenantID, sensorID string, start, end time.Time, minQuality string, pageSize, pageOffset int32) ([]models.SensorReading, int32, error)

	// Sensor Alerts
	CreateAlert(ctx context.Context, alert *models.SensorAlert) (*models.SensorAlert, error)
	GetAlertByUUID(ctx context.Context, tenantID, uuid string) (*models.SensorAlert, error)
	ListAlerts(ctx context.Context, filter models.AlertListFilter) ([]models.SensorAlert, int32, error)
	AcknowledgeAlert(ctx context.Context, tenantID, uuid, userID string) (*models.SensorAlert, error)
	GetActiveAlertsForSensor(ctx context.Context, tenantID, sensorID string) ([]models.SensorAlert, error)

	// Sensor Networks
	GetSensorNetworkByUUID(ctx context.Context, tenantID, uuid string) (*models.SensorNetwork, error)
	GetSensorNetworkByFarm(ctx context.Context, tenantID, farmID string) (*models.SensorNetwork, error)

	// Sensor Calibrations
	CreateCalibration(ctx context.Context, cal *models.SensorCalibration) (*models.SensorCalibration, error)
	GetLatestCalibration(ctx context.Context, tenantID, sensorID string) (*models.SensorCalibration, error)
}

// sensorRepository implements SensorRepository using pgxpool.
type sensorRepository struct {
	pool   *pgxpool.Pool
	logger *p9log.Helper
}

// NewSensorRepository creates a new SensorRepository backed by PostgreSQL.
func NewSensorRepository(pool *pgxpool.Pool, logger p9log.Logger) SensorRepository {
	return &sensorRepository{
		pool:   pool,
		logger: p9log.NewHelper(p9log.With(logger, "component", "SensorRepository")),
	}
}

// =============================================================================
// Sensor CRUD
// =============================================================================

func (r *sensorRepository) CreateSensor(ctx context.Context, sensor *models.Sensor) (*models.Sensor, error) {
	query := `
		INSERT INTO sensors (
			uuid, tenant_id, field_id, farm_id, sensor_type, device_id,
			manufacturer, model, firmware_version,
			location, latitude, longitude, elevation_m,
			installation_date, battery_level_pct, signal_strength_dbm,
			status, protocol, reading_interval_seconds, metadata,
			version, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6,
			$7, $8, $9,
			CASE WHEN $10::float8 IS NOT NULL AND $11::float8 IS NOT NULL
				THEN ST_SetSRID(ST_MakePoint($11, $10), 4326)
				ELSE NULL END,
			$10, $11, $12,
			$13, $14, $15,
			$16, $17, $18, $19,
			1, true, $20, NOW()
		) RETURNING id, uuid, tenant_id, field_id, farm_id, sensor_type, device_id,
			manufacturer, model, firmware_version, latitude, longitude, elevation_m,
			installation_date, last_reading_at, battery_level_pct, signal_strength_dbm,
			status, protocol, reading_interval_seconds, metadata, version,
			is_active, created_by, created_at, updated_by, updated_at`

	var result models.Sensor
	err := r.pool.QueryRow(ctx, query,
		sensor.UUID, sensor.TenantID, sensor.FieldID, sensor.FarmID,
		string(sensor.SensorType), sensor.DeviceID,
		sensor.Manufacturer, sensor.Model, sensor.FirmwareVersion,
		sensor.Latitude, sensor.Longitude, sensor.ElevationM,
		sensor.InstallationDate, sensor.BatteryLevelPct, sensor.SignalStrengthDbm,
		string(sensor.Status), string(sensor.Protocol), sensor.ReadingIntervalSeconds,
		sensor.Metadata, sensor.CreatedBy,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&result.SensorType, &result.DeviceID,
		&result.Manufacturer, &result.Model, &result.FirmwareVersion,
		&result.Latitude, &result.Longitude, &result.ElevationM,
		&result.InstallationDate, &result.LastReadingAt,
		&result.BatteryLevelPct, &result.SignalStrengthDbm,
		&result.Status, &result.Protocol, &result.ReadingIntervalSeconds,
		&result.Metadata, &result.Version,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
		&result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to create sensor: %v", err)
		return nil, errors.Internal("failed to create sensor: %v", err)
	}

	return &result, nil
}

func (r *sensorRepository) GetSensorByUUID(ctx context.Context, tenantID, uuid string) (*models.Sensor, error) {
	query := `
		SELECT id, uuid, tenant_id, field_id, farm_id, sensor_type, device_id,
			manufacturer, model, firmware_version, latitude, longitude, elevation_m,
			installation_date, last_reading_at, battery_level_pct, signal_strength_dbm,
			status, protocol, reading_interval_seconds, metadata, version,
			is_active, created_by, created_at, updated_by, updated_at
		FROM sensors
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL`

	var s models.Sensor
	err := r.pool.QueryRow(ctx, query, uuid, tenantID).Scan(
		&s.ID, &s.UUID, &s.TenantID, &s.FieldID, &s.FarmID,
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
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor %s not found", uuid))
		}
		r.logger.Errorf("failed to get sensor by UUID: %v", err)
		return nil, errors.Internal("failed to get sensor: %v", err)
	}

	return &s, nil
}

func (r *sensorRepository) GetSensorByDeviceID(ctx context.Context, tenantID, deviceID string) (*models.Sensor, error) {
	query := `
		SELECT id, uuid, tenant_id, field_id, farm_id, sensor_type, device_id,
			manufacturer, model, firmware_version, latitude, longitude, elevation_m,
			installation_date, last_reading_at, battery_level_pct, signal_strength_dbm,
			status, protocol, reading_interval_seconds, metadata, version,
			is_active, created_by, created_at, updated_by, updated_at
		FROM sensors
		WHERE device_id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL`

	var s models.Sensor
	err := r.pool.QueryRow(ctx, query, deviceID, tenantID).Scan(
		&s.ID, &s.UUID, &s.TenantID, &s.FieldID, &s.FarmID,
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
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor with device_id %s not found", deviceID))
		}
		return nil, errors.Internal("failed to get sensor by device ID: %v", err)
	}

	return &s, nil
}

func (r *sensorRepository) ListSensors(ctx context.Context, filter models.SensorListFilter) ([]models.Sensor, int32, error) {
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
	err := r.pool.QueryRow(ctx, countQuery,
		filter.TenantID, filter.FieldID, filter.FarmID,
		filter.SensorType, filter.Status, filter.Protocol,
	).Scan(&totalCount)
	if err != nil {
		r.logger.Errorf("failed to count sensors: %v", err)
		return nil, 0, errors.Internal("failed to count sensors: %v", err)
	}

	listQuery := `
		SELECT id, uuid, tenant_id, field_id, farm_id, sensor_type, device_id,
			manufacturer, model, firmware_version, latitude, longitude, elevation_m,
			installation_date, last_reading_at, battery_level_pct, signal_strength_dbm,
			status, protocol, reading_interval_seconds, metadata, version,
			is_active, created_by, created_at, updated_by, updated_at
		FROM sensors
		WHERE tenant_id = $1 AND is_active = true AND deleted_at IS NULL
		AND ($2::varchar = '' OR field_id = $2)
		AND ($3::varchar = '' OR farm_id = $3)
		AND ($4::varchar = '' OR sensor_type = $4)
		AND ($5::varchar = '' OR status = $5)
		AND ($6::varchar = '' OR protocol = $6)
		ORDER BY created_at DESC
		LIMIT $7 OFFSET $8`

	rows, err := r.pool.Query(ctx, listQuery,
		filter.TenantID, filter.FieldID, filter.FarmID,
		filter.SensorType, filter.Status, filter.Protocol,
		filter.PageSize, filter.PageOffset,
	)
	if err != nil {
		r.logger.Errorf("failed to list sensors: %v", err)
		return nil, 0, errors.Internal("failed to list sensors: %v", err)
	}
	defer rows.Close()

	sensors := make([]models.Sensor, 0)
	for rows.Next() {
		var s models.Sensor
		if err := rows.Scan(
			&s.ID, &s.UUID, &s.TenantID, &s.FieldID, &s.FarmID,
			&s.SensorType, &s.DeviceID,
			&s.Manufacturer, &s.Model, &s.FirmwareVersion,
			&s.Latitude, &s.Longitude, &s.ElevationM,
			&s.InstallationDate, &s.LastReadingAt,
			&s.BatteryLevelPct, &s.SignalStrengthDbm,
			&s.Status, &s.Protocol, &s.ReadingIntervalSeconds,
			&s.Metadata, &s.Version,
			&s.IsActive, &s.CreatedBy, &s.CreatedAt,
			&s.UpdatedBy, &s.UpdatedAt,
		); err != nil {
			r.logger.Errorf("failed to scan sensor row: %v", err)
			return nil, 0, errors.Internal("failed to scan sensor: %v", err)
		}
		sensors = append(sensors, s)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, errors.Internal("error iterating sensor rows: %v", err)
	}

	return sensors, totalCount, nil
}

func (r *sensorRepository) UpdateSensor(ctx context.Context, sensor *models.Sensor) (*models.Sensor, error) {
	query := `
		UPDATE sensors SET
			firmware_version = COALESCE(NULLIF($3, ''), firmware_version),
			latitude = COALESCE($4, latitude),
			longitude = COALESCE($5, longitude),
			elevation_m = COALESCE($6, elevation_m),
			location = CASE
				WHEN $4::float8 IS NOT NULL AND $5::float8 IS NOT NULL
				THEN ST_SetSRID(ST_MakePoint($5, $4), 4326)
				ELSE location
			END,
			status = COALESCE(NULLIF($7, ''), status),
			protocol = COALESCE(NULLIF($8, ''), protocol),
			reading_interval_seconds = CASE WHEN $9 > 0 THEN $9 ELSE reading_interval_seconds END,
			metadata = COALESCE($10, metadata),
			version = version + 1,
			updated_by = $11,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, field_id, farm_id, sensor_type, device_id,
			manufacturer, model, firmware_version, latitude, longitude, elevation_m,
			installation_date, last_reading_at, battery_level_pct, signal_strength_dbm,
			status, protocol, reading_interval_seconds, metadata, version,
			is_active, created_by, created_at, updated_by, updated_at`

	var result models.Sensor
	err := r.pool.QueryRow(ctx, query,
		sensor.UUID, sensor.TenantID,
		sensor.FirmwareVersion,
		sensor.Latitude, sensor.Longitude, sensor.ElevationM,
		string(sensor.Status), string(sensor.Protocol),
		sensor.ReadingIntervalSeconds,
		sensor.Metadata,
		sensor.UpdatedBy,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&result.SensorType, &result.DeviceID,
		&result.Manufacturer, &result.Model, &result.FirmwareVersion,
		&result.Latitude, &result.Longitude, &result.ElevationM,
		&result.InstallationDate, &result.LastReadingAt,
		&result.BatteryLevelPct, &result.SignalStrengthDbm,
		&result.Status, &result.Protocol, &result.ReadingIntervalSeconds,
		&result.Metadata, &result.Version,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
		&result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor %s not found", sensor.UUID))
		}
		r.logger.Errorf("failed to update sensor: %v", err)
		return nil, errors.Internal("failed to update sensor: %v", err)
	}

	return &result, nil
}

func (r *sensorRepository) DecommissionSensor(ctx context.Context, tenantID, uuid, userID string) (*models.Sensor, error) {
	query := `
		UPDATE sensors SET
			status = 'DECOMMISSIONED',
			is_active = false,
			version = version + 1,
			updated_by = $3,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, field_id, farm_id, sensor_type, device_id,
			manufacturer, model, firmware_version, latitude, longitude, elevation_m,
			installation_date, last_reading_at, battery_level_pct, signal_strength_dbm,
			status, protocol, reading_interval_seconds, metadata, version,
			is_active, created_by, created_at, updated_by, updated_at`

	var result models.Sensor
	err := r.pool.QueryRow(ctx, query, uuid, tenantID, userID).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&result.SensorType, &result.DeviceID,
		&result.Manufacturer, &result.Model, &result.FirmwareVersion,
		&result.Latitude, &result.Longitude, &result.ElevationM,
		&result.InstallationDate, &result.LastReadingAt,
		&result.BatteryLevelPct, &result.SignalStrengthDbm,
		&result.Status, &result.Protocol, &result.ReadingIntervalSeconds,
		&result.Metadata, &result.Version,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
		&result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor %s not found", uuid))
		}
		r.logger.Errorf("failed to decommission sensor: %v", err)
		return nil, errors.Internal("failed to decommission sensor: %v", err)
	}

	return &result, nil
}

func (r *sensorRepository) UpdateSensorLastReading(ctx context.Context, tenantID, uuid string, readingTime time.Time, batteryPct, signalDbm *float64) error {
	query := `
		UPDATE sensors SET
			last_reading_at = $3,
			battery_level_pct = COALESCE($4, battery_level_pct),
			signal_strength_dbm = COALESCE($5, signal_strength_dbm),
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2`

	_, err := r.pool.Exec(ctx, query, uuid, tenantID, readingTime, batteryPct, signalDbm)
	if err != nil {
		r.logger.Errorf("failed to update sensor last reading: %v", err)
		return errors.Internal("failed to update sensor last reading: %v", err)
	}

	return nil
}

func (r *sensorRepository) ListSensorsByFieldForIrrigation(ctx context.Context, tenantID, fieldID string) ([]models.Sensor, error) {
	query := `
		SELECT id, uuid, tenant_id, field_id, farm_id, sensor_type, device_id,
			manufacturer, model, firmware_version, latitude, longitude, elevation_m,
			installation_date, last_reading_at, battery_level_pct, signal_strength_dbm,
			status, protocol, reading_interval_seconds, metadata, version,
			is_active, created_by, created_at, updated_by, updated_at
		FROM sensors
		WHERE field_id = $1 AND tenant_id = $2
		AND sensor_type IN ('SOIL_MOISTURE', 'TEMPERATURE', 'HUMIDITY', 'RAINFALL')
		AND status = 'ACTIVE' AND is_active = true AND deleted_at IS NULL
		ORDER BY sensor_type, created_at`

	rows, err := r.pool.Query(ctx, query, fieldID, tenantID)
	if err != nil {
		return nil, errors.Internal("failed to list irrigation sensors: %v", err)
	}
	defer rows.Close()

	sensors := make([]models.Sensor, 0)
	for rows.Next() {
		var s models.Sensor
		if err := rows.Scan(
			&s.ID, &s.UUID, &s.TenantID, &s.FieldID, &s.FarmID,
			&s.SensorType, &s.DeviceID,
			&s.Manufacturer, &s.Model, &s.FirmwareVersion,
			&s.Latitude, &s.Longitude, &s.ElevationM,
			&s.InstallationDate, &s.LastReadingAt,
			&s.BatteryLevelPct, &s.SignalStrengthDbm,
			&s.Status, &s.Protocol, &s.ReadingIntervalSeconds,
			&s.Metadata, &s.Version,
			&s.IsActive, &s.CreatedBy, &s.CreatedAt,
			&s.UpdatedBy, &s.UpdatedAt,
		); err != nil {
			return nil, errors.Internal("failed to scan irrigation sensor: %v", err)
		}
		sensors = append(sensors, s)
	}

	return sensors, rows.Err()
}

// =============================================================================
// Sensor Readings
// =============================================================================

func (r *sensorRepository) CreateReading(ctx context.Context, reading *models.SensorReading) (*models.SensorReading, error) {
	if reading.UUID == "" {
		reading.UUID = ulid.NewString()
	}

	query := `
		INSERT INTO sensor_readings (
			uuid, sensor_id, tenant_id, value, unit, recorded_at,
			quality, battery_level_pct, signal_strength_dbm, metadata, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW())
		RETURNING id, uuid, sensor_id, tenant_id, value, unit, recorded_at,
			quality, battery_level_pct, signal_strength_dbm, metadata, created_at`

	metadataJSON := reading.Metadata
	if metadataJSON == nil {
		metadataJSON = json.RawMessage("{}")
	}

	var result models.SensorReading
	err := r.pool.QueryRow(ctx, query,
		reading.UUID, reading.SensorID, reading.TenantID,
		reading.Value, reading.Unit, reading.RecordedAt,
		string(reading.Quality), reading.BatteryLevelPct, reading.SignalStrengthDbm,
		metadataJSON,
	).Scan(
		&result.ID, &result.UUID, &result.SensorID, &result.TenantID,
		&result.Value, &result.Unit, &result.RecordedAt,
		&result.Quality, &result.BatteryLevelPct, &result.SignalStrengthDbm,
		&result.Metadata, &result.CreatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to create sensor reading: %v", err)
		return nil, errors.Internal("failed to create sensor reading: %v", err)
	}

	return &result, nil
}

func (r *sensorRepository) BatchCreateReadings(ctx context.Context, readings []models.SensorReading) (int, error) {
	if len(readings) == 0 {
		return 0, nil
	}

	batch := &pgx.Batch{}
	insertQuery := `
		INSERT INTO sensor_readings (
			uuid, sensor_id, tenant_id, value, unit, recorded_at,
			quality, battery_level_pct, signal_strength_dbm, metadata, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW())`

	for i := range readings {
		rd := &readings[i]
		if rd.UUID == "" {
			rd.UUID = ulid.NewString()
		}
		metadataJSON := rd.Metadata
		if metadataJSON == nil {
			metadataJSON = json.RawMessage("{}")
		}
		batch.Queue(insertQuery,
			rd.UUID, rd.SensorID, rd.TenantID,
			rd.Value, rd.Unit, rd.RecordedAt,
			string(rd.Quality), rd.BatteryLevelPct, rd.SignalStrengthDbm,
			metadataJSON,
		)
	}

	br := r.pool.SendBatch(ctx, batch)
	defer br.Close()

	successCount := 0
	for range readings {
		_, err := br.Exec()
		if err != nil {
			r.logger.Errorf("failed to insert reading in batch: %v", err)
			continue
		}
		successCount++
	}

	return successCount, nil
}

func (r *sensorRepository) GetLatestReading(ctx context.Context, tenantID, sensorID string) (*models.SensorReading, error) {
	query := `
		SELECT id, uuid, sensor_id, tenant_id, value, unit, recorded_at,
			quality, battery_level_pct, signal_strength_dbm, metadata, created_at
		FROM sensor_readings
		WHERE sensor_id = $1 AND tenant_id = $2
		ORDER BY recorded_at DESC
		LIMIT 1`

	var rd models.SensorReading
	err := r.pool.QueryRow(ctx, query, sensorID, tenantID).Scan(
		&rd.ID, &rd.UUID, &rd.SensorID, &rd.TenantID,
		&rd.Value, &rd.Unit, &rd.RecordedAt,
		&rd.Quality, &rd.BatteryLevelPct, &rd.SignalStrengthDbm,
		&rd.Metadata, &rd.CreatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("READING_NOT_FOUND", "no readings found for sensor")
		}
		return nil, errors.Internal("failed to get latest reading: %v", err)
	}

	return &rd, nil
}

func (r *sensorRepository) GetReadingHistory(ctx context.Context, tenantID, sensorID string, start, end time.Time, minQuality string, pageSize, pageOffset int32) ([]models.SensorReading, int32, error) {
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
	err := r.pool.QueryRow(ctx, countQuery, sensorID, tenantID, start, end, minQuality).Scan(&totalCount)
	if err != nil {
		return nil, 0, errors.Internal("failed to count readings: %v", err)
	}

	listQuery := `
		SELECT id, uuid, sensor_id, tenant_id, value, unit, recorded_at,
			quality, battery_level_pct, signal_strength_dbm, metadata, created_at
		FROM sensor_readings
		WHERE sensor_id = $1 AND tenant_id = $2
		AND recorded_at >= $3 AND recorded_at <= $4
		AND ($5::varchar = '' OR quality = $5)
		ORDER BY recorded_at DESC
		LIMIT $6 OFFSET $7`

	rows, err := r.pool.Query(ctx, listQuery, sensorID, tenantID, start, end, minQuality, pageSize, pageOffset)
	if err != nil {
		return nil, 0, errors.Internal("failed to list readings: %v", err)
	}
	defer rows.Close()

	readings := make([]models.SensorReading, 0)
	for rows.Next() {
		var rd models.SensorReading
		if err := rows.Scan(
			&rd.ID, &rd.UUID, &rd.SensorID, &rd.TenantID,
			&rd.Value, &rd.Unit, &rd.RecordedAt,
			&rd.Quality, &rd.BatteryLevelPct, &rd.SignalStrengthDbm,
			&rd.Metadata, &rd.CreatedAt,
		); err != nil {
			return nil, 0, errors.Internal("failed to scan reading row: %v", err)
		}
		readings = append(readings, rd)
	}

	return readings, totalCount, rows.Err()
}

// =============================================================================
// Sensor Alerts
// =============================================================================

func (r *sensorRepository) CreateAlert(ctx context.Context, alert *models.SensorAlert) (*models.SensorAlert, error) {
	query := `
		INSERT INTO sensor_alerts (
			uuid, sensor_id, tenant_id, field_id, sensor_type,
			threshold, actual_value, condition, severity, message,
			acknowledged, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
			false, true, $11, NOW()
		) RETURNING id, uuid, sensor_id, tenant_id, field_id, sensor_type,
			threshold, actual_value, condition, severity, message,
			acknowledged, acknowledged_by, acknowledged_at,
			is_active, created_by, created_at, updated_by, updated_at`

	var result models.SensorAlert
	err := r.pool.QueryRow(ctx, query,
		alert.UUID, alert.SensorID, alert.TenantID, alert.FieldID,
		string(alert.SensorType),
		alert.Threshold, alert.ActualValue,
		string(alert.Condition), string(alert.Severity), alert.Message,
		alert.CreatedBy,
	).Scan(
		&result.ID, &result.UUID, &result.SensorID, &result.TenantID,
		&result.FieldID, &result.SensorType,
		&result.Threshold, &result.ActualValue,
		&result.Condition, &result.Severity, &result.Message,
		&result.Acknowledged, &result.AcknowledgedBy, &result.AcknowledgedAt,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
		&result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to create alert: %v", err)
		return nil, errors.Internal("failed to create alert: %v", err)
	}

	return &result, nil
}

func (r *sensorRepository) GetAlertByUUID(ctx context.Context, tenantID, uuid string) (*models.SensorAlert, error) {
	query := `
		SELECT id, uuid, sensor_id, tenant_id, field_id, sensor_type,
			threshold, actual_value, condition, severity, message,
			acknowledged, acknowledged_by, acknowledged_at,
			is_active, created_by, created_at, updated_by, updated_at
		FROM sensor_alerts
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL`

	var a models.SensorAlert
	err := r.pool.QueryRow(ctx, query, uuid, tenantID).Scan(
		&a.ID, &a.UUID, &a.SensorID, &a.TenantID,
		&a.FieldID, &a.SensorType,
		&a.Threshold, &a.ActualValue,
		&a.Condition, &a.Severity, &a.Message,
		&a.Acknowledged, &a.AcknowledgedBy, &a.AcknowledgedAt,
		&a.IsActive, &a.CreatedBy, &a.CreatedAt,
		&a.UpdatedBy, &a.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ALERT_NOT_FOUND", fmt.Sprintf("alert %s not found", uuid))
		}
		return nil, errors.Internal("failed to get alert: %v", err)
	}

	return &a, nil
}

func (r *sensorRepository) ListAlerts(ctx context.Context, filter models.AlertListFilter) ([]models.SensorAlert, int32, error) {
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
	err := r.pool.QueryRow(ctx, countQuery,
		filter.TenantID, filter.SensorID, filter.FieldID,
		filter.Severity, filter.UnacknowledgedOnly,
	).Scan(&totalCount)
	if err != nil {
		return nil, 0, errors.Internal("failed to count alerts: %v", err)
	}

	listQuery := `
		SELECT id, uuid, sensor_id, tenant_id, field_id, sensor_type,
			threshold, actual_value, condition, severity, message,
			acknowledged, acknowledged_by, acknowledged_at,
			is_active, created_by, created_at, updated_by, updated_at
		FROM sensor_alerts
		WHERE tenant_id = $1 AND is_active = true AND deleted_at IS NULL
		AND ($2::varchar = '' OR sensor_id = $2)
		AND ($3::varchar = '' OR field_id = $3)
		AND ($4::varchar = '' OR severity = $4)
		AND ($5::boolean = false OR acknowledged = false)
		ORDER BY created_at DESC
		LIMIT $6 OFFSET $7`

	rows, err := r.pool.Query(ctx, listQuery,
		filter.TenantID, filter.SensorID, filter.FieldID,
		filter.Severity, filter.UnacknowledgedOnly,
		filter.PageSize, filter.PageOffset,
	)
	if err != nil {
		return nil, 0, errors.Internal("failed to list alerts: %v", err)
	}
	defer rows.Close()

	alerts := make([]models.SensorAlert, 0)
	for rows.Next() {
		var a models.SensorAlert
		if err := rows.Scan(
			&a.ID, &a.UUID, &a.SensorID, &a.TenantID,
			&a.FieldID, &a.SensorType,
			&a.Threshold, &a.ActualValue,
			&a.Condition, &a.Severity, &a.Message,
			&a.Acknowledged, &a.AcknowledgedBy, &a.AcknowledgedAt,
			&a.IsActive, &a.CreatedBy, &a.CreatedAt,
			&a.UpdatedBy, &a.UpdatedAt,
		); err != nil {
			return nil, 0, errors.Internal("failed to scan alert row: %v", err)
		}
		alerts = append(alerts, a)
	}

	return alerts, totalCount, rows.Err()
}

func (r *sensorRepository) AcknowledgeAlert(ctx context.Context, tenantID, uuid, userID string) (*models.SensorAlert, error) {
	query := `
		UPDATE sensor_alerts SET
			acknowledged = true,
			acknowledged_by = $3,
			acknowledged_at = NOW(),
			updated_by = $3,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
		RETURNING id, uuid, sensor_id, tenant_id, field_id, sensor_type,
			threshold, actual_value, condition, severity, message,
			acknowledged, acknowledged_by, acknowledged_at,
			is_active, created_by, created_at, updated_by, updated_at`

	var a models.SensorAlert
	err := r.pool.QueryRow(ctx, query, uuid, tenantID, userID).Scan(
		&a.ID, &a.UUID, &a.SensorID, &a.TenantID,
		&a.FieldID, &a.SensorType,
		&a.Threshold, &a.ActualValue,
		&a.Condition, &a.Severity, &a.Message,
		&a.Acknowledged, &a.AcknowledgedBy, &a.AcknowledgedAt,
		&a.IsActive, &a.CreatedBy, &a.CreatedAt,
		&a.UpdatedBy, &a.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ALERT_NOT_FOUND", fmt.Sprintf("alert %s not found", uuid))
		}
		return nil, errors.Internal("failed to acknowledge alert: %v", err)
	}

	return &a, nil
}

func (r *sensorRepository) GetActiveAlertsForSensor(ctx context.Context, tenantID, sensorID string) ([]models.SensorAlert, error) {
	query := `
		SELECT id, uuid, sensor_id, tenant_id, field_id, sensor_type,
			threshold, actual_value, condition, severity, message,
			acknowledged, acknowledged_by, acknowledged_at,
			is_active, created_by, created_at, updated_by, updated_at
		FROM sensor_alerts
		WHERE sensor_id = $1 AND tenant_id = $2
		AND is_active = true AND acknowledged = false AND deleted_at IS NULL
		ORDER BY severity DESC, created_at DESC`

	rows, err := r.pool.Query(ctx, query, sensorID, tenantID)
	if err != nil {
		return nil, errors.Internal("failed to get active alerts: %v", err)
	}
	defer rows.Close()

	alerts := make([]models.SensorAlert, 0)
	for rows.Next() {
		var a models.SensorAlert
		if err := rows.Scan(
			&a.ID, &a.UUID, &a.SensorID, &a.TenantID,
			&a.FieldID, &a.SensorType,
			&a.Threshold, &a.ActualValue,
			&a.Condition, &a.Severity, &a.Message,
			&a.Acknowledged, &a.AcknowledgedBy, &a.AcknowledgedAt,
			&a.IsActive, &a.CreatedBy, &a.CreatedAt,
			&a.UpdatedBy, &a.UpdatedAt,
		); err != nil {
			return nil, errors.Internal("failed to scan active alert: %v", err)
		}
		alerts = append(alerts, a)
	}

	return alerts, rows.Err()
}

// =============================================================================
// Sensor Networks
// =============================================================================

func (r *sensorRepository) GetSensorNetworkByUUID(ctx context.Context, tenantID, uuid string) (*models.SensorNetwork, error) {
	query := `
		SELECT id, uuid, tenant_id, farm_id, name, description, protocol,
			gateway_id, sensor_ids, total_sensors, active_sensors,
			is_active, created_by, created_at, updated_by, updated_at
		FROM sensor_networks
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL`

	var n models.SensorNetwork
	err := r.pool.QueryRow(ctx, query, uuid, tenantID).Scan(
		&n.ID, &n.UUID, &n.TenantID, &n.FarmID,
		&n.Name, &n.Description, &n.Protocol,
		&n.GatewayID, &n.SensorIDs, &n.TotalSensors, &n.ActiveSensors,
		&n.IsActive, &n.CreatedBy, &n.CreatedAt,
		&n.UpdatedBy, &n.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("NETWORK_NOT_FOUND", fmt.Sprintf("sensor network %s not found", uuid))
		}
		return nil, errors.Internal("failed to get sensor network: %v", err)
	}

	return &n, nil
}

func (r *sensorRepository) GetSensorNetworkByFarm(ctx context.Context, tenantID, farmID string) (*models.SensorNetwork, error) {
	query := `
		SELECT id, uuid, tenant_id, farm_id, name, description, protocol,
			gateway_id, sensor_ids, total_sensors, active_sensors,
			is_active, created_by, created_at, updated_by, updated_at
		FROM sensor_networks
		WHERE farm_id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
		LIMIT 1`

	var n models.SensorNetwork
	err := r.pool.QueryRow(ctx, query, farmID, tenantID).Scan(
		&n.ID, &n.UUID, &n.TenantID, &n.FarmID,
		&n.Name, &n.Description, &n.Protocol,
		&n.GatewayID, &n.SensorIDs, &n.TotalSensors, &n.ActiveSensors,
		&n.IsActive, &n.CreatedBy, &n.CreatedAt,
		&n.UpdatedBy, &n.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("NETWORK_NOT_FOUND", fmt.Sprintf("sensor network for farm %s not found", farmID))
		}
		return nil, errors.Internal("failed to get sensor network by farm: %v", err)
	}

	return &n, nil
}

// =============================================================================
// Sensor Calibrations
// =============================================================================

func (r *sensorRepository) CreateCalibration(ctx context.Context, cal *models.SensorCalibration) (*models.SensorCalibration, error) {
	query := `
		INSERT INTO sensor_calibrations (
			uuid, sensor_id, tenant_id, offset_value, scale_factor,
			calibration_date, next_calibration_date, calibrated_by, notes,
			is_active, created_by, created_at
		) VALUES ($1, $2, $3, $4, $5, NOW(), $6, $7, $8, true, $7, NOW())
		RETURNING id, uuid, sensor_id, tenant_id, offset_value, scale_factor,
			calibration_date, next_calibration_date, calibrated_by, notes,
			is_active, created_by, created_at`

	var result models.SensorCalibration
	err := r.pool.QueryRow(ctx, query,
		cal.UUID, cal.SensorID, cal.TenantID,
		cal.OffsetValue, cal.ScaleFactor,
		cal.NextCalibrationDate, cal.CalibratedBy, cal.Notes,
	).Scan(
		&result.ID, &result.UUID, &result.SensorID, &result.TenantID,
		&result.OffsetValue, &result.ScaleFactor,
		&result.CalibrationDate, &result.NextCalibrationDate,
		&result.CalibratedBy, &result.Notes,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to create calibration: %v", err)
		return nil, errors.Internal("failed to create calibration: %v", err)
	}

	return &result, nil
}

func (r *sensorRepository) GetLatestCalibration(ctx context.Context, tenantID, sensorID string) (*models.SensorCalibration, error) {
	query := `
		SELECT id, uuid, sensor_id, tenant_id, offset_value, scale_factor,
			calibration_date, next_calibration_date, calibrated_by, notes,
			is_active, created_by, created_at
		FROM sensor_calibrations
		WHERE sensor_id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
		ORDER BY calibration_date DESC
		LIMIT 1`

	var result models.SensorCalibration
	err := r.pool.QueryRow(ctx, query, sensorID, tenantID).Scan(
		&result.ID, &result.UUID, &result.SensorID, &result.TenantID,
		&result.OffsetValue, &result.ScaleFactor,
		&result.CalibrationDate, &result.NextCalibrationDate,
		&result.CalibratedBy, &result.Notes,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil // No calibration is not an error
		}
		return nil, errors.Internal("failed to get latest calibration: %v", err)
	}

	return &result, nil
}
