package postgres

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/outbound"
)

type budgetRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewBudgetRepository creates a postgres-backed BudgetRepository.
func NewBudgetRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.BudgetRepository {
	return &budgetRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "AdvisoryBudgetRepository")),
	}
}

const budgetColumns = `
	tenant_id, daily_cost_micros, daily_question_limit, request_latency_budget_ms,
	window_start, spent_cost_micros, spent_questions`

// GetBudget returns the tenant's budget, defaulting when none is configured.
//
// A missing row is not an error and not unlimited. A tenant that nobody has
// configured gets the defaults, which are generous for a person and ruinous
// for a runaway loop — the shape that keeps the first incident small.
func (r *budgetRepository) GetBudget(ctx context.Context, tenantID string) (domain.Budget, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT `+budgetColumns+` FROM advisory_budgets WHERE tenant_id = $1`, tenantID)

	b, err := scanBudget(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.DefaultBudget(tenantID, time.Now()), nil
	}
	if err != nil {
		r.log.Errorw("msg", "failed to read budget", "error", err)
		return domain.Budget{}, p9errors.InternalServer("BUDGET_GET_FAILED", "an internal error occurred")
	}
	return b, nil
}

func (r *budgetRepository) SetBudget(ctx context.Context, b domain.Budget) (domain.Budget, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO advisory_budgets (
			tenant_id, daily_cost_micros, daily_question_limit,
			request_latency_budget_ms, window_start, updated_at
		) VALUES ($1,$2,$3,$4,$5,NOW())
		ON CONFLICT (tenant_id) DO UPDATE SET
			daily_cost_micros         = EXCLUDED.daily_cost_micros,
			daily_question_limit      = EXCLUDED.daily_question_limit,
			request_latency_budget_ms = EXCLUDED.request_latency_budget_ms,
			updated_at                = NOW()
		RETURNING `+budgetColumns,
		b.TenantID, b.DailyCostMicros, b.DailyQuestionLimit,
		b.RequestLatencyBudget.Milliseconds(), domain.DayStart(time.Now()))

	// The spend counters are deliberately not in the update list. Raising a
	// tenant's ceiling should not also forgive what they have already spent
	// today, which is what writing the in-memory copy back would do.
	got, err := scanBudget(row)
	if err != nil {
		r.log.Errorw("msg", "failed to write budget", "error", err)
		return domain.Budget{}, p9errors.InternalServer("BUDGET_SET_FAILED", "an internal error occurred")
	}
	return got, nil
}

// RecordSpend adds one exchange's usage to the tenant's daily counters.
//
// The roll and the increment happen in a single statement. Reading the row,
// deciding in Go whether the day has turned and writing the total back would
// lose one of two questions asked at the same moment from two phones — each
// would read the same starting figure and write back the same total, and the
// tenant would be billed for one of them.
func (r *budgetRepository) RecordSpend(
	ctx context.Context,
	tenantID string,
	windowStart time.Time,
	u domain.Usage,
) (domain.Budget, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO advisory_budgets (
			tenant_id, window_start, spent_cost_micros, spent_questions, updated_at
		) VALUES ($1, $2, $3, 1, NOW())
		ON CONFLICT (tenant_id) DO UPDATE SET
			-- CASE rather than a separate reset: if the stored window is an
			-- older day, this exchange starts the new day's counters rather
			-- than adding to yesterday's.
			spent_cost_micros = CASE
				WHEN advisory_budgets.window_start < EXCLUDED.window_start THEN EXCLUDED.spent_cost_micros
				ELSE advisory_budgets.spent_cost_micros + EXCLUDED.spent_cost_micros
			END,
			spent_questions = CASE
				WHEN advisory_budgets.window_start < EXCLUDED.window_start THEN 1
				ELSE advisory_budgets.spent_questions + 1
			END,
			window_start = GREATEST(advisory_budgets.window_start, EXCLUDED.window_start),
			updated_at   = NOW()
		RETURNING `+budgetColumns,
		tenantID, domain.DayStart(windowStart), u.CostMicros)

	got, err := scanBudget(row)
	if err != nil {
		r.log.Errorw("msg", "failed to record spend", "error", err)
		return domain.Budget{}, p9errors.InternalServer("BUDGET_SPEND_FAILED", "an internal error occurred")
	}
	return got, nil
}

func scanBudget(row pgx.Row) (domain.Budget, error) {
	var b domain.Budget
	var latencyMS int64
	if err := row.Scan(
		&b.TenantID, &b.DailyCostMicros, &b.DailyQuestionLimit, &latencyMS,
		&b.WindowStart, &b.SpentCostMicros, &b.SpentQuestions,
	); err != nil {
		return domain.Budget{}, err
	}
	b.RequestLatencyBudget = time.Duration(latencyMS) * time.Millisecond
	b.WindowStart = domain.DayStart(b.WindowStart)
	return b, nil
}
