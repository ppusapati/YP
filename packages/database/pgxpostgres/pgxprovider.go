package pgxpostgres

import (
	"context"
	"database/sql"
	"log"

	"p9e.in/samavaya/packages/saas"
	"p9e.in/samavaya/packages/saas/data"

	"github.com/jackc/pgx/v5/pgxpool"
)

type HasTenant sql.NullString

// MultiTenancy entity
type MultiTenancy struct {
	TenantId HasTenant
}

type DbProvider saas.DbProvider[*pgxpool.Pool]
type ClientProvider saas.ClientProvider[*pgxpool.Pool]
type ClientProviderFunc saas.ClientProviderFunc[*pgxpool.Pool]

func (c ClientProviderFunc) Get(ctx context.Context, dsn string) (*pgxpool.Pool, error) {
	return c(ctx, dsn)
}

func NewDbProvider(cs data.ConnStrResolver, cp ClientProvider) DbProvider {
	return saas.NewDbProvider[*pgxpool.Pool](cs, cp)
}

type DbWrap struct {
	*pgxpool.Pool
}

// NewDbWrap wraps a pgxpool.Pool to implement io.Closer
func NewDbWrap(db *pgxpool.Pool) *DbWrap {
	return &DbWrap{db}
}

func (d *DbWrap) Close() error {
	return closeDb(d.Pool)
}

func closeDb(d *pgxpool.Pool) error {
	log.Println("closing database connection pool")
	d.Close()
	return nil
}
