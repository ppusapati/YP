//go:build integration

package rlspool

import (
	"context"
	"flag"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/p9context"
)

// These need a database, and they need the non-superuser role services connect
// with in production — a superuser bypasses RLS entirely and would make every
// one of them pass whatever the policies said.
//
//	go test -tags=integration ./database/rlspool/ \
//	    -rls-dsn "postgres://yp_app@127.0.0.1:5432/rlstest?sslmode=disable" \
//	    -rls-admin-dsn "postgres://postgres@127.0.0.1:5432/rlstest?sslmode=disable"
var (
	appDSN   = flag.String("rls-dsn", "", "DSN for the application role, which RLS applies to")
	adminDSN = flag.String("rls-admin-dsn", "", "DSN for a role that can create the fixture table")
)

const (
	tenantA = "01JBQZK8P0TENANTAAAAAAAAAA"
	tenantB = "01JBQZK8P0TENANTBBBBBBBBBB"
)

// setupFixture creates a tenant-scoped table with the same policy shape every
// table in this platform uses.
func setupFixture(t *testing.T) {
	t.Helper()
	if *appDSN == "" || *adminDSN == "" {
		t.Skip("no -rls-dsn / -rls-admin-dsn given")
	}

	ctx := context.Background()
	admin, err := pgxpool.New(ctx, *adminDSN)
	if err != nil {
		t.Fatalf("admin connect: %v", err)
	}
	defer admin.Close()

	for _, stmt := range []string{
		`DROP TABLE IF EXISTS rls_probe`,
		`CREATE TABLE rls_probe (
			id        TEXT PRIMARY KEY,
			tenant_id CHAR(26) NOT NULL,
			note      TEXT NOT NULL DEFAULT ''
		)`,
		`ALTER TABLE rls_probe ENABLE ROW LEVEL SECURITY`,
		`ALTER TABLE rls_probe FORCE ROW LEVEL SECURITY`,
		`CREATE POLICY rls_probe_select ON rls_probe FOR SELECT
			USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))`,
		`CREATE POLICY rls_probe_insert ON rls_probe FOR INSERT
			WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))`,
		`GRANT SELECT, INSERT, UPDATE, DELETE ON rls_probe TO ` + appRole(t),
	} {
		if _, err := admin.Exec(ctx, stmt); err != nil {
			t.Fatalf("fixture %q: %v", firstWords(stmt), err)
		}
	}
	t.Cleanup(func() {
		a, err := pgxpool.New(context.Background(), *adminDSN)
		if err != nil {
			return
		}
		defer a.Close()
		_, _ = a.Exec(context.Background(), `DROP TABLE IF EXISTS rls_probe`)
	})
}

// appRole reads the role name out of the application DSN, so the fixture
// grants to whoever the test will connect as.
func appRole(t *testing.T) string {
	t.Helper()
	cfg, err := pgxpool.ParseConfig(*appDSN)
	if err != nil {
		t.Fatalf("parse -rls-dsn: %v", err)
	}
	return cfg.ConnConfig.User
}

func firstWords(s string) string {
	f := strings.Fields(s)
	if len(f) > 4 {
		f = f[:4]
	}
	return strings.Join(f, " ")
}

func scoped(ctx context.Context, tenantID string) context.Context {
	return p9context.NewRLSScope(ctx, p9context.RLSScope{TenantID: tenantID})
}

// ---------------------------------------------------------------------------

// The point of the whole package: a pool built here lets an ordinary,
// non-superuser role write and read its own tenant's rows. With a plain
// pgxpool it cannot do either, because nothing sets app.tenant_id.
func TestAScopedPoolCanWriteAndReadItsOwnTenant(t *testing.T) {
	setupFixture(t)
	ctx := context.Background()

	pool, err := New(ctx, *appDSN)
	if err != nil {
		t.Fatalf("New: %v", err)
	}
	defer pool.Close()

	if _, err := pool.Exec(scoped(ctx, tenantA),
		`INSERT INTO rls_probe (id, tenant_id, note) VALUES ('a1', $1, 'A')`, tenantA); err != nil {
		t.Fatalf("insert as tenant A: %v", err)
	}

	var note string
	if err := pool.QueryRow(scoped(ctx, tenantA),
		`SELECT note FROM rls_probe WHERE id = 'a1'`).Scan(&note); err != nil {
		t.Fatalf("read back as tenant A: %v", err)
	}
	if note != "A" {
		t.Errorf("note = %q", note)
	}
}

// And a plain pool cannot, which is the defect this replaces. Without it the
// comparison above proves nothing: both could be passing for some other
// reason.
func TestAPlainPoolCannotWriteAtAll(t *testing.T) {
	setupFixture(t)
	ctx := context.Background()

	plain, err := pgxpool.New(ctx, *appDSN)
	if err != nil {
		t.Fatalf("pgxpool.New: %v", err)
	}
	defer plain.Close()

	_, err = plain.Exec(scoped(ctx, tenantA),
		`INSERT INTO rls_probe (id, tenant_id) VALUES ('plain', $1)`, tenantA)
	if err == nil {
		t.Fatal("a plain pool inserted successfully; RLS is not in force, so this suite proves nothing")
	}
	if !strings.Contains(err.Error(), "row-level security") {
		t.Errorf("a plain pool failed for some other reason: %v", err)
	}
}

