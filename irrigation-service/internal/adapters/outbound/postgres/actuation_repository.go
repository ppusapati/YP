package postgres

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
)

// The actuator's two ports, implemented against postgres.
//
// The SQL here is deliberately dull. Everything that involves a judgement —
// whether a zone is still running, how much of a run falls inside the daily
// window, whether a heartbeat is stale — lives in the domain, where it can be
// tested without a database. A query can be read and checked by eye; an
// off-by-one in a rest interval cannot.

// ActuationStore is the narrow view of this repository that the actuator takes.
//
// Narrow on purpose, and it satisfies application.ZoneStateReader and
// application.CommandRecorder between them. Handing the actuator the whole
// IrrigationRepository would give the component that opens valves the ability
// to rewrite schedules and runs, and something would eventually find a reason
// to use it.
type ActuationStore interface {
	ZoneState(ctx context.Context, tenantID, zoneID string) (domain.ZoneState, error)
	ControllerForZone(ctx context.Context, tenantID, zoneID string) (*domain.WaterController, error)
	RecordCommand(ctx context.Context, cmd *domain.IrrigationCommand) error
	RecordOutcome(ctx context.Context, commandID string, accepted bool, detail string) error
}

// NewActuationStore creates the postgres-backed store the actuator uses.
func NewActuationStore(pool *pgxpool.Pool, log p9log.Logger) ActuationStore {
	return &irrigationRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "IrrigationActuationStore")),
	}
}

// ZoneState assembles what the interlocks need to know about a zone now.
func (r *irrigationRepository) ZoneState(ctx context.Context, tenantID, zoneID string) (domain.ZoneState, error) {
	state := domain.ZoneState{ZoneID: zoneID, Limits: domain.DefaultZoneLimits()}

	limits, err := r.zoneLimits(ctx, tenantID, zoneID)
	if err != nil {
		return state, err
	}
	state.Limits = limits

	runs, err := r.recentRuns(ctx, tenantID, zoneID)
	if err != nil {
		return state, err
	}
	summary := domain.SummariseRuns(runs, time.Now())
	state.LastRunEndedAt = summary.LastRunEndedAt
	state.MinutesRunToday = summary.MinutesRunToday
	state.Running = summary.Running

	controller, err := r.ControllerForZone(ctx, tenantID, zoneID)
	if err != nil {
		return state, err
	}
	if controller != nil {
		state.ControllerOnline = domain.ControllerReachable(
			controller.Status, controller.LastHeartbeat, time.Now())
	}
	return state, nil
}

