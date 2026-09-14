// Package repositories re-exports satellite-tile-service's persistence layer.
// See the services package for why this is an alias shim.
package repositories

import (
	internalrepos "p9e.in/samavaya/agriculture/satellite-tile-service/internal/repositories"
)

// TileRepository is the persistence port.
type TileRepository = internalrepos.TileRepository

// NewTileRepository creates a Postgres-backed repository.
var NewTileRepository = internalrepos.NewTileRepository
