// Package services re-exports satellite-tile-service's application layer for
// callers outside this service — cmd/monolith, which cannot import internal/.
//
// This was a second copy of the package, carrying its own copy of the bug
// where a tile request returned HTTP 200 with a zero-byte body. An alias means
// there is one implementation and the fix applies everywhere.
package services

import (
	internalservices "p9e.in/samavaya/agriculture/satellite-tile-service/internal/services"
)

// TileService is the tile business logic.
type TileService = internalservices.TileService

// TileStore fetches rendered tiles from object storage.
type TileStore = internalservices.TileStore

// NewTileService creates the service.
var NewTileService = internalservices.NewTileService