// One tenant cannot read another's rows, which is what the policies are for.
func TestOneTenantCannotSeeAnother(t *testing.T) {
	setupFixture(t)
	ctx := context.Background()

	pool, err := New(ctx, *appDSN)
	if err != nil {
		t.Fatalf("New: %v", err)
	}
	defer pool.Close()

	if _, err := pool.Exec(scoped(ctx, tenantA),
		`INSERT INTO rls_probe (id, tenant_id, note) VALUES ('a1', $1, 'A')`, tenantA); err != nil {
		t.Fatalf("insert as A: %v", err)
	}
	if _, err := pool.Exec(scoped(ctx, tenantB),
		`INSERT INTO rls_probe (id, tenant_id, note) VALUES ('b1', $1, 'B')`, tenantB); err != nil {
		t.Fatalf("insert as B: %v", err)
	}

	var seen int
	if err := pool.QueryRow(scoped(ctx, tenantB),
		`SELECT count(*) FROM rls_probe WHERE id = 'a1'`).Scan(&seen); err != nil {
		t.Fatalf("read as B: %v", err)
	}
	if seen != 0 {
		t.Error("tenant B read tenant A's row")
	}

	// And B sees its own.
	if err := pool.QueryRow(scoped(ctx, tenantB),
		`SELECT count(*) FROM rls_probe`).Scan(&seen); err != nil {
		t.Fatalf("count as B: %v", err)
	}
	if seen != 1 {
		t.Errorf("tenant B sees %d rows, want only its own", seen)
	}
}

// The one that matters most: a connection must not carry the previous
// caller's tenant.
//
// Connections are shared. If the scope were written only when a caller had
// one, a query with no tenant would run under whatever the last caller set —
// and a background job or a missed middleware would silently read another
// tenant's rows. So the settings are written on every acquire, empty included.
func TestAConnectionDoesNotCarryThePreviousTenant(t *testing.T) {
	setupFixture(t)
	ctx := context.Background()

	// One connection, so the second query is guaranteed to reuse the first's.
	cfg, err := pgxpool.ParseConfig(*appDSN)
	if err != nil {
		t.Fatalf("parse: %v", err)
	}
	cfg.MaxConns, cfg.MinConns = 1, 1

	pool, err := NewWithConfig(ctx, cfg)
	if err != nil {
		t.Fatalf("NewWithConfig: %v", err)
	}
	defer pool.Close()

	if _, err := pool.Exec(scoped(ctx, tenantA),
		`INSERT INTO rls_probe (id, tenant_id, note) VALUES ('a1', $1, 'A')`, tenantA); err != nil {
		t.Fatalf("insert as A: %v", err)
	}

	// The same connection, now with no tenant in context at all.
	var seen int
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM rls_probe`).Scan(&seen); err != nil {
		t.Fatalf("unscoped read: %v", err)
	}
	if seen != 0 {
		t.Errorf("an unscoped query read %d rows on a connection last used by tenant A", seen)
	}
}

// A config that already sets PrepareConn is refused rather than silently
// overridden, because a hook that does not run is the defect this package
// exists to fix.
func TestAConflictingHookIsRefused(t *testing.T) {
	if *appDSN == "" {
		t.Skip("no -rls-dsn given")
	}
	cfg, err := pgxpool.ParseConfig(*appDSN)
	if err != nil {
		t.Fatalf("parse: %v", err)
	}
	cfg.PrepareConn = func(context.Context, *pgx.Conn) (bool, error) { return true, nil }

	if _, err := NewWithConfig(context.Background(), cfg); err == nil {
		t.Fatal("a config with its own PrepareConn was accepted and would have had it dropped")
	}
}

// Probe names the misconfiguration that would otherwise be silent: a
// background sweep under a role RLS applies to reads nothing, for ever,
// without an error anywhere.
func TestProbeRefusesARoleThatRLSApplies(t *testing.T) {
	setupFixture(t)
	ctx := context.Background()

	app, err := NewSystem(ctx, *appDSN)
	if err != nil {
		t.Fatalf("NewSystem: %v", err)
	}
	defer app.Close()

	if err := Probe(ctx, app); err == nil {
		t.Error("Probe accepted a role that RLS applies to for cross-tenant work")
	}

	admin, err := NewSystem(ctx, *adminDSN)
	if err != nil {
		t.Fatalf("NewSystem(admin): %v", err)
	}
	defer admin.Close()

	if err := Probe(ctx, admin); err != nil {
		t.Errorf("Probe refused a privileged role: %v", err)
	}
}
