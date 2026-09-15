// Package postgres implements the outbound.DeviceRepository port using pgx.
package postgres

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/device-service/internal/domain"
	"p9e.in/samavaya/agriculture/device-service/internal/ports/outbound"
)

const deviceColumns = `
	id, tenant_id, serial, name, kind, farm_id, field_id, fleet,
	firmware_version, hardware_revision, latitude, longitude,
	provisioned_at, last_seen_at, battery_percent, signal_dbm, fault,
	enrolment_token_hash, retired_at, retired_reason`

type deviceRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewDeviceRepository creates a postgres-backed DeviceRepository.
func NewDeviceRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.DeviceRepository {
	return &deviceRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "DevicePostgresRepository")),
	}
}

func scanDevice(row pgx.Row) (*domain.Device, error) {
	var d domain.Device
	if err := row.Scan(
		&d.ID, &d.TenantID, &d.Serial, &d.Name, &d.Kind, &d.FarmID, &d.FieldID, &d.Fleet,
		&d.FirmwareVersion, &d.HardwareRevision, &d.Latitude, &d.Longitude,
		&d.ProvisionedAt, &d.LastSeenAt, &d.BatteryPercent, &d.SignalDBM, &d.Fault,
		&d.EnrolmentTokenHash, &d.RetiredAt, &d.RetiredReason,
	); err != nil {
		return nil, err
	}
	return &d, nil
}

