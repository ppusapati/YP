// Package postgres implements the outbound.PlanRepository port using pgx.
package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/planning-service/internal/domain"
	"p9e.in/samavaya/agriculture/planning-service/internal/ports/outbound"
)

const planColumns = `
	id, tenant_id, field_id, farm_id, season, year, crop, variety,
	area_hectares, status, sowing_window, rotation_check, budget,
	target_yield_tonnes_ha, notes, created_by, created_at, updated_at, version`

type planRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewPlanRepository creates a postgres-backed PlanRepository.
func NewPlanRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.PlanRepository {
	return &planRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "PlanningPostgresRepository")),
	}
}

func scanPlan(row pgx.Row) (*domain.SeasonPlan, error) {
	var p domain.SeasonPlan
	var window, rotation, budget []byte

	if err := row.Scan(
		&p.ID, &p.TenantID, &p.FieldID, &p.FarmID, &p.Season, &p.Year,
		&p.Crop, &p.Variety, &p.AreaHectares, &p.Status,
		&window, &rotation, &budget,
		&p.TargetYieldTonnesHa, &p.Notes,
		&p.CreatedBy, &p.CreatedAt, &p.UpdatedAt, &p.Version,
	); err != nil {
		return nil, err
	}

	// A plan whose JSON will not decode is returned with the rest intact rather
	// than failing the read. The stored columns are what the seed was ordered
	// against, and a blank window on a visible plan is something a person can
	// see and fix; a 500 hides the plan entirely.
	if len(window) > 0 {
		_ = json.Unmarshal(window, &p.SowingWindow)
	}
	if len(rotation) > 0 {
		_ = json.Unmarshal(rotation, &p.RotationCheck)
	}
	if len(budget) > 0 {
		_ = json.Unmarshal(budget, &p.Budget)
	}
	return &p, nil
}

func encodePlan(p *domain.SeasonPlan) (window, rotation, budget []byte, err error) {
	if window, err = json.Marshal(p.SowingWindow); err != nil {
		return nil, nil, nil, err
	}
	if rotation, err = json.Marshal(p.RotationCheck); err != nil {
		return nil, nil, nil, err
	}
	if budget, err = json.Marshal(p.Budget); err != nil {
		return nil, nil, nil, err
	}
	return window, rotation, budget, nil
}

func (r *planRepository) CreatePlan(ctx context.Context, p *domain.SeasonPlan) (*domain.SeasonPlan, error) {
	window, rotation, budget, err := encodePlan(p)
	if err != nil {
		return nil, p9errors.InternalServer("PLAN_ENCODE_FAILED", "an internal error occurred")
	}

	row := r.pool.QueryRow(ctx, `
		INSERT INTO season_plans (
			id, tenant_id, field_id, farm_id, season, year, crop, variety,
			area_hectares, status, sowing_window, rotation_check, budget,
			target_yield_tonnes_ha, notes, created_by, created_at, updated_at, version)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19)
		RETURNING `+planColumns,
		p.ID, p.TenantID, p.FieldID, p.FarmID, p.Season, p.Year, p.Crop, p.Variety,
		p.AreaHectares, p.Status, window, rotation, budget,
		p.TargetYieldTonnesHa, p.Notes, p.CreatedBy, p.CreatedAt, p.UpdatedAt, p.Version)

	created, err := scanPlan(row)
	if err != nil {
		// The unique constraint is the one failure a caller can act on: there
		// is already a plan for this field and season, and the answer is to
		// edit it rather than to retry.
		if isUniqueViolation(err) {
			return nil, p9errors.Conflict("PLAN_EXISTS", fmt.Sprintf(
				"this field already has a %s %d plan; edit that one rather than creating a second",
				strings.ToLower(string(p.Season)), p.Year))
		}
		r.log.Errorw("msg", "failed to create plan", "field", p.FieldID, "error", err)
		return nil, p9errors.InternalServer("PLAN_CREATE_FAILED", "an internal error occurred")
	}
	return created, nil
}

