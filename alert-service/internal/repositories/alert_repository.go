// Package repositories holds alert-service's persistence adapters.
package repositories

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/agriculture/alert-service/internal/models"
	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
)

// AlertFilter narrows a listing. Zero values mean "no constraint".
type AlertFilter struct {
	FarmID   string
	FieldID  string
	Severity models.AlertSeverity
	// Statuses matches any of the listed statuses. A list rather than a single
	// value because the proto has no EXPIRED: a caller asking for closed
	// alerts means both RESOLVED and EXPIRED, and forcing that into one value
	// would silently hide the expired ones.
	Statuses []models.AlertStatus
	Source   string
	Since    *time.Time
	Until    *time.Time
	Offset   int32
	Limit    int32
}

// AlertRepository is alert-service's persistence port.
//
// Every method takes an explicit tenant ID rather than reading one from the
// context. Most of this service's writes arrive from a Kafka consumer, which
// has no request and therefore no RLS scope to inherit; making the tenant a
// parameter means there is no path where it can be quietly absent.
type AlertRepository interface {
	CreateAlert(ctx context.Context, tenantID string, a *models.Alert) (*models.Alert, error)
	// UpsertSourcedAlert records an alert raised by another service, keyed on
	// (source, source_alert_id). Reports whether a row was inserted.
	UpsertSourcedAlert(ctx context.Context, tenantID string, a *models.Alert) (*models.Alert, bool, error)
	GetAlert(ctx context.Context, tenantID, id string) (*models.Alert, error)
	ListAlerts(ctx context.Context, tenantID string, f AlertFilter) ([]*models.Alert, int32, error)
	SetStatus(ctx context.Context, tenantID, id string, status models.AlertStatus, by string, at time.Time) (*models.Alert, error)
	MarkRead(ctx context.Context, tenantID, id string) (*models.Alert, error)
	MarkAllRead(ctx context.Context, tenantID, farmID string) (int32, error)
	UnreadCount(ctx context.Context, tenantID, farmID string) (int32, error)
	ExpireDue(ctx context.Context, tenantID string, now time.Time) (int32, error)

	ListRules(ctx context.Context, tenantID, fieldID string) ([]*models.AlertRule, error)
	GetRule(ctx context.Context, tenantID, id string) (*models.AlertRule, error)
	CreateRule(ctx context.Context, tenantID string, r *models.AlertRule) (*models.AlertRule, error)
	UpdateRule(ctx context.Context, tenantID string, r *models.AlertRule) (*models.AlertRule, error)
	// TouchRuleFired records that a rule fired, for cooldown accounting.
	TouchRuleFired(ctx context.Context, tenantID, id string, at time.Time) error

	UpsertFieldRisk(ctx context.Context, tenantID string, s *models.FieldRiskScore) error
	ListFieldRisks(ctx context.Context, tenantID, farmID string) ([]*models.FieldRiskScore, error)
}

type alertRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewAlertRepository creates a Postgres-backed AlertRepository.
func NewAlertRepository(pool *pgxpool.Pool, logger p9log.Logger) AlertRepository {
	return &alertRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(logger, "component", "AlertRepository")),
	}
}

