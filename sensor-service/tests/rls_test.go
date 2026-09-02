//go:build integration

package tests

import (
	"context"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"p9e.in/samavaya/packages/testutil"
)

func TestRLSEnabled(t *testing.T) {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		t.Skip("DATABASE_URL not set — skipping RLS tests")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dsn)
	require.NoError(t, err)
	defer pool.Close()

	tables := []string{
		"sensors",
		"sensor_readings",
		"sensor_alerts",
		"sensor_networks",
		"sensor_calibrations",
	}

	for _, table := range tables {
		t.Run(table+"_rls_enabled", func(t *testing.T) {
			testutil.TableHasRLS(t, ctx, pool, table)
		})
		t.Run(table+"_has_policies", func(t *testing.T) {
			testutil.TableHasRLSPolicies(t, ctx, pool, table)
		})
	}
}
