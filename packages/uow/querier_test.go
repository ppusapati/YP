package uow

import (
	"context"
	"testing"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

type fakeQuerier struct{ tag string }

func (f *fakeQuerier) Query(_ context.Context, _ string, _ ...any) (pgx.Rows, error) {
	return nil, nil
}
func (f *fakeQuerier) QueryRow(_ context.Context, _ string, _ ...any) pgx.Row { return nil }
func (f *fakeQuerier) Exec(_ context.Context, _ string, _ ...any) (pgconn.CommandTag, error) {
	return pgconn.CommandTag{}, nil
}

func TestQuerierContext_RoundTrip(t *testing.T) {
	ctx := context.Background()

	if _, ok := QuerierFromContext(ctx); ok {
		t.Fatal("expected no querier in empty context")
	}

	fq := &fakeQuerier{tag: "test-tx"}
	ctx = NewQuerierContext(ctx, fq)

	got, ok := QuerierFromContext(ctx)
	if !ok {
		t.Fatal("expected querier in context")
	}
	if got.(*fakeQuerier).tag != "test-tx" {
		t.Fatalf("got tag %q, want %q", got.(*fakeQuerier).tag, "test-tx")
	}
}

func TestQuerierFromContext_Missing(t *testing.T) {
	_, ok := QuerierFromContext(context.Background())
	if ok {
		t.Fatal("expected false for missing querier")
	}
}