// inTenant runs fn inside a transaction with app.tenant_id set.
//
// Every method goes through here, reads included, because the RLS policies on
// these tables are FORCE'd: set_config with is_local=true is transaction-scoped,
// so a query issued straight against the pool arrives with no tenant set and
// the policy matches nothing. The failure mode is the quiet one — an empty
// result rather than an error — so the transaction is not optional.
//
// The queries below still filter on tenant_id explicitly. That is redundant
// with the policy by design: it keeps the intent visible at the call site, it
// lets the tenant indexes do their work, and it means a table that loses its
// policy in some future migration does not silently start returning everyone's
// alerts.
func (r *alertRepository) inTenant(ctx context.Context, tenantID string, fn func(pgx.Tx) error) error {
	if strings.TrimSpace(tenantID) == "" {
		return p9errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return r.dbErr("begin", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck

	if _, err := tx.Exec(ctx, "SELECT set_config('app.tenant_id', $1, true)", tenantID); err != nil {
		return r.dbErr("set tenant", err)
	}
	if err := fn(tx); err != nil {
		return err
	}
	if err := tx.Commit(ctx); err != nil {
		return r.dbErr("commit", err)
	}
	return nil
}

// dbErr logs the real error and returns an opaque one. The detail belongs in
// the log, not in a response to a caller who cannot act on it and should not
// learn the schema from it.
func (r *alertRepository) dbErr(op string, err error) error {
	r.log.Errorw("msg", "database error", "op", op, "error", err)
	return p9errors.InternalServer("DB_ERROR", "an internal error occurred")
}

// ---------------------------------------------------------------------------
// Alerts
// ---------------------------------------------------------------------------

const alertCols = `
	id, tenant_id, field_id, COALESCE(farm_id, ''), field_name,
	alert_type, severity, status, title, message, read, action_url,
	source, COALESCE(source_alert_id, ''),
	metric_value, threshold_value, metrics, recommendations,
	created_at, acknowledged_at, acknowledged_by, resolved_at, expires_at`

// alertScan holds the loose-typed destinations for one row. The enum-ish
// columns are scanned as plain strings and converted afterwards: the model's
// types are named string types, and relying on the driver to map those would
// tie the schema to a reflection detail.
type alertScan struct {
	a          models.Alert
	tenant     string
	alertType  string
	severity   string
	status     string
	source     string
	sourceID   string
	metricsRaw []byte
}

func (s *alertScan) dest() []any {
	return []any{
		&s.a.ID, &s.tenant, &s.a.FieldID, &s.a.FarmID, &s.a.FieldName,
		&s.alertType, &s.severity, &s.status, &s.a.Title, &s.a.Message, &s.a.Read, &s.a.ActionURL,
		&s.source, &s.sourceID,
		&s.a.MetricValue, &s.a.ThresholdValue, &s.metricsRaw, &s.a.Recommendations,
		&s.a.CreatedAt, &s.a.AcknowledgedAt, &s.a.AcknowledgedBy, &s.a.ResolvedAt, &s.a.ExpiresAt,
	}
}

func (s *alertScan) alert() *models.Alert {
	s.a.AlertType = models.AlertType(s.alertType)
	s.a.Severity = models.AlertSeverity(s.severity)
	s.a.Status = models.AlertStatus(s.status)
	s.a.Source = s.source
	s.a.SourceAlertID = s.sourceID
	if len(s.metricsRaw) > 0 {
		// A metrics column that will not parse is bad data, not a reason to
		// hide the alert: the farmer still needs to know about the frost.
		_ = json.Unmarshal(s.metricsRaw, &s.a.Metrics)
	}
	out := s.a
	return &out
}

func scanAlert(row pgx.Row) (*models.Alert, error) {
	var s alertScan
	if err := row.Scan(s.dest()...); err != nil {
		return nil, err
	}
	return s.alert(), nil
}

func (r *alertRepository) CreateAlert(ctx context.Context, tenantID string, a *models.Alert) (*models.Alert, error) {
	out, _, err := r.insertAlert(ctx, tenantID, a, false)
	return out, err
}

func (r *alertRepository) UpsertSourcedAlert(ctx context.Context, tenantID string, a *models.Alert) (*models.Alert, bool, error) {
	return r.insertAlert(ctx, tenantID, a, true)
}

// insertAlert writes one alert. When dedupe is set, a row already present for
// the same (source, source_alert_id) is returned untouched rather than
// duplicated or overwritten.
func (r *alertRepository) insertAlert(ctx context.Context, tenantID string, a *models.Alert, dedupe bool) (*models.Alert, bool, error) {
	if a == nil {
		return nil, false, p9errors.BadRequest("INVALID_ALERT", "alert is required")
	}
	if strings.TrimSpace(a.FieldID) == "" {
		return nil, false, p9errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if a.Severity == "" {
		a.Severity = models.AlertSeverityWarning
	}
	if a.Status == "" {
		a.Status = models.AlertStatusActive
	}
	if !a.Severity.IsValid() {
		return nil, false, p9errors.BadRequest("INVALID_SEVERITY", "unknown alert severity")
	}
	if !a.Status.IsValid() {
		return nil, false, p9errors.BadRequest("INVALID_STATUS", "unknown alert status")
	}

	metrics, err := json.Marshal(orEmptyMap(a.Metrics))
	if err != nil {
		return nil, false, p9errors.BadRequest("INVALID_METRICS", "metrics could not be encoded")
	}

	// The conflict clause is a no-op update rather than DO NOTHING so that
	// RETURNING still yields the row. DO NOTHING returns nothing on conflict,
	// which would leave the consumer unable to tell a duplicate from a failure.
	const q = `
		INSERT INTO alerts (
			id, tenant_id, field_id, farm_id, field_name,
			alert_type, severity, status, title, message, read, action_url,
			source, source_alert_id,
			metric_value, threshold_value, metrics, recommendations,
			created_at, expires_at)
		VALUES ($1,$2,$3,NULLIF($4,''),$5,$6,$7,$8,$9,$10,$11,$12,$13,NULLIF($14,''),
		        $15,$16,$17,$18,COALESCE($19, NOW()),$20)
		ON CONFLICT (tenant_id, source, source_alert_id)
			WHERE source_alert_id IS NOT NULL
			DO UPDATE SET id = alerts.id
		RETURNING ` + alertCols + `, (xmax = 0) AS inserted`

	var created bool
	var out *models.Alert
	err = r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		row := tx.QueryRow(ctx, q,
			a.ID, tenantID, a.FieldID, a.FarmID, a.FieldName,
			string(a.AlertType), string(a.Severity), string(a.Status), a.Title, a.Message, a.Read, a.ActionURL,
			orDefault(a.Source, "alert-service"), a.SourceAlertID,
			a.MetricValue, a.ThresholdValue, metrics, orEmptySlice(a.Recommendations),
			nullableTime(a.CreatedAt), a.ExpiresAt,
		)
		scanned, scanErr := scanAlertWithFlag(row, &created)
		if scanErr != nil {
			// A unique violation still reaching here means the conflict target
			// did not match — a sourced alert without a source id, typically.
			var pgErr *pgconn.PgError
			if errors.As(scanErr, &pgErr) && pgErr.Code == "23505" {
				return p9errors.Conflict("ALERT_EXISTS", "an alert with this source id already exists")
			}
			return r.dbErr("insert alert", scanErr)
		}
		out = scanned
		return nil
	})
	if err != nil {
		return nil, false, err
	}
	if !dedupe {
		created = true
	}
	return out, created, nil
}

// scanAlertWithFlag reads the same columns plus the insert/conflict flag.
func scanAlertWithFlag(row pgx.Row, inserted *bool) (*models.Alert, error) {
	var s alertScan
	if err := row.Scan(append(s.dest(), inserted)...); err != nil {
		return nil, err
	}
	return s.alert(), nil
}

func (r *alertRepository) GetAlert(ctx context.Context, tenantID, id string) (*models.Alert, error) {
	var out *models.Alert
	err := r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		row := tx.QueryRow(ctx,
			`SELECT `+alertCols+` FROM alerts WHERE tenant_id = $1 AND id = $2`, tenantID, id)
		a, err := scanAlert(row)
		if errors.Is(err, pgx.ErrNoRows) {
			return p9errors.NotFound("ALERT_NOT_FOUND", "alert not found")
		}
		if err != nil {
			return r.dbErr("get alert", err)
		}
		out = a
		return nil
	})
	return out, err
}

