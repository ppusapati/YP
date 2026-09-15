package modulith

import (
	"context"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"
)

const migrationTable = "schema_migrations"

// RunAllMigrations discovers and runs migrations from every service directory.
// Each service's migrations are prefixed with the service name in the tracking
// table to avoid filename collisions (e.g., "farm-service/000001_init.up.sql").
func RunAllMigrations(ctx context.Context, pool *pgxpool.Pool, logger *zap.Logger, root string) error {
	entries, err := os.ReadDir(root)
	if err != nil {
		return fmt.Errorf("read root dir: %w", err)
	}

	var serviceDirs []string
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		migDir := filepath.Join(root, e.Name(), "migrations")
		if info, err := os.Stat(migDir); err == nil && info.IsDir() {
			serviceDirs = append(serviceDirs, e.Name())
		}
	}
	sort.Strings(serviceDirs)

	conn, err := pool.Acquire(ctx)
	if err != nil {
		return fmt.Errorf("migrate: acquire connection: %w", err)
	}
	defer conn.Release()

	if _, err := conn.Exec(ctx, fmt.Sprintf(`CREATE TABLE IF NOT EXISTS %s (
		version TEXT PRIMARY KEY,
		dirty   BOOLEAN NOT NULL DEFAULT false,
		applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
	)`, migrationTable)); err != nil {
		return fmt.Errorf("migrate: create tracking table: %w", err)
	}

	applied, err := loadApplied(ctx, conn)
	if err != nil {
		return err
	}

	for _, svc := range serviceDirs {
		migDir := filepath.Join(root, svc, "migrations")
		logger.Info("running migrations", zap.String("service", svc))

		files, err := collectUpFiles(os.DirFS(migDir))
		if err != nil {
			return fmt.Errorf("migrate %s: collect files: %w", svc, err)
		}

		for _, f := range files {
			version := svc + "/" + f
			if applied[version] {
				continue
			}

			logger.Info("applying migration", zap.String("version", version))

			content, err := os.ReadFile(filepath.Join(migDir, f))
			if err != nil {
				return fmt.Errorf("migrate %s: read %s: %w", svc, f, err)
			}

			tx, err := conn.Begin(ctx)
			if err != nil {
				return fmt.Errorf("migrate %s: begin tx: %w", svc, err)
			}

			if _, err := tx.Exec(ctx, string(content)); err != nil {
				_ = tx.Rollback(ctx)
				return fmt.Errorf("migrate %s: exec %s: %w", svc, f, err)
			}

			if _, err := tx.Exec(ctx,
				fmt.Sprintf("INSERT INTO %s (version, dirty) VALUES ($1, false)", migrationTable),
				version,
			); err != nil {
				_ = tx.Rollback(ctx)
				return fmt.Errorf("migrate %s: record %s: %w", svc, f, err)
			}

			if err := tx.Commit(ctx); err != nil {
				return fmt.Errorf("migrate %s: commit %s: %w", svc, f, err)
			}
		}
	}

	logger.Info("all service migrations complete")
	return nil
}

func loadApplied(ctx context.Context, conn *pgxpool.Conn) (map[string]bool, error) {
	rows, err := conn.Query(ctx, fmt.Sprintf("SELECT version FROM %s", migrationTable))
	if err != nil {
		return nil, fmt.Errorf("migrate: query applied: %w", err)
	}
	defer rows.Close()

	applied := make(map[string]bool)
	for rows.Next() {
		var v string
		if err := rows.Scan(&v); err != nil {
			return nil, fmt.Errorf("migrate: scan version: %w", err)
		}
		applied[v] = true
	}
	return applied, rows.Err()
}

func collectUpFiles(migrations fs.FS) ([]string, error) {
	var files []string
	err := fs.WalkDir(migrations, ".", func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}
		if strings.HasSuffix(p, ".up.sql") {
			files = append(files, p)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	sort.Strings(files)
	return files, nil
}