func (r *planRepository) GetPlan(ctx context.Context, id, tenantID string) (*domain.SeasonPlan, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+planColumns+` FROM season_plans WHERE id = $1 AND tenant_id = $2`, id, tenantID)

	plan, err := scanPlan(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("PLAN_NOT_FOUND", fmt.Sprintf("plan not found: %s", id))
		}
		r.log.Errorw("msg", "failed to get plan", "id", id, "error", err)
		return nil, p9errors.InternalServer("PLAN_GET_FAILED", "an internal error occurred")
	}
	return plan, nil
}

func (r *planRepository) ListPlans(ctx context.Context, params domain.ListPlansParams) ([]domain.SeasonPlan, int64, error) {
	where := []string{"tenant_id = $1"}
	args := []any{params.TenantID}

	add := func(clause string, value any) {
		args = append(args, value)
		where = append(where, fmt.Sprintf(clause, len(args)))
	}
	if params.FieldID != "" {
		add("field_id = $%d", params.FieldID)
	}
	if params.FarmID != "" {
		add("farm_id = $%d", params.FarmID)
	}
	if params.Season != "" {
		add("season = $%d", string(params.Season))
	}
	if params.Year != 0 {
		add("year = $%d", params.Year)
	}
	if params.Status != "" {
		add("status = $%d", string(params.Status))
	}
	clause := " WHERE " + strings.Join(where, " AND ")

	var total int64
	if err := r.pool.QueryRow(ctx,
		"SELECT COUNT(*) FROM season_plans"+clause, args...).Scan(&total); err != nil {
		r.log.Errorw("msg", "failed to count plans", "error", err)
		return nil, 0, p9errors.InternalServer("PLAN_LIST_FAILED", "an internal error occurred")
	}

	args = append(args, params.Limit, params.Offset)
	rows, err := r.pool.Query(ctx,
		`SELECT `+planColumns+` FROM season_plans`+clause+
			fmt.Sprintf(" ORDER BY year DESC, season, crop LIMIT $%d OFFSET $%d", len(args)-1, len(args)),
		args...)
	if err != nil {
		r.log.Errorw("msg", "failed to list plans", "error", err)
		return nil, 0, p9errors.InternalServer("PLAN_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	out := make([]domain.SeasonPlan, 0, params.Limit)
	for rows.Next() {
		plan, err := scanPlan(rows)
		if err != nil {
			return nil, 0, p9errors.InternalServer("PLAN_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, *plan)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, p9errors.InternalServer("PLAN_LIST_FAILED", "an internal error occurred")
	}
	return out, total, nil
}

// UpdatePlan writes a draft plan back, refusing a stale edit.
//
// The version check is part of the UPDATE rather than a read before it: two
// people editing the same plan from the field is the normal case, and a
// check-then-write would let the second overwrite the first between the two
// statements. baseVersion of 0 means the caller is not tracking versions.
func (r *planRepository) UpdatePlan(ctx context.Context, p *domain.SeasonPlan, baseVersion int64) (*domain.SeasonPlan, error) {
	window, rotation, budget, err := encodePlan(p)
	if err != nil {
		return nil, p9errors.InternalServer("PLAN_ENCODE_FAILED", "an internal error occurred")
	}

	row := r.pool.QueryRow(ctx, `
		UPDATE season_plans SET
			field_id = $3, farm_id = $4, season = $5, year = $6, crop = $7,
			variety = $8, area_hectares = $9, sowing_window = $10,
			rotation_check = $11, budget = $12, target_yield_tonnes_ha = $13,
			notes = $14, updated_at = $15, version = version + 1
		WHERE id = $1 AND tenant_id = $2 AND ($16 = 0 OR version = $16)
		RETURNING `+planColumns,
		p.ID, p.TenantID, p.FieldID, p.FarmID, p.Season, p.Year, p.Crop,
		p.Variety, p.AreaHectares, window, rotation, budget,
		p.TargetYieldTonnesHa, p.Notes, p.UpdatedAt, baseVersion)

	updated, err := scanPlan(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			// No row matched: either the plan is gone or the version moved on.
			// The distinction matters to the caller, so it costs one more query.
			return nil, r.explainMissingUpdate(ctx, p.ID, p.TenantID, baseVersion)
		}
		if isUniqueViolation(err) {
			return nil, p9errors.Conflict("PLAN_EXISTS", fmt.Sprintf(
				"this field already has a %s %d plan",
				strings.ToLower(string(p.Season)), p.Year))
		}
		r.log.Errorw("msg", "failed to update plan", "id", p.ID, "error", err)
		return nil, p9errors.InternalServer("PLAN_UPDATE_FAILED", "an internal error occurred")
	}
	return updated, nil
}

func (r *planRepository) explainMissingUpdate(ctx context.Context, id, tenantID string, baseVersion int64) error {
	var current int64
	err := r.pool.QueryRow(ctx,
		"SELECT version FROM season_plans WHERE id = $1 AND tenant_id = $2", id, tenantID).Scan(&current)
	switch {
	case errors.Is(err, pgx.ErrNoRows):
		return p9errors.NotFound("PLAN_NOT_FOUND", fmt.Sprintf("plan not found: %s", id))
	case err != nil:
		return p9errors.InternalServer("PLAN_UPDATE_FAILED", "an internal error occurred")
	default:
		return p9errors.Conflict("PLAN_VERSION_STALE", fmt.Sprintf(
			"%s: you edited version %d and it is now at version %d",
			domain.ErrVersionStale.Error(), baseVersion, current))
	}
}

func (r *planRepository) SetStatus(ctx context.Context, id, tenantID string, status domain.PlanStatus) (*domain.SeasonPlan, error) {
	row := r.pool.QueryRow(ctx, `
		UPDATE season_plans
		SET status = $3, updated_at = NOW(), version = version + 1
		WHERE id = $1 AND tenant_id = $2
		RETURNING `+planColumns, id, tenantID, string(status))

	updated, err := scanPlan(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("PLAN_NOT_FOUND", fmt.Sprintf("plan not found: %s", id))
		}
		r.log.Errorw("msg", "failed to set plan status", "id", id, "error", err)
		return nil, p9errors.InternalServer("PLAN_STATUS_FAILED", "an internal error occurred")
	}
	return updated, nil
}

// PreviousCrop is the crop this field last grew before the given season.
//
// Draft plans are excluded. A draft is a thing somebody is still thinking
// about, and rotating against a crop that was never sown would give a verdict
// on a history that did not happen.
//
// Ordering is by (year, season) with the season ranked in calendar order, so
// a rabi plan in 2025 correctly follows kharif 2025 rather than rabi 2024.
func (r *planRepository) PreviousCrop(ctx context.Context, tenantID, fieldID string, beforeYear int, beforeSeason domain.Season) (string, error) {
	var crop string
	err := r.pool.QueryRow(ctx, `
		SELECT crop FROM season_plans
		WHERE tenant_id = $1
		  AND field_id = $2
		  AND status IN ('COMMITTED', 'COMPLETED')
		  AND (year, `+seasonRankSQL+`) < ($3, $4)
		ORDER BY year DESC, `+seasonRankSQL+` DESC
		LIMIT 1`,
		tenantID, fieldID, beforeYear, seasonRank(beforeSeason)).Scan(&crop)

	switch {
	case errors.Is(err, pgx.ErrNoRows):
		// Not an error. A newly broken field has no history, and the rotation
		// check reports that as unverified rather than as a failure.
		return "", nil
	case err != nil:
		r.log.Warnw("msg", "failed to read cropping history", "field", fieldID, "error", err)
		return "", p9errors.InternalServer("PLAN_HISTORY_FAILED", "an internal error occurred")
	default:
		return crop, nil
	}
}

// seasonRankSQL orders the seasons within a year the way the calendar runs.
//
// Zaid (March) comes first, then kharif (June), then rabi (October). Sorting
// the season text alphabetically would put kharif before rabi before zaid,
// which is only accidentally right for two of the three pairs.
const seasonRankSQL = `CASE season WHEN 'ZAID' THEN 1 WHEN 'KHARIF' THEN 2 WHEN 'RABI' THEN 3 ELSE 0 END`

func seasonRank(s domain.Season) int {
	switch s {
	case domain.Zaid:
		return 1
	case domain.Kharif:
		return 2
	case domain.Rabi:
		return 3
	default:
		return 0
	}
}

func isUniqueViolation(err error) bool {
	return strings.Contains(err.Error(), "23505") ||
		strings.Contains(strings.ToLower(err.Error()), "duplicate key")
}