func (r *alertRepository) ListAlerts(ctx context.Context, tenantID string, f AlertFilter) ([]*models.Alert, int32, error) {
	where := []string{"tenant_id = $1"}
	args := []any{tenantID}

	add := func(clause string, val any) {
		args = append(args, val)
		where = append(where, fmt.Sprintf(clause, len(args)))
	}
	if f.FarmID != "" {
		add("farm_id = $%d", f.FarmID)
	}
	if f.FieldID != "" {
		add("field_id = $%d", f.FieldID)
	}
	if f.Severity != "" {
		add("severity = $%d", string(f.Severity))
	}
	if len(f.Statuses) > 0 {
		vals := make([]string, 0, len(f.Statuses))
		for _, s := range f.Statuses {
			vals = append(vals, string(s))
		}
		add("status = ANY($%d)", vals)
	}
	if f.Source != "" {
		add("source = $%d", f.Source)
	}
	if f.Since != nil {
		add("created_at >= $%d", *f.Since)
	}
	if f.Until != nil {
		add("created_at <= $%d", *f.Until)
	}
	clause := strings.Join(where, " AND ")

	limit := f.Limit
	if limit <= 0 {
		limit = 50
	}
	offset := f.Offset
	if offset < 0 {
		offset = 0
	}

	var out []*models.Alert
	var total int32
	err := r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		// Counted in the same transaction as the page, so the total and the
		// rows describe the same snapshot. Counting separately lets a
		// concurrent insert make the total disagree with what was returned.
		if err := tx.QueryRow(ctx, `SELECT COUNT(*) FROM alerts WHERE `+clause, args...).Scan(&total); err != nil {
			return r.dbErr("count alerts", err)
		}

		// Ordered by created_at then id: created_at alone is not unique, and a
		// non-deterministic tiebreak makes rows jump between pages.
		q := `SELECT ` + alertCols + ` FROM alerts WHERE ` + clause +
			fmt.Sprintf(` ORDER BY created_at DESC, id DESC LIMIT $%d OFFSET $%d`, len(args)+1, len(args)+2)
		rows, err := tx.Query(ctx, q, append(args, limit, offset)...)
		if err != nil {
			return r.dbErr("list alerts", err)
		}
		defer rows.Close()

		for rows.Next() {
			a, err := scanAlert(rows)
			if err != nil {
				return r.dbErr("scan alert", err)
			}
			out = append(out, a)
		}
		if err := rows.Err(); err != nil {
			return r.dbErr("iterate alerts", err)
		}
		return nil
	})
	return out, total, err
}

