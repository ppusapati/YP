package uow

import (
	"context"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

// Querier is the common query interface satisfied by *pgxpool.Pool, *pgxpool.Conn, and pgx.Tx.
// Repositories that accept a Querier instead of a concrete pool type can transparently
// run on an RLS-protected transaction obtained from SetRLSOnPool.
type Querier interface {
	Query(ctx context.Context, sql string, args ...any) (pgx.Rows, error)
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
	Exec(ctx context.Context, sql string, args ...any) (pgconn.CommandTag, error)
}

type rlsQuerierKey struct{}

// NewQuerierContext stores a Querier in the context.
// SetRLSOnPool uses this to inject the RLS-scoped transaction so that downstream
// code calling QuerierFromContext receives a connection on which set_config has
// already been executed.
func NewQuerierContext(ctx context.Context, q Querier) context.Context {
	return context.WithValue(ctx, rlsQuerierKey{}, q)
}

// QuerierFromContext retrieves the Querier stored by NewQuerierContext.
// Returns (nil, false) when no Querier is present.
func QuerierFromContext(ctx context.Context) (Querier, bool) {
	q, ok := ctx.Value(rlsQuerierKey{}).(Querier)
	return q, ok
}
