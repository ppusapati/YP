// Package postgres implements finance-service's repository ports using pgx.
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

	"p9e.in/samavaya/agriculture/finance-service/internal/domain"
	"p9e.in/samavaya/agriculture/finance-service/internal/ports/outbound"
)

const quoteColumns = `
	id, tenant_id, field_id, farm_id, crop, category, season, year,
	area_hectares, sum_insured_per_hectare, total_sum_insured,
	indemnity_level, threshold_yield_kg_ha, lines, actuarial_premium,
	actuarial_rate, farmer_premium, subsidy, confidence, history_seasons,
	basis, quoted_at, expires_at`

const creditColumns = `
	id, tenant_id, farm_id, status, score, band, factors, seasons_considered,
	mean_yield_kg_ha, yield_variability, mean_profit_per_hectare,
	indicative_limit, caveat, assessed_at`

const claimColumns = `
	id, tenant_id, quote_id, field_id, farm_id, crop, season, year, cause,
	loss_started_on, loss_ended_on, description, status,
	claimed_area_hectares, reported_yield_kg_ha, threshold_yield_kg_ha,
	indicated_payout, evidence, evidence_summary, submitted_by, submitted_at,
	created_at, updated_at, version`

type repository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewRepository creates a postgres-backed repository serving all three ports.
func NewRepository(pool *pgxpool.Pool, log p9log.Logger) *repository {
	return &repository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "FinancePostgresRepository")),
	}
}

// Compile-time proof that the one type satisfies all three ports.
var (
	_ outbound.QuoteRepository  = (*repository)(nil)
	_ outbound.CreditRepository = (*repository)(nil)
	_ outbound.ClaimRepository  = (*repository)(nil)
)

// ─────────────────────────────────────────────────────────────────────────────
// Quotes
// ─────────────────────────────────────────────────────────────────────────────

func scanQuote(row pgx.Row) (*domain.InsuranceQuote, error) {
	var q domain.InsuranceQuote
	var lines []byte

	if err := row.Scan(
		&q.ID, &q.TenantID, &q.FieldID, &q.FarmID, &q.Crop, &q.Category,
		&q.Season, &q.Year, &q.AreaHectares, &q.SumInsuredPerHectare,
		&q.TotalSumInsured, &q.IndemnityLevel, &q.ThresholdYieldKgHa, &lines,
		&q.ActuarialPremium, &q.ActuarialRate, &q.FarmerPremium, &q.Subsidy,
		&q.Confidence, &q.HistorySeasons, &q.Basis, &q.QuotedAt, &q.ExpiresAt,
	); err != nil {
		return nil, err
	}
	if len(lines) > 0 {
		_ = json.Unmarshal(lines, &q.Lines)
	}
	return &q, nil
}

func (r *repository) CreateQuote(ctx context.Context, q *domain.InsuranceQuote) (*domain.InsuranceQuote, error) {
	lines, err := json.Marshal(q.Lines)
	if err != nil {
		return nil, p9errors.InternalServer("QUOTE_ENCODE_FAILED", "an internal error occurred")
	}

	row := r.pool.QueryRow(ctx, `
		INSERT INTO insurance_quotes (
			id, tenant_id, field_id, farm_id, crop, category, season, year,
			area_hectares, sum_insured_per_hectare, total_sum_insured,
			indemnity_level, threshold_yield_kg_ha, lines, actuarial_premium,
			actuarial_rate, farmer_premium, subsidy, confidence, history_seasons,
			basis, quoted_at, expires_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,
			$19,$20,$21,$22,$23)
		RETURNING `+quoteColumns,
		q.ID, q.TenantID, q.FieldID, q.FarmID, q.Crop, string(q.Category),
		string(q.Season), q.Year, q.AreaHectares, q.SumInsuredPerHectare,
		q.TotalSumInsured, q.IndemnityLevel, q.ThresholdYieldKgHa, lines,
		q.ActuarialPremium, q.ActuarialRate, q.FarmerPremium, q.Subsidy,
		string(q.Confidence), q.HistorySeasons, q.Basis, q.QuotedAt, q.ExpiresAt)

	created, err := scanQuote(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create quote", "field", q.FieldID, "error", err)
		return nil, p9errors.InternalServer("QUOTE_CREATE_FAILED", "an internal error occurred")
	}
	return created, nil
}

