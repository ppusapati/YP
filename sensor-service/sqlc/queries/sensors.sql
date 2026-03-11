-- =============================================================================
-- Sensor Queries
-- =============================================================================

-- name: CreateSensor :one
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
    ST_SetSRID(ST_MakePoint($11, $10), 4326), $10, $11, $12,
    $13, $14, $15,
    $16, $17, $18, $19,
    1, true, $20, NOW()
) RETURNING *;

-- name: GetSensorByUUID :one
SELECT * FROM sensors
WHERE uuid = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL;

-- name: GetSensorByDeviceID :one
SELECT * FROM sensors
WHERE device_id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL;

-- name: ListSensors :many
SELECT * FROM sensors
WHERE tenant_id = $1
  AND is_active = true
  AND deleted_at IS NULL
  AND (CAST($2 AS VARCHAR) = '' OR field_id = $2)
  AND (CAST($3 AS VARCHAR) = '' OR farm_id = $3)
  AND (CAST($4 AS VARCHAR) = '' OR sensor_type = $4)
  AND (CAST($5 AS VARCHAR) = '' OR status = $5)
  AND (CAST($6 AS VARCHAR) = '' OR protocol = $6)
ORDER BY created_at DESC
LIMIT $7 OFFSET $8;

-- name: CountSensors :one
SELECT COUNT(*) FROM sensors
WHERE tenant_id = $1
  AND is_active = true
  AND deleted_at IS NULL
  AND (CAST($2 AS VARCHAR) = '' OR field_id = $2)
  AND (CAST($3 AS VARCHAR) = '' OR farm_id = $3)
  AND (CAST($4 AS VARCHAR) = '' OR sensor_type = $4)
  AND (CAST($5 AS VARCHAR) = '' OR status = $5)
  AND (CAST($6 AS VARCHAR) = '' OR protocol = $6);

-- name: UpdateSensor :one
UPDATE sensors SET
    firmware_version = COALESCE(NULLIF($3, ''), firmware_version),
    latitude = COALESCE($4, latitude),
    longitude = COALESCE($5, longitude),
    elevation_m = COALESCE($6, elevation_m),
    location = CASE
        WHEN $4 IS NOT NULL AND $5 IS NOT NULL
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
RETURNING *;

-- name: DecommissionSensor :one
UPDATE sensors SET
    status = 'DECOMMISSIONED',
    is_active = false,
    version = version + 1,
    updated_by = $3,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
RETURNING *;

-- name: UpdateSensorLastReading :exec
UPDATE sensors SET
    last_reading_at = $3,
    battery_level_pct = COALESCE($4, battery_level_pct),
    signal_strength_dbm = COALESCE($5, signal_strength_dbm),
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2;

-- name: ListSensorsByFieldForIrrigation :many
SELECT * FROM sensors
WHERE field_id = $1
  AND tenant_id = $2
  AND sensor_type IN ('SOIL_MOISTURE', 'TEMPERATURE', 'HUMIDITY', 'RAINFALL')
  AND status = 'ACTIVE'
  AND is_active = true
  AND deleted_at IS NULL
ORDER BY sensor_type, created_at;

-- =============================================================================
-- Sensor Reading Queries
-- =============================================================================

-- name: CreateSensorReading :one
INSERT INTO sensor_readings (
    uuid, sensor_id, tenant_id, value, unit, recorded_at,
    quality, battery_level_pct, signal_strength_dbm, metadata, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW()
) RETURNING *;

-- name: BatchCreateSensorReadings :copyfrom
INSERT INTO sensor_readings (
    uuid, sensor_id, tenant_id, value, unit, recorded_at,
    quality, battery_level_pct, signal_strength_dbm, metadata, created_at
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11);

-- name: GetLatestReading :one
SELECT * FROM sensor_readings
WHERE sensor_id = $1 AND tenant_id = $2
ORDER BY recorded_at DESC
LIMIT 1;

-- name: GetReadingHistory :many
SELECT * FROM sensor_readings
WHERE sensor_id = $1
  AND tenant_id = $2
  AND recorded_at >= $3
  AND recorded_at <= $4
  AND (CAST($5 AS VARCHAR) = '' OR quality = $5)
ORDER BY recorded_at DESC
LIMIT $6 OFFSET $7;

