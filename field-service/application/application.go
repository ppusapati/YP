// Package application re-exports field-service's application layer so that
// callers outside this service — cmd/monolith, which mounts every service in
// one process — can reach it.
//
// Go's internal rule stops anything outside field-service/ from importing
// field-service/internal/..., and the monolith is outside. This repository's
// usual answer is a second copy of the package next to the internal one, which
// means every change has to be made twice and a missed one compiles fine until
// the two drift. That drift is not hypothetical: it is what produced a
// satellite service returning a hardcoded trend line for months.
//
// Aliases avoid it. There is one implementation; this file only makes its names
// reachable. A type alias is the same type, so a value produced here satisfies
// an interface declared internally — a copy would produce a second,
// incompatible type with identical methods.
package application

import (
	internalapp "p9e.in/samavaya/agriculture/field-service/internal/application"
)

// NewFieldService creates the application service.
var NewFieldService = internalapp.NewFieldService
