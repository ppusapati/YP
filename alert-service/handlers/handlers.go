// Package handlers re-exports alert-service's inbound ConnectRPC adapter for
// callers outside this service. See the repositories package for why this is an
// alias shim rather than a second copy.
package handlers

import (
	internalhandlers "p9e.in/samavaya/agriculture/alert-service/internal/handlers"
)

// AlertHandler is the ConnectRPC handler for the alert service.
type AlertHandler = internalhandlers.AlertHandler

// NewAlertHandler creates the handler.
var NewAlertHandler = internalhandlers.NewAlertHandler
