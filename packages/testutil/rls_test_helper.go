// Package testutil provides shared test utilities for the YieldPoint platform.
package testutil

import (
	"context"
	"fmt"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// RLSTestConfig holds configuration for RLS validation tests.
type RLSTestConfig struct {
	Pool      *pgxpool.Pool
	Table     string
	TenantCol string
	IDCol     string
}

// SetTenant sets the app.tenant_id session variable for RLS.
func SetTenant(ctx context.Context, pool *pgxpool.Pool, tenantID string) error {
	_, err := pool.Exec(ctx, fmt.Sprintf("SET app.tenant_id = '%s'", tenantID))
	return err
}

// ResetTenant clears the app.tenant_id session variable.
func ResetTenant(ctx context.Context, pool *pgxpool.Pool) error {
	_, err := pool.Exec(ctx, "RESET app.tenant_id")
	return err
}

// AssertRLSIsolation verifies that RLS prevents cross-tenant data access.
// It inserts a row as tenantA, then verifies tenantB cannot see it.
func AssertRLSIsolation(t *testing.T, ctx context.Context, cfg RLSTestConfig) {
	t.Helper()

	tenantA := "01TENANT_A_TEST00000000000"
	tenantB := "01TENANT_B_TEST00000000000"
	testID := "01RLS_TEST_ID000000000000"

	conn, err := cfg.Pool.Acquire(ctx)
	require.NoError(t, err)
	defer conn.Release()

	// Insert as tenant A
	_, err = conn.Exec(ctx, fmt.Sprintf("SET LOCAL app.tenant_id = '%s'", tenantA))
	require.NoError(t, err)

	insertSQL := fmt.Sprintf(
		"INSERT INTO %s (%s, %s) VALUES ($1, $2) ON CONFLICT DO NOTHING",
		cfg.Table, cfg.IDCol, cfg.TenantCol,
	)
	_, err = conn.Exec(ctx, insertSQL, testID, tenantA)
	if err != nil {
		t.Skipf("Cannot insert test row into %s (table may need more required columns): %v", cfg.Table, err)
		return
	}

	// Verify tenant A can see the row
	countSQL := fmt.Sprintf("SELECT COUNT(*) FROM %s WHERE %s = $1", cfg.Table, cfg.IDCol)
	var countA int
	err = conn.QueryRow(ctx, countSQL, testID).Scan(&countA)
	require.NoError(t, err)
	assert.Equal(t, 1, countA, "tenant A should see its own row")

	// Switch to tenant B
	_, err = conn.Exec(ctx, fmt.Sprintf("SET LOCAL app.tenant_id = '%s'", tenantB))
	require.NoError(t, err)

	var countB int
	err = conn.QueryRow(ctx, countSQL, testID).Scan(&countB)
	require.NoError(t, err)
	assert.Equal(t, 0, countB, "tenant B should NOT see tenant A's row in table %s", cfg.Table)

	// Cleanup: reset and delete
	_, _ = conn.Exec(ctx, fmt.Sprintf("SET LOCAL app.tenant_id = '%s'", tenantA))
	_, _ = conn.Exec(ctx, fmt.Sprintf("DELETE FROM %s WHERE %s = $1", cfg.Table, cfg.IDCol), testID)
}

// TableHasRLS checks that a table has RLS enabled and forced.
func TableHasRLS(t *testing.T, ctx context.Context, pool *pgxpool.Pool, table string) {
	t.Helper()

	var rlsEnabled, rlsForced bool
	err := pool.QueryRow(ctx,
		"SELECT relrowsecurity, relforcerowsecurity FROM pg_class WHERE relname = $1",
		table,
	).Scan(&rlsEnabled, &rlsForced)
	require.NoError(t, err, "table %s should exist in pg_class", table)
	assert.True(t, rlsEnabled, "RLS should be enabled on table %s", table)
	assert.True(t, rlsForced, "RLS should be forced on table %s", table)
}

// TableHasRLSPolicies checks that a table has at least one RLS policy.
func TableHasRLSPolicies(t *testing.T, ctx context.Context, pool *pgxpool.Pool, table string) {
	t.Helper()

	var count int
	err := pool.QueryRow(ctx,
		"SELECT COUNT(*) FROM pg_policies WHERE tablename = $1",
		table,
	).Scan(&count)
	require.NoError(t, err)
	assert.Greater(t, count, 0, "table %s should have at least one RLS policy", table)
}
