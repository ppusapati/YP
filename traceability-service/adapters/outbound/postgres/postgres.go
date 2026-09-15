// Package postgres re-exports traceability-service's persistence adapter. See
// the application package for why this is an alias shim rather than a copy.
package postgres

import (
	internalpostgres "p9e.in/samavaya/agriculture/traceability-service/internal/adapters/outbound/postgres"
)

// NewTraceabilityRepository creates a Postgres-backed repository.
var NewTraceabilityRepository = internalpostgres.NewTraceabilityRepository
