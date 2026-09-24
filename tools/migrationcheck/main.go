// Command migrationcheck applies every service's migrations to its own empty
// database.
//
// It exists because auth-service's 000004_add_rls could not apply to a fresh
// database at all: it referenced a deleted_at column that table has never had,
// so CREATE POLICY failed and migrate rolled the whole file back. Nothing
// caught it, because the only thing that creates an empty database is a new
// deployment — which would have found it by failing to start the
// authentication service.
//
// Migrations are applied through the platform's own migrate package rather
// than psql, so what is exercised is the code path a service runs at boot.
//
// Usage:
//
//	PGHOST=localhost PGPORT=5432 PGUSER=yieldpoint PGPASSWORD=… \
//	    go run ./tools/migrationcheck
package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"

	"p9e.in/samavaya/packages/database/migrate"
)

// needsExtension lists services whose schema requires a PostgreSQL extension
// the stock image does not ship.
//
// Skipped by name rather than by swallowing errors, so that a migration
// failing for any other reason is still a failure. The comment on each is what
// it needs, so adding the right image is a decision somebody can make.
var needsExtension = map[string]string{
	"advisory-service":            "pgvector, for the retrieval embeddings",
	"satellite-ingestion-service": "postgis, for scene footprints",
	"sensor-service":              "timescaledb, for the sensor_readings hypertable",
}

func main() {
	root, err := repoRoot()
	if err != nil {
		fail("locate the repository root: %v", err)
	}

	services, err := servicesWithMigrations(root)
	if err != nil {
		fail("list services: %v", err)
	}
	if len(services) == 0 {
		fail("no service migrations found under %s", root)
	}

	admin := dsn("postgres")

	// When the databases already exist — because scripts/init-databases.sh has
	// just bootstrapped the cluster the way docker-compose does — they are
	// kept rather than recreated. Dropping them would take the roles' default
	// privileges with them, and those are per-database: every table a service
	// creates afterwards would then be readable by nobody but its owner.
	//
	// They are still empty, so this still answers the question it exists to
	// answer, and answers a second one: whether the non-superuser migration
	// role can run every migration.
	keepDatabases := os.Getenv("MIGRATIONCHECK_KEEP_DATABASES") == "1"
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Minute)
	defer cancel()

	logger := zap.NewNop()
	var failures []string
	var skipped, applied int

	for _, svc := range services {
		if why, skip := needsExtension[svc]; skip {
			fmt.Printf("  skip  %-32s needs %s\n", svc, why)
			skipped++
			continue
		}

		db := strings.ReplaceAll(svc, "-", "_")
		if !keepDatabases {
			if err := recreate(ctx, admin, db); err != nil {
				failures = append(failures, fmt.Sprintf("%s: %v", svc, err))
				fmt.Printf("  FAIL  %-32s %v\n", svc, err)
				continue
			}
		}

		n, err := apply(ctx, dsn(db), filepath.Join(root, svc, "migrations"), logger)
		if err != nil {
			failures = append(failures, fmt.Sprintf("%s: %v", svc, err))
			fmt.Printf("  FAIL  %-32s %v\n", svc, err)
			continue
		}
		fmt.Printf("  ok    %-32s %2d migrations\n", svc, n)
		applied++
	}

	fmt.Printf("\n%d applied, %d skipped, %d failed\n", applied, skipped, len(failures))
	if len(failures) > 0 {
		fmt.Println("\nA migration that cannot apply to an empty database is a service that " +
			"cannot be deployed from scratch:")
		for _, f := range failures {
			fmt.Println("  -", f)
		}
		os.Exit(1)
	}
}

func apply(ctx context.Context, url, dir string, logger *zap.Logger) (int, error) {
	pool, err := pgxpool.New(ctx, url)
	if err != nil {
		return 0, fmt.Errorf("connect: %w", err)
	}
	defer pool.Close()

	before, _ := countApplied(ctx, pool)
	if err := migrate.Up(ctx, pool, os.DirFS(dir), logger); err != nil {
		return 0, err
	}
	after, err := countApplied(ctx, pool)
	if err != nil {
		return 0, err
	}
	return after - before, nil
}

func countApplied(ctx context.Context, pool *pgxpool.Pool) (int, error) {
	var n int
	err := pool.QueryRow(ctx, `SELECT count(*) FROM schema_migrations`).Scan(&n)
	return n, err
}

// recreate drops and creates the service's database, so each run starts from
// the empty state a new deployment begins in.
func recreate(ctx context.Context, adminURL, db string) error {
	conn, err := pgx.Connect(ctx, adminURL)
	if err != nil {
		return fmt.Errorf("connect as admin: %w", err)
	}
	defer conn.Close(ctx) //nolint:errcheck

	// The name comes from a directory in this repository, not from input, and
	// an identifier cannot be a bind parameter.
	if _, err := conn.Exec(ctx, fmt.Sprintf(`DROP DATABASE IF EXISTS %q`, db)); err != nil {
		return fmt.Errorf("drop: %w", err)
	}
	if _, err := conn.Exec(ctx, fmt.Sprintf(`CREATE DATABASE %q`, db)); err != nil {
		return fmt.Errorf("create: %w", err)
	}
	return nil
}

func dsn(db string) string {
	return fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
		env("PGUSER", "yieldpoint"), env("PGPASSWORD", "yieldpoint"),
		env("PGHOST", "localhost"), env("PGPORT", "5432"), db)
}

func env(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

// servicesWithMigrations finds every directory holding a migrations folder, so
// a service added tomorrow is covered without anybody remembering to list it.
func servicesWithMigrations(root string) ([]string, error) {
	entries, err := os.ReadDir(root)
	if err != nil {
		return nil, err
	}
	var out []string
	for _, e := range entries {
		if !e.IsDir() || strings.HasPrefix(e.Name(), ".") {
			continue
		}
		if st, err := os.Stat(filepath.Join(root, e.Name(), "migrations")); err == nil && st.IsDir() {
			out = append(out, e.Name())
		}
	}
	sort.Strings(out)
	return out, nil
}

func repoRoot() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", err
	}
	for {
		if _, err := os.Stat(filepath.Join(dir, "go.mod")); err == nil {
			return dir, nil
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", fmt.Errorf("no go.mod above the working directory")
		}
		dir = parent
	}
}

func fail(format string, args ...interface{}) {
	fmt.Fprintf(os.Stderr, format+"\n", args...)
	os.Exit(1)
}