func (r *alertRepository) SetStatus(ctx context.Context, tenantID, id string, status models.AlertStatus, by string, at time.Time) (*models.Alert, error) {
	if !status.IsValid() {
		return nil, p9errors.BadRequest("INVALID_STATUS", "unknown alert status")
	}
	if at.IsZero() {
		at = time.Now().UTC()
	}

	// Acknowledging also marks the alert read: someone acting on it has by
	// definition seen it, and leaving it in the unread count afterwards makes
	// the badge wrong.
	const q = `
		UPDATE alerts SET
			status          = $3,
			read            = read OR $3 IN ('ACKNOWLEDGED','RESOLVED'),
			acknowledged_at = CASE WHEN $3 = 'ACKNOWLEDGED' THEN $4 ELSE acknowledged_at END,
			acknowledged_by = CASE WHEN $3 = 'ACKNOWLEDGED' THEN $5 ELSE acknowledged_by END,
			resolved_at     = CASE WHEN $3 = 'RESOLVED'     THEN $4 ELSE resolved_at END,
			resolved_by     = CASE WHEN $3 = 'RESOLVED'     THEN $5 ELSE resolved_by END
		WHERE tenant_id = $1 AND id = $2
		RETURNING ` + alertCols

	var out *models.Alert
	err := r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		a, err := scanAlert(tx.QueryRow(ctx, q, tenantID, id, string(status), at, by))
		if errors.Is(err, pgx.ErrNoRows) {
			return p9errors.NotFound("ALERT_NOT_FOUND", "alert not found")
		}
		if err != nil {
			return r.dbErr("set alert status", err)
		}
		out = a
		return nil
	})
	return out, err
}

func (r *alertRepository) MarkRead(ctx context.Context, tenantID, id string) (*models.Alert, error) {
	var out *models.Alert
	err := r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		a, err := scanAlert(tx.QueryRow(ctx,
			`UPDATE alerts SET read = TRUE WHERE tenant_id = $1 AND id = $2 RETURNING `+alertCols,
			tenantID, id))
		if errors.Is(err, pgx.ErrNoRows) {
			return p9errors.NotFound("ALERT_NOT_FOUND", "alert not found")
		}
		if err != nil {
			return r.dbErr("mark read", err)
		}
		out = a
		return nil
	})
	return out, err
}

