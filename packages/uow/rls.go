package uow

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgconn"
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
// Uses set_config() with is_local=true to scope variables to the current transaction.
// set_config is preferred over SET LOCAL because its parameters are properly
// escaped by the driver, eliminating any SQL injection surface.
func setRLSVariables(ctx context.Context, tx interface{ Exec(context.Context, string, ...interface{}) (pgconn.CommandTag, error) }, scope p9context.RLSScope) error {
	if scope.TenantID != "" {
		if _, err := tx.Exec(ctx, "SELECT set_config('app.tenant_id', $1, true)", scope.TenantID); err != nil {
			return errors.InternalServer(
				"RLS_TENANT_SET_FAILED",
				fmt.Sprintf("Failed to set tenant_id: %v", err),
			)
		}
	}

	if scope.CompanyID != "" {
		if _, err := tx.Exec(ctx, "SELECT set_config('app.company_id', $1, true)", scope.CompanyID); err != nil {
			return errors.InternalServer(
				"RLS_COMPANY_SET_FAILED",
				fmt.Sprintf("Failed to set company_id: %v", err),
			)
		}
	}

	if scope.BranchID != "" {
		if _, err := tx.Exec(ctx, "SELECT set_config('app.branch_id', $1, true)", scope.BranchID); err != nil {
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

// SetRLSOnPool executes a read-only function within a transaction that has
// RLS session variables set. Using a transaction ensures that set_config
// with is_local=true scopes the variables to the transaction, preventing
// leakage to other connections when the connection returns to the pool.
func SetRLSOnPool(ctx context.Context, pool *pgxpool.Pool, fn func(context.Context) error) error {
	tx, err := pool.Begin(ctx)
	if err != nil {
		return errors.InternalServer(
			"POOL_BEGIN_FAILED",
			fmt.Sprintf("Failed to begin transaction: %v", err),
		)
	}
	defer tx.Rollback(ctx) //nolint:errcheck

	scope := p9context.MustRLSScope(ctx)
	if err := setRLSVariables(ctx, tx, scope); err != nil {
		return err
	}

	if err := fn(ctx); err != nil {
		return err
	}

	return tx.Commit(ctx)
}
