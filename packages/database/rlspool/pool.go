// Package rlspool builds connection pools that carry the caller's tenant into
// PostgreSQL, so row-level security can actually do something.
//
// # What was wrong
//
// Every table in this platform has RLS policies keyed on
// current_setting('app.tenant_id'). Nothing set it. Repositories query the
// pool directly, and only uow.RLSFactory ever ran set_config — inside a
// transaction the repositories do not open. So under the non-superuser role
// scripts/setup-db-roles.sql defines for production, every INSERT violated its
// policy's WITH CHECK and every SELECT matched nothing.
//
// It went unnoticed because docker-compose connects as the superuser
// `yieldpoint`, and a superuser bypasses RLS entirely. The policies had never
// been exercised anywhere: not in development, not in tests, not in CI.
//
// Tenant isolation did not depend on them — the repositories' own
// `tenant_id = $1` clauses are present and correct — but a defence that cannot
// engage is not a defence, and the one place it matters is the query somebody
// eventually writes without that clause.
//
// # How this fixes it
//
// A pool built here sets app.tenant_id, app.company_id and app.branch_id on
// every connection as it is acquired, from the context of the query that is
// acquiring it. pgx calls PrepareConn with that context, which is what makes
// this possible without changing a single repository.
//
// The settings are written on *every* acquire, including when the context
// carries no tenant at all. That costs a round trip per acquire, and it is
// deliberate. Connections are shared between tenants; skipping the write when
// the caller has no tenant would leave the previous caller's tenant in place
// and hand the next query somebody else's rows. A cache keyed on the
// connection would avoid most of those round trips, and it is not worth the
// class of bug a stale entry would be.
package rlspool

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/p9context"
)

// applyScope sets all three settings in one round trip.
//
// All three every time, and empty where the caller has none: these are session
// settings on a pooled connection, so one left over from the last caller is
// another tenant's data handed to this one.
//
// is_local is false because most queries here do not run in a transaction. A
// transaction that sets them again with is_local true — uow.RLSFactory does —
// overrides these for its duration and reverts afterwards, which is the
// behaviour both want.
const applyScope = `SELECT
	set_config('app.tenant_id',  $1, false),
	set_config('app.company_id', $2, false),
	set_config('app.branch_id',  $3, false)`

// New opens a pool that scopes every connection to the caller's tenant.
//
// A drop-in replacement for pgxpool.New. Services should use it for the pool
// their repositories read and write through.
func New(ctx context.Context, dsn string) (*pgxpool.Pool, error) {
	cfg, err := pgxpool.ParseConfig(dsn)
	if err != nil {
		return nil, fmt.Errorf("rlspool: parse config: %w", err)
	}
	return NewWithConfig(ctx, cfg)
}

// NewWithConfig is New for a caller that has tuned the pool itself.
//
// It replaces PrepareConn. A config that set its own would have it silently
// dropped, so that is refused rather than quietly overridden: a hook that does
// not run is exactly the failure this package exists to fix.
func NewWithConfig(ctx context.Context, cfg *pgxpool.Config) (*pgxpool.Pool, error) {
	if cfg == nil {
		return nil, fmt.Errorf("rlspool: config is required")
	}
	if cfg.PrepareConn != nil {
		return nil, fmt.Errorf("rlspool: the config already sets PrepareConn, which this would replace")
	}

	cfg.PrepareConn = func(ctx context.Context, conn *pgx.Conn) (bool, error) {
		scope := p9context.MustRLSScope(ctx)
		if _, err := conn.Exec(ctx, applyScope,
			scope.TenantID, scope.CompanyID, scope.BranchID); err != nil {
			// False and an error: the connection is destroyed and the query
			// fails. Returning true would hand back a connection carrying
			// whatever the last caller set, which is the one outcome worth
			// losing a connection to avoid.
			return false, fmt.Errorf("rlspool: could not scope the connection to its tenant: %w", err)
		}
		return true, nil
	}

	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("rlspool: %w", err)
	}
	return pool, nil
}

// NewSystem opens a pool for work that is legitimately cross-tenant.
//
// A few things in this platform are: alert-service's rule scanner enumerates
// every tenant's due rules, and irrigation-service's sweep closes finished
// runs on every farm. They have no request to inherit a tenant from, and a
// per-tenant pool would return them nothing.
//
// Connections from this pool are left unscoped, so the role behind the DSN has
// to be one RLS does not apply to — a role with BYPASSRLS. Under an ordinary
// role a cross-tenant read returns zero rows, which is not an error and looks
// exactly like a platform where nothing is due. That is why Probe exists and
// why services should call it at startup.
func NewSystem(ctx context.Context, dsn string) (*pgxpool.Pool, error) {
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		return nil, fmt.Errorf("rlspool: system pool: %w", err)
	}
	return pool, nil
}

// Probe reports whether a system pool's role can actually read across tenants.
//
// Worth calling at startup and logging loudly, because the failure it catches
// is silent: a background sweep under a role that RLS applies to reads no rows
// and does nothing, for ever, without an error anywhere. A sweep that finds
// nothing looks identical to a platform with nothing to do.
func Probe(ctx context.Context, pool *pgxpool.Pool) error {
	var super, bypass bool
	if err := pool.QueryRow(ctx,
		`SELECT rolsuper, rolbypassrls FROM pg_roles WHERE rolname = current_user`).
		Scan(&super, &bypass); err != nil {
		return fmt.Errorf("rlspool: could not read the connected role: %w", err)
	}
	if super || bypass {
		return nil
	}
	return fmt.Errorf("rlspool: this role is subject to row-level security, so cross-tenant " +
		"background work will read no rows and do nothing silently; grant it BYPASSRLS or " +
		"point the system DSN at a role that has it")
}