func (r *alertRepository) MarkAllRead(ctx context.Context, tenantID, farmID string) (int32, error) {
	var n int32
	err := r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		// An empty farm_id marks the whole tenant read, which is what "mark
		// all read" means when the caller is not looking at one farm.
		tag, err := tx.Exec(ctx, `
			UPDATE alerts SET read = TRUE
			WHERE tenant_id = $1 AND read = FALSE
			  AND ($2 = '' OR farm_id = $2)`, tenantID, farmID)
		if err != nil {
			return r.dbErr("mark all read", err)
		}
		n = int32(tag.RowsAffected())
		return nil
	})
	return n, err
}

func (r *alertRepository) UnreadCount(ctx context.Context, tenantID, farmID string) (int32, error) {
	var n int32
	err := r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		// Only ACTIVE alerts count. A resolved alert nobody opened is not
		// something the farmer still has to look at.
		return tx.QueryRow(ctx, `
			SELECT COUNT(*) FROM alerts
			WHERE tenant_id = $1 AND read = FALSE AND status = 'ACTIVE'
			  AND ($2 = '' OR farm_id = $2)`, tenantID, farmID).Scan(&n)
	})
	if err != nil {
		return 0, err
	}
	return n, nil
}

func (r *alertRepository) ExpireDue(ctx context.Context, tenantID string, now time.Time) (int32, error) {
	if now.IsZero() {
		now = time.Now().UTC()
	}
	var n int32
	err := r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		tag, err := tx.Exec(ctx, `
			UPDATE alerts SET status = 'EXPIRED'
			WHERE tenant_id = $1 AND status = 'ACTIVE'
			  AND expires_at IS NOT NULL AND expires_at <= $2`, tenantID, now)
		if err != nil {
			return r.dbErr("expire alerts", err)
		}
		n = int32(tag.RowsAffected())
		return nil
	})
	return n, err
}

// ---------------------------------------------------------------------------
// Rules
// ---------------------------------------------------------------------------

const ruleCols = `
	id, tenant_id, field_id, COALESCE(farm_id, ''), alert_type, metric, condition,
	threshold, severity, enabled, threshold_json, notify_channels,
	cooldown_minutes, created_at, updated_at`

func scanRule(row pgx.Row) (*models.AlertRule, error) {
	var r models.AlertRule
	var tenant, alertType, severity string
	if err := row.Scan(
		&r.ID, &tenant, &r.FieldID, &r.FarmID, &alertType, &r.Metric, &r.Condition,
		&r.Threshold, &severity, &r.Enabled, &r.ThresholdJSON, &r.NotifyChannels,
		&r.CooldownMinutes, &r.CreatedAt, &r.UpdatedAt,
	); err != nil {
		return nil, err
	}
	r.AlertType = models.AlertType(alertType)
	r.Severity = models.AlertSeverity(severity)
	return &r, nil
}

func (r *alertRepository) ListRules(ctx context.Context, tenantID, fieldID string) ([]*models.AlertRule, error) {
	var out []*models.AlertRule
	err := r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		rows, err := tx.Query(ctx, `
			SELECT `+ruleCols+` FROM alert_rules
			WHERE tenant_id = $1 AND deleted_at IS NULL AND ($2 = '' OR field_id = $2)
			ORDER BY metric, id`, tenantID, fieldID)
		if err != nil {
			return r.dbErr("list rules", err)
		}
		defer rows.Close()
		for rows.Next() {
			rule, err := scanRule(rows)
			if err != nil {
				return r.dbErr("scan rule", err)
			}
			out = append(out, rule)
		}
		return rows.Err()
	})
	return out, err
}

func (r *alertRepository) GetRule(ctx context.Context, tenantID, id string) (*models.AlertRule, error) {
	var out *models.AlertRule
	err := r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		rule, err := scanRule(tx.QueryRow(ctx,
			`SELECT `+ruleCols+` FROM alert_rules WHERE tenant_id = $1 AND id = $2 AND deleted_at IS NULL`,
			tenantID, id))
		if errors.Is(err, pgx.ErrNoRows) {
			return p9errors.NotFound("ALERT_RULE_NOT_FOUND", "alert rule not found")
		}
		if err != nil {
			return r.dbErr("get rule", err)
		}
		out = rule
		return nil
	})
	return out, err
}

