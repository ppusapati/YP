package admin

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
)

// The SQL-backed usage gatherer.
//
// Counting farms, fields, sensors and users per tenant sounds like one query
// with three joins. It is not, for two reasons that shape everything below.
//
// First, each service owns its own database — farm_service, field_service,
// sensor_service, auth_service are four separate databases on (today) one
// server. There is no join across them. So usage is four queries against four
// connections, stitched together in Go by tenant id.
//
// Second, and more dangerously: every one of those tables has FORCE ROW LEVEL
// SECURITY with a policy keyed on current_setting('app.tenant_id'). With that
// setting unset the comparison is NULL, the policy matches nothing, and
// `SELECT COUNT(*) FROM farms` returns 0 — successfully. A cross-tenant
// gatherer connecting as an ordinary application role therefore reports that
// every tenant on the platform has nothing in it, with no error anywhere. That
// is why Gather refuses to run before checking that its connection actually
// bypasses RLS: see errRLSWouldHideEverything.

// Metric names one of the counts a UsageSource supplies.
type Metric string

const (
	MetricFarms   Metric = "farms"
	MetricFields  Metric = "fields"
	MetricSensors Metric = "sensors"
	MetricUsers   Metric = "users"
)

// Querier is the subset of a pgx pool this package needs.
//
// *pgxpool.Pool satisfies it. An interface rather than the concrete pool so
// the gathering logic — which is where the interesting failures are — can be
// tested without a server.
type Querier interface {
	Query(ctx context.Context, sql string, args ...any) (pgx.Rows, error)
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
}

// UsageSource is one metric read from one database.
type UsageSource struct {
	// Metric says which field of the snapshot this source fills.
	Metric Metric
	// DB is the connection to that service's database.
	DB Querier
	// Query must return rows of (tenant_id text, count bigint,
	// last_activity timestamptz null), one row per tenant.
	Query string
}

// The default queries, one per service database.
//
// All four count only live rows and report the most recent write, because the
// dashboard's most useful column is "when did anything last happen here" and a
// count that includes soft-deleted rows makes an abandoned tenant look busy.
const (
	QueryFarms = `SELECT tenant_id, COUNT(*), MAX(updated_at)
	              FROM farms WHERE deleted_at IS NULL GROUP BY tenant_id`

	QueryFields = `SELECT tenant_id, COUNT(*), MAX(updated_at)
	               FROM fields WHERE deleted_at IS NULL GROUP BY tenant_id`

	QuerySensors = `SELECT tenant_id, COUNT(*), MAX(updated_at)
	                FROM sensors WHERE deleted_at IS NULL GROUP BY tenant_id`

	// Users have no deleted_at; deactivation is the soft delete here.
	QueryUsers = `SELECT tenant_id, COUNT(*), MAX(updated_at)
	              FROM users WHERE is_active GROUP BY tenant_id`
)

// bypassCheck asks whether this connection can see past row-level security.
//
// Superuser or a role with BYPASSRLS. Anything else silently counts zero rows
// on every FORCE RLS table, which is the failure this exists to catch.
const bypassCheck = `SELECT current_setting('is_superuser') = 'on'
                     OR COALESCE((SELECT rolbypassrls FROM pg_roles
                                  WHERE rolname = current_user), false)`

var errRLSWouldHideEverything = errors.New(
	"admin: this connection does not bypass row-level security, so every " +
		"cross-tenant count would come back as zero without an error; grant " +
		"BYPASSRLS to the role the usage gatherer connects as")

// SQLUsage gathers per-tenant counts from the service databases.
//
// Built to be run on a schedule by a collector and its result cached, not
// called from the request path: four aggregate queries across four databases
// is not something to do while an operator waits, and the snapshot's age is
// reported to the dashboard precisely so that it does not have to be fresh.
type SQLUsage struct {
	sources []UsageSource
	now     func() time.Time
}

