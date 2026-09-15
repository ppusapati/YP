package admin

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

// The gatherer's interesting failures are the quiet ones: a connection that
// cannot see past row-level security counts zero rows and reports success, and
// a source that fails halfway leaves counts that look like a fault rather than
// a gap. Both are tested here; the arithmetic barely needs testing at all.

// ── A fake pgx connection ───────────────────────────────────────────────────

type fakeRow struct {
	tenantID string
	count    int64
	last     *time.Time
}

type fakeDB struct {
	bypassesRLS bool
	bypassErr   error
	rows        []fakeRow
	queryErr    error
	queries     []string
}

func (d *fakeDB) QueryRow(_ context.Context, sql string, _ ...any) pgx.Row {
	d.queries = append(d.queries, sql)
	return &boolRow{value: d.bypassesRLS, err: d.bypassErr}
}

func (d *fakeDB) Query(_ context.Context, sql string, _ ...any) (pgx.Rows, error) {
	d.queries = append(d.queries, sql)
	if d.queryErr != nil {
		return nil, d.queryErr
	}
	return &fakeRows{rows: d.rows, i: -1}, nil
}

type boolRow struct {
	value bool
	err   error
}

func (r *boolRow) Scan(dest ...any) error {
	if r.err != nil {
		return r.err
	}
	*(dest[0].(*bool)) = r.value
	return nil
}

type fakeRows struct {
	rows []fakeRow
	i    int
	err  error
}

func (r *fakeRows) Next() bool { r.i++; return r.i < len(r.rows) }
func (r *fakeRows) Close()     {}
func (r *fakeRows) Err() error { return r.err }
func (r *fakeRows) Scan(dest ...any) error {
	row := r.rows[r.i]
	*(dest[0].(*string)) = row.tenantID
	*(dest[1].(*int64)) = row.count
	*(dest[2].(**time.Time)) = row.last
	return nil
}

// The rest of pgx.Rows, unused by the gatherer.
func (r *fakeRows) CommandTag() pgconn.CommandTag                { return pgconn.CommandTag{} }
func (r *fakeRows) FieldDescriptions() []pgconn.FieldDescription { return nil }
func (r *fakeRows) Values() ([]any, error)                       { return nil, nil }
func (r *fakeRows) RawValues() [][]byte                          { return nil }
func (r *fakeRows) Conn() *pgx.Conn                              { return nil }

func bypassing(rows ...fakeRow) *fakeDB {
	return &fakeDB{bypassesRLS: true, rows: rows}
}

func source(m Metric, db Querier) UsageSource {
	return UsageSource{Metric: m, DB: db, Query: "SELECT 1"}
}

// ── The quiet failure ───────────────────────────────────────────────────────

func TestAConnectionThatCannotSeePastRLSIsRefused(t *testing.T) {
	// The whole reason ensureBypassesRLS exists. Every one of these tables has
	// FORCE ROW LEVEL SECURITY keyed on app.tenant_id; unset, the policy
	// matches nothing and COUNT(*) returns 0 with no error. Without this check
	// the dashboard would report that every tenant on the platform is empty,
	// confidently.
	db := &fakeDB{bypassesRLS: false, rows: []fakeRow{{tenantID: "t-1", count: 5}}}
	u, err := NewSQLUsage(source(MetricFarms, db))
	if err != nil {
		t.Fatalf("building the gatherer: %v", err)
	}

	got, err := u.Usage(context.Background())
	if err == nil {
		t.Fatalf("a non-bypassing connection was accepted and returned %v", got)
	}
	if !errors.Is(err, errRLSWouldHideEverything) {
		t.Errorf("error %v; want the row-level security refusal", err)
	}
	if got != nil {
		t.Error("counts were returned alongside the refusal")
	}
}

func TestTheRLSCheckRunsBeforeTheCount(t *testing.T) {
	// Ordering matters: a check that ran afterwards would still have executed a
	// cross-tenant query as an under-privileged role, and the zero it returned
	// would be in the logs looking like a real measurement.
	db := &fakeDB{bypassesRLS: false}
	u, _ := NewSQLUsage(source(MetricFarms, db))
	_, _ = u.Usage(context.Background())

	if len(db.queries) != 1 {
		t.Fatalf("ran %d queries, want only the check: %v", len(db.queries), db.queries)
	}
}

// ── Partial results ─────────────────────────────────────────────────────────

func TestOneFailedSourceFailsTheWholeSnapshot(t *testing.T) {
	// A partial snapshot does not read as "incomplete" downstream. Farms
	// counted and fields missing reads as a tenant with sensors and no fields,
	// which DeriveHealth correctly calls degraded — a fault invented out of a
	// gap.
	ok := bypassing(fakeRow{tenantID: "t-1", count: 3})
	broken := &fakeDB{bypassesRLS: true, queryErr: errors.New("relation \"fields\" does not exist")}

	u, _ := NewSQLUsage(source(MetricFarms, ok), source(MetricFields, broken))

	got, err := u.Usage(context.Background())
	if err == nil {
		t.Fatal("a failed source was reported as success")
	}
	if got != nil {
		t.Errorf("partial counts were returned: %v", got)
	}
	// And the message says which source, because "usage gathering failed" sends
	// somebody to read four services' logs.
	if msg := err.Error(); !strings.Contains(msg, "fields") {
		t.Errorf("error %q does not name the failing source", msg)
	}
}