func (r *alertRepository) CreateRule(ctx context.Context, tenantID string, rule *models.AlertRule) (*models.AlertRule, error) {
	if rule == nil || strings.TrimSpace(rule.FieldID) == "" {
		return nil, p9errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if strings.TrimSpace(rule.Metric) == "" {
		return nil, p9errors.BadRequest("INVALID_METRIC", "metric is required")
	}
	if rule.Severity == "" {
		rule.Severity = models.AlertSeverityWarning
	}
	if rule.Condition == "" {
		rule.Condition = "GT"
	}

	var out *models.AlertRule
	err := r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		created, err := scanRule(tx.QueryRow(ctx, `
			INSERT INTO alert_rules (
				id, tenant_id, field_id, farm_id, alert_type, metric, condition,
				threshold, severity, enabled, threshold_json, notify_channels, cooldown_minutes)
			VALUES ($1,$2,$3,NULLIF($4,''),$5,$6,$7,$8,$9,$10,$11,$12,$13)
			RETURNING `+ruleCols,
			rule.ID, tenantID, rule.FieldID, rule.FarmID, string(rule.AlertType), rule.Metric,
			rule.Condition, rule.Threshold, string(rule.Severity), rule.Enabled,
			rule.ThresholdJSON, orEmptySlice(rule.NotifyChannels), rule.CooldownMinutes))
		if err != nil {
			var pgErr *pgconn.PgError
			if errors.As(err, &pgErr) && pgErr.Code == "23505" {
				return p9errors.Conflict("ALERT_RULE_EXISTS",
					"a rule already exists for this metric on this field")
			}
			return r.dbErr("create rule", err)
		}
		out = created
		return nil
	})
	return out, err
}

func (r *alertRepository) UpdateRule(ctx context.Context, tenantID string, rule *models.AlertRule) (*models.AlertRule, error) {
	if rule == nil || strings.TrimSpace(rule.ID) == "" {
		return nil, p9errors.BadRequest("INVALID_RULE_ID", "rule id is required")
	}

	var out *models.AlertRule
	err := r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		// COALESCE on the nullable-by-empty-string fields so that a partial
		// update does not blank out what it did not mention.
		updated, err := scanRule(tx.QueryRow(ctx, `
			UPDATE alert_rules SET
				alert_type       = COALESCE(NULLIF($3, ''), alert_type),
				metric           = COALESCE(NULLIF($4, ''), metric),
				condition        = COALESCE(NULLIF($5, ''), condition),
				threshold        = $6,
				severity         = COALESCE(NULLIF($7, ''), severity),
				enabled          = $8,
				threshold_json   = COALESCE(NULLIF($9, ''), threshold_json),
				notify_channels  = COALESCE(NULLIF($10, ARRAY[]::TEXT[]), notify_channels),
				cooldown_minutes = $11,
				updated_at       = NOW()
			WHERE tenant_id = $1 AND id = $2 AND deleted_at IS NULL
			RETURNING `+ruleCols,
			tenantID, rule.ID, string(rule.AlertType), rule.Metric, rule.Condition,
			rule.Threshold, string(rule.Severity), rule.Enabled, rule.ThresholdJSON,
			orEmptySlice(rule.NotifyChannels), rule.CooldownMinutes))
		if errors.Is(err, pgx.ErrNoRows) {
			return p9errors.NotFound("ALERT_RULE_NOT_FOUND", "alert rule not found")
		}
		if err != nil {
			return r.dbErr("update rule", err)
		}
		out = updated
		return nil
	})
	return out, err
}

func (r *alertRepository) TouchRuleFired(ctx context.Context, tenantID, id string, at time.Time) error {
	if at.IsZero() {
		at = time.Now().UTC()
	}
	return r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx,
			`UPDATE alert_rules SET last_fired_at = $3 WHERE tenant_id = $1 AND id = $2`,
			tenantID, id, at); err != nil {
			return r.dbErr("touch rule", err)
		}
		return nil
	})
}

// ---------------------------------------------------------------------------
// Field risk
// ---------------------------------------------------------------------------

