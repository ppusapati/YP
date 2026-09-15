// Package postgres implements sustainability-service's repository ports using pgx.
package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/sustainability-service/internal/domain"
	"p9e.in/samavaya/agriculture/sustainability-service/internal/ports/outbound"
)

const inputColumns = `
	id, tenant_id, field_id, crop, year, category, product, quantity, unit,
	nitrogen_kg, applied_on, applied_by, notes, organic_permitted, created_at`

const footprintColumns = `
	id, tenant_id, field_id, farm_id, crop, year, area_hectares, water_regime,
	lines, missing_sources, total_kg_co2e, kg_co2e_per_hectare,
	kg_co2e_per_tonne, yield_tonnes, complete, computed_at, method`

// maxUnpagedInputs bounds the unpaged read.
//
// A footprint and a certification check both need every record, not a page —
// but "every record" still has to have a ceiling, or one mis-scripted import
// loop turns a routine check into an out-of-memory. 50,000 applications is
// more than a lifetime of records for one field; hitting it means something
// has gone wrong upstream, and the read says so rather than returning a
// truncated history that a certification check would read as clean.
const maxUnpagedInputs = 50000

type repository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewRepository creates a postgres-backed repository serving both ports.
func NewRepository(pool *pgxpool.Pool, log p9log.Logger) *repository {
	return &repository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "SustainabilityPostgresRepository")),
	}
}

// Compile-time proof that the one type satisfies both ports.
var (
	_ outbound.InputRepository     = (*repository)(nil)
	_ outbound.FootprintRepository = (*repository)(nil)
)

// ─────────────────────────────────────────────────────────────────────────────
// Input use
// ─────────────────────────────────────────────────────────────────────────────

func scanInput(row pgx.Row) (*domain.InputUse, error) {
	var in domain.InputUse
	var nitrogen *float64
	var appliedOn *time.Time

	if err := row.Scan(
		&in.ID, &in.TenantID, &in.FieldID, &in.Crop, &in.Year,
		&in.Category, &in.Product, &in.Quantity, &in.Unit,
		&nitrogen, &appliedOn, &in.AppliedBy, &in.Notes,
		&in.OrganicPermitted, &in.CreatedAt,
	); err != nil {
		return nil, err
	}

	// NULL nitrogen stays zero on the struct, which the domain reads as
	// "unknown". The column is nullable precisely so an unmeasured figure and
	// a measured zero are not the same row.
	if nitrogen != nil {
		in.NitrogenKg = *nitrogen
	}
	if appliedOn != nil {
		in.AppliedOn = *appliedOn
	}
	return &in, nil
}

func (r *repository) CreateInput(ctx context.Context, in *domain.InputUse) (*domain.InputUse, error) {
	var nitrogen *float64
	if in.NitrogenKg > 0 {
		nitrogen = &in.NitrogenKg
	}
	// NULL rather than the zero time when no date was given. Year 1 in a
	// TIMESTAMPTZ column sorts before everything and reads as a real date to
	// every query that touches it.
	var appliedOn *time.Time
	if !in.AppliedOn.IsZero() {
		appliedOn = &in.AppliedOn
	}

	row := r.pool.QueryRow(ctx, `
		INSERT INTO input_uses (
			id, tenant_id, field_id, crop, year, category, product, quantity,
			unit, nitrogen_kg, applied_on, applied_by, notes, organic_permitted,
			created_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)
		RETURNING `+inputColumns,
		in.ID, in.TenantID, in.FieldID, in.Crop, in.Year, string(in.Category),
		in.Product, in.Quantity, in.Unit, nitrogen, appliedOn, in.AppliedBy,
		in.Notes, in.OrganicPermitted, in.CreatedAt)

	created, err := scanInput(row)
	if err != nil {
		r.log.Errorw("msg", "failed to record input use", "field", in.FieldID, "error", err)
		return nil, p9errors.InternalServer("INPUT_CREATE_FAILED", "an internal error occurred")
	}
	return created, nil
}

// inputFilter builds the WHERE clause both input reads share.
func inputFilter(params domain.ListInputUseParams) (string, []any) {
	where := []string{"tenant_id = $1"}
	args := []any{params.TenantID}

	add := func(clause string, value any) {
		args = append(args, value)
		where = append(where, fmt.Sprintf(clause, len(args)))
	}
	if params.FieldID != "" {
		add("field_id = $%d", params.FieldID)
	}
	if params.Year != 0 {
		add("year = $%d", params.Year)
	}
	if params.Category != "" {
		add("category = $%d", string(params.Category))
	}
	if !params.From.IsZero() {
		add("applied_on >= $%d", params.From)
	}
	if !params.To.IsZero() {
		add("applied_on <= $%d", params.To)
	}
	return " WHERE " + strings.Join(where, " AND "), args
}