func (r *deviceRepository) CreateDevice(ctx context.Context, d *domain.Device) (*domain.Device, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO devices (
			id, tenant_id, serial, name, kind, farm_id, field_id, fleet,
			firmware_version, hardware_revision, latitude, longitude,
			provisioned_at, enrolment_token_hash
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
		RETURNING `+deviceColumns,
		d.ID, d.TenantID, d.Serial, d.Name, string(d.Kind), d.FarmID, d.FieldID, d.Fleet,
		d.FirmwareVersion, d.HardwareRevision, d.Latitude, d.Longitude,
		d.ProvisionedAt, d.EnrolmentTokenHash,
	)

	created, err := scanDevice(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create device", "serial", d.Serial, "error", err)
		return nil, p9errors.InternalServer("DEVICE_CREATE_FAILED", "an internal error occurred")
	}
	return created, nil
}

func (r *deviceRepository) GetDevice(ctx context.Context, id, tenantID string) (*domain.Device, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+deviceColumns+` FROM devices WHERE id = $1 AND tenant_id = $2`, id, tenantID)

	d, err := scanDevice(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("DEVICE_NOT_FOUND", fmt.Sprintf("device not found: %s", id))
		}
		return nil, p9errors.InternalServer("DEVICE_GET_FAILED", "an internal error occurred")
	}
	return d, nil
}

func (r *deviceRepository) GetDeviceBySerial(ctx context.Context, serial, tenantID string) (*domain.Device, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+deviceColumns+` FROM devices WHERE serial = $1 AND tenant_id = $2`, serial, tenantID)

	d, err := scanDevice(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("DEVICE_NOT_FOUND", fmt.Sprintf("device not found: %s", serial))
		}
		return nil, p9errors.InternalServer("DEVICE_GET_FAILED", "an internal error occurred")
	}
	return d, nil
}

func (r *deviceRepository) ListDevices(ctx context.Context, params domain.ListDevicesParams) ([]domain.Device, int64, error) {
	where := []string{"tenant_id = $1"}
	args := []any{params.TenantID}

	for _, f := range []struct {
		column string
		value  string
	}{
		{"fleet", params.Fleet},
		{"farm_id", params.FarmID},
		{"field_id", params.FieldID},
		{"kind", string(params.Kind)},
	} {
		if f.value != "" {
			args = append(args, f.value)
			where = append(where, fmt.Sprintf("%s = $%d", f.column, len(args)))
		}
	}

	// Status is not a column — it is derived from last_seen_at on read — so it
	// is not a filter here. The application layer applies it, which keeps the
	// rule in one place rather than in SQL and in Go where they would drift.
	clause := strings.Join(where, " AND ")

	var total int64
	if err := r.pool.QueryRow(ctx,
		"SELECT COUNT(*) FROM devices WHERE "+clause, args...,
	).Scan(&total); err != nil {
		return nil, 0, p9errors.InternalServer("DEVICE_LIST_FAILED", "an internal error occurred")
	}

	args = append(args, params.Limit, params.Offset)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(
		`SELECT %s FROM devices WHERE %s ORDER BY serial LIMIT $%d OFFSET $%d`,
		deviceColumns, clause, len(args)-1, len(args)), args...)
	if err != nil {
		return nil, 0, p9errors.InternalServer("DEVICE_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	out, err := collectDevices(rows)
	return out, total, err
}

func (r *deviceRepository) FleetDevices(ctx context.Context, tenantID, fleet string) ([]domain.Device, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT `+deviceColumns+` FROM devices WHERE tenant_id = $1 AND fleet = $2`,
		tenantID, fleet)
	if err != nil {
		return nil, p9errors.InternalServer("FLEET_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()
	return collectDevices(rows)
}

func collectDevices(rows pgx.Rows) ([]domain.Device, error) {
	var out []domain.Device
	for rows.Next() {
		d, err := scanDevice(rows)
		if err != nil {
			return nil, p9errors.InternalServer("DEVICE_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, *d)
	}
	return out, rows.Err()
}

func (r *deviceRepository) UpdateDeviceHealth(ctx context.Context, d *domain.Device) error {
	// last_seen_at only moves forward. A replayed backlog arrives in whatever
	// order it was queued, and an older reading must not roll the device's
	// state back — the domain checks this too, and so does the statement, so
	// a future caller that skips the domain cannot undo it.
	tag, err := r.pool.Exec(ctx, `
		UPDATE devices SET
			last_seen_at = $3,
			battery_percent = $4,
			signal_dbm = $5,
			fault = $6,
			firmware_version = COALESCE(NULLIF($7, ''), firmware_version),
			updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2
		  AND (last_seen_at IS NULL OR last_seen_at < $3)`,
		d.ID, d.TenantID, d.LastSeenAt, d.BatteryPercent, d.SignalDBM, d.Fault, d.FirmwareVersion,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to update device health", "device", d.ID, "error", err)
		return p9errors.InternalServer("DEVICE_HEALTH_FAILED", "an internal error occurred")
	}
	if tag.RowsAffected() == 0 {
		// The row exists — the caller loaded it — so zero rows means a
		// concurrent heartbeat already wrote something newer. Not an error.
		r.log.Debugw("msg", "a newer heartbeat won", "device", d.ID)
	}
	return nil
}

func (r *deviceRepository) RetireDevice(ctx context.Context, id, tenantID, reason string) (*domain.Device, error) {
	row := r.pool.QueryRow(ctx, `
		UPDATE devices SET retired_at = NOW(), retired_reason = $3, updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2 AND retired_at IS NULL
		RETURNING `+deviceColumns,
		id, tenantID, reason)

	d, err := scanDevice(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			// Either it does not exist or it is already retired. Retiring twice
			// is not a failure worth surfacing, so the second read decides.
			existing, getErr := r.GetDevice(ctx, id, tenantID)
			if getErr == nil {
				return existing, nil
			}
			return nil, p9errors.NotFound("DEVICE_NOT_FOUND", fmt.Sprintf("device not found: %s", id))
		}
		return nil, p9errors.InternalServer("DEVICE_RETIRE_FAILED", "an internal error occurred")
	}
	return d, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Rollouts
// ─────────────────────────────────────────────────────────────────────────────

const rolloutColumns = `
	id, tenant_id, fleet, kind, version, artifact_url, artifact_sha256,
	state, stage_percent, failure_threshold, offered, succeeded, failed,
	halted_reason, created_by, created_at`

func scanRollout(row pgx.Row) (*domain.FirmwareRollout, error) {
	var r domain.FirmwareRollout
	if err := row.Scan(
		&r.ID, &r.TenantID, &r.Fleet, &r.Kind, &r.Version, &r.ArtifactURL, &r.ArtifactSHA256,
		&r.State, &r.StagePercent, &r.FailureThreshold, &r.Offered, &r.Succeeded, &r.Failed,
		&r.HaltedReason, &r.CreatedBy, &r.CreatedAt,
	); err != nil {
		return nil, err
	}
	return &r, nil
}

func (r *deviceRepository) CreateRollout(ctx context.Context, rollout *domain.FirmwareRollout) (*domain.FirmwareRollout, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO firmware_rollouts (
			id, tenant_id, fleet, kind, version, artifact_url, artifact_sha256,
			state, stage_percent, failure_threshold, created_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
		RETURNING `+rolloutColumns,
		rollout.ID, rollout.TenantID, rollout.Fleet, string(rollout.Kind),
		rollout.Version, rollout.ArtifactURL, rollout.ArtifactSHA256,
		string(rollout.State), rollout.StagePercent, rollout.FailureThreshold, rollout.CreatedBy,
	)

	created, err := scanRollout(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create rollout", "error", err)
		return nil, p9errors.InternalServer("ROLLOUT_CREATE_FAILED", "an internal error occurred")
	}
	return created, nil
}

func (r *deviceRepository) GetRollout(ctx context.Context, id, tenantID string) (*domain.FirmwareRollout, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+rolloutColumns+` FROM firmware_rollouts WHERE id = $1 AND tenant_id = $2`,
		id, tenantID)

	rollout, err := scanRollout(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("ROLLOUT_NOT_FOUND", fmt.Sprintf("rollout not found: %s", id))
		}
		return nil, p9errors.InternalServer("ROLLOUT_GET_FAILED", "an internal error occurred")
	}
	return rollout, nil
}

func (r *deviceRepository) SaveRollout(ctx context.Context, rollout *domain.FirmwareRollout) error {
	_, err := r.pool.Exec(ctx, `
		UPDATE firmware_rollouts SET
			state = $3, stage_percent = $4,
			offered = $5, succeeded = $6, failed = $7,
			halted_reason = $8, updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2`,
		rollout.ID, rollout.TenantID, string(rollout.State), rollout.StagePercent,
		rollout.Offered, rollout.Succeeded, rollout.Failed, rollout.HaltedReason,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to save rollout", "rollout", rollout.ID, "error", err)
		return p9errors.InternalServer("ROLLOUT_SAVE_FAILED", "an internal error occurred")
	}
	return nil
}

func (r *deviceRepository) ListRollouts(ctx context.Context, params domain.ListRolloutsParams) ([]domain.FirmwareRollout, int64, error) {
	where := []string{"tenant_id = $1"}
	args := []any{params.TenantID}
	if params.Fleet != "" {
		args = append(args, params.Fleet)
		where = append(where, fmt.Sprintf("fleet = $%d", len(args)))
	}
	clause := strings.Join(where, " AND ")

	var total int64
	if err := r.pool.QueryRow(ctx,
		"SELECT COUNT(*) FROM firmware_rollouts WHERE "+clause, args...,
	).Scan(&total); err != nil {
		return nil, 0, p9errors.InternalServer("ROLLOUT_LIST_FAILED", "an internal error occurred")
	}

	args = append(args, params.Limit, params.Offset)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(
		`SELECT %s FROM firmware_rollouts WHERE %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d`,
		rolloutColumns, clause, len(args)-1, len(args)), args...)
	if err != nil {
		return nil, 0, p9errors.InternalServer("ROLLOUT_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	var out []domain.FirmwareRollout
	for rows.Next() {
		rollout, err := scanRollout(rows)
		if err != nil {
			return nil, 0, p9errors.InternalServer("ROLLOUT_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, *rollout)
	}
	return out, total, rows.Err()
}

func (r *deviceRepository) UpsertDeviceUpdate(ctx context.Context, u *domain.DeviceUpdate) error {
	// One row per device per rollout: a device reporting DOWNLOADING then
	// FAILED leaves one record of where it got to, not a log to reduce.
	_, err := r.pool.Exec(ctx, `
		INSERT INTO device_updates (device_id, rollout_id, tenant_id, state, detail, updated_at)
		VALUES ($1,$2,$3,$4,$5,$6)
		ON CONFLICT (rollout_id, device_id)
		DO UPDATE SET state = EXCLUDED.state, detail = EXCLUDED.detail,
		              updated_at = EXCLUDED.updated_at`,
		u.DeviceID, u.RolloutID, u.TenantID, string(u.State), u.Detail, u.UpdatedAt,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to record device update", "device", u.DeviceID, "error", err)
		return p9errors.InternalServer("UPDATE_RECORD_FAILED", "an internal error occurred")
	}
	return nil
}