func (r *alertRepository) UpsertFieldRisk(ctx context.Context, tenantID string, s *models.FieldRiskScore) error {
	if s == nil || strings.TrimSpace(s.FieldID) == "" {
		return p9errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	factors, err := json.Marshal(orEmptyMap(s.RiskFactors))
	if err != nil {
		return p9errors.BadRequest("INVALID_RISK_FACTORS", "risk factors could not be encoded")
	}
	at := s.EvaluatedAt
	if at.IsZero() {
		at = time.Now().UTC()
	}

	return r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		// Guarded on calculated_at so that an out-of-order arrival — a retried
		// evaluation landing after a newer one — cannot roll the score back to
		// a stale value.
		if _, err := tx.Exec(ctx, `
			INSERT INTO field_risk_scores (
				tenant_id, field_id, farm_id, field_name, overall_score,
				risk_factors, trend, calculated_at, updated_at)
			VALUES ($1,$2,NULLIF($3,''),$4,$5,$6,$7,$8,NOW())
			ON CONFLICT (tenant_id, field_id) DO UPDATE SET
				farm_id       = COALESCE(NULLIF(EXCLUDED.farm_id, ''), field_risk_scores.farm_id),
				field_name    = COALESCE(NULLIF(EXCLUDED.field_name, ''), field_risk_scores.field_name),
				overall_score = EXCLUDED.overall_score,
				risk_factors  = EXCLUDED.risk_factors,
				trend         = EXCLUDED.trend,
				calculated_at = EXCLUDED.calculated_at,
				updated_at    = NOW()
			WHERE EXCLUDED.calculated_at >= field_risk_scores.calculated_at`,
			tenantID, s.FieldID, s.FarmID, s.FieldName,
			clamp01(s.OverallRisk), factors, s.Trend, at); err != nil {
			return r.dbErr("upsert field risk", err)
		}
		return nil
	})
}

func (r *alertRepository) ListFieldRisks(ctx context.Context, tenantID, farmID string) ([]*models.FieldRiskScore, error) {
	var out []*models.FieldRiskScore
	err := r.inTenant(ctx, tenantID, func(tx pgx.Tx) error {
		rows, err := tx.Query(ctx, `
			SELECT field_id, COALESCE(farm_id, ''), field_name, overall_score,
			       risk_factors, trend, calculated_at
			FROM field_risk_scores
			WHERE tenant_id = $1 AND ($2 = '' OR farm_id = $2)
			ORDER BY overall_score DESC, field_id`, tenantID, farmID)
		if err != nil {
			return r.dbErr("list field risks", err)
		}
		defer rows.Close()

		for rows.Next() {
			var s models.FieldRiskScore
			var factors []byte
			if err := rows.Scan(&s.FieldID, &s.FarmID, &s.FieldName, &s.OverallRisk,
				&factors, &s.Trend, &s.EvaluatedAt); err != nil {
				return r.dbErr("scan field risk", err)
			}
			if len(factors) > 0 {
				_ = json.Unmarshal(factors, &s.RiskFactors)
			}
			// The individual dimensions live in the JSONB rather than in
			// columns, since the alert engine may add one without a migration.
			s.TemperatureRisk = s.RiskFactors["temperature"]
			s.WaterRisk = s.RiskFactors["water"]
			s.PestRisk = s.RiskFactors["pest"]
			s.DiseaseRisk = s.RiskFactors["disease"]
			s.NutrientRisk = s.RiskFactors["nutrient"]
			s.GrowthRisk = s.RiskFactors["growth"]
			s.CalculatedAt = s.EvaluatedAt.Format(time.RFC3339)
			out = append(out, &s)
		}
		return rows.Err()
	})
	return out, err
}

// ---------------------------------------------------------------------------

func orEmptyMap(m map[string]float64) map[string]float64 {
	if m == nil {
		return map[string]float64{}
	}
	return m
}

func orEmptySlice(s []string) []string {
	if s == nil {
		return []string{}
	}
	return s
}

func orDefault(v, fallback string) string {
	if strings.TrimSpace(v) == "" {
		return fallback
	}
	return v
}

// nullableTime lets the caller leave CreatedAt unset and take the database's
// clock, which is what an alert raised now should use.
func nullableTime(t time.Time) any {
	if t.IsZero() {
		return nil
	}
	return t
}

func clamp01(v float64) float64 {
	if v < 0 {
		return 0
	}
	if v > 1 {
		return 1
	}
	return v
}
