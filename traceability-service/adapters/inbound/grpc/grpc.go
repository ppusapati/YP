// Package grpc re-exports traceability-service's inbound ConnectRPC adapter.
// See the application package for why this is an alias shim rather than a copy.
package grpc

import (
	internalgrpc "p9e.in/samavaya/agriculture/traceability-service/internal/adapters/inbound/grpc"
)

// TraceabilityHandler is the ConnectRPC handler for the traceability service.
type TraceabilityHandler = internalgrpc.TraceabilityHandler

// NewTraceabilityHandler creates the handler.
var NewTraceabilityHandler = internalgrpc.NewTraceabilityHandler
