-- ==========================================================================
-- Irrigation Zones
-- ==========================================================================

-- name: CreateIrrigationZone :one
INSERT INTO irrigation_zones (
    uuid, tenant_id, field_id, farm_id, name, description,
    area_hectares, soil_type, crop_type, crop_growth_stage,
    latitude, longitude, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6,
    $7, $8, $9, $10,
    $11, $12, $13, $14, $15
) RETURNING *;

-- name: GetIrrigationZoneByUUID :one
SELECT * FROM irrigation_zones
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: ListIrrigationZonesByField :many
SELECT * FROM irrigation_zones
WHERE tenant_id = $1 AND field_id = $2 AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $3 OFFSET $4;

-- name: ListIrrigationZonesByFarm :many
SELECT * FROM irrigation_zones
WHERE tenant_id = $1 AND farm_id = $2 AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $3 OFFSET $4;

-- name: CountIrrigationZonesByField :one
SELECT COUNT(*)::int AS count FROM irrigation_zones
WHERE tenant_id = $1 AND field_id = $2 AND deleted_at IS NULL;

-- name: CountIrrigationZonesByFarm :one
SELECT COUNT(*)::int AS count FROM irrigation_zones
WHERE tenant_id = $1 AND farm_id = $2 AND deleted_at IS NULL;

-- name: UpdateIrrigationZone :one
UPDATE irrigation_zones SET
    name = $3,
    description = $4,
    area_hectares = $5,
    soil_type = $6,
    crop_type = $7,
    crop_growth_stage = $8,
    latitude = $9,
    longitude = $10,
    is_active = $11,
    updated_by = $12,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteIrrigationZone :exec
UPDATE irrigation_zones SET
    deleted_by = $3,
    deleted_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- ==========================================================================
-- Water Controllers
-- ==========================================================================

-- name: CreateWaterController :one
INSERT INTO water_controllers (
    uuid, tenant_id, zone_id, field_id, farm_id, name, model,
    firmware_version, controller_type, protocol, status, endpoint,
    max_flow_rate_liters_per_hour, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7,
    $8, $9, $10, $11, $12,
    $13, $14, $15, $16
) RETURNING *;

-- name: GetWaterControllerByUUID :one
SELECT * FROM water_controllers
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: ListWaterControllersByZone :many
SELECT * FROM water_controllers
WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $3 OFFSET $4;

-- name: ListWaterControllersByField :many
SELECT * FROM water_controllers
WHERE tenant_id = $1 AND field_id = $2 AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $3 OFFSET $4;

-- name: ListWaterControllersByStatus :many
SELECT * FROM water_controllers
WHERE tenant_id = $1 AND status = $2 AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $3 OFFSET $4;

-- name: CountWaterControllersByZone :one
SELECT COUNT(*)::int AS count FROM water_controllers
WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL;

-- name: CountWaterControllersByField :one
SELECT COUNT(*)::int AS count FROM water_controllers
WHERE tenant_id = $1 AND field_id = $2 AND deleted_at IS NULL;

-- name: CountWaterControllersByStatus :one
SELECT COUNT(*)::int AS count FROM water_controllers
WHERE tenant_id = $1 AND status = $2 AND deleted_at IS NULL;

-- name: UpdateWaterControllerStatus :one
UPDATE water_controllers SET
    status = $3,
    last_heartbeat = NOW(),
    updated_by = $4,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
RETURNING *;

-- name: UpdateWaterController :one
UPDATE water_controllers SET
    name = $3,
    model = $4,
    firmware_version = $5,
    controller_type = $6,
    protocol = $7,
    endpoint = $8,
    max_flow_rate_liters_per_hour = $9,
    updated_by = $10,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteWaterController :exec
UPDATE water_controllers SET
    deleted_by = $3,
    deleted_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- ==========================================================================
-- Irrigation Schedules
-- ==========================================================================

-- name: CreateIrrigationSchedule :one
INSERT INTO irrigation_schedules (
    uuid, tenant_id, field_id, farm_id, zone_id, name, description,
    schedule_type, start_time, end_time, duration_minutes,
    water_quantity_liters, flow_rate_liters_per_hour, frequency,
    soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
    controller_id, status, version, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7,
    $8, $9, $10, $11,
    $12, $13, $14,
    $15, $16, $17,
    $18, $19, $20, $21, $22, $23
) RETURNING *;