-- name: CountReadingHistory :one
SELECT COUNT(*) FROM sensor_readings
WHERE sensor_id = $1
  AND tenant_id = $2
  AND recorded_at >= $3
  AND recorded_at <= $4
  AND (CAST($5 AS VARCHAR) = '' OR quality = $5);

-- name: GetAverageReadingInWindow :one
SELECT
    AVG(value) as avg_value,
    MIN(value) as min_value,
    MAX(value) as max_value,
    COUNT(*) as reading_count
FROM sensor_readings
WHERE sensor_id = $1
  AND tenant_id = $2
  AND recorded_at >= $3
  AND recorded_at <= $4
  AND quality = 'GOOD';

-- =============================================================================
-- Sensor Alert Queries
-- =============================================================================

-- name: CreateSensorAlert :one
INSERT INTO sensor_alerts (
    uuid, sensor_id, tenant_id, field_id, sensor_type,
    threshold, actual_value, condition, severity, message,
    acknowledged, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
    false, true, $11, NOW()
) RETURNING *;

-- name: GetAlertByUUID :one
SELECT * FROM sensor_alerts
WHERE uuid = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL;

-- name: ListAlerts :many
SELECT * FROM sensor_alerts
WHERE tenant_id = $1
  AND is_active = true
  AND deleted_at IS NULL
  AND (CAST($2 AS VARCHAR) = '' OR sensor_id = $2)
  AND (CAST($3 AS VARCHAR) = '' OR field_id = $3)
  AND (CAST($4 AS VARCHAR) = '' OR severity = $4)
  AND ($5 = false OR acknowledged = false)
ORDER BY created_at DESC
LIMIT $6 OFFSET $7;

-- name: CountAlerts :one
SELECT COUNT(*) FROM sensor_alerts
WHERE tenant_id = $1
  AND is_active = true
  AND deleted_at IS NULL
  AND (CAST($2 AS VARCHAR) = '' OR sensor_id = $2)
  AND (CAST($3 AS VARCHAR) = '' OR field_id = $3)
  AND (CAST($4 AS VARCHAR) = '' OR severity = $4)
  AND ($5 = false OR acknowledged = false);

-- name: AcknowledgeAlert :one
UPDATE sensor_alerts SET
    acknowledged = true,
    acknowledged_by = $3,
    acknowledged_at = NOW(),
    updated_by = $3,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
RETURNING *;

-- name: GetActiveAlertRulesForSensor :many
SELECT * FROM sensor_alerts
WHERE sensor_id = $1
  AND tenant_id = $2
  AND is_active = true
  AND acknowledged = false
  AND deleted_at IS NULL
ORDER BY severity DESC, created_at DESC;

-- =============================================================================
-- Sensor Network Queries
-- =============================================================================

-- name: GetSensorNetworkByUUID :one
SELECT * FROM sensor_networks
WHERE uuid = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL;

-- name: GetSensorNetworkByFarm :one
SELECT * FROM sensor_networks
WHERE farm_id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
LIMIT 1;

-- name: CreateSensorNetwork :one
INSERT INTO sensor_networks (
    uuid, tenant_id, farm_id, name, description, protocol,
    gateway_id, sensor_ids, total_sensors, active_sensors,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
    true, $11, NOW()
) RETURNING *;

-- name: UpdateSensorNetworkCounts :exec
UPDATE sensor_networks SET
    sensor_ids = $3,
    total_sensors = $4,
    active_sensors = $5,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2;

-- =============================================================================
-- Sensor Calibration Queries
-- =============================================================================

-- name: CreateSensorCalibration :one
INSERT INTO sensor_calibrations (
    uuid, sensor_id, tenant_id, offset_value, scale_factor,
    calibration_date, next_calibration_date, calibrated_by, notes,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, NOW(), $6, $7, $8,
    true, $7, NOW()
) RETURNING *;

-- name: GetLatestCalibration :one
SELECT * FROM sensor_calibrations
WHERE sensor_id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
ORDER BY calibration_date DESC
LIMIT 1;

-- name: ListCalibrationsForSensor :many
SELECT * FROM sensor_calibrations
WHERE sensor_id = $1 AND tenant_id = $2 AND is_active = true AND deleted_at IS NULL
ORDER BY calibration_date DESC;
