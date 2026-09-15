// Package postgres implements the outbound.MarketRepository port using pgx.
package postgres

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/market-service/internal/domain"
	"p9e.in/samavaya/agriculture/market-service/internal/ports/outbound"
)

type marketRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewMarketRepository creates a postgres-backed MarketRepository.
func NewMarketRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.MarketRepository {
	return &marketRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "MarketPostgresRepository")),
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Markets
// ─────────────────────────────────────────────────────────────────────────────

func (r *marketRepository) ListMarkets(ctx context.Context, params domain.ListMarketsParams) ([]domain.Market, int64, error) {
	where := []string{"tenant_id = $1"}
	args := []any{params.TenantID}

	if params.State != "" {
		args = append(args, params.State)
		where = append(where, fmt.Sprintf("state = $%d", len(args)))
	}
	if params.District != "" {
		args = append(args, params.District)
		where = append(where, fmt.Sprintf("district = $%d", len(args)))
	}
	if params.Kind != "" {
		args = append(args, string(params.Kind))
		where = append(where, fmt.Sprintf("kind = $%d", len(args)))
	}

	clause := strings.Join(where, " AND ")

	var total int64
	if err := r.pool.QueryRow(ctx,
		"SELECT COUNT(*) FROM markets WHERE "+clause, args...,
	).Scan(&total); err != nil {
		r.log.Errorw("msg", "failed to count markets", "error", err)
		return nil, 0, p9errors.InternalServer("MARKET_LIST_FAILED", "an internal error occurred")
	}

	args = append(args, params.Limit, params.Offset)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT id, tenant_id, name, kind, state, district,
		       latitude, longitude, external_ref, created_at, updated_at
		FROM markets WHERE %s
		ORDER BY name
		LIMIT $%d OFFSET $%d`, clause, len(args)-1, len(args)), args...)
	if err != nil {
		r.log.Errorw("msg", "failed to list markets", "error", err)
		return nil, 0, p9errors.InternalServer("MARKET_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	var out []domain.Market
	for rows.Next() {
		var m domain.Market
		if err := rows.Scan(
			&m.ID, &m.TenantID, &m.Name, &m.Kind, &m.State, &m.District,
			&m.Latitude, &m.Longitude, &m.ExternalRef, &m.CreatedAt, &m.UpdatedAt,
		); err != nil {
			return nil, 0, p9errors.InternalServer("MARKET_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, m)
	}
	return out, total, rows.Err()
}

func (r *marketRepository) UpsertMarket(ctx context.Context, m *domain.Market) (*domain.Market, error) {
	if m.ID == "" {
		m.ID = ulid.NewString()
	}

	// Keyed on the external reference where there is one, so re-importing a
	// market list corrects the existing row rather than creating a duplicate
	// that splits every price history in two.
	row := r.pool.QueryRow(ctx, `
		INSERT INTO markets (id, tenant_id, name, kind, state, district,
		                     latitude, longitude, external_ref)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		ON CONFLICT (tenant_id, external_ref) WHERE external_ref <> ''
		DO UPDATE SET name = EXCLUDED.name, kind = EXCLUDED.kind,
		              state = EXCLUDED.state, district = EXCLUDED.district,
		              latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude,
		              updated_at = NOW()
		RETURNING id, tenant_id, name, kind, state, district,
		          latitude, longitude, external_ref, created_at, updated_at`,
		m.ID, m.TenantID, m.Name, string(m.Kind), m.State, m.District,
		m.Latitude, m.Longitude, m.ExternalRef,
	)

	var out domain.Market
	if err := row.Scan(
		&out.ID, &out.TenantID, &out.Name, &out.Kind, &out.State, &out.District,
		&out.Latitude, &out.Longitude, &out.ExternalRef, &out.CreatedAt, &out.UpdatedAt,
	); err != nil {
		r.log.Errorw("msg", "failed to upsert market", "error", err)
		return nil, p9errors.InternalServer("MARKET_UPSERT_FAILED", "an internal error occurred")
	}
	return &out, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Quotes
// ─────────────────────────────────────────────────────────────────────────────

func (r *marketRepository) UpsertQuotes(ctx context.Context, quotes []domain.PriceQuote) (int, error) {
	if len(quotes) == 0 {
		return 0, nil
	}

	batch := &pgx.Batch{}
	for _, q := range quotes {
		// ON CONFLICT rather than INSERT: a feed replayed after an outage must
		// correct the day's price, not add a second row that doubles its
		// weight in every average computed afterwards.
		batch.Queue(`
			INSERT INTO price_quotes (
				id, tenant_id, commodity, variety, market_id, market_name,
				min_price, max_price, modal_price, unit, currency,
				price_per_quintal, arrivals_tonnes, quoted_on, source
			) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)
			ON CONFLICT (tenant_id, market_id, commodity, variety, quoted_on)
			DO UPDATE SET
				min_price = EXCLUDED.min_price,
				max_price = EXCLUDED.max_price,
				modal_price = EXCLUDED.modal_price,
				unit = EXCLUDED.unit,
				currency = EXCLUDED.currency,
				price_per_quintal = EXCLUDED.price_per_quintal,
				arrivals_tonnes = EXCLUDED.arrivals_tonnes,
				market_name = EXCLUDED.market_name,
				source = EXCLUDED.source`,
			q.ID, q.TenantID, q.Commodity, q.Variety, q.MarketID, q.MarketName,
			q.MinPrice, q.MaxPrice, q.ModalPrice, string(q.Unit), q.Currency,
			q.PricePerQuintal, q.ArrivalsTonnes, q.QuotedOn, q.Source,
		)
	}

	results := r.pool.SendBatch(ctx, batch)
	defer results.Close()

	written := 0
	for range quotes {
		if _, err := results.Exec(); err != nil {
			r.log.Errorw("msg", "failed to upsert quote", "error", err)
			return written, p9errors.InternalServer("QUOTE_UPSERT_FAILED", "an internal error occurred")
		}
		written++
	}
	return written, nil
}

func (r *marketRepository) ListQuotes(ctx context.Context, params domain.ListQuotesParams) ([]domain.PriceQuote, int64, error) {
	where := []string{"tenant_id = $1"}
	args := []any{params.TenantID}

	if params.Commodity != "" {
		args = append(args, params.Commodity)
		where = append(where, fmt.Sprintf("commodity = $%d", len(args)))
	}
	if params.MarketID != "" {
		args = append(args, params.MarketID)
		where = append(where, fmt.Sprintf("market_id = $%d", len(args)))
	}
	if !params.From.IsZero() {
		args = append(args, params.From)
		where = append(where, fmt.Sprintf("quoted_on >= $%d", len(args)))
	}
	if !params.To.IsZero() {
		args = append(args, params.To)
		where = append(where, fmt.Sprintf("quoted_on <= $%d", len(args)))
	}

	clause := strings.Join(where, " AND ")

	var total int64
	if err := r.pool.QueryRow(ctx,
		"SELECT COUNT(*) FROM price_quotes WHERE "+clause, args...,
	).Scan(&total); err != nil {
		r.log.Errorw("msg", "failed to count quotes", "error", err)
		return nil, 0, p9errors.InternalServer("QUOTE_LIST_FAILED", "an internal error occurred")
	}

	args = append(args, params.Limit, params.Offset)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT id, tenant_id, commodity, variety, market_id, market_name,
		       min_price, max_price, modal_price, unit, currency,
		       price_per_quintal, arrivals_tonnes, quoted_on, source, created_at
		FROM price_quotes WHERE %s
		ORDER BY quoted_on DESC
		LIMIT $%d OFFSET $%d`, clause, len(args)-1, len(args)), args...)
	if err != nil {
		r.log.Errorw("msg", "failed to list quotes", "error", err)
		return nil, 0, p9errors.InternalServer("QUOTE_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	out, err := scanQuotes(rows)
	return out, total, err
}

// QuoteWindow returns the last `days` of quotes oldest first.
//
// Ordered ascending because that is what the statistics and the least-squares
// trend fit expect; a descending window would compute a slope of the right
// magnitude and the wrong sign, which is the kind of error that turns "sell"
// into "hold".
func (r *marketRepository) QuoteWindow(ctx context.Context, tenantID, commodity, marketID string, days int) ([]domain.PriceQuote, error) {
	cutoff := time.Now().AddDate(0, 0, -days)

	rows, err := r.pool.Query(ctx, `
		SELECT id, tenant_id, commodity, variety, market_id, market_name,
		       min_price, max_price, modal_price, unit, currency,
		       price_per_quintal, arrivals_tonnes, quoted_on, source, created_at
		FROM price_quotes
		WHERE tenant_id = $1 AND commodity = $2 AND market_id = $3 AND quoted_on >= $4
		ORDER BY quoted_on ASC`,
		tenantID, commodity, marketID, cutoff,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to load quote window", "error", err)
		return nil, p9errors.InternalServer("QUOTE_WINDOW_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	return scanQuotes(rows)
}

func scanQuotes(rows pgx.Rows) ([]domain.PriceQuote, error) {
	var out []domain.PriceQuote
	for rows.Next() {
		var q domain.PriceQuote
		if err := rows.Scan(
			&q.ID, &q.TenantID, &q.Commodity, &q.Variety, &q.MarketID, &q.MarketName,
			&q.MinPrice, &q.MaxPrice, &q.ModalPrice, &q.Unit, &q.Currency,
			&q.PricePerQuintal, &q.ArrivalsTonnes, &q.QuotedOn, &q.Source, &q.CreatedAt,
		); err != nil {
			return nil, p9errors.InternalServer("QUOTE_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, q)
	}
	return out, rows.Err()
}

// ─────────────────────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────────────────────

func (r *marketRepository) CreateAlert(ctx context.Context, a *domain.PriceAlert) (*domain.PriceAlert, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO price_alerts (id, tenant_id, commodity, market_id, direction,
		                          threshold_per_quintal, enabled, created_by)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
		RETURNING id, tenant_id, commodity, market_id, direction,
		          threshold_per_quintal, enabled, created_by, created_at,
		          last_fired_at, last_fired_price`,
		a.ID, a.TenantID, a.Commodity, a.MarketID, string(a.Direction),
		a.ThresholdPerQuintal, a.Enabled, a.CreatedBy,
	)

	out, err := scanAlert(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create alert", "error", err)
		return nil, p9errors.InternalServer("ALERT_CREATE_FAILED", "an internal error occurred")
	}
	return out, nil
}

func (r *marketRepository) ListAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.PriceAlert, int64, error) {
	where := []string{"tenant_id = $1"}
	args := []any{params.TenantID}

	if params.Commodity != "" {
		args = append(args, params.Commodity)
		where = append(where, fmt.Sprintf("commodity = $%d", len(args)))
	}
	clause := strings.Join(where, " AND ")

	var total int64
	if err := r.pool.QueryRow(ctx,
		"SELECT COUNT(*) FROM price_alerts WHERE "+clause, args...,
	).Scan(&total); err != nil {
		return nil, 0, p9errors.InternalServer("ALERT_LIST_FAILED", "an internal error occurred")
	}

	args = append(args, params.Limit, params.Offset)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT id, tenant_id, commodity, market_id, direction,
		       threshold_per_quintal, enabled, created_by, created_at,
		       last_fired_at, last_fired_price
		FROM price_alerts WHERE %s
		ORDER BY created_at DESC
		LIMIT $%d OFFSET $%d`, clause, len(args)-1, len(args)), args...)
	if err != nil {
		return nil, 0, p9errors.InternalServer("ALERT_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	var out []domain.PriceAlert
	for rows.Next() {
		a, err := scanAlert(rows)
		if err != nil {
			return nil, 0, err
		}
		out = append(out, *a)
	}
	return out, total, rows.Err()
}

func (r *marketRepository) DeleteAlert(ctx context.Context, id, tenantID string) (bool, error) {
	tag, err := r.pool.Exec(ctx,
		"DELETE FROM price_alerts WHERE id = $1 AND tenant_id = $2", id, tenantID)
	if err != nil {
		r.log.Errorw("msg", "failed to delete alert", "id", id, "error", err)
		return false, p9errors.InternalServer("ALERT_DELETE_FAILED", "an internal error occurred")
	}
	return tag.RowsAffected() > 0, nil
}

func (r *marketRepository) MatchingAlerts(ctx context.Context, tenantID, commodity, marketID string) ([]domain.PriceAlert, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT id, tenant_id, commodity, market_id, direction,
		       threshold_per_quintal, enabled, created_by, created_at,
		       last_fired_at, last_fired_price
		FROM price_alerts
		WHERE tenant_id = $1 AND commodity = $2 AND market_id = $3 AND enabled`,
		tenantID, commodity, marketID,
	)
	if err != nil {
		return nil, p9errors.InternalServer("ALERT_MATCH_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	var out []domain.PriceAlert
	for rows.Next() {
		a, err := scanAlert(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, *a)
	}
	return out, rows.Err()
}

func (r *marketRepository) MarkAlertFired(ctx context.Context, id, tenantID string, price float64) error {
	_, err := r.pool.Exec(ctx, `
		UPDATE price_alerts
		SET last_fired_at = NOW(), last_fired_price = $3, updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2`,
		id, tenantID, price,
	)
	if err != nil {
		return p9errors.InternalServer("ALERT_FIRE_FAILED", "an internal error occurred")
	}
	return nil
}

func scanAlert(row pgx.Row) (*domain.PriceAlert, error) {
	var a domain.PriceAlert
	if err := row.Scan(
		&a.ID, &a.TenantID, &a.Commodity, &a.MarketID, &a.Direction,
		&a.ThresholdPerQuintal, &a.Enabled, &a.CreatedBy, &a.CreatedAt,
		&a.LastFiredAt, &a.LastFiredPrice,
	); err != nil {
		return nil, err
	}
	return &a, nil
}