func (r *repository) GetQuote(ctx context.Context, id, tenantID string) (*domain.InsuranceQuote, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+quoteColumns+` FROM insurance_quotes WHERE id = $1 AND tenant_id = $2`,
		id, tenantID)

	q, err := scanQuote(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("QUOTE_NOT_FOUND", fmt.Sprintf("quote not found: %s", id))
		}
		r.log.Errorw("msg", "failed to get quote", "id", id, "error", err)
		return nil, p9errors.InternalServer("QUOTE_GET_FAILED", "an internal error occurred")
	}
	return q, nil
}

func (r *repository) ListQuotes(ctx context.Context, params domain.ListQuotesParams) ([]domain.InsuranceQuote, int64, error) {
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
		"SELECT COUNT(*) FROM insurance_quotes"+clause, args...).Scan(&total); err != nil {
		return nil, 0, p9errors.InternalServer("QUOTE_LIST_FAILED", "an internal error occurred")
	}

	args = append(args, params.Limit, params.Offset)
	rows, err := r.pool.Query(ctx,
		`SELECT `+quoteColumns+` FROM insurance_quotes`+clause+
			fmt.Sprintf(" ORDER BY quoted_at DESC LIMIT $%d OFFSET $%d", len(args)-1, len(args)),
		args...)
	if err != nil {
		return nil, 0, p9errors.InternalServer("QUOTE_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	out := make([]domain.InsuranceQuote, 0, params.Limit)
	for rows.Next() {
		q, err := scanQuote(rows)
		if err != nil {
			return nil, 0, p9errors.InternalServer("QUOTE_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, *q)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, p9errors.InternalServer("QUOTE_LIST_FAILED", "an internal error occurred")
	}
	return out, total, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Credit
// ─────────────────────────────────────────────────────────────────────────────

func scanAssessment(row pgx.Row) (*domain.CreditAssessment, error) {
	var a domain.CreditAssessment
	var factors []byte

	if err := row.Scan(
		&a.ID, &a.TenantID, &a.FarmID, &a.Status, &a.Score, &a.Band, &factors,
		&a.SeasonsConsidered, &a.MeanYieldKgHa, &a.YieldVariability,
		&a.MeanProfitPerHa, &a.IndicativeLimit, &a.Caveat, &a.AssessedAt,
	); err != nil {
		return nil, err
	}
	if len(factors) > 0 {
		_ = json.Unmarshal(factors, &a.Factors)
	}
	return &a, nil
}

// SaveAssessment stores a credit reading.
//
// Every assessment is kept rather than overwriting the farm's previous one. A
// score is a thing somebody may have been lent money against, and a table that
// holds only the current answer cannot say what the lender was shown.
func (r *repository) SaveAssessment(ctx context.Context, a *domain.CreditAssessment) (*domain.CreditAssessment, error) {
	factors, err := json.Marshal(a.Factors)
	if err != nil {
		return nil, p9errors.InternalServer("CREDIT_ENCODE_FAILED", "an internal error occurred")
	}

	row := r.pool.QueryRow(ctx, `
		INSERT INTO credit_assessments (
			id, tenant_id, farm_id, status, score, band, factors,
			seasons_considered, mean_yield_kg_ha, yield_variability,
			mean_profit_per_hectare, indicative_limit, caveat, assessed_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
		RETURNING `+creditColumns,
		a.ID, a.TenantID, a.FarmID, string(a.Status), a.Score, string(a.Band),
		factors, a.SeasonsConsidered, a.MeanYieldKgHa, a.YieldVariability,
		a.MeanProfitPerHa, a.IndicativeLimit, a.Caveat, a.AssessedAt)

	saved, err := scanAssessment(row)
	if err != nil {
		r.log.Errorw("msg", "failed to save credit assessment", "farm", a.FarmID, "error", err)
		return nil, p9errors.InternalServer("CREDIT_SAVE_FAILED", "an internal error occurred")
	}
	return saved, nil
}

func (r *repository) GetAssessment(ctx context.Context, id, tenantID string) (*domain.CreditAssessment, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+creditColumns+` FROM credit_assessments WHERE id = $1 AND tenant_id = $2`,
		id, tenantID)

	a, err := scanAssessment(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("ASSESSMENT_NOT_FOUND",
				fmt.Sprintf("credit assessment not found: %s", id))
		}
		return nil, p9errors.InternalServer("CREDIT_GET_FAILED", "an internal error occurred")
	}
	return a, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Claims
// ─────────────────────────────────────────────────────────────────────────────

func scanClaim(row pgx.Row) (*domain.Claim, error) {
	var c domain.Claim
	var evidence []byte
	var lossEnded, submittedAt *time.Time

	if err := row.Scan(
		&c.ID, &c.TenantID, &c.QuoteID, &c.FieldID, &c.FarmID, &c.Crop,
		&c.Season, &c.Year, &c.Cause, &c.LossStartedOn, &lossEnded,
		&c.Description, &c.Status, &c.ClaimedAreaHectares, &c.ReportedYieldKgHa,
		&c.ThresholdYieldKgHa, &c.IndicatedPayout, &evidence, &c.EvidenceSummary,
		&c.SubmittedBy, &submittedAt, &c.CreatedAt, &c.UpdatedAt, &c.Version,
	); err != nil {
		return nil, err
	}
	if lossEnded != nil {
		c.LossEndedOn = *lossEnded
	}
	if submittedAt != nil {
		c.SubmittedAt = *submittedAt
	}
	if len(evidence) > 0 {
		_ = json.Unmarshal(evidence, &c.Evidence)
	}
	return &c, nil
}

func claimTimes(c *domain.Claim) (lossEnded, submittedAt *time.Time) {
	// NULL rather than the zero time. Year 1 in a TIMESTAMPTZ column reads as a
	// real date to every query that touches it, and "the loss ended in the year
	// 1" would quietly become an evidence window fifteen centuries wide.
	if !c.LossEndedOn.IsZero() {
		lossEnded = &c.LossEndedOn
	}
	if !c.SubmittedAt.IsZero() {
		submittedAt = &c.SubmittedAt
	}
	return lossEnded, submittedAt
}

func (r *repository) CreateClaim(ctx context.Context, c *domain.Claim) (*domain.Claim, error) {
	evidence, err := json.Marshal(c.Evidence)
	if err != nil {
		return nil, p9errors.InternalServer("CLAIM_ENCODE_FAILED", "an internal error occurred")
	}
	lossEnded, submittedAt := claimTimes(c)

	row := r.pool.QueryRow(ctx, `
		INSERT INTO claims (
			id, tenant_id, quote_id, field_id, farm_id, crop, season, year,
			cause, loss_started_on, loss_ended_on, description, status,
			claimed_area_hectares, reported_yield_kg_ha, threshold_yield_kg_ha,
			indicated_payout, evidence, evidence_summary, submitted_by,
			submitted_at, created_at, updated_at, version)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,
			$19,$20,$21,$22,$23,$24)
		RETURNING `+claimColumns,
		c.ID, c.TenantID, c.QuoteID, c.FieldID, c.FarmID, c.Crop, string(c.Season),
		c.Year, string(c.Cause), c.LossStartedOn, lossEnded, c.Description,
		string(c.Status), c.ClaimedAreaHectares, c.ReportedYieldKgHa,
		c.ThresholdYieldKgHa, c.IndicatedPayout, evidence, c.EvidenceSummary,
		c.SubmittedBy, submittedAt, c.CreatedAt, c.UpdatedAt, c.Version)

	created, err := scanClaim(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create claim", "field", c.FieldID, "error", err)
		return nil, p9errors.InternalServer("CLAIM_CREATE_FAILED", "an internal error occurred")
	}
	return created, nil
}

func (r *repository) GetClaim(ctx context.Context, id, tenantID string) (*domain.Claim, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+claimColumns+` FROM claims WHERE id = $1 AND tenant_id = $2`, id, tenantID)

	c, err := scanClaim(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("CLAIM_NOT_FOUND", fmt.Sprintf("claim not found: %s", id))
		}
		r.log.Errorw("msg", "failed to get claim", "id", id, "error", err)
		return nil, p9errors.InternalServer("CLAIM_GET_FAILED", "an internal error occurred")
	}
	return c, nil
}

func (r *repository) ListClaims(ctx context.Context, params domain.ListClaimsParams) ([]domain.Claim, int64, error) {
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
	if params.Status != "" {
		add("status = $%d", string(params.Status))
	}
	clause := " WHERE " + strings.Join(where, " AND ")

	var total int64
	if err := r.pool.QueryRow(ctx,
		"SELECT COUNT(*) FROM claims"+clause, args...).Scan(&total); err != nil {
		return nil, 0, p9errors.InternalServer("CLAIM_LIST_FAILED", "an internal error occurred")
	}

	args = append(args, params.Limit, params.Offset)
	rows, err := r.pool.Query(ctx,
		`SELECT `+claimColumns+` FROM claims`+clause+
			fmt.Sprintf(" ORDER BY created_at DESC LIMIT $%d OFFSET $%d", len(args)-1, len(args)),
		args...)
	if err != nil {
		return nil, 0, p9errors.InternalServer("CLAIM_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	out := make([]domain.Claim, 0, params.Limit)
	for rows.Next() {
		c, err := scanClaim(rows)
		if err != nil {
			return nil, 0, p9errors.InternalServer("CLAIM_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, *c)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, p9errors.InternalServer("CLAIM_LIST_FAILED", "an internal error occurred")
	}
	return out, total, nil
}

func (r *repository) SaveClaim(ctx context.Context, c *domain.Claim) (*domain.Claim, error) {
	evidence, err := json.Marshal(c.Evidence)
	if err != nil {
		return nil, p9errors.InternalServer("CLAIM_ENCODE_FAILED", "an internal error occurred")
	}
	lossEnded, submittedAt := claimTimes(c)

	row := r.pool.QueryRow(ctx, `
		UPDATE claims SET
			cause = $3, loss_started_on = $4, loss_ended_on = $5,
			description = $6, status = $7, claimed_area_hectares = $8,
			reported_yield_kg_ha = $9, threshold_yield_kg_ha = $10,
			indicated_payout = $11, evidence = $12, evidence_summary = $13,
			submitted_by = $14, submitted_at = $15, updated_at = $16,
			version = version + 1
		WHERE id = $1 AND tenant_id = $2
		RETURNING `+claimColumns,
		c.ID, c.TenantID, string(c.Cause), c.LossStartedOn, lossEnded,
		c.Description, string(c.Status), c.ClaimedAreaHectares,
		c.ReportedYieldKgHa, c.ThresholdYieldKgHa, c.IndicatedPayout, evidence,
		c.EvidenceSummary, c.SubmittedBy, submittedAt, c.UpdatedAt)

	saved, err := scanClaim(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, p9errors.NotFound("CLAIM_NOT_FOUND", fmt.Sprintf("claim not found: %s", c.ID))
		}
		r.log.Errorw("msg", "failed to save claim", "id", c.ID, "error", err)
		return nil, p9errors.InternalServer("CLAIM_SAVE_FAILED", "an internal error occurred")
	}
	return saved, nil
}
