// Package repositories re-exports alert-service's persistence layer so that
// callers outside this service — cmd/monolith, which mounts every service in
// one process — can reach it.
//
// Go's internal rule stops anything outside alert-service/ from importing
// alert-service/internal/..., and the monolith is outside. The rest of this
// repository solves that by keeping a second copy of the package next to the
// internal one, which means every change has to be made twice and a missed one
// compiles fine until the two drift.
//
// Aliases avoid that. There is one implementation; this file only makes its
// names reachable. A type alias is the same type, so a value produced here
// satisfies an interface declared internally — a copy would produce a second,
// incompatible type with identical methods.
package repositories

import (
	internalrepos "p9e.in/samavaya/agriculture/alert-service/internal/repositories"
)

// AlertRepository is alert-service's persistence port.
type AlertRepository = internalrepos.AlertRepository

// AlertFilter narrows an alert listing.
type AlertFilter = internalrepos.AlertFilter

// NewAlertRepository creates a Postgres-backed AlertRepository.
var NewAlertRepository = internalrepos.NewAlertRepository