func (r *repository) ListInputs(ctx context.Context, params domain.ListInputUseParams) ([]domain.InputUse, int64, error) {
	clause, args := inputFilter(params)

	var total int64
	if err := r.pool.QueryRow(ctx,
		"SELECT COUNT(*) FROM input_uses"+clause, args...).Scan(&total); err != nil {
		r.log.Errorw("msg", "failed to count input uses", "error", err)
		return nil, 0, p9errors.InternalServer("INPUT_LIST_FAILED", "an internal error occurred")
	}

	args = append(args, params.Limit, params.Offset)
	rows, err := r.pool.Query(ctx,
		`SELECT `+inputColumns+` FROM input_uses`+clause+
			fmt.Sprintf(" ORDER BY applied_on DESC NULLS LAST, created_at DESC LIMIT $%d OFFSET $%d",
				len(args)-1, len(args)),
		args...)
	if err != nil {
		r.log.Errorw("msg", "failed to list input uses", "error", err)
		return nil, 0, p9errors.InternalServer("INPUT_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	out, err := collectInputs(rows)
	if err != nil {
		return nil, 0, err
	}
	return out, total, nil
}

// AllInputs is the unpaged read a footprint and a certification check need.
//
// Ordered oldest first, which is the order a certification check reads a
// history in and the order an auditor expects the export to be in.
func (r *repository) AllInputs(ctx context.Context, params domain.ListInputUseParams) ([]domain.InputUse, error) {
	clause, args := inputFilter(params)

	args = append(args, maxUnpagedInputs+1)
	rows, err := r.pool.Query(ctx,
		`SELECT `+inputColumns+` FROM input_uses`+clause+
			fmt.Sprintf(" ORDER BY applied_on ASC NULLS FIRST, created_at ASC LIMIT $%d", len(args)),
		args...)
	if err != nil {
		r.log.Errorw("msg", "failed to read the input history", "error", err)
		return nil, p9errors.InternalServer("INPUT_READ_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	out, err := collectInputs(rows)
	if err != nil {
		return nil, err
	}

	// Refused rather than truncated. A certification check run against the
	// first 50,000 of 60,000 records would report a clean field on the strength
	// of the records it happened to read.
	if len(out) > maxUnpagedInputs {
		return nil, p9errors.InternalServer("TOO_MANY_INPUTS", fmt.Sprintf(
			"this field has more than %d input records, which is more than a "+
				"footprint or a certification check can read in one pass. Nothing "+
				"has been computed, because a partial read would look like an answer.",
			maxUnpagedInputs))
	}
	return out, nil
}

func collectInputs(rows pgx.Rows) ([]domain.InputUse, error) {
	var out []domain.InputUse
	for rows.Next() {
		in, err := scanInput(rows)
		if err != nil {
			return nil, p9errors.InternalServer("INPUT_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, *in)
	}
	if err := rows.Err(); err != nil {
		return nil, p9errors.InternalServer("INPUT_READ_FAILED", "an internal error occurred")
	}
	return out, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Footprints
// ─────────────────────────────────────────────────────────────────────────────

func scanFootprint(row pgx.Row) (*domain.Footprint, error) {
	var f domain.Footprint
	var lines, missing []byte

	if err := row.Scan(
		&f.ID, &f.TenantID, &f.FieldID, &f.FarmID, &f.Crop, &f.Year,
		&f.AreaHectares, &f.WaterRegime, &lines, &missing,
		&f.TotalKgCO2e, &f.KgCO2ePerHa, &f.KgCO2ePerTonne, &f.YieldTonnes,
		&f.Complete, &f.ComputedAt, &f.Method,
	); err != nil {
		return nil, err
	}
	if len(lines) > 0 {
		_ = json.Unmarshal(lines, &f.Lines)
	}
	if len(missing) > 0 {
		_ = json.Unmarshal(missing, &f.MissingSources)
	}
	return &f, nil
}

// SaveFootprint writes the current footprint for a field-year.
//
// An upsert on (tenant, field, year): recomputing replaces the previous answer
// rather than adding to it, which is what stops a field carrying three
// different totals for 2026 with nothing to say which one a buyer was shown.
func (r *repository) SaveFootprint(ctx context.Context, f *domain.Footprint) (*domain.Footprint, error) {
	lines, err := json.Marshal(f.Lines)
	if err != nil {
		return nil, p9errors.InternalServer("FOOTPRINT_ENCODE_FAILED", "an internal error occurred")
	}
	missing, err := json.Marshal(f.MissingSources)
	if err != nil {
		return nil, p9errors.InternalServer("FOOTPRINT_ENCODE_FAILED", "an internal error occurred")
	}

	row := r.pool.QueryRow(ctx, `
		INSERT INTO footprints (
			id, tenant_id, field_id, farm_id, crop, year, area_hectares,
			water_regime, lines, missing_sources, total_kg_co2e,
			kg_co2e_per_hectare, kg_co2e_per_tonne, yield_tonnes, complete,
			computed_at, method)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)
		ON CONFLICT (tenant_id, field_id, year) DO UPDATE SET
			farm_id = EXCLUDED.farm_id,
			crop = EXCLUDED.crop,
			area_hectares = EXCLUDED.area_hectares,
			water_regime = EXCLUDED.water_regime,
			lines = EXCLUDED.lines,
			missing_sources = EXCLUDED.missing_sources,
			total_kg_co2e = EXCLUDED.total_kg_co2e,
			kg_co2e_per_hectare = EXCLUDED.kg_co2e_per_hectare,
			kg_co2e_per_tonne = EXCLUDED.kg_co2e_per_tonne,
			yield_tonnes = EXCLUDED.yield_tonnes,
			complete = EXCLUDED.complete,
			computed_at = EXCLUDED.computed_at,
			method = EXCLUDED.method
		RETURNING `+footprintColumns,
		f.ID, f.TenantID, f.FieldID, f.FarmID, f.Crop, f.Year, f.AreaHectares,
		string(f.WaterRegime), lines, missing, f.TotalKgCO2e, f.KgCO2ePerHa,
		f.KgCO2ePerTonne, f.YieldTonnes, f.Complete, f.ComputedAt, f.Method)

	saved, err := scanFootprint(row)
	if err != nil {
		r.log.Errorw("msg", "failed to save footprint", "field", f.FieldID, "error", err)
		return nil, p9errors.InternalServer("FOOTPRINT_SAVE_FAILED", "an internal error occurred")
	}
	return saved, nil
}

func (r *repository) GetFootprint(ctx context.Context, id, tenantID string) (*domain.Footprint, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+footprintColumns+` FROM footprints WHERE id = $1 AND tenant_id = $2`,
		id, tenantID)

	f, err := scanFootprint(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("FOOTPRINT_NOT_FOUND", fmt.Sprintf("footprint not found: %s", id))
		}
		r.log.Errorw("msg", "failed to get footprint", "id", id, "error", err)
		return nil, p9errors.InternalServer("FOOTPRINT_GET_FAILED", "an internal error occurred")
	}
	return f, nil
}

func (r *repository) ListFootprints(ctx context.Context, params domain.ListFootprintsParams) ([]domain.Footprint, int64, error) {
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
	if params.Year != 0 {
		add("year = $%d", params.Year)
	}
	clause := " WHERE " + strings.Join(where, " AND ")

	var total int64
	if err := r.pool.QueryRow(ctx,
		"SELECT COUNT(*) FROM footprints"+clause, args...).Scan(&total); err != nil {
		return nil, 0, p9errors.InternalServer("FOOTPRINT_LIST_FAILED", "an internal error occurred")
	}

	args = append(args, params.Limit, params.Offset)
	rows, err := r.pool.Query(ctx,
		`SELECT `+footprintColumns+` FROM footprints`+clause+
			fmt.Sprintf(" ORDER BY year DESC, computed_at DESC LIMIT $%d OFFSET $%d",
				len(args)-1, len(args)),
		args...)
	if err != nil {
		return nil, 0, p9errors.InternalServer("FOOTPRINT_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	out := make([]domain.Footprint, 0, params.Limit)
	for rows.Next() {
		f, err := scanFootprint(rows)
		if err != nil {
			return nil, 0, p9errors.InternalServer("FOOTPRINT_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, *f)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, p9errors.InternalServer("FOOTPRINT_LIST_FAILED", "an internal error occurred")
	}
	return out, total, nil
}
