// Package postgres re-exports field-service's persistence adapter. See the
// application package for why this is an alias shim rather than a copy.
package postgres

import (
	internalpostgres "p9e.in/samavaya/agriculture/field-service/internal/adapters/outbound/postgres"
)

// NewFieldRepository creates a Postgres-backed repository.
var NewFieldRepository = internalpostgres.NewFieldRepository