-- name: GetIrrigationScheduleByUUID :one
SELECT * FROM irrigation_schedules
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: ListIrrigationSchedulesByField :many
SELECT * FROM irrigation_schedules
WHERE tenant_id = $1 AND field_id = $2 AND deleted_at IS NULL
ORDER BY start_time DESC
LIMIT $3 OFFSET $4;

-- name: ListIrrigationSchedulesByZone :many
SELECT * FROM irrigation_schedules
WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL
ORDER BY start_time DESC
LIMIT $3 OFFSET $4;

-- name: ListIrrigationSchedulesByFarm :many
SELECT * FROM irrigation_schedules
WHERE tenant_id = $1 AND farm_id = $2 AND deleted_at IS NULL
ORDER BY start_time DESC
LIMIT $3 OFFSET $4;

-- name: ListIrrigationSchedulesByStatus :many
SELECT * FROM irrigation_schedules
WHERE tenant_id = $1 AND status = $2 AND deleted_at IS NULL
ORDER BY start_time DESC
LIMIT $3 OFFSET $4;

-- name: CountIrrigationSchedulesByField :one
SELECT COUNT(*)::int AS count FROM irrigation_schedules
WHERE tenant_id = $1 AND field_id = $2 AND deleted_at IS NULL;

-- name: CountIrrigationSchedulesByZone :one
SELECT COUNT(*)::int AS count FROM irrigation_schedules
WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL;

-- name: CountIrrigationSchedulesByFarm :one
SELECT COUNT(*)::int AS count FROM irrigation_schedules
WHERE tenant_id = $1 AND farm_id = $2 AND deleted_at IS NULL;

-- name: CountIrrigationSchedulesByStatus :one
SELECT COUNT(*)::int AS count FROM irrigation_schedules
WHERE tenant_id = $1 AND status = $2 AND deleted_at IS NULL;

-- name: UpdateIrrigationSchedule :one
UPDATE irrigation_schedules SET
    name = $3,
    description = $4,
    schedule_type = $5,
    start_time = $6,
    end_time = $7,
    duration_minutes = $8,
    water_quantity_liters = $9,
    flow_rate_liters_per_hour = $10,
    frequency = $11,
    soil_moisture_threshold_pct = $12,
    weather_adjusted = $13,
    crop_growth_stage = $14,
    controller_id = $15,
    status = $16,
    version = version + 1,
    updated_by = $17,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
RETURNING *;

-- name: UpdateIrrigationScheduleStatus :one
UPDATE irrigation_schedules SET
    status = $3,
    version = version + 1,
    updated_by = $4,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteIrrigationSchedule :exec
UPDATE irrigation_schedules SET
    deleted_by = $3,
    deleted_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- ==========================================================================
-- Irrigation Events
-- ==========================================================================

-- name: CreateIrrigationEvent :one
INSERT INTO irrigation_events (
    uuid, tenant_id, schedule_id, zone_id, controller_id, status,
    started_at, ended_at, actual_duration_minutes, actual_water_liters,
    soil_moisture_before_pct, soil_moisture_after_pct, failure_reason,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6,
    $7, $8, $9, $10,
    $11, $12, $13,
    $14, $15, $16
) RETURNING *;

-- name: GetIrrigationEventByUUID :one
SELECT * FROM irrigation_events
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: ListIrrigationEventsByZone :many
SELECT * FROM irrigation_events
WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $3 OFFSET $4;

-- name: ListIrrigationEventsBySchedule :many
SELECT * FROM irrigation_events
WHERE tenant_id = $1 AND schedule_id = $2 AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $3 OFFSET $4;

-- name: ListIrrigationEventsByField :many
SELECT * FROM irrigation_events
WHERE tenant_id = $1
  AND zone_id IN (SELECT uuid FROM irrigation_zones WHERE field_id = $2 AND tenant_id = $1 AND deleted_at IS NULL)
  AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $3 OFFSET $4;

