// Package repositories re-exports satellite-analytics-service's persistence
// layer. See the services package for why this is an alias shim.
package repositories

import (
	internalrepos "p9e.in/samavaya/agriculture/satellite-analytics-service/internal/repositories"
)

// AnalyticsRepository is the persistence port.
type AnalyticsRepository = internalrepos.AnalyticsRepository

// NewAnalyticsRepository creates a Postgres-backed repository.
var NewAnalyticsRepository = internalrepos.NewAnalyticsRepository
