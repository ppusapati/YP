package uow

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
)

// RLSFactory creates UnitOfWork instances that automatically set RLS session variables.
// It extracts RLSScope from context and sets PostgreSQL session variables
// (app.tenant_id, app.company_id, app.branch_id) at the start of each transaction.
type RLSFactory struct {
	pool *pgxpool.Pool
}

// NewRLSFactory creates a new RLS-aware Factory from a connection pool.
func NewRLSFactory(pool *pgxpool.Pool) Factory {
	return &RLSFactory{pool: pool}
}

// Begin starts a new transaction and sets RLS session variables from context.
func (f *RLSFactory) Begin(ctx context.Context) (UnitOfWork, error) {
	tx, err := f.pool.Begin(ctx)
	if err != nil {
		return nil, errors.InternalServer(
			"TRANSACTION_BEGIN_FAILED",
			fmt.Sprintf("Failed to begin transaction: %v", err),
		)
	}

	// Extract RLS scope from context
	scope := p9context.MustRLSScope(ctx)

	// Set RLS session variables
	if err := setRLSVariables(ctx, tx, scope); err != nil {
		// Rollback and return error
		_ = tx.Rollback(ctx)
		return nil, err
	}

	return NewUnitOfWork(tx), nil
}

// setRLSVariables sets PostgreSQL session variables for RLS policies.
// Uses SET LOCAL to scope variables to the current transaction only.
func setRLSVariables(ctx context.Context, tx interface{ Exec(context.Context, string, ...interface{}) (interface{}, error) }, scope p9context.RLSScope) error {
	// Always set tenant_id (may be empty for super-admin operations)
	if scope.TenantID != "" {
		if _, err := tx.Exec(ctx, "SET LOCAL app.tenant_id = $1", scope.TenantID); err != nil {
			return errors.InternalServer(
				"RLS_TENANT_SET_FAILED",
				fmt.Sprintf("Failed to set tenant_id: %v", err),
			)
		}
	}

	// Set company_id if present
	if scope.CompanyID != "" {
		if _, err := tx.Exec(ctx, "SET LOCAL app.company_id = $1", scope.CompanyID); err != nil {
			return errors.InternalServer(
				"RLS_COMPANY_SET_FAILED",
				fmt.Sprintf("Failed to set company_id: %v", err),
			)
		}
	}

	// Set branch_id if present
	if scope.BranchID != "" {
		if _, err := tx.Exec(ctx, "SET LOCAL app.branch_id = $1", scope.BranchID); err != nil {
			return errors.InternalServer(
				"RLS_BRANCH_SET_FAILED",
				fmt.Sprintf("Failed to set branch_id: %v", err),
			)
		}
	}

	return nil
}

// WithRLSTransaction executes a function within a transaction with RLS variables set.
// Automatically commits on success or rolls back on error.
func WithRLSTransaction(ctx context.Context, pool *pgxpool.Pool, fn func(uow UnitOfWork) error) error {
	factory := NewRLSFactory(pool)
	return WithTx(ctx, factory, fn)
}

// SetRLSOnPool sets RLS session variables on a pooled connection for non-transactional reads.
// This acquires a connection, sets variables, executes the function, and releases the connection.
// Note: The session variables are reset when the connection is returned to the pool.
func SetRLSOnPool(ctx context.Context, pool *pgxpool.Pool, fn func(context.Context) error) error {
	conn, err := pool.Acquire(ctx)
	if err != nil {
		return errors.InternalServer(
			"POOL_ACQUIRE_FAILED",
			fmt.Sprintf("Failed to acquire connection: %v", err),
		)
	}
	defer conn.Release()

	// Extract RLS scope from context
	scope := p9context.MustRLSScope(ctx)

	// Set RLS variables using SET (not SET LOCAL, since no transaction)
	if scope.TenantID != "" {
		if _, err := conn.Exec(ctx, "SET app.tenant_id = $1", scope.TenantID); err != nil {
			return errors.InternalServer(
				"RLS_TENANT_SET_FAILED",
				fmt.Sprintf("Failed to set tenant_id: %v", err),
			)
		}
	}

	if scope.CompanyID != "" {
		if _, err := conn.Exec(ctx, "SET app.company_id = $1", scope.CompanyID); err != nil {
			return errors.InternalServer(
				"RLS_COMPANY_SET_FAILED",
				fmt.Sprintf("Failed to set company_id: %v", err),
			)
		}
	}

	if scope.BranchID != "" {
		if _, err := conn.Exec(ctx, "SET app.branch_id = $1", scope.BranchID); err != nil {
			return errors.InternalServer(
				"RLS_BRANCH_SET_FAILED",
				fmt.Sprintf("Failed to set branch_id: %v", err),
			)
		}
	}

	return fn(ctx)
}
