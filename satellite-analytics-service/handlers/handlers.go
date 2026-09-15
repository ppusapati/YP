// Package handlers re-exports satellite-analytics-service's inbound adapter.
// See the services package for why this is an alias shim.
package handlers

import (
	internalhandlers "p9e.in/samavaya/agriculture/satellite-analytics-service/internal/handlers"
)

// AnalyticsHandler is the ConnectRPC handler.
type AnalyticsHandler = internalhandlers.AnalyticsHandler

// NewAnalyticsHandler creates the handler.
var NewAnalyticsHandler = internalhandlers.NewAnalyticsHandler
