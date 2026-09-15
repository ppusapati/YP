// Package services re-exports satellite-analytics-service's application layer
// for callers outside this service — cmd/monolith, which mounts every service
// in one process and cannot import internal/.
//
// This used to be a second copy of the package, and the copies had drifted in
// the way second copies do. The internal one gained real NDVI time-series
// analysis; this one kept returning hardcoded values — trend slope 0.02,
// R² 0.87, current value 0.72 — and persisting them as a fitted temporal
// analysis. Anyone running the monolith was shown numbers that had never been
// computed from anything.
//
// A type alias is the same type, so there is now one implementation and
// nothing to keep in step.
package services

import (
	internalservices "p9e.in/samavaya/agriculture/satellite-analytics-service/internal/services"
)

// AnalyticsService is the satellite analytics business logic.
type AnalyticsService = internalservices.AnalyticsService

// NewAnalyticsService creates the service.
var NewAnalyticsService = internalservices.NewAnalyticsService
