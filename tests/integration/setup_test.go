//go:build e2e

// Package integration_test provides end-to-end smoke tests that exercise
// multiple YieldPoint services against a real PostgreSQL instance.
//
// The tests use direct database operations (pgxpool) rather than running
// services. All relevant service migrations are applied during setup and
// RLS tenant context is configured per-connection.
//
// Run:
//
//	DATABASE_URL="postgres://yieldpoint_test:yieldpoint_test@localhost:5433/yieldpoint_test?sslmode=disable" \
//	  go test -tags=e2e -v -count=1 ./tests/integration/...
package integration_test

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const (
	testTenantID = "01J0000000TEST00TENANT001"
	testUserID   = "01J0000000TEST0000USER001"
)

// serviceDBOrder is the order in which service migrations are applied.
// Services whose schemas are referenced by later tests come first.
var serviceDBOrder = []string{
	"farm-service",
	"field-service",
	"crop-service",
	"sensor-service",
	"irrigation-service",
	"soil-service",
	"yield-service",
	"pest-prediction-service",
	"plant-diagnosis-service",
	"satellite-service",
	"traceability-service",
	"commerce-service",
}

// ---------------------------------------------------------------------------
// Pool helpers
// ---------------------------------------------------------------------------

// testPool creates a pgxpool connected to DATABASE_URL. Skips the test if the
// env var is absent or the database is unreachable.
func testPool(t *testing.T) *pgxpool.Pool {
	t.Helper()

	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		t.Skip("DATABASE_URL not set -- skipping e2e test")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Skipf("cannot connect to test database: %v", err)
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		t.Skipf("database ping failed: %v", err)
	}
	return pool
}

// ---------------------------------------------------------------------------
// Migration runner
// ---------------------------------------------------------------------------

// rootDir returns the project root (two levels up from tests/integration/).
func rootDir() string {
	// When run with `go test ./tests/integration/...` the working directory
	// is the package directory, i.e. <root>/tests/integration.
	wd, err := os.Getwd()
	if err != nil {
		panic(fmt.Sprintf("Getwd: %v", err))
	}
	return filepath.Join(wd, "..", "..")
}

// runMigrations applies every *.up.sql migration for all services, in order.
func runMigrations(t *testing.T, pool *pgxpool.Pool) {
	t.Helper()

	root := rootDir()
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
	defer cancel()

	for _, svc := range serviceDBOrder {
		migDir := filepath.Join(root, svc, "migrations")
		entries, err := os.ReadDir(migDir)
		if err != nil {
			t.Fatalf("reading migrations for %s: %v", svc, err)
		}

		// Collect and sort *.up.sql files lexicographically.
		var upFiles []string
		for _, e := range entries {
			if !e.IsDir() && strings.HasSuffix(e.Name(), ".up.sql") {
				upFiles = append(upFiles, filepath.Join(migDir, e.Name()))
			}
		}
		sort.Strings(upFiles)

		for _, f := range upFiles {
			sql, err := os.ReadFile(f)
			if err != nil {
				t.Fatalf("reading %s: %v", f, err)
			}
			if _, err := pool.Exec(ctx, string(sql)); err != nil {
				t.Fatalf("migration %s failed: %v", filepath.Base(f), err)
			}
		}
	}
}

// ---------------------------------------------------------------------------
// RLS helper
// ---------------------------------------------------------------------------

// setTenant configures the PostgreSQL session variable used by RLS policies.
// Because pgxpool multiplexes connections, we set the variable in a callback
// passed to pool.Exec (single-shot) — but for multi-statement flows each
// test should acquire a single connection from the pool.
func setTenant(ctx context.Context, pool *pgxpool.Pool, tenantID string) error {
	_, err := pool.Exec(ctx, fmt.Sprintf("SET app.tenant_id = '%s'", tenantID))
	return err
}

// ---------------------------------------------------------------------------
// TestMain: one-time setup & teardown
// ---------------------------------------------------------------------------

var sharedPool *pgxpool.Pool

func TestMain(m *testing.M) {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		// Not an error — tests will individually skip.
		os.Exit(m.Run())
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	pool, err := pgxpool.New(ctx, dsn)
	cancel()
	if err != nil {
		fmt.Fprintf(os.Stderr, "cannot connect to test database: %v\n", err)
		os.Exit(1)
	}

	sharedPool = pool

	// Apply all service migrations.
	// We use a lightweight wrapper since we cannot call t.Helper()/t.Fatalf()
	// from TestMain — so any migration failure is a hard exit.
	root := rootDir()
	migCtx, migCancel := context.WithTimeout(context.Background(), 2*time.Minute)
	defer migCancel()
	for _, svc := range serviceDBOrder {
		migDir := filepath.Join(root, svc, "migrations")
		entries, _ := os.ReadDir(migDir)
		var upFiles []string
		for _, e := range entries {
			if !e.IsDir() && strings.HasSuffix(e.Name(), ".up.sql") {
				upFiles = append(upFiles, filepath.Join(migDir, e.Name()))
			}
		}
		sort.Strings(upFiles)
		for _, f := range upFiles {
			sql, err := os.ReadFile(f)
			if err != nil {
				fmt.Fprintf(os.Stderr, "reading %s: %v\n", f, err)
				os.Exit(1)
			}
			if _, err := pool.Exec(migCtx, string(sql)); err != nil {
				fmt.Fprintf(os.Stderr, "migration %s failed: %v\n", filepath.Base(f), err)
				os.Exit(1)
			}
		}
	}

	code := m.Run()

	pool.Close()
	os.Exit(code)
}