// ── What it gathers ─────────────────────────────────────────────────────────

func TestCountsFromSeveralDatabasesAreStitchedByTenant(t *testing.T) {
	// The reason this is four queries rather than one join: each service owns
	// its own database, so there is nothing to join across.
	older := time.Date(2026, 6, 1, 0, 0, 0, 0, time.UTC)
	newer := time.Date(2026, 6, 14, 0, 0, 0, 0, time.UTC)

	u, _ := NewSQLUsage(
		source(MetricFarms, bypassing(
			fakeRow{tenantID: "t-1", count: 3, last: &older},
			fakeRow{tenantID: "t-2", count: 1, last: &older})),
		source(MetricFields, bypassing(
			fakeRow{tenantID: "t-1", count: 12, last: &newer})),
		source(MetricUsers, bypassing(
			fakeRow{tenantID: "t-1", count: 7, last: &older})),
	)
	u.now = func() time.Time { return now }

	got, err := u.Usage(context.Background())
	if err != nil {
		t.Fatalf("gathering: %v", err)
	}
	if len(got) != 2 {
		t.Fatalf("got %d tenants, want 2", len(got))
	}

	one := got["t-1"]
	if one.Farms != 3 || one.Fields != 12 || one.Users != 7 {
		t.Errorf("t-1 farms=%d fields=%d users=%d, want 3/12/7", one.Farms, one.Fields, one.Users)
	}
	// Sensors had no source at all, which is zero rather than wrong — the
	// snapshot says what was measured.
	if one.Sensors != 0 {
		t.Errorf("t-1 sensors %d, want 0", one.Sensors)
	}
	if one.LastActivityAt == nil || !one.LastActivityAt.Equal(newer) {
		t.Errorf("last activity %v, want the most recent write across sources (%v)",
			one.LastActivityAt, newer)
	}
	if !one.GatheredAt.Equal(now) {
		t.Errorf("gathered at %v, want %v", one.GatheredAt, now)
	}

	// A tenant present in one source and absent from another keeps the counts
	// it has rather than being dropped.
	if two := got["t-2"]; two.Farms != 1 || two.Fields != 0 {
		t.Errorf("t-2 farms=%d fields=%d, want 1/0", two.Farms, two.Fields)
	}
}

func TestPaddedTenantIdsStillMatchTheRegistry(t *testing.T) {
	// tenant_id is CHAR(26). A short value comes back space-padded, and an
	// unpadded lookup against the registry would silently find nothing — the
	// tenant would show as never measured while its rows sat right there.
	u, _ := NewSQLUsage(source(MetricFarms, bypassing(
		fakeRow{tenantID: "t-1                      ", count: 4})))

	got, err := u.Usage(context.Background())
	if err != nil {
		t.Fatalf("gathering: %v", err)
	}
	if snap, ok := got["t-1"]; !ok || snap.Farms != 4 {
		t.Errorf("got %v; the padded id did not normalise", got)
	}
}

func TestRowsWithNoTenantAreSkipped(t *testing.T) {
	u, _ := NewSQLUsage(source(MetricFarms, bypassing(
		fakeRow{tenantID: "", count: 9},
		fakeRow{tenantID: "t-1", count: 4})))

	got, _ := u.Usage(context.Background())
	if len(got) != 1 {
		t.Errorf("got %v, want only the real tenant", got)
	}
}

// ── Construction ────────────────────────────────────────────────────────────

func TestAGathererNeedsSources(t *testing.T) {
	if _, err := NewSQLUsage(); err == nil {
		t.Error("a gatherer with no sources was built; it would report every tenant empty")
	}
}

func TestASourceWithNoDatabaseIsRefused(t *testing.T) {
	if _, err := NewSQLUsage(UsageSource{Metric: MetricFarms, Query: "SELECT 1"}); err == nil {
		t.Error("a source with no database was accepted")
	}
	if _, err := NewSQLUsage(UsageSource{Metric: MetricFarms, DB: bypassing()}); err == nil {
		t.Error("a source with no query was accepted")
	}
}

func TestADuplicatedMetricIsRefused(t *testing.T) {
	// The second would silently overwrite the first, which reads as a count
	// that is wrong rather than one that is missing.
	_, err := NewSQLUsage(source(MetricFarms, bypassing()), source(MetricFarms, bypassing()))
	if err == nil {
		t.Error("the same metric was accepted from two sources")
	}
}