-- name: ListIrrigationEventsByTimeRange :many
SELECT * FROM irrigation_events
WHERE tenant_id = $1 AND zone_id = $2
  AND started_at >= $3 AND started_at <= $4
  AND deleted_at IS NULL
ORDER BY started_at DESC
LIMIT $5 OFFSET $6;

-- name: CountIrrigationEventsByZone :one
SELECT COUNT(*)::int AS count FROM irrigation_events
WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL;

-- name: CountIrrigationEventsBySchedule :one
SELECT COUNT(*)::int AS count FROM irrigation_events
WHERE tenant_id = $1 AND schedule_id = $2 AND deleted_at IS NULL;

-- name: CountIrrigationEventsByTimeRange :one
SELECT COUNT(*)::int AS count FROM irrigation_events
WHERE tenant_id = $1 AND zone_id = $2
  AND started_at >= $3 AND started_at <= $4
  AND deleted_at IS NULL;

-- name: UpdateIrrigationEvent :one
UPDATE irrigation_events SET
    status = $3,
    ended_at = $4,
    actual_duration_minutes = $5,
    actual_water_liters = $6,
    soil_moisture_after_pct = $7,
    failure_reason = $8,
    updated_by = $9,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
RETURNING *;

-- ==========================================================================
-- Irrigation Decisions
-- ==========================================================================

-- name: CreateIrrigationDecision :one
INSERT INTO irrigation_decisions (
    uuid, tenant_id, zone_id, field_id, schedule_id,
    input_soil_moisture, input_temperature, input_humidity,
    input_rainfall_forecast_mm, input_wind_speed, input_crop_type,
    input_growth_stage, input_evapotranspiration_mm,
    output_should_irrigate, output_water_quantity_liters,
    output_duration_minutes, output_optimal_time, output_reasoning,
    output_confidence_score, decided_at, applied,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8,
    $9, $10, $11,
    $12, $13,
    $14, $15,
    $16, $17, $18,
    $19, $20, $21,
    $22, $23, $24
) RETURNING *;

-- name: GetIrrigationDecisionByUUID :one
SELECT * FROM irrigation_decisions
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: ListIrrigationDecisionsByZone :many
SELECT * FROM irrigation_decisions
WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL
ORDER BY decided_at DESC
LIMIT $3 OFFSET $4;

-- name: MarkDecisionApplied :one
UPDATE irrigation_decisions SET
    applied = TRUE,
    updated_by = $3,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
RETURNING *;

-- ==========================================================================
-- Water Usage Logs
-- ==========================================================================

-- name: CreateWaterUsageLog :one
INSERT INTO water_usage_logs (
    uuid, tenant_id, zone_id, controller_id, water_liters,
    recorded_at, period_start, period_end,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8,
    $9, $10, $11
) RETURNING *;

-- name: ListWaterUsageLogs :many
SELECT * FROM water_usage_logs
WHERE tenant_id = $1 AND zone_id = $2
  AND period_start >= $3 AND period_end <= $4
  AND deleted_at IS NULL
ORDER BY recorded_at DESC;

-- name: ListWaterUsageLogsByField :many
SELECT wul.* FROM water_usage_logs wul
INNER JOIN irrigation_zones iz ON wul.zone_id = iz.uuid AND iz.field_id = $2
WHERE wul.tenant_id = $1
  AND wul.period_start >= $3 AND wul.period_end <= $4
  AND wul.deleted_at IS NULL
ORDER BY wul.recorded_at DESC;

-- name: SumWaterUsageByZone :one
SELECT COALESCE(SUM(water_liters), 0)::double precision AS total_liters
FROM water_usage_logs
WHERE tenant_id = $1 AND zone_id = $2
  AND period_start >= $3 AND period_end <= $4
  AND deleted_at IS NULL;

-- name: SumWaterUsageByField :one
SELECT COALESCE(SUM(wul.water_liters), 0)::double precision AS total_liters
FROM water_usage_logs wul
INNER JOIN irrigation_zones iz ON wul.zone_id = iz.uuid AND iz.field_id = $2
WHERE wul.tenant_id = $1
  AND wul.period_start >= $3 AND wul.period_end <= $4
  AND wul.deleted_at IS NULL;
