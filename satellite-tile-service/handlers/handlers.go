// Package handlers re-exports satellite-tile-service's inbound adapter.
// See the services package for why this is an alias shim.
package handlers

import (
	internalhandlers "p9e.in/samavaya/agriculture/satellite-tile-service/internal/handlers"
)

// TileHandler is the ConnectRPC handler.
type TileHandler = internalhandlers.TileHandler

// NewTileHandler creates the handler.
var NewTileHandler = internalhandlers.NewTileHandler