// NewSQLUsage builds the gatherer.
func NewSQLUsage(sources ...UsageSource) (*SQLUsage, error) {
	if len(sources) == 0 {
		return nil, errors.New("admin: at least one usage source is required")
	}
	seen := map[Metric]bool{}
	for _, src := range sources {
		if src.DB == nil {
			return nil, fmt.Errorf("admin: usage source %q has no database", src.Metric)
		}
		if src.Query == "" {
			return nil, fmt.Errorf("admin: usage source %q has no query", src.Metric)
		}
		if seen[src.Metric] {
			// Two sources for one metric means the second silently overwrites
			// the first, which reads as a count that is wrong rather than
			// missing.
			return nil, fmt.Errorf("admin: metric %q is supplied twice", src.Metric)
		}
		seen[src.Metric] = true
	}
	return &SQLUsage{sources: sources, now: time.Now}, nil
}

// Usage implements UsageStore.
//
// All or nothing: if any source fails, the whole call fails and nothing is
// returned. That is deliberate and it is the opposite of what feels helpful.
// A partial snapshot — farms counted, fields missing — does not read as
// "incomplete" downstream, it reads as a tenant with forty sensors and no
// fields, which DeriveHealth correctly calls degraded. A missing measurement
// shows as unknown and prompts somebody to look; a partial one invents a fault
// and wastes their time.
func (u *SQLUsage) Usage(ctx context.Context) (map[string]UsageSnapshot, error) {
	gathered := u.now()
	snapshots := map[string]UsageSnapshot{}

	for _, src := range u.sources {
		if err := ensureBypassesRLS(ctx, src.DB); err != nil {
			return nil, fmt.Errorf("usage source %q: %w", src.Metric, err)
		}
		if err := u.gather(ctx, src, snapshots, gathered); err != nil {
			return nil, fmt.Errorf("usage source %q: %w", src.Metric, err)
		}
	}
	return snapshots, nil
}

func (u *SQLUsage) gather(ctx context.Context, src UsageSource, into map[string]UsageSnapshot, gathered time.Time) error {
	rows, err := src.DB.Query(ctx, src.Query)
	if err != nil {
		return err
	}
	defer rows.Close()

	for rows.Next() {
		var (
			tenantID string
			count    int64
			last     *time.Time
		)
		if err := rows.Scan(&tenantID, &count, &last); err != nil {
			return err
		}
		// tenant_id is CHAR(26), so it arrives space-padded if anything ever
		// writes a short value. Trimming here rather than trusting the column
		// keeps the join against the registry from silently missing.
		tenantID = trimPadding(tenantID)
		if tenantID == "" {
			continue
		}

		snap := into[tenantID]
		snap.TenantID = tenantID
		snap.GatheredAt = gathered
		switch src.Metric {
		case MetricFarms:
			snap.Farms = count
		case MetricFields:
			snap.Fields = count
		case MetricSensors:
			snap.Sensors = count
		case MetricUsers:
			snap.Users = count
		default:
			return fmt.Errorf("unknown metric %q", src.Metric)
		}
		// The latest write across every source, which is what the dashboard
		// means by "last activity" — a tenant nobody has touched in a month is
		// one where none of these moved.
		if last != nil && (snap.LastActivityAt == nil || last.After(*snap.LastActivityAt)) {
			t := *last
			snap.LastActivityAt = &t
		}
		into[tenantID] = snap
	}
	return rows.Err()
}

func ensureBypassesRLS(ctx context.Context, db Querier) error {
	var bypasses bool
	if err := db.QueryRow(ctx, bypassCheck).Scan(&bypasses); err != nil {
		return fmt.Errorf("checking row-level security: %w", err)
	}
	if !bypasses {
		return errRLSWouldHideEverything
	}
	return nil
}

func trimPadding(s string) string {
	end := len(s)
	for end > 0 && (s[end-1] == ' ' || s[end-1] == '\t') {
		end--
	}
	start := 0
	for start < end && s[start] == ' ' {
		start++
	}
	return s[start:end]
}
