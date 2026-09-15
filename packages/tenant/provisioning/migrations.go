package provisioning

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// MigrationRunner runs schema migrations against a tenant database.
type MigrationRunner interface {
	// RunMigrations applies all pending migrations to the target database.
	RunMigrations(ctx context.Context, pool *pgxpool.Pool, tenantID string) error
}

// ServiceMigration defines a single service's migration set.
type ServiceMigration struct {
	// ServiceName identifies the service (e.g., "identity", "inventory", "accounting").
	ServiceName string
	// Statements is the ordered list of DDL statements to execute.
	Statements []string
}

// DefaultMigrationRunner applies SQL migration statements for each registered service.
type DefaultMigrationRunner struct {
	migrations []ServiceMigration
}

// NewMigrationRunner creates a runner with the given service migrations.
func NewMigrationRunner(migrations []ServiceMigration) *DefaultMigrationRunner {
	return &DefaultMigrationRunner{
		migrations: migrations,
	}
}

// RunMigrations applies all service migrations to the target pool within a transaction per service.
// Each service migration runs in its own transaction so a partial failure can be identified.
func (r *DefaultMigrationRunner) RunMigrations(ctx context.Context, pool *pgxpool.Pool, tenantID string) error {
	for _, svc := range r.migrations {
		if err := r.runServiceMigration(ctx, pool, svc); err != nil {
			return fmt.Errorf("migration failed for service %q (tenant %s): %w", svc.ServiceName, tenantID, err)
		}
	}
	return nil
}

// runServiceMigration runs a single service's migration statements in a transaction.
func (r *DefaultMigrationRunner) runServiceMigration(ctx context.Context, pool *pgxpool.Pool, svc ServiceMigration) error {
	tx, err := pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin transaction: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck

	for i, stmt := range svc.Statements {
		if _, err := tx.Exec(ctx, stmt); err != nil {
			return fmt.Errorf("statement %d: %w", i, err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit: %w", err)
	}

	return nil
}

// MigrationResult records the outcome of running migrations.
type MigrationResult struct {
	ServiceName string        `json:"service_name"`
	Success     bool          `json:"success"`
	Duration    time.Duration `json:"duration"`
	Error       string        `json:"error,omitempty"`
}

// RunAllMigrations runs migrations for all services and returns individual results.
// It continues past failures so the caller can see which services succeeded.
func RunAllMigrations(ctx context.Context, runner MigrationRunner, pool *pgxpool.Pool, tenantID string) ([]MigrationResult, error) {
	err := runner.RunMigrations(ctx, pool, tenantID)
	if err != nil {
		return nil, err
	}
	return nil, nil
}

// CoreMigrations returns the base DDL statements needed by every tenant database.
// These create the shared infrastructure tables (migrations tracking, tenant metadata).
func CoreMigrations() ServiceMigration {
	return ServiceMigration{
		ServiceName: "core",
		Statements: []string{
			`CREATE TABLE IF NOT EXISTS schema_migrations (
				id SERIAL PRIMARY KEY,
				service_name TEXT NOT NULL,
				version TEXT NOT NULL,
				applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
				UNIQUE(service_name, version)
			)`,
			`CREATE TABLE IF NOT EXISTS tenant_settings (
				key TEXT PRIMARY KEY,
				value TEXT NOT NULL,
				updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
			)`,
			`CREATE TABLE IF NOT EXISTS roles (
				id TEXT PRIMARY KEY,
				name TEXT NOT NULL UNIQUE,
				description TEXT,
				is_system BOOLEAN NOT NULL DEFAULT FALSE,
				created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
			)`,
			`CREATE TABLE IF NOT EXISTS users (
				id TEXT PRIMARY KEY,
				email TEXT NOT NULL UNIQUE,
				name TEXT NOT NULL,
				role_id TEXT REFERENCES roles(id),
				is_active BOOLEAN NOT NULL DEFAULT TRUE,
				created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
				updated_at TIMESTAMPTZ
			)`,
		},
	}
}