// zoneLimits reads a zone's safety overrides.
//
// The columns are nullable so that "no override" stays distinguishable from
// "set to the same number the code uses", and a NULL takes the package
// default. `automatic` is the exception: NOT NULL DEFAULT FALSE, because a
// zone nobody has opted in must not accept automatic commands.
func (r *irrigationRepository) zoneLimits(ctx context.Context, tenantID, zoneID string) (domain.ZoneLimits, error) {
	limits := domain.DefaultZoneLimits()

	var maxRun, minRest, maxDaily *int32
	var automatic bool
	err := r.queryRow(ctx, `
		SELECT max_run_minutes, min_rest_minutes, max_daily_minutes, automatic
		FROM irrigation_zones
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		zoneID, tenantID,
	).Scan(&maxRun, &minRest, &maxDaily, &automatic)
	switch {
	case err == pgx.ErrNoRows:
		return limits, errors.NotFound("ZONE_NOT_FOUND", "zone not found")
	case err != nil:
		r.log.Errorw("msg", "failed to read zone limits", "zone_id", zoneID, "error", err)
		return limits, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}

	if maxRun != nil {
		limits.MaxRunMinutes = *maxRun
	}
	if minRest != nil {
		limits.MinRestMinutes = *minRest
	}
	if maxDaily != nil {
		limits.MaxDailyMinutes = *maxDaily
	}
	limits.Automatic = automatic
	return limits, nil
}

// recentRuns reads the zone's runs that could still bear on a new command.
//
// Bounded by the daily window plus one maximum run, because a set that began
// before the window may still overlap it, and anything older can affect
// neither the rest interval nor the daily total. It is a handful of rows, so
// the summarising happens in Go rather than in SQL.
func (r *irrigationRepository) recentRuns(ctx context.Context, tenantID, zoneID string) ([]domain.Run, error) {
	since := time.Now().Add(-domain.DailyWindow).
		Add(-time.Duration(domain.MaxRunMinutes) * time.Minute)

	rows, err := r.query(ctx, `
		SELECT started_at, ended_at, COALESCE(actual_duration_minutes, 0)
		FROM irrigation_events
		WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL
		  AND started_at IS NOT NULL AND started_at >= $3
		ORDER BY started_at`,
		tenantID, zoneID, since,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to read recent runs", "zone_id", zoneID, "error", err)
		return nil, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	defer rows.Close()

	var runs []domain.Run
	for rows.Next() {
		var run domain.Run
		var started *time.Time
		if err := rows.Scan(&started, &run.EndedAt, &run.DurationMinutes); err != nil {
			r.log.Errorw("msg", "failed to scan run", "zone_id", zoneID, "error", err)
			return nil, errors.InternalServer("DB_SCAN_ERROR", "an internal error occurred")
		}
		if started == nil {
			continue
		}
		run.StartedAt = *started
		runs = append(runs, run)
	}
	if err := rows.Err(); err != nil {
		r.log.Errorw("msg", "failed to read recent runs", "zone_id", zoneID, "error", err)
		return nil, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	return runs, nil
}

// ControllerForZone returns the controller that serves a zone, or nil.
//
// nil is not an error: a zone may be irrigated by hand, and the actuator turns
// that into a clear "this zone has no controller" rather than a database
// failure the caller has to interpret.
func (r *irrigationRepository) ControllerForZone(ctx context.Context, tenantID, zoneID string) (*domain.WaterController, error) {
	row := r.queryRow(ctx, `
		SELECT id, tenant_id, zone_id, field_id, farm_id, name, model,
			firmware_version, controller_type, protocol, status, endpoint,
			max_flow_rate_liters_per_hour, last_heartbeat, is_active,
			created_by, created_at, updated_at
		FROM water_controllers
		WHERE tenant_id = $1 AND zone_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY created_at
		LIMIT 1`,
		tenantID, zoneID,
	)
	c, err := scanController(row)
	switch {
	case err == pgx.ErrNoRows:
		return nil, nil
	case err != nil:
		r.log.Errorw("msg", "failed to read the zone's controller", "zone_id", zoneID, "error", err)
		return nil, errors.InternalServer("DB_ERROR", "an internal error occurred")
	}
	return c, nil
}

// RecordCommand writes a command before it is sent.
//
// Before, not after: a send that times out otherwise leaves a valve that may
// be open and no row saying so. The outcome columns stay NULL until something
// settles them, and NULL means "not known" rather than "refused".
//
// ON CONFLICT DO NOTHING because the command id is the idempotency key the
// controller sees, so a retry carrying the same id must not produce a second
// row any more than it produces a second run.
func (r *irrigationRepository) RecordCommand(ctx context.Context, cmd *domain.IrrigationCommand) error {
	if cmd == nil {
		return errors.BadRequest("INVALID_COMMAND", "command is required")
	}
	err := r.exec(ctx, `
		INSERT INTO irrigation_commands (
			id, tenant_id, zone_id, controller_id, kind, duration_minutes,
			liters_requested, reason, issued_by, issued_at
		) VALUES ($1, $2, $3, NULLIF($4, ''), $5, $6, $7, $8, $9, $10)
		ON CONFLICT (id) DO NOTHING`,
		cmd.ID, cmd.TenantID, cmd.ZoneID, cmd.ControllerID, string(cmd.Kind),
		cmd.DurationMinutes, cmd.LitersRequested, cmd.Reason, cmd.IssuedBy, cmd.IssuedAt,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to record command", "command_id", cmd.ID, "error", err)
		return errors.InternalServer("COMMAND_RECORD_FAILED", "an internal error occurred")
	}
	return nil
}

// RecordOutcome settles a command once the controller has answered.
//
// Only an unsettled command is updated. A controller that answers twice — a
// late ack after a timeout was already recorded — must not be able to rewrite
// history into something tidier than what happened.
func (r *irrigationRepository) RecordOutcome(ctx context.Context, commandID string, accepted bool, detail string) error {
	if commandID == "" {
		return errors.BadRequest("INVALID_COMMAND", "command id is required")
	}
	err := r.exec(ctx, `
		UPDATE irrigation_commands
		SET accepted = $2, outcome_detail = NULLIF($3, ''), settled_at = NOW()
		WHERE id = $1 AND settled_at IS NULL`,
		commandID, accepted, detail,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to record command outcome",
			"command_id", commandID, "error", err)
		return errors.InternalServer("COMMAND_OUTCOME_FAILED", "an internal error occurred")
	}
	return nil
}
