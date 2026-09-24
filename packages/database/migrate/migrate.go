package migrate

import (
	"context"
	"fmt"
	"hash/crc32"
	"io/fs"
	"path"
	"sort"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"
)

const migrationTable = "schema_migrations"

// Up applies all pending .up.sql migrations from the provided filesystem.
// It uses a PostgreSQL advisory lock to prevent concurrent migration runs
// and tracks applied versions in a schema_migrations table.
//
// The fs.FS should contain files named like "000001_description.up.sql".
// Files are sorted lexicographically and applied in order. Already-applied
// versions (by filename) are skipped.
func Up(ctx context.Context, pool *pgxpool.Pool, migrations fs.FS, logger *zap.Logger) error {
	conn, err := pool.Acquire(ctx)
	if err != nil {
		return fmt.Errorf("migrate: acquire connection: %w", err)
	}
	defer conn.Release()

	lockID := int64(crc32.ChecksumIEEE([]byte(migrationTable)))
	if _, err := conn.Exec(ctx, "SELECT pg_advisory_lock($1)", lockID); err != nil {
		return fmt.Errorf("migrate: advisory lock: %w", err)
	}
	defer func() {
		_, _ = conn.Exec(ctx, "SELECT pg_advisory_unlock($1)", lockID)
	}()

	if err := ensureTable(ctx, conn, logger); err != nil {
		return err
	}

	files, err := collectUpFiles(migrations)
	if err != nil {
		return fmt.Errorf("migrate: reading migrations: %w", err)
	}
	if len(files) == 0 {
		logger.Info("migrate: no migration files found")
		return nil
	}

	applied, err := appliedVersions(ctx, conn)
	if err != nil {
		return err
	}

	pending := 0
	for _, f := range files {
		if applied[f] {
			continue
		}
		pending++

		logger.Info("migrate: applying", zap.String("file", f))

		content, err := fs.ReadFile(migrations, f)
		if err != nil {
			return fmt.Errorf("migrate: read %s: %w", f, err)
		}

		tx, err := conn.Begin(ctx)
		if err != nil {
			return fmt.Errorf("migrate: begin tx for %s: %w", f, err)
		}

		if _, err := tx.Exec(ctx, string(content)); err != nil {
			_ = tx.Rollback(ctx)
			return fmt.Errorf("migrate: exec %s: %w", f, err)
		}

		if _, err := tx.Exec(ctx,
			fmt.Sprintf("INSERT INTO %s (version, dirty) VALUES ($1, false)", migrationTable),
			f,
		); err != nil {
			_ = tx.Rollback(ctx)
			return fmt.Errorf("migrate: record %s: %w", f, err)
		}

		if err := tx.Commit(ctx); err != nil {
			return fmt.Errorf("migrate: commit %s: %w", f, err)
		}

		logger.Info("migrate: applied", zap.String("file", f))
	}

	if pending == 0 {
		logger.Info("migrate: schema is up to date")
	} else {
		logger.Info("migrate: done", zap.Int("applied", pending))
	}
	return nil
}

func ensureTable(ctx context.Context, conn *pgxpool.Conn, logger *zap.Logger) error {
	query := fmt.Sprintf(`CREATE TABLE IF NOT EXISTS %s (
		version TEXT PRIMARY KEY,
		dirty   BOOLEAN NOT NULL DEFAULT false,
		applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
	)`, migrationTable)

	if _, err := conn.Exec(ctx, query); err != nil {
		return fmt.Errorf("migrate: create tracking table: %w", err)
	}
	logger.Debug("migrate: tracking table ready")
	return nil
}

func appliedVersions(ctx context.Context, conn *pgxpool.Conn) (map[string]bool, error) {
	rows, err := conn.Query(ctx,
		fmt.Sprintf("SELECT version FROM %s", migrationTable))
	if err != nil {
		return nil, fmt.Errorf("migrate: query applied versions: %w", err)
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
		name := path.Base(p)
		if strings.HasSuffix(name, ".up.sql") {
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

// UpFromDSN applies pending migrations over a connection of its own, then
// closes it.
//
// Migrations are DDL, and the role a service serves requests with does not run
// DDL: it is the DML-only, non-superuser role the row-level security policies
// apply to. Handing migrations the request pool would mean either giving that
// role the ability to drop tables, or a service that cannot start.
//
// So this opens a short-lived pool as the migration role and closes it before
// the service begins serving. A plain pgxpool rather than an rlspool one:
// migrations are not tenant-scoped, and a connection carrying an empty
// app.tenant_id is exactly right for DDL.
//
// dsn falls back to the application DSN at the call site, which is correct for
// a development stack that connects as a superuser and wrong in production —
// where it will fail loudly on the first CREATE TABLE rather than quietly.
func UpFromDSN(ctx context.Context, dsn string, migrations fs.FS, logger *zap.Logger) error {
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		return fmt.Errorf("migrate: connect as the migration role: %w", err)
	}
	defer pool.Close()

	return Up(ctx, pool, migrations, logger)
}
